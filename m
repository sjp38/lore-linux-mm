Date: Tue, 4 Mar 2008 15:14:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Notifier for Externally Mapped Memory (EMM)
In-Reply-To: <1204670529.6241.52.camel@lappy>
Message-ID: <Pine.LNX.4.64.0803041511080.21441@schroedinger.engr.sgi.com>
References: <20080221144023.GC9427@v2.random>  <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random>  <20080302155457.GK8091@v2.random>
 <20080303213707.GA8091@v2.random>  <20080303220502.GA5301@v2.random>
 <47CC9B57.5050402@qumranet.com>  <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
  <20080304133020.GC5301@v2.random>  <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
  <20080304222030.GB8951@v2.random>  <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <1204670529.6241.52.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Peter Zijlstra wrote:

> 
> On Tue, 2008-03-04 at 14:35 -0800, Christoph Lameter wrote:
> 
> > RCU means that the callbacks occur in an atomic context.
> 
> Not really, if it requires moving the VM locks to sleepable locks under
> a .config option, I think its also fair to require PREEMPT_RCU.

Which would make the patchset pretty complex. RCU is not needed with a 
single linked list. Linked list operations can exploit atomic pointer 
updates and we only tear down the list when a single execution thread 
remains.


Having said that: Here a couple of updates to address Andrea's complaint 
that we not check the referenced bit from the external mapper when the 
rerferences bit is set on an OS pte.

Plus two barriers to ensure that a new emm notifier object becomes
visible before the base pointer is updated.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/rmap.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-03-04 14:36:36.321922321 -0800
+++ linux-2.6/mm/rmap.c	2008-03-04 15:10:46.159429369 -0800
@@ -298,10 +298,10 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
-	if (!referenced)
-		/* rmap lock held */
-		referenced = emm_notify(mm, emm_referenced,
-					address, address + PAGE_SIZE);
+
+	/* rmap lock held */
+	if (emm_notify(mm, emm_referenced, address, address + PAGE_SIZE))
+			referenced = 1;
 out:
 	return referenced;
 }
@@ -1057,6 +1057,7 @@ EXPORT_SYMBOL_GPL(emm_notifier_release);
 void emm_notifier_register(struct emm_notifier *e, struct mm_struct *mm)
 {
 	e->next = mm->emm_notifier;
+	smp_wmb();
 	mm->emm_notifier = e;
 }
 EXPORT_SYMBOL_GPL(emm_notifier_register);
@@ -1069,6 +1070,7 @@ int __emm_notify(struct mm_struct *mm, e
 	int x;
 
 	while (e) {
+		smp_rmb();
 		if (e->func) {
 			x = e->func(e, mm, op, start, end);
 			if (x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
