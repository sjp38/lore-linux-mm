Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7133E6B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 10:03:36 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBIF4gpK007308
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 10:04:42 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBIF5X7a189196
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 10:05:33 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBIF5Wgx004008
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 10:05:33 -0500
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <494A2F94.2090800@cs.columbia.edu>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	 <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu>
	 <4949B4ED.9060805@google.com>  <494A2F94.2090800@cs.columbia.edu>
Content-Type: text/plain
Date: Thu, 18 Dec 2008 07:05:20 -0800
Message-Id: <1229612720.17206.505.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Mike Waychison <mikew@google.com>, jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-12-18 at 06:10 -0500, Oren Laadan wrote:
> >> +    mutex_lock(&mm->context.lock);
> >> +
> >> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
> >> +    hh->nldt = mm->context.size;
> >> +
> >> +    cr_debug("nldt %d\n", hh->nldt);
> >> +
> >> +    ret = cr_write_obj(ctx, &h, hh);
> >> +    cr_hbuf_put(ctx, sizeof(*hh));
> >> +    if (ret < 0)
> >> +        goto out;
> >> +
> >> +    ret = cr_kwrite(ctx, mm->context.ldt,
> >> +            mm->context.size * LDT_ENTRY_SIZE);
> > 
> > Do we really want to emit anything under lock?  I realize that this
> > patch goes and does a ton of writes with mmap_sem held for read -- is
> > this ok?
> 
> Because all tasks in the container must be frozen during the checkpoint,
> there is no performance penalty for keeping the locks. Although the object
> should not change in the interim anyways, the locks protects us from, e.g.
> the task unfreezing somehow, or being killed by the OOM killer, or any
> other change incurred from the "outside world" (even future code).
> 
> Put in other words - in the long run it is safer to assume that the
> underlying object may otherwise change.
> 
> (If we want to drop the lock here before cr_kwrite(), we need to copy the
> data to a temporary buffer first. If we also want to drop mmap_sem(), we
> need to be more careful with following the vma's.)
> 
> Do you see a reason to not keeping the locks ?

Mike, although we're doing writes of the checkpoint file here, the *mm*
access is read-only.  We only need really mmap_sem for write if we're
creating new VMAs, which we only do on restore.  Was there an action
taken on the mm that would require a write that we missed?

Oren, I never considered the locking overhead, either.  The fact that
the processes are frozen is very, very important here.  The code is fine
as it stands because this *is* a very simple way to do it.  But, this
probably deserves a comment. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
