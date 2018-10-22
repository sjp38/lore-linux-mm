Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6316B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 05:37:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c13-v6so24229495ede.6
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 02:37:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17-v6si17183728ejj.38.2018.10.22.02.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 02:37:55 -0700 (PDT)
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b343cf1a-ea15-b70e-ff5a-e08d3dc5354d@suse.cz>
Date: Mon, 22 Oct 2018 11:37:53 +0200
MIME-Version: 1.0
In-Reply-To: <20181017063330.15384-4-aaron.lu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 10/17/18 8:33 AM, Aaron Lu wrote:
> Profile on Intel Skylake server shows the most time consuming part
> under zone->lock on allocation path is accessing those to-be-returned
> page's "struct page" on the free_list inside zone->lock. One explanation
> is, different CPUs are releasing pages to the head of free_list and
> those page's 'struct page' may very well be cache cold for the allocating
> CPU when it grabs these pages from free_list' head. The purpose here
> is to avoid touching these pages one by one inside zone->lock.

What about making the pages cache-hot first, without zone->lock, by
traversing via page->lru. It would need some safety checks obviously
(maybe based on page_to_pfn + pfn_valid, or something) to make sure we
only read from real struct pages in case there's some update racing. The
worst case would be not populating enough due to race, and thus not
gaining the performance when doing the actual rmqueueing under lock.

Vlastimil
