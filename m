Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA096B4675
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:28:00 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so22523920pll.23
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:28:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g79sor4037668pfg.24.2018.11.26.23.27.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:27:59 -0800 (PST)
Date: Tue, 27 Nov 2018 10:27:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/10] mm/huge_memory: fix lockdep complaint on 32-bit
 i_size_read()
Message-ID: <20181127072754.lbm2icnyvw6v3dio@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261520070.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261520070.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:21:58PM -0800, Hugh Dickins wrote:
> Huge tmpfs testing, on 32-bit kernel with lockdep enabled, showed that
> __split_huge_page() was using i_size_read() while holding the irq-safe
> lru_lock and page tree lock, but the 32-bit i_size_read() uses an
> irq-unsafe seqlock which should not be nested inside them.
> 
> Instead, read the i_size earlier in split_huge_page_to_list(), and pass
> the end offset down to __split_huge_page(): all while holding head page
> lock, which is enough to prevent truncation of that extent before the
> page tree lock has been taken.
> 
> Fixes: baa355fd33142 ("thp: file pages support for split_huge_page()")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
