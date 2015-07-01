Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id BB6E06B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:28:03 -0400 (EDT)
Received: by wiga1 with SMTP id a1so117294297wig.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:28:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk2si23766071wib.80.2015.07.01.00.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 00:28:02 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:27:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 36/51] writeback: implement bdi_for_each_wb()
Message-ID: <20150701072757.GW7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-37-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-37-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:50, Tejun Heo wrote:
> This will be used to implement bdi-wide operations which should be
> distributed across all its cgroup bdi_writebacks.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

One comment below.

> @@ -445,6 +500,14 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
>  {
>  }
>  
> +struct wb_iter {
> +	int		next_id;
> +};
> +
> +#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id)		\
> +	for ((iter)->next_id = (start_blkcg_id);			\
> +	     ({	(wb_cur) = !(iter)->next_id++ ? &(bdi)->wb : NULL; }); )
> +

This looks quite confusing. Won't it be easier to understand as:

struct wb_iter {
} __attribute__ ((unused));

#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id) \
  if (((wb_cur) = (!start_blkcg_id ? &(bdi)->wb : NULL)))

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
