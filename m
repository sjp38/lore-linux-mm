Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87E396B0033
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 13:59:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z50so19129962qtj.9
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 10:59:17 -0700 (PDT)
Received: from st11p00im-asmtp004.me.com (st11p00im-asmtp004.me.com. [17.172.80.98])
        by mx.google.com with ESMTPS id y206si889032qka.454.2017.10.14.10.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Oct 2017 10:59:16 -0700 (PDT)
Received: from process-dkim-sign-daemon.st11p00im-asmtp004.me.com by
 st11p00im-asmtp004.me.com
 (Oracle Communications Messaging Server 8.0.1.2.20170607 64bit (built Jun  7
 2017)) id <0OXT00E00R7K6900@st11p00im-asmtp004.me.com> for linux-mm@kvack.org;
 Sat, 14 Oct 2017 17:59:15 +0000 (GMT)
Date: Sat, 14 Oct 2017 19:59:06 +0200
From: Damian Tometzki <damian.tometzki@icloud.com>
Subject: Re: [PATCH for linux-next] mm/page-writeback.c: make changes of
 dirty_writeback_centisecs take effect immediately
Message-id: <20171014175906.GA1825@zrhn9910b>
References: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-disposition: inline
In-reply-to: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: axboe@kernel.dk, akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, yamada.masahiro@socionext.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 14. Oct 16:38, Yafang Shao wrote:
> This patch is the followup of the prvious patch:
> [writeback: schedule periodic writeback with sysctl].
> 
> There's another issue to fix.
> For example,
> - When the tunable was set to one hour and is reset to one second, the
>   new setting will not take effect for up to one hour.
> 
> Kicking the flusher threads immediately fixes it.
> 
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/page-writeback.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3969e69..768fe4e 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1978,7 +1978,16 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>  	int ret;
>  
>  	ret = proc_dointvec(table, write, buffer, length, ppos);
> -	if (!ret && !old_interval && dirty_writeback_interval)
> +
> +	/*
> +	 * Writing 0 to dirty_writeback_interval will disable periodic writeback
> +	 * and a different non-zero value will wakeup the writeback threads.
> +	 * wb_wakeup_delayed() would be more appropriate, but it's a pain to
> +	 * iterate over all bdis and wbs.
> +	 * The reason we do this is to make the change take effect immediately.
> +	 */
> +	if (!ret && write && dirty_writeback_interval &&
> +		dirty_writeback_interval != old_interval)
>  		wakeup_flusher_threads(WB_REASON_PERIODIC);
Is that call right ? The call need two arguments ?
--> wakeup_flusher_threads(0,WB_REASON_PERIODIC);

best regards
Damian

>  
>  	return ret;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
