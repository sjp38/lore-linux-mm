Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89C996B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:42:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9-v6so5284874wrj.15
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:42:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r57si3456971edd.193.2018.04.19.06.42.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 06:42:41 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 07/14] slub: Remove page->counters
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-8-willy@infradead.org>
Message-ID: <0d049d18-ebde-82ec-ed1d-85daabf6582f@suse.cz>
Date: Thu, 19 Apr 2018 15:42:37 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-8-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Use page->private instead, now that these two fields are in the same
> location.  Include a compile-time assert that the fields don't get out
> of sync.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Why not retain a small union of "counters" and inuse/objects/frozens
within the SLUB's sub-structure? IMHO it would be more obvious and
reduce churn?

...

> @@ -358,17 +359,10 @@ static __always_inline void slab_unlock(struct page *page)
>  
>  static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
>  {
> -	struct page tmp;
> -	tmp.counters = counters_new;
> -	/*
> -	 * page->counters can cover frozen/inuse/objects as well
> -	 * as page->_refcount.  If we assign to ->counters directly
> -	 * we run the risk of losing updates to page->_refcount, so
> -	 * be careful and only assign to the fields we need.
> -	 */
> -	page->frozen  = tmp.frozen;
> -	page->inuse   = tmp.inuse;
> -	page->objects = tmp.objects;

BTW was this ever safe to begin with? IIRC bitfields are frowned upon as
a potential RMW. Or is there still at least guarantee the RMW happens
only within the 32bit struct and not the whole 64bit word, which used to
include also _refcount?
