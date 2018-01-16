Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FAEF6B0285
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:30:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 79so15836154ion.20
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:30:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor1728475ite.108.2018.01.16.11.30.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 11:30:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7f100b0f-3588-be25-41f6-a0e4dde27916@linux.intel.com>
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
 <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp> <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <7f100b0f-3588-be25-41f6-a0e4dde27916@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Jan 2018 11:30:54 -0800
Message-ID: <CA+55aFyThu2FrxUh-4WrGHAd_QX=v1H2L+UNnUkks7n+dSvcfA@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Tue, Jan 16, 2018 at 12:06 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 01/15/2018 06:14 PM, Linus Torvalds wrote:
>> But I'm adding Dave Hansen explicitly to the cc, in case he has any
>> ideas. Not because I blame him, but he's touched the sparsemem code
>> fairly recently, so maybe he'd have some idea on adding sanity
>> checking to the sparsemem version of pfn_to_page().
>
> I swear I haven't touched it lately!

Heh. I did

    git blame -C mm/sparse.c | grep 2017

and your name shows up at the beginning a lot because of commit
c4e1be9ec113 ("mm, sparsemem: break out of loops early").

And Michal Hocko (who shows up even more) was already on the cc.

> I'm not sure I'd go after pfn_to_page().  *Maybe* if we were close to
> the places where we've done a pfn_to_page(), but I'm not seeing those.

Fair enough. I just wanted to add debugging, looked at Tetsuo's
config, and went "no way am I adding debugging to the sparsemem case
because it's so confusing".

That said, I also started looking at "kmap_to_page()". That's
something that is *really* different with HIGHMEM, and while most of
the users are in random drivers that do crazy things, I do note that
one of the users is in mm/swap.c.

That thing goes back to commit 5a178119b0fb ("mm: add support for
direct_IO to highmem pages") and was only used for swap_writepage(),
if I read this right.

That swap_writepage() use of kmap()'ed patches was removed some time
later in commit 62a8067a7f35 ("bio_vec-backed iov_iter"), but the
crazy kmap_to_page() thing remained.

I see nothing actively wrong in there, but it really feels like a
"that is all bogus" thing to me.

> Did anyone else notice the
>
>         [   31.068198]  ? vmalloc_sync_all+0x150/0x150
>
> present in a bunch of the stack traces?  That should be pretty uncommon.

No, didn't notice that. And yes, vmalloc_sync_all() might be interesting.

>  Is it just part of the normal do_page_fault() stack and the stack
> dumper picks up on it?

I don't think so. It should *not* happen normally. The fact that it
shows up in the trace means it happened that time.

It doesn't seem HIGHMEM-related, though. Or maybe the highmem signal
is bogus too, and it's just that Tetsuo's reproducer needs magical
timing.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
