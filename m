Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id D09486B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:08:41 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id kv19so2659196vcb.7
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 15:08:41 -0700 (PDT)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com. [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id e10si11052896vdw.92.2015.03.16.15.08.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 15:08:41 -0700 (PDT)
Received: by mail-vc0-f176.google.com with SMTP id kv19so2659175vcb.7
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 15:08:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150315170521.GA2278@moon>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	<20150315142137.GA21741@redhat.com>
	<1426431270.28068.92.camel@stgolabs.net>
	<20150315152652.GA24590@redhat.com>
	<1426434125.28068.100.camel@stgolabs.net>
	<20150315170521.GA2278@moon>
Date: Mon, 16 Mar 2015 15:08:40 -0700
Message-ID: <CAGXu5j+S1iw6VCjqfS_sPTOjNz8XAy0kkFD7dTvvTTgagx-PMA@mail.gmail.com>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file serialization
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, koct9i@gmail.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 15, 2015 at 10:05 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Sun, Mar 15, 2015 at 08:42:05AM -0700, Davidlohr Bueso wrote:
>> > > > Yes, this code needs cleanups, I agree. Does this series makes it better?
>> > > > To me it doesn't, and the diffstat below shows that it blows the code.
>> > >
>> > > Looking at some of the caller paths now, I have to disagree.
>> >
>> > And I believe you are wrong. But let me repeat, I leave this to Cyrill
>> > and Konstantin. Cleanups are always subjective.
>> >
>> > > > In fact, to me it complicates this code. For example. Personally I think
>> > > > that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
>> > >
>> > > How could you remove this?
>> >
>> > Just remove this flag and the test_and_set_bit(MMF_EXE_FILE_CHANGED) check.
>> > Again, this is subjective, but to me it looks ugly. Why do we allow to
>> > change ->exe_file but only once?
>
> This came from very first versions of the functionality implemented
> in prctl. It supposed to help sysadmins to notice if there exe
> transition happened. As to me it doesn't bring much security, if I
> would be a virus I would simply replace executing code with ptrace
> or via other ways without telling outside world that i've changed
> exe path. That said I would happily rip off this MMF_EXE_FILE_CHANGED
> bit but I fear security guys won't be that happy about it.
> (CC'ing Kees)
>
> As to series as a "cleanup" in general -- we need to measure that
> at least it doesn't bring perf downgrade at least.
>
>> Ok I think I am finally seeing where you are going. And I like it *a
>> lot* because it allows us to basically replace mmap_sem with rcu
>> (MMF_EXE_FILE_CHANGED being the only user that requires a lock!!), but
>> am afraid it might not be possible. I mean currently we have no rule wrt
>> to users that don't deal with prctl.
>>
>> Forbidding multiple exe_file changes to be generic would certainly
>> change address space semantics, probably for the better (tighter around
>> security), but changed nonetheless so users would have a right to
>> complain, no? So if we can get away with removing MMF_EXE_FILE_CHANGED
>> I'm all for it. Andrew?

I can't figure out why MMF_EXE_FILE_CHANGED is used to stop a second
change. But it does seem useful to mark a process as "hey, we know for
sure this the exe_file changed on this process" from an accounting
perspective.

And I'd agree about the malware: it would never use this interface, so
there's no security benefit I can see. Maybe I haven't had enough
coffee, though. :)

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
