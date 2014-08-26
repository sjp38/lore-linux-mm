Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 33BE96B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:04:34 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so14790800wes.19
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 07:04:33 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.228])
        by mx.google.com with ESMTP id e3si4649329wib.102.2014.08.26.07.04.32
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 07:04:32 -0700 (PDT)
Date: Tue, 26 Aug 2014 17:04:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140826140419.GA10625@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140826064952.GR25918@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Aug 26, 2014 at 10:49:52AM +0400, Cyrill Gorcunov wrote:
> On Mon, Aug 25, 2014 at 09:45:34PM -0700, Hugh Dickins wrote:
> > > +static int clear_refs(struct mm_struct *mm, enum clear_refs_types type,
> > > +                      int write)
> > > +{
> ...
> > > +
> > > +	if (write)
> > > +		down_write(&mm->mmap_sem);
> > > +	else
> > > +		down_read(&mm->mmap_sem);
> > > +
> > > +	if (type == CLEAR_REFS_SOFT_DIRTY)
> > > +		mmu_notifier_invalidate_range_start(mm, 0, -1);
> > > +
> > > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > > +		cp.vma = vma;
> > > +		if (is_vm_hugetlb_page(vma))
> > > +			continue;
> ...
> > > +		if (type == CLEAR_REFS_ANON && vma->vm_file)
> > > +			continue;
> > > +		if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> > > +			continue;
> > > +		if (type == CLEAR_REFS_SOFT_DIRTY &&
> > > +		    (vma->vm_flags & VM_SOFTDIRTY)) {
> > > +			if (!write) {
> > > +				r = -EAGAIN;
> > > +				break;
> > 
> > Hmm.  For a long time I thought you were fixing another important bug
> > with down_write, since we "always" use down_write to modify vm_flags.
> > 
> > But now I'm realizing that if this is the _only_ place which modifies
> > vm_flags with down_read, then it's "probably" safe.  I've a vague
> > feeling that this was discussed before - is that so, Cyrill?
> 
> Well, as far as I remember we were not talking before about vm_flags
> and read-lock in this function, maybe it was on some unrelated lkml thread
> without me CC'ed? Until I miss something obvious using read-lock here
> for vm_flags modification should be safe, since the only thing which is
> important (in context of vma-softdirty) is the vma's presence. Hugh,
> mind to refresh my memory, how long ago the discussion took place?

It seems safe in vma-softdirty context. But if somebody else will decide that
it's fine to modify vm_flags without down_write (in their context), we
will get trouble. Sasha will come with weird bug report one day ;)

At least vm_flags must be updated atomically to avoid race in middle of
load-modify-store.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
