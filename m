Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id F3E996B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 20:03:44 -0400 (EDT)
Date: Wed, 30 May 2012 02:03:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 23/35] autonuma: core
Message-ID: <20120530000315.GW21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-24-git-send-email-aarcange@redhat.com>
 <20120529114554.GA7017@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529114554.GA7017@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 02:45:54PM +0300, Kirill A. Shutemov wrote:
> On Fri, May 25, 2012 at 07:02:27PM +0200, Andrea Arcangeli wrote:
> 
> > +static int knumad_do_scan(void)
> > +{
> 
> ...
> 
> > +	if (knumad_test_exit(mm) || !vma) {
> > +		mm_autonuma = mm->mm_autonuma;
> > +		if (mm_autonuma->mm_node.next != &knumad_scan.mm_head) {
> > +			mm_autonuma = list_entry(mm_autonuma->mm_node.next,
> > +						 struct mm_autonuma, mm_node);
> > +			knumad_scan.mm = mm_autonuma->mm;
> > +			atomic_inc(&knumad_scan.mm->mm_count);
> > +			knumad_scan.address = 0;
> > +			knumad_scan.mm->mm_autonuma->numa_fault_pass++;
> > +		} else
> > +			knumad_scan.mm = NULL;
> 
> knumad_scan.mm should be nulled only after list_del otherwise you will
> have race with autonuma_exit():

Thanks for noticing I managed to reproduce it by setting
knuma_scand/scan_sleep_millisecs and
knuma_scand/scan_sleep_pass_millisecs both to 0 and running a loop of
"while :; do memhog -r10 10m &>/dev/null; done".

So the problem was that if knuma_scand would change the knumad_scan.mm
after the mm->mm_users was 0 but before autonuma_exit run,
autonuma_exit wouldn't notice that the mm->mm_auotnuma was already
unlinked and it would unlink again.

autonuma_exit itself doesn't need to tell anything to knuma_scand,
because if it notices knuma_scand.mm == mm, it will do nothing and it
_always_ relies on knumad_scan to unlink it.

And if instead knuma_scand.mm is != mm, then autonuma_exit knows the
knuma_scand daemon will never have a chance to see the "mm" in the
list again if it arrived first (setting mm_autonuma->mm = NULL there
is just a debug tweak according to the comment).

The "serialize" event is there only to wait the knuma_scand main loop
before taking down the mm (it's not related to the list management).

The mm_autonuma->mm is useless after the "mm_autonuma" has been
unlinked so it's ok to use that to track if knuma_scand arrives first.

The exit path of the kernel daemon also forgot to check for
knumad_test_exit(mm) before unlinking, but that only runs if
kthread_should_stop() is true, and nobody calls kthread_stop so it's
only a theoretical improvement.

So this seems to fix it.

diff --git a/mm/autonuma.c b/mm/autonuma.c
index c2a5a82..768250a 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -679,9 +679,12 @@ static int knumad_do_scan(void)
 		} else
 			knumad_scan.mm = NULL;
 
-		if (knumad_test_exit(mm))
+		if (knumad_test_exit(mm)) {
 			list_del(&mm->mm_autonuma->mm_node);
-		else
+			/* tell autonuma_exit not to list_del */
+			VM_BUG_ON(mm->mm_autonuma->mm != mm);
+			mm->mm_autonuma->mm = NULL;
+		} else
 			mm_numa_fault_flush(mm);
 
 		mmdrop(mm);
@@ -770,8 +773,12 @@ static int knuma_scand(void *none)
 
 	mm = knumad_scan.mm;
 	knumad_scan.mm = NULL;
-	if (mm)
+	if (mm && knumad_test_exit(mm)) {
 		list_del(&mm->mm_autonuma->mm_node);
+		/* tell autonuma_exit not to list_del */
+		VM_BUG_ON(mm->mm_autonuma->mm != mm);
+		mm->mm_autonuma->mm = NULL;
+	}
 	mutex_unlock(&knumad_mm_mutex);
 
 	if (mm)
@@ -996,11 +1003,15 @@ void autonuma_exit(struct mm_struct *mm)
 	mutex_lock(&knumad_mm_mutex);
 	if (knumad_scan.mm == mm)
 		serialize = true;
-	else
+	else if (mm->mm_autonuma->mm) {
+		VM_BUG_ON(mm->mm_autonuma->mm != mm);
+		mm->mm_autonuma->mm = NULL; /* debug */
 		list_del(&mm->mm_autonuma->mm_node);
+	}
 	mutex_unlock(&knumad_mm_mutex);
 
 	if (serialize) {
+		/* prevent the mm to go away under knumad_do_scan main loop */
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
