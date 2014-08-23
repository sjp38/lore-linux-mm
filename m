Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 592406B0035
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 19:56:11 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so11553869wgh.6
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 16:56:10 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.228])
        by mx.google.com with ESMTP id ot9si49594734wjc.62.2014.08.23.16.56.09
        for <linux-mm@kvack.org>;
        Sat, 23 Aug 2014 16:56:10 -0700 (PDT)
Date: Sun, 24 Aug 2014 02:50:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/3] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140823235058.GA27234@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-2-git-send-email-pfeiner@google.com>
 <20140823230011.GA26483@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140823230011.GA26483@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Aug 24, 2014 at 02:00:11AM +0300, Kirill A. Shutemov wrote:
> On Sat, Aug 23, 2014 at 06:11:59PM -0400, Peter Feiner wrote:
> > For VMAs that don't want write notifications, PTEs created for read
> > faults have their write bit set. If the read fault happens after
> > VM_SOFTDIRTY is cleared, then the PTE's softdirty bit will remain
> > clear after subsequent writes.
> > 
> > Here's a simple code snippet to demonstrate the bug:
> > 
> >   char* m = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
> >                  MAP_ANONYMOUS | MAP_SHARED, -1, 0);
> >   system("echo 4 > /proc/$PPID/clear_refs"); /* clear VM_SOFTDIRTY */
> >   assert(*m == '\0');     /* new PTE allows write access */
> >   assert(!soft_dirty(x));
> >   *m = 'x';               /* should dirty the page */
> >   assert(soft_dirty(x));  /* fails */
> > 
> > With this patch, write notifications are enabled when VM_SOFTDIRTY is
> > cleared. Furthermore, to avoid faults, write notifications are
> > disabled when VM_SOFTDIRTY is reset.
> > 
> > Signed-off-by: Peter Feiner <pfeiner@google.com>

One more case to consider: mprotect() which doesn't trigger successful
vma_merge() will not set VM_SOFTDIRTY and will not enable write-protect on
the vma.

It's probably better to take VM_SOFTDIRTY into account in
vma_wants_writenotify() and re-think logic in other corners.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
