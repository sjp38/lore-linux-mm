Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5668D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:35:25 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:35:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: avoid unnecessary anon_vma lock
Message-Id: <20110329153517.3b87842f.akpm@linux-foundation.org>
In-Reply-To: <m2fwq718u4.fsf@firstfloor.org>
References: <1301277532.3981.25.camel@sli10-conroe>
	<m2fwq718u4.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, 28 Mar 2011 09:57:39 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> Shaohua Li <shaohua.li@intel.com> writes:
> 
> > If we only change vma->vm_end, we can avoid taking anon_vma lock even 'insert'
> > isn't NULL, which is the case of split_vma.
> > From my understanding, we need the lock before because rmap must get the
> > 'insert' VMA when we adjust old VMA's vm_end (the 'insert' VMA is linked to
> > anon_vma list in __insert_vm_struct before).
> > But now this isn't true any more. The 'insert' VMA is already linked to
> > anon_vma list in __split_vma(with anon_vma_clone()) instead of
> > __insert_vm_struct. There is no race rmap can't get required VMAs.
> > So the anon_vma lock is unnecessary, and this can reduce one locking in brk
> > case and improve scalability.
> 
> Looks good to me.

Looks way too tricky to me.

Please review this code for maintainability.  Have we documented what
we're doing as completely and as clearly as we are able?

This comment:

		/*
		 * split_vma has split insert from vma, and needs
		 * us to insert it before dropping the locks
		 * (it may either follow vma or precede it).
		 */

is now at least misleading.  It doesn't explain which "locks" it means,
and with this patch we only drop a single lock.


And this comment:

	/*
	 * When changing only vma->vm_end, we don't really need anon_vma
	 * lock. This is a fairly rare case by itself, but the anon_vma
	 * lock may be shared between many sibling processes.  Skipping
	 * the lock for brk adjustments makes a difference sometimes.
	 */

fails to explain _why_ the anon_vma lock isn't needed in this case, and
didn't tell readers why it is safe to alter vma->vm_pgoff without
anon_vma_lock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
