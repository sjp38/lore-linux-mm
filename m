Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7A976B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 17:43:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u62so130227153pfk.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 14:43:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b61si8369292plc.304.2017.03.03.14.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 14:43:30 -0800 (PST)
Date: Fri, 3 Mar 2017 14:43:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, swap: Fix a race in free_swap_and_cache()
Message-Id: <20170303144329.94d47b1015ba2f18f64c5893@linux-foundation.org>
In-Reply-To: <20170301143905.12846-1-ying.huang@intel.com>
References: <20170301143905.12846-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  1 Mar 2017 22:38:09 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> Before using cluster lock in free_swap_and_cache(), the
> swap_info_struct->lock will be held during freeing the swap entry and
> acquiring page lock, so the page swap count will not change when
> testing page information later.  But after using cluster lock, the
> cluster lock (or swap_info_struct->lock) will be held only during
> freeing the swap entry.  So before acquiring the page lock, the page
> swap count may be changed in another thread.  If the page swap count
> is not 0, we should not delete the page from the swap cache.  This is
> fixed via checking page swap count again after acquiring the page
> lock.

What are the user-visible runtime effects of this bug?  Please always
include this info when fixing things, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
