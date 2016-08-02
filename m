Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 119E96B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 21:43:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e139so334412725oib.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 18:43:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w76si424528itc.2.2016.08.01.18.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 18:43:10 -0700 (PDT)
Subject: Re: [PATCH] mm/slab: Improve performance of gathering slabinfo stats
References: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160802005514.GA14725@js1304-P5Q-DELUXE>
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Message-ID: <4a3fe3bc-eb1d-ea18-bd70-98b8b9c6a7d7@oracle.com>
Date: Mon, 1 Aug 2016 18:43:00 -0700
MIME-Version: 1.0
In-Reply-To: <20160802005514.GA14725@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Joonsoo,

On 08/01/2016 05:55 PM, Joonsoo Kim wrote:
> Your patch updates these counters not only when a slabs are created and
> destroyed but also when object is allocated/freed from the slab. This
> would hurt runtime performance.
>

The counters are not updated for each object allocation/free - only if 
that allocation/free results in that slab moving from one list 
(free/partial/full) to another.

>> > slab lists for gathering slabinfo stats, resulting in a dramatic
>> > performance improvement. We tested this after growing the dentry cache to
>> > 70GB, and the performance improved from 2s to 2ms.
> Nice improvement. I can think of an altenative.
>
> I guess that improvement of your change comes from skipping to iterate
> n->slabs_full list. We can achieve it just with introducing only num_slabs.
> num_slabs can be updated when a slabs are created and destroyed.
>

Yes, slabs_full is typically the largest list.

> We can calculate num_slabs_full by following equation.
>
> num_slabs_full = num_slabs - num_slabs_partial - num_slabs_free
>
> Calculating both num_slabs_partial and num_slabs_free by iterating
> n->slabs_XXX list would not take too much time.

Yes, this would work too. We cannot avoid traversal of slabs_partial, 
and slabs_free is usually a small list, so this should give us similar 
performance benefits. But having separate counters could also be useful 
for debugging, like the ones defined under CONFIG_DEBUG_SLAB/STATS. 
Won't that help?

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
