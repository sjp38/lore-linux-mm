Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0506B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 09:28:11 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id k15so225555qaq.38
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 06:28:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c93si64620126qgf.89.2014.07.10.06.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jul 2014 06:28:10 -0700 (PDT)
Date: Thu, 10 Jul 2014 09:27:17 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 05/13] clear_refs: remove clear_refs_private->vma and
 introduce clear_refs_test_walk()
Message-ID: <20140710132717.GA12391@nhori>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140710113219.GA30954@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140710113219.GA30954@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 10, 2014 at 02:32:19PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 01, 2014 at 01:07:23PM -0400, Naoya Horiguchi wrote:
> > @@ -822,38 +844,14 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
> >  		};
> >  		struct mm_walk clear_refs_walk = {
> >  			.pmd_entry = clear_refs_pte_range,
> > +			.test_walk = clear_refs_test_walk,
> >  			.mm = mm,
> >  			.private = &cp,
> >  		};
> >  		down_read(&mm->mmap_sem);
> >  		if (type == CLEAR_REFS_SOFT_DIRTY)
> >  			mmu_notifier_invalidate_range_start(mm, 0, -1);
> > -		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > -			cp.vma = vma;
> > -			if (is_vm_hugetlb_page(vma))
> > -				continue;
> > -			/*
> > -			 * Writing 1 to /proc/pid/clear_refs affects all pages.
> > -			 *
> > -			 * Writing 2 to /proc/pid/clear_refs only affects
> > -			 * Anonymous pages.
> > -			 *
> > -			 * Writing 3 to /proc/pid/clear_refs only affects file
> > -			 * mapped pages.
> > -			 *
> > -			 * Writing 4 to /proc/pid/clear_refs affects all pages.
> > -			 */
> > -			if (type == CLEAR_REFS_ANON && vma->vm_file)
> > -				continue;
> > -			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> > -				continue;
> > -			if (type == CLEAR_REFS_SOFT_DIRTY) {
> > -				if (vma->vm_flags & VM_SOFTDIRTY)
> > -					vma->vm_flags &= ~VM_SOFTDIRTY;
> > -			}
> > -			walk_page_range(vma->vm_start, vma->vm_end,
> > -					&clear_refs_walk);
> > -		}
> > +		walk_page_range(0, ~0UL, &clear_refs_walk);
> 
> 'vma' variable is now unused in the clear_refs_write().

Yes, will remove it.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
