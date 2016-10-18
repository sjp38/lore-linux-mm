Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5051B6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:35:04 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id kc8so229534252pab.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:35:04 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id ci5si29017275pad.250.2016.10.18.02.35.01
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 02:35:03 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
In-Reply-To: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall into buddy slow path
Date: Tue, 18 Oct 2016 17:34:41 +0800
Message-ID: <022d01d22922$dad86f90$90894eb0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

> @@ -1908,7 +1908,7 @@ void wb_workfn(struct work_struct *work)
>  	long pages_written;
> 
>  	set_worker_desc("flush-%s", dev_name(wb->bdi->dev));
> -	current->flags |= PF_SWAPWRITE;

If flags carries PF_LESS_THROTTLE before modified, then you 
have to restore it. 

> +	current->flags |= (PF_SWAPWRITE | PF_BDI_FLUSHER | PF_LESS_THROTTLE);
> 
>  	if (likely(!current_is_workqueue_rescuer() ||
>  		   !test_bit(WB_registered, &wb->state))) {
> @@ -1938,7 +1938,7 @@ void wb_workfn(struct work_struct *work)
>  	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
>  		wb_wakeup_delayed(wb);
> 
> -	current->flags &= ~PF_SWAPWRITE;
> +	current->flags &= ~(PF_SWAPWRITE | PF_BDI_FLUSHER | PF_LESS_THROTTLE);
>  }
> 
thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
