Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9314C6B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 22:57:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q16-v6so8576615pls.15
        for <linux-mm@kvack.org>; Mon, 28 May 2018 19:57:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w16-v6si30106301plk.592.2018.05.28.19.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 May 2018 19:57:28 -0700 (PDT)
Date: Mon, 28 May 2018 19:57:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: convert scan_control.priority int => byte
Message-ID: <20180529025722.GA25784@bombadil.infradead.org>
References: <20180529024025.58353-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529024025.58353-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 28, 2018 at 07:40:25PM -0700, Greg Thelen wrote:
> Reclaim priorities range from 0..12(DEF_PRIORITY).
> scan_control.priority is a 4 byte int, which is overkill.
> 
> Since commit 6538b8ea886e ("x86_64: expand kernel stack to 16K") x86_64
> stack overflows are not an issue.  But it's inefficient to use 4 bytes
> for priority.

If you're looking to shave a few more bytes, allocation order can fit
in a u8 too (can't be more than 6 bits, and realistically won't be more
than 4 bits).  reclaim_idx likewise will fit in a u8, and actually won't
be more than 3 bits.

I am sceptical that nr_to_reclaim should really be an unsigned long; I
don't think we should be trying to free 4 billion pages in a single call.
nr_scanned might be over 4 billion (!) but nr_reclaimed can probably
shrink to unsigned int along with nr_to_reclaim.
