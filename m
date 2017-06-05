Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 784616B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 09:32:05 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y31so64394552qty.7
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 06:32:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d51si13379703qtc.12.2017.06.05.06.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 06:32:04 -0700 (PDT)
Date: Mon, 5 Jun 2017 15:31:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] signal: Avoid undefined behaviour in
 kill_something_info
Message-ID: <20170605133159.GA10301@redhat.com>
References: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On 06/05, zhongjiang wrote:
>
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

you need to do this before read_lock(tasklist)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
