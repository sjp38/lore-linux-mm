Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id B65616B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:31:35 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id s1so505903qeb.25
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:31:35 -0800 (PST)
Received: from mail-gg0-x22f.google.com (mail-gg0-x22f.google.com [2607:f8b0:4002:c02::22f])
        by mx.google.com with ESMTPS id hi9si1414775qcb.15.2014.01.14.18.31.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 18:31:35 -0800 (PST)
Received: by mail-gg0-f175.google.com with SMTP id c2so339148ggn.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:31:34 -0800 (PST)
Date: Tue, 14 Jan 2014 18:31:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently
 instead of page->lru
In-Reply-To: <20140114180044.1E401C47@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1401141829530.32645@chino.kir.corp.google.com>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180044.1E401C47@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-685474905-1389753093=:32645"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-685474905-1389753093=:32645
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 14 Jan 2014, Dave Hansen wrote:

> diff -puN include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently include/linux/mm_types.h
> --- a/include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently	2014-01-14 09:57:56.099621967 -0800
> +++ b/include/linux/mm_types.h	2014-01-14 09:57:56.106622281 -0800
> @@ -124,6 +124,8 @@ struct page {
>  	union {
>  		struct list_head lru;	/* Pageout list, eg. active_list
>  					 * protected by zone->lru_lock !
> +					 * Can be used as a generic list
> +					 * by the page owner.
>  					 */
>  		struct {		/* slub per cpu partial pages */
>  			struct page *next;	/* Next partial slab */
> @@ -136,7 +138,6 @@ struct page {
>  #endif
>  		};
>  
> -		struct list_head list;	/* slobs list of pages */
>  		struct slab *slab_page; /* slab fields */
>  		struct rcu_head rcu_head;	/* Used by SLAB
>  						 * when destroying via RCU

Did you try with a CONFIG_BLOCK config?

block/blk-mq.c: In function a??blk_mq_free_rq_mapa??:
block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
block/blk-mq.c:1094:10: warning: initialization from incompatible pointer type [enabled by default]
block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
block/blk-mq.c:1095:22: error: a??struct pagea?? has no member named a??lista??
block/blk-mq.c: In function a??blk_mq_init_rq_mapa??:
block/blk-mq.c:1159:22: error: a??struct pagea?? has no member named a??lista??
--531381512-685474905-1389753093=:32645--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
