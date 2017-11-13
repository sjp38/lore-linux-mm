Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF9D06B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 15:00:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 11so9828807wrb.10
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 12:00:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor10022432edc.15.2017.11.13.12.00.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Nov 2017 12:00:08 -0800 (PST)
Date: Mon, 13 Nov 2017 23:00:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171113200005.xzbhenukotzicwd2@node.shutemov.name>
References: <20171107130539.52676-1-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1711131642370.1851@nanos>
 <20171113164154.fp5fd2seozbmxcbs@node.shutemov.name>
 <alpine.DEB.2.20.1711131754590.1851@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711131754590.1851@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 05:57:03PM +0100, Thomas Gleixner wrote:
> On Mon, 13 Nov 2017, Kirill A. Shutemov wrote:
> 
> > On Mon, Nov 13, 2017 at 04:43:26PM +0100, Thomas Gleixner wrote:
> > > On Tue, 7 Nov 2017, Kirill A. Shutemov wrote:
> > > 
> > > > In case of 5-level paging, we don't put any mapping above 47-bit, unless
> > > > userspace explicitly asked for it.
> > > > 
> > > > Userspace can ask for allocation from full address space by specifying
> > > > hint address above 47-bit.
> > > > 
> > > > Nicholas noticed that current implementation violates this interface:
> > > > we can get vma partly in high addresses if we ask for a mapping at very
> > > > end of 47-bit address space.
> > > > 
> > > > Let's make sure that, when consider hint address for non-MAP_FIXED
> > > > mapping, start and end of resulting vma are on the same side of 47-bit
> > > > border.
> > > 
> > > What happens for mappings with MAP_FIXED which cross the border?
> > 
> > It will succeed with 5-level paging.
> 
> And why is this allowed?
> 
> > It should be safe as with 4-level paging such request would fail and it's
> > reasonable to expect that userspace is not relying on the failure to
> > function properly.
> 
> Huch?
> 
> The first rule when looking at user space is that is broken or
> hostile. Reasonable and user space are mutually exclusive.

That's basically the same assumption we made to implement current
interface of allocation memory above 47-bits.

The premise is that nobody in right mind would try mmap(addr, MAP_FIXED)
where addr >= (1UL << 47) as it will always fail. So we can allow this to
succeed on 5-level paging machine as a way to allocate from larger address
space.

By the same logic we can allow allocation for cases where addr is below
(1UL << 47), but addr+size is above the limit.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
