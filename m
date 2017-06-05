Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6286B6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 08:37:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m57so39662668qta.9
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 05:37:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r32si10097973qta.195.2017.06.05.05.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 05:37:49 -0700 (PDT)
Date: Mon, 5 Jun 2017 14:37:45 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] signal: Avoid undefined behaviour in kill_something_info
Message-ID: <20170605123744.GA9807@redhat.com>
References: <1496653897-53093-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496653897-53093-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, stsp@list.ru, Waiman.Long@hpe.com, mingo@kernel.org, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On 06/05, zhongjiang wrote:
>
>  static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>  {
> -	int ret;
> +	int ret, vpid;
>  
>  	if (pid > 0) {
>  		rcu_read_lock();
> @@ -1395,8 +1395,12 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>  
>  	read_lock(&tasklist_lock);
>  	if (pid != -1) {
> +		if (pid == INT_MIN)
> +			vpid = INT_MAX;

Well, this probably needs a comment to explain that this is just "avoid ub".

And if we really want the fix, to me

	if (pid == INT_MIN)
		return -ESRCH;

at the start makes more sense...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
