Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 450646B0253
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 12:34:48 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n83so248883111qkn.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 09:34:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z65si7930444qhc.47.2016.04.29.09.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 09:34:47 -0700 (PDT)
Date: Fri, 29 Apr 2016 18:34:44 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160429163444.GM11700@redhat.com>
References: <20160428102051.17d1c728@t450s.home>
 <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429070611.GA4990@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Apr 29, 2016 at 10:06:11AM +0300, Kirill A. Shutemov wrote:
> Hm. I just woke up and haven't got any coffee yet, but I don't why my
> approach would be worse for performance. Both have the same algorithmic
> complexity.

Even before looking at the overall performance, I'm not sure your
patch is really fixing it all: you didn't touch reuse_swap_page which
is used by do_wp_page to know if it can call do_wp_page_reuse. Your
patch would still trigger a COW instead of calling do_wp_page_reuse,
but it would only happen if the page was pinned after the pmd split,
which is probably not what the testcase is triggering. My patch
instead fixed that too.

total_mapcount returns the wrong value for reuse_swap_page, which is
probably why you didn't try to use it there.

The main issue of my patch is that it has a performance downside that
is page_mapcount becomes expensive for all other usages, which is
better than breaking vfio but I couldn't use total_mapcount again
because it counts things wrong in reuse_swap_page.

Like I said there's room for optimizations so today I tried to
optimize more stuff...
