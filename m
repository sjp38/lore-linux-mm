Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D205D6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:58:58 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so1675963pad.1
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:58:58 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id po10si2213944pab.384.2014.03.13.13.58.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 13:58:57 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so1584808pdj.34
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:58:57 -0700 (PDT)
Date: Thu, 13 Mar 2014 13:57:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
In-Reply-To: <1394737202.2452.8.camel@buesod1.americas.hpqcorp.net>
Message-ID: <alpine.LSU.2.11.1403131352240.20266@eggly.anvils>
References: <531F6689.60307@oracle.com> <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net> <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org> <531F75D1.3060909@oracle.com> <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
 <531F79F7.5090201@oracle.com> <1394574323.2786.45.camel@buesod1.americas.hpqcorp.net> <531F8C3A.1040502@oracle.com> <1394737202.2452.8.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Thu, 13 Mar 2014, Davidlohr Bueso wrote:
> On Tue, 2014-03-11 at 18:20 -0400, Sasha Levin wrote:
> > On 03/11/2014 05:45 PM, Davidlohr Bueso wrote:
> > > On Tue, 2014-03-11 at 17:02 -0400, Sasha Levin wrote:
> > >> >On 03/11/2014 04:47 PM, Davidlohr Bueso wrote:
> > >>>> > >>Bingo! With the above patch:
> > >>>>> > >> >
> > >>>>> > >> >[  243.565794] kernel BUG at mm/vmacache.c:76!
> > >>>>> > >> >[  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > >>>>> > >> >[  243.568048] Dumping ftrace buffer:
> > >>>>> > >> >[  243.568740]    (ftrace buffer empty)
> > >>>>> > >> >[  243.569481] Modules linked in:
> > >>>>> > >> >[  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143
> > >>> > >and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
> > >>> > >the root cause it the same as Fengguang's report.
> > >> >
> > >> >The BUG still happens without DEBUG_PAGEALLOC.
> > > Any idea what trinity itself is doing?
> > >
> > > Could you add the following, I just want to make sure the bug isn't
> > > being caused by an overflow:
> > 
> > Not hitting that WARN.
> 
> Sasha, could you please try the following patch:
> https://lkml.org/lkml/2014/3/13/312

I was getting the "kernel BUG at mm/vmacache.c:76!" running KSM
on mmotm: Oleg's patch (buildable version below) fixes it for me.

Hugh

--- mmotm/mm/vmacache.c	2014-03-12 18:39:38.008011317 -0700
+++ linux/mm/vmacache.c	2014-03-13 12:21:11.592030813 -0700
@@ -31,15 +31,20 @@ void vmacache_flush_all(struct mm_struct
 	rcu_read_unlock();
 }
 
+static bool vmacache_valid_mm(struct mm_struct *mm)
+{
+	return current->mm == mm && !(current->flags & PF_KTHREAD);
+}
+
 void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
 {
-	int idx = VMACACHE_HASH(addr);
-	current->vmacache[idx] = newvma;
+	if (vmacache_valid_mm(newvma->vm_mm))
+		current->vmacache[VMACACHE_HASH(addr)] = newvma;
 }
 
 static bool vmacache_valid(struct mm_struct *mm)
 {
-	struct task_struct *curr = current;
+	struct task_struct *curr;
 
 	/*
 	 * This task may be accessing a foreign mm via (for example)
@@ -47,9 +52,10 @@ static bool vmacache_valid(struct mm_str
 	 * task's vmacache pertains to a different mm (ie, its own).  There is
 	 * nothing we can do here.
 	 */
-	if (mm != curr->mm)
-		return false;
+	if (!vmacache_valid_mm(mm))
+ 		return false;
 
+	curr = current;
 	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
 		/*
 		 * First attempt will always be invalid, initialize

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
