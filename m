Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id AC82F6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:56:21 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id hz20so15403481lab.27
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 07:56:20 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.228])
        by mx.google.com with ESMTP id jf6si3916921lac.14.2014.08.26.07.56.19
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 07:56:19 -0700 (PDT)
Date: Tue, 26 Aug 2014 17:56:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140826145612.GA11226@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
 <20140826140419.GA10625@node.dhcp.inet.fi>
 <20140826141914.GA8952@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140826141914.GA8952@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Aug 26, 2014 at 06:19:14PM +0400, Cyrill Gorcunov wrote:
> On Tue, Aug 26, 2014 at 05:04:19PM +0300, Kirill A. Shutemov wrote:
> > > > 
> > > > But now I'm realizing that if this is the _only_ place which modifies
> > > > vm_flags with down_read, then it's "probably" safe.  I've a vague
> > > > feeling that this was discussed before - is that so, Cyrill?
> > > 
> > > Well, as far as I remember we were not talking before about vm_flags
> > > and read-lock in this function, maybe it was on some unrelated lkml thread
> > > without me CC'ed? Until I miss something obvious using read-lock here
> > > for vm_flags modification should be safe, since the only thing which is
> > > important (in context of vma-softdirty) is the vma's presence. Hugh,
> > > mind to refresh my memory, how long ago the discussion took place?
> > 
> > It seems safe in vma-softdirty context. But if somebody else will decide that
> > it's fine to modify vm_flags without down_write (in their context), we
> > will get trouble. Sasha will come with weird bug report one day ;)
> > 
> > At least vm_flags must be updated atomically to avoid race in middle of
> > load-modify-store.
> 
> Which race you mean here? Two concurrent clear-refs?

Two concurent clear-refs is fine. But if somebody else will exploit the
same approch to set/clear other VM_FOO and it will race with clear-refs
we get trouble: some modifications can be lost.

Basically, it's safe if only soft-dirty is allowed to modify vm_flags
without down_write(). But why is soft-dirty so special?

Should we consider moving protection of some vma fields under per-vma lock
rather use over-loaded mmap_sem?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
