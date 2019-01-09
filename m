Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B98538E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:24:59 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so4313606pgv.23
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 07:24:59 -0800 (PST)
Received: from zg8tmtu5ljy1ljeznc42.icoremail.net (zg8tmtu5ljy1ljeznc42.icoremail.net. [159.65.134.6])
        by mx.google.com with SMTP id i16si66128209pgk.445.2019.01.09.07.24.58
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 07:24:58 -0800 (PST)
From: "Peng Wang" <rocking@whu.edu.cn>
References: <20190109090628.1695-1-rocking@whu.edu.cn> <20190109121352.GI6310@bombadil.infradead.org>
In-Reply-To: <20190109121352.GI6310@bombadil.infradead.org>
Subject: RE: [PATCH] mm/slub.c: re-randomize random_seq if necessary
Date: Wed, 9 Jan 2019 23:24:44 +0800
Message-ID: <000501d4a82f$74821b40$5d8651c0$@whu.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Matthew Wilcox' <willy@infradead.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Wednesday, January 9, 2019 8:14 PM, Matthew Wilcox wrote:
> On Wed, Jan 09, 2019 at 05:06:27PM +0800, Peng Wang wrote:
> > calculate_sizes() could be called in several places
> > like (red_zone/poison/order/store_user)_store() while
> > random_seq remains unchanged.
> >
> > If random_seq is not NULL in calculate_sizes(), re-randomize it.
> 
> Why do we want to re-randomise the slab at these points?

At these points, s->size might change,
but random_seq still use the old size and not updated.

When doing shuffle_freelist() in allocat_slab(),
old next object offset would be used. 

    idx = s->random_seq[*pos];

One possible case:

s->size gets smaller, then number of objects in a slab gets bigger.
The size of s->random_seq array should be bigger but not updated.
In next_freelist_entry(), *pos might exceed the s->random_seq.

When we get zero value from s->random_seq[*pos] twice after exceeding,
BUG_ON(object == fp) would be triggered in set_freepointer().
