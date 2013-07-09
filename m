Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 08D686B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 15:49:07 -0400 (EDT)
Date: Tue, 9 Jul 2013 21:43:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust()
	interaction
Message-ID: <20130709194321.GA31104@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com> <20130708180424.GA6490@redhat.com> <20130708180501.GB6490@redhat.com> <CAHGf_=qPuzH_R1Jfztnhj4JEAX9xfD37461LRKrhHgL4nq-eHg@mail.gmail.com> <20130709152836.GA10033@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709152836.GA10033@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Colin Cross <ccross@android.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/09, Oleg Nesterov wrote:
>
> I can be easily wrong, but to me vma_adjust() and its usage looks a bit
> overcomplicated. Perhaps it makes sense to distinguish mmapped/hole cases.
> mbind_range/madvise/etc need vma_join(vma, ...), not prev/anon_vma/file.
> Perhaps. not sure.

And I am just curious if something like below makes any sense...

Suppose we add the new helper, vma_update(vma, new). Note that "new" is
the fake vma, it just describes how do want to change vma.

static bool
can_merge_vma(struct vm_area_struct *prev, struct vm_area_struct *next)
{
	if (prev->vm_end != next->vm_start)
		return false;
	if (prev->vm_pgoff + vma_pages(prev) != next->vm_pgoff)
		return false;

	if (prev->vm_file != next->vm_file)
		return false;
	if (prev->vm_flags != next->vm_flags)
		return false;
	if (!mpol_equal(vma_policy(prev), vma_policy(next)))
		return false;

	if (prev->anon_vma != next->anon_vma)	/* WRONG, FIXME !!! */
		return false;

	if (next->vm_ops && next->vm_ops->close)
		return false;

	return true;
}

struct vm_area_struct *
vma_update(struct vm_area_struct *vma, struct vm_area_struct *new)
{
	struct vm_area_struct *prev = vma->vm_prev;
	struct vm_area_struct *next = vma->vm_next;
	struct vm_area_struct *new_ret;
	unsigned long new_end;
	int err;

	/* prev/next != vma means we can merge with prev/next */
	if (!prev || !can_merge_vma(prev, new))
		prev = vma;
	if (!next || !can_merge_vma(new, next))
		next = vma;

	if (new->vm_start > vma->vm_start) {	/* prev == vma */
		if (next != vma) {
			/* vma shrinks, next grows, case 4 */
			new_end = new->vm_start;
			new_ret = next;
			goto adjust;
		}
		err = split_vma(vma->vm_mm, vma, new->vm_start, 1);
		if (err)
			return ERR_PTR(err);
	}

	if (new->vm_end < vma->vm_end) {	/* next == vma */
		if (prev != vma) {
			/* prev grows, vma shrinks, case 5 */
			new_end = new->vm_end;
			new_ret = vma;
			goto adjust;
		}
		err = split_vma(vma->vm_mm, vma, new->vm_end, 0);
		if (err)
			return ERR_PTR(err);
	}

	if (prev == next)	/* true if split_vma() was called */
		return vma;

	new_end = next->vm_end;
	new_ret = prev;
adjust:
	err = vma_adjust(prev, prev->vm_start, new_end, prev->vm_pgoff, NULL);
	if (err)
		return ERR_PTR(err);
	khugepaged_enter_vma_merge(new_ret);
	return new_ret;
}

Now we can change madvise_behavior() and other similar users as below.

As for mmap_region() we can add another helper which simply tries to
expand prev/next (case 1-3).

Oleg.

--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -46,10 +46,9 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		     struct vm_area_struct **prev,
 		     unsigned long start, unsigned long end, int behavior)
 {
-	struct mm_struct * mm = vma->vm_mm;
-	int error = 0;
-	pgoff_t pgoff;
 	unsigned long new_flags = vma->vm_flags;
+	struct vm_area_struct new;
+	int error = 0;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -100,34 +99,21 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		goto out;
 	}
 
-	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
-	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
-				vma->vm_file, pgoff, vma_policy(vma));
-	if (*prev) {
-		vma = *prev;
-		goto success;
-	}
-
-	*prev = vma;
+	new = *vma;
+	new.vm_flags = new_flags;
+	new.vm_start = start;
+	new.vm_end = end;
+	vma = vma_update(vma, &new);
 
-	if (start != vma->vm_start) {
-		error = split_vma(mm, vma, start, 1);
-		if (error)
-			goto out;
-	}
-
-	if (end != vma->vm_end) {
-		error = split_vma(mm, vma, end, 0);
-		if (error)
-			goto out;
+	if (IS_ERR(vma)) {
+		error = PTR_ERR(vma);
+		goto out;
 	}
-
-success:
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
-
+	*prev = vma;
 out:
 	if (error == -ENOMEM)
 		error = -EAGAIN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
