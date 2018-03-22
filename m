Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D00256B0003
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:17:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q11so1885953pfd.8
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:17:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c20si5060531pfi.18.2018.03.22.08.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:17:25 -0700 (PDT)
Date: Thu, 22 Mar 2018 08:17:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
Message-ID: <20180322151719.GA28468@bombadil.infradead.org>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-3-aaron.lu@intel.com>
 <9cad642d-9fe5-b2c3-456c-279065c32337@suse.cz>
 <20180313033453.GB13782@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313033453.GB13782@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>

On Tue, Mar 13, 2018 at 11:34:53AM +0800, Aaron Lu wrote:
> I wish there is a data structure that has the flexibility of list while
> at the same time we can locate the Nth element in the list without the
> need to iterate. That's what I'm looking for when developing clustered
> allocation for order 0 pages. In the end, I had to use another place to
> record where the Nth element is. I hope to send out v2 of that RFC
> series soon but I'm still collecting data for it. I would appreciate if
> people could take a look then :-)

Sorry, I missed this.  There is such a data structure -- the IDR, or
possibly a bare radix tree, or we can build a better data structure on
top of the radix tree (I talked about one called the XQueue a while ago).

The IDR will automatically grow to whatever needed size, it stores
pointers, you can find out quickly where the last allocated index is,
you can remove from the middle of the array.  Disadvantage is that it
requires memory allocation to store the array of pointers, *but* it
can always hold at least one entry.  So if you have no memory, you can
always return the one element in your IDR to the free pool and allocate
from that page.
