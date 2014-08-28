Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 85AD26B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 02:31:11 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so341940lbi.22
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:31:09 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id k6si3852805lae.29.2014.08.27.23.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 23:31:08 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so336691lbv.24
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:31:08 -0700 (PDT)
Date: Thu, 28 Aug 2014 10:31:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140828063106.GE23629@moon>
References: <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
 <20140826140419.GA10625@node.dhcp.inet.fi>
 <20140826141914.GA8952@moon>
 <20140826145612.GA11226@node.dhcp.inet.fi>
 <20140826151813.GB8952@moon>
 <20140826154355.GA11464@node.dhcp.inet.fi>
 <20140826155351.GC8952@moon>
 <alpine.LSU.2.11.1408271512090.7961@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408271512090.7961@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Wed, Aug 27, 2014 at 04:12:43PM -0700, Hugh Dickins wrote:
> > > 
> > > Weak argument to me.
> 
> Yes.  However rarely it's modified, we don't want any chance of it
> corrupting another flag.
> 
> VM_SOFTDIRTY is special in the sense that it's maintained in a very
> different way from the other VM_flags.  If we had a little alignment
> padding space somewhere in struct vm_area_struct, I think I'd jump at
> Kirill's suggestion to move it out of vm_flags and into a new field:
> that would remove some other special casing, like the vma merge issue.
> 
> But I don't think we have such padding space, and we'd prefer not to
> bloat struct vm_area_struct for it; so maybe it should stay for now.
> Besides, with Peter's patch, we're also talking about the locking on
> modifications to vm_page_prot, aren't we?

I think so.

> > > What about walk through vmas twice: first with down_write() to modify
> > > vm_flags and vm_page_prot, then downgrade_write() and do
> > > walk_page_range() on every vma?
> > 
> > I still it's undeeded,
> 
> Yes, so long as nothing else is doing the same.
> No bug yet, that we can see, but a bug in waiting.

:-)

> 
> > but for sure using write-lock/downgrade won't hurt,
> > so no argues from my side.
> 
> Yes, Kirill's two-stage suggestion seems the best:
> 
> down_write
> quickly scan vmas clearing VM_SOFT_DIRTY and updating vm_page_prot
> downgrade_write (or up_write, down_read?)
> slowly walk page tables write protecting and clearing soft-dirty on ptes
> up_read
> 
> But please don't mistake me for someone who has a good grasp of
> soft-dirty: I don't.

Thanks for sharing opinion, Hugh! (And thanks for second email about
vma-flags) So lets move it to Kirill's way, otherwise indeed one day
it might end up in a bug which for sure will not be easy to catch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
