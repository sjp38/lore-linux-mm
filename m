Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C16A6B0266
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 10:08:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so12821571wme.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 07:08:02 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id f126si17059893wma.121.2016.11.08.07.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 07:08:01 -0800 (PST)
Date: Tue, 8 Nov 2016 07:08:00 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH/RFC v2] z3fold: use per-page read/write lock
Message-ID: <20161108150800.GL26852@two.firstfloor.org>
References: <20161108135834.d0b57fa435393c64f358980a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108135834.d0b57fa435393c64f358980a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Tue, Nov 08, 2016 at 01:58:34PM +0100, Vitaly Wool wrote:
> Most of z3fold operations are in-page, such as modifying z3fold
> page header or moving z3fold objects within a page. Taking
> per-pool spinlock to protect per-page objects is therefore
> suboptimal, and the idea of having a per-page spinlock (or rwlock)
> has been around for some time. However, adding one directly to the
> z3fold header makes the latter quite big on some systems so that
> it won't fit in a signle chunk.
> 
> This patch implements spinlock-based per-page locking mechanism
> which is lightweight enough to fit into the z3fold header.
> 
> Changes from v1 [1]:
> - custom locking mechanism changed to spinlocks
> - no read/write locks, just per-page spinlock

Looks good.

BTW the spinlock could still grow when debug options  like
lockdep are enabled. So something would still need to be done about
that BUILD_BUG_ON(). Otherwise would need to force a raw spin lock.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
