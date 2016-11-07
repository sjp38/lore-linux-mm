Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06F4F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:32:07 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h201so1611090lfg.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:06 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n82si15565209lfd.206.2016.11.07.03.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:32:05 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a20so5132978wme.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:05 -0800 (PST)
Date: Mon, 7 Nov 2016 14:29:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] shmem: fix pageflags after swapping DMA32 object
Message-ID: <20161107112900.GC13280@node.shutemov.name>
References: <alpine.LSU.2.11.1611062003510.11253@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1611062003510.11253@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

On Sun, Nov 06, 2016 at 08:08:29PM -0800, Hugh Dickins wrote:
> If shmem_alloc_page() does not set PageLocked and PageSwapBacked, then
> shmem_replace_page() needs to do so for itself.  Without this, it puts
> newpage on the wrong lru, re-unlocks the unlocked newpage, and system
> descends into "Bad page" reports and freeze; or if CONFIG_DEBUG_VM=y,
> it hits an earlier VM_BUG_ON_PAGE(!PageLocked), depending on config.
> 
> But shmem_replace_page() is not a common path: it's only called when
> swapin (or swapoff) finds the page was already read into an unsuitable
> zone: usually all zones are suitable, but gem objects for a few drm
> devices (gma500, omapdrm, crestline, broadwater) require zone DMA32
> if there's more than 4GB of ram.
> 
> Fixes: 800d8c63b2e9 ("shmem: add huge pages support")
> Cc: stable@vger.kernel.org # v4.8
> Signed-off-by: Hugh Dickins <hughd@google.com>

Sorry for that.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
