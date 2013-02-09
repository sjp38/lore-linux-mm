Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 668BD6B0002
	for <linux-mm@kvack.org>; Sat,  9 Feb 2013 00:51:39 -0500 (EST)
Received: by mail-vc0-f179.google.com with SMTP id gb23so2862128vcb.10
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 21:51:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130204180423.GI7523@quack.suse.cz>
References: <20130131222335.GA13525@quack.suse.cz>
	<20130131230327.GN4503@ZenIV.linux.org.uk>
	<20130204180423.GI7523@quack.suse.cz>
Date: Fri, 8 Feb 2013 21:51:37 -0800
Message-ID: <CANN689FEZv9dzYFePKX_HS7au-_Wp98aB4KOu7UsO1o7=D9=_w@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] mmap_sem in ->fault and ->page_mkwrite
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@zeniv.linux.org.uk>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Feb 4, 2013 at 10:04 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 31-01-13 23:03:27, Al Viro wrote:
>> On Thu, Jan 31, 2013 at 11:23:35PM +0100, Jan Kara wrote:
>> >   Hi,
>> >
>> >   I'm not sure if this is such a great topic but it's a question which
>> > I came across a few times already and LSF/MM is a good place for
>> > brainstorming somewhat crazy ideas ;).
>> >
>> > So currently ->fault() and ->page_mkwrite() are called under mmap_sem held
>> > for reading. Now this creates sometimes unpleasant locking dependencies for
>> > filesystems (modern filesystems have to do an equivalent of ->write_begin
>> > in ->page_mkwrite and that is a non-trivial operation). Just to mention my
>> > last itch, I had to split reader side of filesystem freezing lock into two
>> > locks - one which ranks above mmap_sem and one which ranks below it. Then
>> > writer side has to wait for both locks. It works but ...
>> >
>> > So I was wondering: Would it be somehow possible we could drop mmap_sem in
>> > these two callbacks (especially ->page_mkwrite())? I understand process'
>> > mapping can change under us once we drop the semaphore so we'd have to
>> > somehow recheck we have still the right page after re-taking mmap_sem. Like
>> > if we protected VMAs with SRCU so that they don't disappear under us once
>> > we drop mmap_sem and after retaking mmap_sem we would recheck whether VMA
>> > still applies to our fault.

I'm not sure if there is enough interest for an MM topic there;
however I would like to at least discuss this privately with you - I
have a lot of mmap_sem frustrations too :)

>> > And I know there's VM_FAULT_RETRY but that really seems like a special hack
>> > for x86 architecture page fault code. Making it work for all architectures
>> > and callers such as get_user_pages() didn't really seem plausible to me.

There is really nothing x86 specific about FAULT_FLAG_ALLOW_RETRY -
upstream code already uses it (on all archs) to drop mmap_sem during
large mlocks that hit disk; and patches in -mm extend this to handle
MAP_POPULATE mmaps as well. Using it during page faults is currently
only done on x86, but doing that on other arch page fault handlers
wouldn't be hard - the code is easy to write, it's just a matter of
getting it tested on all archs.

This leaves the issue of all the other gup users. I don't think
dropping and regrabbing mmap_sem within gup is realistic in general,
as the call sites don't expect VMAs to change in the middle of the gup
call.

>> Please, *please*, don't.  VMA locking is complete horror without SRCU
>> mess thrown in.  It's a bloody bad idea, at least without a very massive
>> cleanup prior to that thing.
>>
>> Start with drawing the call graph for vma-related code - at least the
>> parts from relevant locks grabbed to accesses of fields protected by
>> said locks.
>   VMAs are protected by mmap_sem AFAIK so that doesn't look all that
> complex. But I guess you are pointing at the fact that sometimes mmap_sem
> is acquired rather far (sometimes even in arch code) from the places which
> use the protection of mmap_sem and so it would be difficult (if possible at
> all) to verify that once we drop mmap_sem, all these places will happily
> handle that fact. I agree it would be a mess unless we somehow simplify
> things first...

Yes.

FAULT_FLAG_ALLOW_RETRY is my attempt at giving a way for call sites
which can deal with mmap_sem being dropped to signal that, so that we
don't need to convert every call sites at once. But if you have a
better way to go about it, I would be open to discuss it :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
