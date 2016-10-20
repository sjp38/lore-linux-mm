Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA516B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 09:05:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m138so105238269itm.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:05:21 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20066.outbound.protection.outlook.com. [40.107.2.66])
        by mx.google.com with ESMTPS id j22si7609831ite.83.2016.10.20.06.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 06:05:21 -0700 (PDT)
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall
 into buddy slow path
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
 <1476967085-89647-1-git-send-email-zhouxianrong@huawei.com>
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Message-ID: <bbaf4763-fe98-24c9-c63b-111930ebea84@nextfour.com>
Date: Thu, 20 Oct 2016 16:05:12 +0300
MIME-Version: 1.0
In-Reply-To: <1476967085-89647-1-git-send-email-zhouxianrong@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com



On 20.10.2016 15:38, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
>
> The bdi flusher should be throttled only depends on 
> own bdi and is decoupled with others.
>
> separate PGDAT_WRITEBACK into PGDAT_ANON_WRITEBACK and
> PGDAT_FILE_WRITEBACK avoid scanning anon lru and it is ok 
> then throttled on file WRITEBACK.
>
> i think above may be not right.
>
> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
> ---
>  fs/fs-writeback.c      |    8 ++++++--
>  include/linux/mmzone.h |    7 +++++--
>  mm/vmscan.c            |   20 ++++++++++++--------
>  3 files changed, 23 insertions(+), 12 deletions(-)
>
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 05713a5..ddcc70f 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1905,10 +1905,13 @@ void wb_workfn(struct work_struct *work)
>  {
>  	struct bdi_writeback *wb = container_of(to_delayed_work(work),
>  						struct bdi_writeback, dwork);
> +	struct backing_dev_info *bdi = container_of(to_delayed_work(work),
> +						struct backing_dev_info, wb.dwork);
>  	long pages_written;
>  
>  	set_worker_desc("flush-%s", dev_name(wb->bdi->dev));
> -	current->flags |= PF_SWAPWRITE;
> +	current->flags |= (PF_SWAPWRITE | PF_LESS_THROTTLE);
> +	current->bdi = bdi;
>  
>  	if (likely(!current_is_workqueue_rescuer() ||
>  		   !test_bit(WB_registered, &wb->state))) {
> @@ -1938,7 +1941,8 @@ void wb_workfn(struct work_struct *work)
>  	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
>  		wb_wakeup_delayed(wb);
>  
> -	current->flags &= ~PF_SWAPWRITE;
> +	current->bdi = NULL;
> +	current->flags &= ~(PF_SWAPWRITE | PF_LESS_THROTTLE);
>  }
>  
>  /*
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7f2ae99..fa602e9 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -528,8 +528,11 @@ enum pgdat_flags {
>  					 * many dirty file pages at the tail
>  					 * of the LRU.
>  					 */
> -	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
> -					 * many pages under writeback
> +	PGDAT_ANON_WRITEBACK,		/* reclaim scanning has recently found
> +					 * many anonymous pages under writeback
> +					 */
> +	PGDAT_FILE_WRITEBACK,		/* reclaim scanning has recently found
> +					 * many file pages under writeback
>  					 */
>  	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */

Nobody seems to be clearing those bits (same was with PGDAT_WRITEBACK) ?


--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
