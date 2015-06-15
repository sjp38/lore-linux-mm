Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 198FA6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:36:44 -0400 (EDT)
Received: by qgeu36 with SMTP id u36so4366215qge.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 09:36:43 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id k136si12151679qhk.30.2015.06.15.09.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 09:36:42 -0700 (PDT)
Date: Mon, 15 Jun 2015 11:36:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/7] slub: improve bulk alloc strategy
In-Reply-To: <20150615155246.18824.3788.stgit@devil>
Message-ID: <alpine.DEB.2.11.1506151135130.20358@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155246.18824.3788.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, 15 Jun 2015, Jesper Dangaard Brouer wrote:

> -			break;
> +		if (unlikely(!object)) {
> +			c->tid = next_tid(c->tid);

tid increment is not needed here since the per cpu information is not
modified.

> +			local_irq_enable();
> +
> +			/* Invoke slow path one time, then retry fastpath
> +			 * as side-effect have updated c->freelist
> +			 */
> +			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
> +					    _RET_IP_, c);
> +			if (unlikely(!p[i])) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
