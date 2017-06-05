Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABF466B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 09:09:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 8so23480415wms.11
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 06:09:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l59si28843101edl.281.2017.06.05.06.09.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 06:09:05 -0700 (PDT)
Date: Mon, 5 Jun 2017 15:09:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] signal: Avoid undefined behaviour in
 kill_something_info
Message-ID: <20170605130903.GP9248@dhcp22.suse.cz>
References: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, oleg@redhat.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On Mon 05-06-17 20:53:27, zhongjiang wrote:
> diff --git a/kernel/signal.c b/kernel/signal.c
> index ca92bcf..63148f7 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1395,6 +1395,12 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>  
>  	read_lock(&tasklist_lock);
>  	if (pid != -1) {
> +		/*
> +	 	 * -INT_MIN is undefined, it need to exclude following case to 
> + 		 * avoid the UBSAN detection.
> +		 */
> +		if (pid == INT_MIN)
> +			return -ESRCH;

this will obviously keep the tasklist_lock held...

>  		ret = __kill_pgrp_info(sig, info,
>  				pid ? find_vpid(-pid) : task_pgrp(current));
>  	} else {
> -- 
> 1.7.12.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
