Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 051BA6B0082
	for <linux-mm@kvack.org>; Tue, 22 May 2012 02:03:27 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 22 May 2012 02:03:26 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C75156E8057
	for <linux-mm@kvack.org>; Tue, 22 May 2012 02:03:23 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4M63N2u150820
	for <linux-mm@kvack.org>; Tue, 22 May 2012 02:03:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4M63LFY006348
	for <linux-mm@kvack.org>; Tue, 22 May 2012 02:03:23 -0400
Date: Tue, 22 May 2012 11:31:33 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to
 install and remove uprobes breakpoints
Message-ID: <20120522060133.GB10829@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
 <tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
 <20120521143701.74ab2d0b.akpm@linux-foundation.org>
 <CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, sfr@canb.auug.org.au, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

> 
> That said, I think that's true of uprobes too. Why the f*ck would
> uprobes do it's "munmap" operation when we walk the page tables? This
> function was called by more than just the actual unmapping, it was
> called by stuff that wants to zap the pages but leave the mapping
> around.
> 

This was pointed out by Oleg earlier and I had moved the code to
unlink_file_vma.

However by the time unlink_file_vma() is called, the pages would
have been unmapped (in unmap_vmas()) and the task->rss_stat counts
accounted (in zap_pte_range()).

If the exiting process has probepoints, uprobe_munmap() checks if the
breakpoint instruction was around before decrementing the probe count.
This check results in a file backed page being re-read by
uprobe_munmap() and also it cannot find the breakpoint (because we read
a file backed page).

i.e 

1. The task->rss_stat counts gets incremented again because we have read
a page.

2. mm->uprobes_state.count which should have decremented, doesnt get
decremented as uprobe_munmap fails to see the breakpoint.

Hence I had to move back the callback to zap pages so that we do the
cleanup before the task->rss_stat counts are accounted.

That said, Oleg has a in-works patch/idea for removing uprobe_munmap and
mm->uprobes_state.count, which when done, will remove the
uprobe_munmap hook. https://lkml.org/lkml/2012/4/16/594

Please do let me know if you have better ideas to handle this.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
