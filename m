Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e3.ny.us.ibm.com (8.12.9/8.12.2) with ESMTP id h5G3sdE2160956
	for <linux-mm@kvack.org>; Sun, 15 Jun 2003 23:54:39 -0400
Received: from sparklet.in.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by northrelay04.pok.ibm.com (8.12.9/NCO/VER6.5) with ESMTP id h5G3sZPv039102
	for <linux-mm@kvack.org>; Sun, 15 Jun 2003 23:54:37 -0400
Received: (from suparna@localhost)
	by sparklet.in.ibm.com (8.11.6/8.11.0) id h5G3xiJ10468
	for linux-mm@kvack.org; Mon, 16 Jun 2003 09:29:44 +0530
Date: Mon, 16 Jun 2003 09:29:44 +0530
From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: use_mm/unuse_mm correctness
Message-ID: <20030616092944.A10463@in.ibm.com>
Reply-To: suparna@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Can anyone spot a problem in the following routines ?

These are used by AIO workqueue routines to take on the 
caller's address space when executing certain operations,
and then to switch back to the workqueue thread's original 
mm context. 

We are seeing some strange bugs in -mm lately, and this
code is one of the suspects. Can't yet see what could be
wrong ...

/*
 * use_mm
 * 	Makes the calling kernel thread take on the specified 
 * 	mm context. 
 * 	Called by the retry thread execute retries within the 
 * 	iocb issuer's mm context, so that copy_from/to_user
 * 	operations work seamlessly for aio.
 * 	(Note: this routine is intended to be called only 
 * 	from a kernel thread context)
 */
static void use_mm(struct mm_struct *mm)
{
	struct mm_struct *active_mm = current->active_mm;
	atomic_inc(&mm->mm_count);
	current->mm = mm;

	current->active_mm = mm;
	activate_mm(active_mm, mm);

	mmdrop(active_mm);
}

/*
 * unuse_mm
 * 	Reverses the effect of use_mm, i.e. releases the
 * 	specified mm context which was earlier taken on
 * 	by the calling kernel thread 
 * 	(Note: this routine is intended to be called only 
 * 	from a kernel thread context)
 */
void unuse_mm(struct mm_struct *mm)
{
	current->mm = NULL;
	/* active_mm is still 'mm' */
	enter_lazy_tlb(mm, current, smp_processor_id());
}

Regards
Suparna

-- 
Suparna Bhattacharya (suparna@in.ibm.com)
Linux Technology Center
IBM Software Labs, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
