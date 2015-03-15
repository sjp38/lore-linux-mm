Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3EF828FD
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 13:05:27 -0400 (EDT)
Received: by lbcgn8 with SMTP id gn8so6859799lbc.2
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 10:05:25 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id xx4si6017549lbb.92.2015.03.15.10.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Mar 2015 10:05:24 -0700 (PDT)
Received: by ladw1 with SMTP id w1so22803046lad.0
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 10:05:23 -0700 (PDT)
Date: Sun, 15 Mar 2015 20:05:21 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
 serialization
Message-ID: <20150315170521.GA2278@moon>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
 <20150315142137.GA21741@redhat.com>
 <1426431270.28068.92.camel@stgolabs.net>
 <20150315152652.GA24590@redhat.com>
 <1426434125.28068.100.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426434125.28068.100.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Sun, Mar 15, 2015 at 08:42:05AM -0700, Davidlohr Bueso wrote:
> > > > Yes, this code needs cleanups, I agree. Does this series makes it better?
> > > > To me it doesn't, and the diffstat below shows that it blows the code.
> > >
> > > Looking at some of the caller paths now, I have to disagree.
> > 
> > And I believe you are wrong. But let me repeat, I leave this to Cyrill
> > and Konstantin. Cleanups are always subjective.
> > 
> > > > In fact, to me it complicates this code. For example. Personally I think
> > > > that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
> > >
> > > How could you remove this?
> > 
> > Just remove this flag and the test_and_set_bit(MMF_EXE_FILE_CHANGED) check.
> > Again, this is subjective, but to me it looks ugly. Why do we allow to
> > change ->exe_file but only once?

This came from very first versions of the functionality implemented
in prctl. It supposed to help sysadmins to notice if there exe
transition happened. As to me it doesn't bring much security, if I
would be a virus I would simply replace executing code with ptrace
or via other ways without telling outside world that i've changed
exe path. That said I would happily rip off this MMF_EXE_FILE_CHANGED
bit but I fear security guys won't be that happy about it.
(CC'ing Kees)

As to series as a "cleanup" in general -- we need to measure that
at least it doesn't bring perf downgrade at least.

> Ok I think I am finally seeing where you are going. And I like it *a
> lot* because it allows us to basically replace mmap_sem with rcu
> (MMF_EXE_FILE_CHANGED being the only user that requires a lock!!), but
> am afraid it might not be possible. I mean currently we have no rule wrt
> to users that don't deal with prctl. 
> 
> Forbidding multiple exe_file changes to be generic would certainly
> change address space semantics, probably for the better (tighter around
> security), but changed nonetheless so users would have a right to
> complain, no? So if we can get away with removing MMF_EXE_FILE_CHANGED
> I'm all for it. Andrew?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
