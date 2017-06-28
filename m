Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27DF12802FE
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 13:18:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m77so15568984lfe.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:18:59 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id j83si1283726lfi.200.2017.06.28.10.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 10:18:57 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id g21so5746900lfk.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:18:57 -0700 (PDT)
Date: Wed, 28 Jun 2017 20:18:54 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v3 1/2] mm/list_lru.c: fix list_lru_count_node() to be
 race free
Message-ID: <20170628171854.t4sjyjv55j673qzv@esperanza>
References: <20170622174929.GB3273@esperanza>
 <1498630044-26724-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498630044-26724-1-git-send-email-stummala@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Jun 28, 2017 at 11:37:23AM +0530, Sahitya Tummala wrote:
> list_lru_count_node() iterates over all memcgs to get
> the total number of entries on the node but it can race with
> memcg_drain_all_list_lrus(), which migrates the entries from
> a dead cgroup to another. This can return incorrect number of
> entries from list_lru_count_node().
> 
> Fix this by keeping track of entries per node and simply return
> it in list_lru_count_node().
> 
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> ---
>  include/linux/list_lru.h |  1 +
>  mm/list_lru.c            | 14 ++++++--------
>  2 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index cb0ba9f..eff61bc 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -44,6 +44,7 @@ struct list_lru_node {
>  	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
>  	struct list_lru_memcg	*memcg_lrus;
>  #endif
> +	long nr_count;

'nr_count' sounds awkward. I think it should be called 'nr_items'.

Other than that, looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
