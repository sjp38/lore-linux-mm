Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 989566B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 22:38:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q62so338943211oih.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 19:38:46 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v27si616892iov.11.2016.08.01.19.38.43
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 19:38:44 -0700 (PDT)
Date: Tue, 2 Aug 2016 11:43:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/slab: Improve performance of gathering slabinfo stats
Message-ID: <20160802024342.GA15062@js1304-P5Q-DELUXE>
References: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160802005514.GA14725@js1304-P5Q-DELUXE>
 <4a3fe3bc-eb1d-ea18-bd70-98b8b9c6a7d7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a3fe3bc-eb1d-ea18-bd70-98b8b9c6a7d7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Aug 01, 2016 at 06:43:00PM -0700, Aruna Ramakrishna wrote:
> Hi Joonsoo,
> 
> On 08/01/2016 05:55 PM, Joonsoo Kim wrote:
> >Your patch updates these counters not only when a slabs are created and
> >destroyed but also when object is allocated/freed from the slab. This
> >would hurt runtime performance.
> >
> 
> The counters are not updated for each object allocation/free - only
> if that allocation/free results in that slab moving from one list
> (free/partial/full) to another.
> 
> >>> slab lists for gathering slabinfo stats, resulting in a dramatic
> >>> performance improvement. We tested this after growing the dentry cache to
> >>> 70GB, and the performance improved from 2s to 2ms.
> >Nice improvement. I can think of an altenative.
> >
> >I guess that improvement of your change comes from skipping to iterate
> >n->slabs_full list. We can achieve it just with introducing only num_slabs.
> >num_slabs can be updated when a slabs are created and destroyed.
> >
> 
> Yes, slabs_full is typically the largest list.
> 
> >We can calculate num_slabs_full by following equation.
> >
> >num_slabs_full = num_slabs - num_slabs_partial - num_slabs_free
> >
> >Calculating both num_slabs_partial and num_slabs_free by iterating
> >n->slabs_XXX list would not take too much time.
> 
> Yes, this would work too. We cannot avoid traversal of
> slabs_partial, and slabs_free is usually a small list, so this
> should give us similar performance benefits. But having separate
> counters could also be useful for debugging, like the ones defined
> under CONFIG_DEBUG_SLAB/STATS. Won't that help?

We can calculate these counters by traversing all list so it would not
be helpful except for performance reason. Cost of maintaining these
counters isn't free so it's better not to add more than we need.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
