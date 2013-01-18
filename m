Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 688896B0007
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 00:30:08 -0500 (EST)
Date: Fri, 18 Jan 2013 14:30:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 1/8] Introduce new system call mvolatile
Message-ID: <20130118053006.GB31368@blaptop>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
 <1357187286-18759-2-git-send-email-minchan@kernel.org>
 <50F75875.30909@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F75875.30909@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Jan 16, 2013 at 05:48:37PM -0800, John Stultz wrote:
> On 01/02/2013 08:27 PM, Minchan Kim wrote:
> >This patch adds new system call m[no]volatile.
> >If someone asks is_volatile system call, it could be added, too.
> 
> So some nits below from my initial playing around with this patchset.
> 
> >+/*
> >+ * Return -EINVAL if range doesn't include a right vma at all.
> >+ * Return -ENOMEM with interrupting range opeartion if memory is not enough to
> >+ * merge/split vmas.
> >+ * Return 0 if range consists of only proper vmas.
> >+ * Return 1 if part of range includes inavlid area(ex, hole/huge/ksm/mlock/
> >+ * special area)
> >+ */
> >+SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
> >+{
> >+	unsigned long end, tmp;
> >+	struct vm_area_struct *vma, *prev;
> >+	bool invalid = false;
> >+	int error = -EINVAL;
> >+
> >+	down_write(&current->mm->mmap_sem);
> >+	if (start & ~PAGE_MASK)
> >+		goto out;
> >+
> >+	len &= PAGE_MASK;
> >+	if (!len)
> >+		goto out;
> >+
> >+	end = start + len;
> >+	if (end < start)
> >+		goto out;
> >+
> >+	vma = find_vma_prev(current->mm, start, &prev);
> >+	if (!vma)
> >+		goto out;
> >+
> >+	if (start > vma->vm_start)
> >+		prev = vma;
> >+
> >+	for (;;) {
> >+		/* Here start < (end|vma->vm_end). */
> >+		if (start < vma->vm_start) {
> >+			start = vma->vm_start;
> >+			if (start >= end)
> >+				goto out;
> >+			invalid = true;
> >+		}
> >+
> >+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
> >+		tmp = vma->vm_end;
> >+		if (end < tmp)
> >+			tmp = end;
> >+
> >+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> >+		error = do_mvolatile(vma, &prev, start, tmp);
> >+		if (error == -ENOMEM) {
> >+			up_write(&current->mm->mmap_sem);
> >+			return error;
> >+		}
> >+		if (error == -EINVAL)
> >+			invalid = true;
> >+		else
> >+			error = 0;
> >+		start = tmp;
> >+		if (prev && start < prev->vm_end)
> >+			start = prev->vm_end;
> >+		if (start >= end)
> >+			break;
> >+
> >+		vma = prev->vm_next;
> >+		if (!vma)
> >+			break;
> >+	}
> >+out:
> >+	up_write(&current->mm->mmap_sem);
> >+	return invalid ? 1 : 0;
> >+}
> 
> The error logic here is really strange. If any of the early error
> cases are triggered (ie: (start & ~PAGE_MASK), etc), then we jump to
> out and return 0 (instead of EINVAL). I don't think that's what you
> intended.

Need fixing.

> 
> 
> >+/*
> >+ * Return -ENOMEM with interrupting range opeartion if memory is not enough
> >+ * to merge/split vmas.
> >+ * Return 1 if part of range includes purged's one, otherwise, return 0
> >+ */
> >+SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
> >+{
> >+	unsigned long end, tmp;
> >+	struct vm_area_struct *vma, *prev;
> >+	int ret, error = -EINVAL;
> >+	bool is_purged = false;
> >+
> >+	down_write(&current->mm->mmap_sem);
> >+	if (start & ~PAGE_MASK)
> >+		goto out;
> >+
> >+	len &= PAGE_MASK;
> >+	if (!len)
> >+		goto out;
> >+
> >+	end = start + len;
> >+	if (end < start)
> >+		goto out;
> >+
> >+	vma = find_vma_prev(current->mm, start, &prev);
> >+	if (!vma)
> >+		goto out;
> >+
> >+	if (start > vma->vm_start)
> >+		prev = vma;
> >+
> >+	for (;;) {
> >+		/* Here start < (end|vma->vm_end). */
> >+		if (start < vma->vm_start) {
> >+			start = vma->vm_start;
> >+			if (start >= end)
> >+				goto out;
> >+		}
> >+
> >+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
> >+		tmp = vma->vm_end;
> >+		if (end < tmp)
> >+			tmp = end;
> >+
> >+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> >+		error = do_mnovolatile(vma, &prev, start, tmp, &is_purged);
> >+		if (error) {
> >+			WARN_ON(error != -ENOMEM);
> >+			goto out;
> >+		}
> >+		start = tmp;
> >+		if (prev && start < prev->vm_end)
> >+			start = prev->vm_end;
> >+		if (start >= end)
> >+			break;
> >+
> >+		vma = prev->vm_next;
> >+		if (!vma)
> >+			break;
> >+	}
> 
> I'm still not sure how this logic improves over the madvise case. If
> we catch an error mid-way through setting a series of vmas to
> non-volatile, we end up exiting and losing state (ie: if only the
> first vma was purged, but half way through 10 vmas we get a ENOMEM
> error. So the first vma is now non-volatile, but we do not return
> the purged flag ).

Right. 

> 
> If we're going to have a new syscall for this (which I'm not sure is
> the right approach), we should make use of multiple arguments so we
> can return if data was purged, even if we hit an error midway).

It would be easier method to achieve our goal than below suggestion
in case of VMA-basd approach because it's hard to expect how many
we need vmas with atomically.

Will do it in next version.

> 
> Alternatively, if we can find a way to allocate any necessary memory
> before we do any vma volatility state changes, then we can return
> ENOMEM then and be confident we won't end up with failed partial
> state change (this is the approach I used in my fallocate-volatile
> patches).

Thanks for the review, John.

> 
> thanks
> -john
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
