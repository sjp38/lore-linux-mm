Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F16B0009
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 14:40:14 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p202-v6so4878428lfe.3
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 11:40:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g77-v6sor3021607lfl.87.2018.03.24.11.40.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 11:40:12 -0700 (PDT)
Date: Sat, 24 Mar 2018 21:40:09 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180324184009.dyjlt4rj4b6y6sz3@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

Hello Kirill,

I don't have any objections to the idea behind this patch set.
Well, at least I don't know how to better tackle the problem you
describe in the cover letter. Please, see below for my comments
regarding implementation details.

On Wed, Mar 21, 2018 at 04:21:17PM +0300, Kirill Tkhai wrote:
> The patch introduces shrinker::id number, which is used to enumerate
> memcg-aware shrinkers. The number start from 0, and the code tries
> to maintain it as small as possible.
> 
> This will be used as to represent a memcg-aware shrinkers in memcg
> shrinkers map.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/shrinker.h |    1 +
>  mm/vmscan.c              |   59 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 60 insertions(+)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index a3894918a436..738de8ef5246 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -66,6 +66,7 @@ struct shrinker {
>  
>  	/* These are for internal use */
>  	struct list_head list;
> +	int id;

This definition could definitely use a comment.

BTW shouldn't we ifdef it?

>  	/* objs pending delete, per node */
>  	atomic_long_t *nr_deferred;
>  };
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8fcd9f8d7390..91b5120b924f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -159,6 +159,56 @@ unsigned long vm_total_pages;
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> +static DEFINE_IDA(bitmap_id_ida);
> +static DECLARE_RWSEM(bitmap_rwsem);

Can't we reuse shrinker_rwsem for protecting the ida?

> +static int bitmap_id_start;
> +
> +static int alloc_shrinker_id(struct shrinker *shrinker)
> +{
> +	int id, ret;
> +
> +	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> +		return 0;
> +retry:
> +	ida_pre_get(&bitmap_id_ida, GFP_KERNEL);
> +	down_write(&bitmap_rwsem);
> +	ret = ida_get_new_above(&bitmap_id_ida, bitmap_id_start, &id);

AFAIK ida always allocates the smallest available id so you don't need
to keep track of bitmap_id_start.

> +	if (!ret) {
> +		shrinker->id = id;
> +		bitmap_id_start = shrinker->id + 1;
> +	}
> +	up_write(&bitmap_rwsem);
> +	if (ret == -EAGAIN)
> +		goto retry;
> +
> +	return ret;
> +}
