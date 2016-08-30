Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73C406B028B
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 21:07:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i2so12368770qke.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 18:07:00 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0225.hostedemail.com. [216.40.44.225])
        by mx.google.com with ESMTPS id s31si25672502qtb.18.2016.08.29.18.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 18:06:59 -0700 (PDT)
Message-ID: <1472519215.5512.30.camel@perches.com>
Subject: Re: [PATCH v4 resend] mm/slab: Improve performance of gathering
 slabinfo stats
From: Joe Perches <joe@perches.com>
Date: Mon, 29 Aug 2016 18:06:55 -0700
In-Reply-To: <1472517876-26814-1-git-send-email-aruna.ramakrishna@oracle.com>
References: <1472517876-26814-1-git-send-email-aruna.ramakrishna@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2016-08-29 at 17:44 -0700, Aruna Ramakrishna wrote:
> This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
> total number of allocated slabs per node, per cache.
[]
> We tested this after
> growing the dentry cache to 70GB, and the performance improved from 2s to
> 5ms.

Seems sensible, thanks.

One completely trivial note:
> diff --git a/mm/slab.c b/mm/slab.c
[]
> @@ -1394,24 +1395,27 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
>  	for_each_kmem_cache_node(cachep, node, n) {
>  		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
>  		unsigned long active_slabs = 0, num_slabs = 0;
> +		unsigned long num_slabs_partial = 0, num_slabs_free = 0;
> +		unsigned long num_slabs_full;
[]
> +		num_slabs_full = num_slabs -
> +			(num_slabs_partial + num_slabs_free);

vs

> @@ -4111,6 +4119,8 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>  	unsigned long num_objs;
>  	unsigned long active_slabs = 0;
>  	unsigned long num_slabs, free_objects = 0, shared_avail = 0;
> +	unsigned long num_slabs_partial = 0, num_slabs_free = 0;
> +	unsigned long num_slabs_full = 0;
[]
> +	num_slabs_full = num_slabs - (num_slabs_partial + num_slabs_free);

It seems odd to have different initialization styles
for num_slabs_full.  It seems the second one doesn't
need to be initialized.

It'd also be nicer I think if the two declarations
blocks had more similar layouts.

Maybe in a follow-on patch.  Or not.  Your choice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
