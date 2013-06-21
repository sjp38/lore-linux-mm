Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C3CC56B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 18:07:22 -0400 (EDT)
Message-ID: <1371852439.1798.27.camel@buesod1.americas.hpqcorp.net>
Subject: Re: linux-next: Tree for Jun 21 [ BROKEN ipc/ipc-msg ]
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Fri, 21 Jun 2013 15:07:19 -0700
In-Reply-To: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
References: 
	<CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>

On Fri, 2013-06-21 at 21:34 +0200, Sedat Dilek wrote:
> On Fri, Jun 21, 2013 at 10:17 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > Hi all,
> >
> > Happy solstice!
> >
> > Changes since 20130620:
> >
> > Dropped tree: mailbox (really bad merge conflicts with the arm-soc tree)
> >
> > The net-next tree gained a conflict against the net tree.
> >
> > The leds tree still had its build failure, so I used the version from
> > next-20130607.
> >
> > The arm-soc tree gained conflicts against the tip, net-next, mfd and
> > mailbox trees.
> >
> > The staging tree still had its build failure for which I disabled some
> > code.
> >
> > The akpm tree lost a few patches that turned up elsewhere and gained
> > conflicts against the ftrace and arm-soc trees.
> >
> > ----------------------------------------------------------------------------
> >
> 
> [ CC IPC folks ]
> 
> Building via 'make deb-pkg' with fakeroot fails here like this:
> 
> make: *** [deb-pkg] Terminated
> /usr/bin/fakeroot: line 181:  2386 Terminated
> FAKEROOTKEY=$FAKEROOTKEY LD_LIBRARY_PATH="$PATHS" LD_PRELOAD="$LIB"
> "$@"
> semop(1): encountered an error: Identifier removed
> semop(2): encountered an error: Invalid argument
> semop(1): encountered an error: Identifier removed
> semop(1): encountered an error: Identifier removed
> semop(1): encountered an error: Invalid argument
> semop(1): encountered an error: Invalid argument
> semop(1): encountered an error: Invalid argument
> 

Hmmm those really shouldn't be related to the message queue changes. Are
you sure you got the right bisect? 

Manfred has a few ipc/sem.c patches in linux-next, starting at commit
c50df1b4 (ipc/sem.c: cacheline align the semaphore structures), does
reverting any of those instead of "ipc,msg: shorten critical region in
msgrcv" help at all? Also, anything reported in dmesg?

> The issue is present since next-20130606!
> 
> LAST KNOWN GOOD: next-20130605
> FIRST KNOWN BAD: next-20130606
> 
> KNOWN GOOD: next-20130604
> KNOWN BAD:  next-20130607 || next-20130619 || next-20130620 || next-20130621
> 
> git-bisect says CULPRIT commit is...
> 
>      "ipc,msg: shorten critical region in msgrcv"

This I get. I went through the code again and it looks correct and
functionally equivalent to the old msgrcv.

> 
> NOTE: msg_lock_(check_) routines have to be restored (one more revert needed)!

This I don't get. Restoring msg_lock_[check] is already equivalent to
reverting "ipc,msg: shorten critical region in msgrcv" and several other
of the msq patches. What other patch needs reverted?

Anyway, I'll see if I can reproduce the issue, maybe I'm missing
something.

Thanks,
Davidlohr

> 
> Reverting both (below) commits makes fakeroot build via 'make dep-pkg" again.
> 
> I have tested the revert-patches with next-20130606 and next-20130621
> (see file-attachments).
> 
> My build-script is attached!
> 
> Can someone of the IPC folks look at that?
> Thanks!
> 
> - Sedat -
> 
> 
> P.S.: Commit-IDs listed below.
> 
> [ next-20130606 ]
> 
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/?id=next-20130606
> 
> "ipc: remove unused functions"
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=8793fdfb0d0a6ed5916767e29a15d3eb56e04e79
> 
> "ipc,msg: shorten critical region in msgrcv"
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=c0ff93322847a54f74a5450032c4df64c17fdaed
> 
> [ next-20130621 ]
> 
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/?id=next-20130621
> 
> "ipc: remove unused functions"
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=941ce57c81dcceadf55265616ee1e8bef18b0ad3
> 
> "ipc,msg: shorten critical region in msgrcv"
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=62190df4081ee8504e3611d45edb40450cb408ac


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
