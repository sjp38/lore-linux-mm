Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84CD86B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:22:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so388986wmu.2
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:22:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n11si490267edi.417.2017.09.18.03.22.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 03:22:47 -0700 (PDT)
Date: Mon, 18 Sep 2017 12:22:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: introduce sanity check on dirty ratio sysctl value
Message-ID: <20170918102244.GJ32516@quack2.suse.cz>
References: <1505669968-12593-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505669968-12593-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 18-09-17 01:39:28, Yafang Shao wrote:
> we can find the logic in domain_dirty_limits() that
> when dirty bg_thresh is bigger than dirty thresh,
> bg_thresh will be set as thresh * 1 / 2.
> 	if (bg_thresh >= thresh)
> 		bg_thresh = thresh / 2;
> 
> But actually we can set dirty_background_raio bigger than
> dirty_ratio successfully. This behavior may mislead us.
> So we should do this sanity check at the beginning.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

...

>  {
> +	int old_ratio = dirty_background_ratio;
> +	unsigned long bytes;
>  	int ret;
>  
>  	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
> -	if (ret == 0 && write)
> -		dirty_background_bytes = 0;
> +
> +	if (ret == 0 && write) {
> +		if (vm_dirty_ratio > 0) {
> +			if (dirty_background_ratio >= vm_dirty_ratio)
> +				ret = -EINVAL;
> +		} else if (vm_dirty_bytes > 0) {
> +			bytes = global_dirtyable_memory() * PAGE_SIZE *
> +					dirty_background_ratio / 100;
> +			if (bytes >= vm_dirty_bytes)
> +				ret = -EINVAL;
> +		}
> +
> +		if (ret == 0)
> +			dirty_background_bytes = 0;
> +		else
> +			dirty_background_ratio = old_ratio;
> +	}
> +

How about implementing something like

bool vm_dirty_settings_valid(void)

helper which would validate whether current dirtiness settings are
consistent. That way we would not have to repeat very similar checks four
times. Also the arithmetics in:

global_dirtyable_memory() * PAGE_SIZE * dirty_background_ratio / 100 

could overflow so I'd prefer to first divide by 100 and then multiply by
dirty_background_ratio...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
