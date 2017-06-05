Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76A6A6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 08:53:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s4so7471681wrc.15
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 05:53:35 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id c195si4037265wmc.103.2017.06.05.05.53.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 05:53:34 -0700 (PDT)
Message-ID: <593552F3.4040407@huawei.com>
Date: Mon, 5 Jun 2017 20:47:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] signal: Avoid undefined behaviour in kill_something_info
References: <1496653897-53093-1-git-send-email-zhongjiang@huawei.com> <20170605123744.GA9807@redhat.com>
In-Reply-To: <20170605123744.GA9807@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, stsp@list.ru, Waiman.Long@hpe.com, mingo@kernel.org, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On 2017/6/5 20:37, Oleg Nesterov wrote:
> On 06/05, zhongjiang wrote:
>>  static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>>  {
>> -	int ret;
>> +	int ret, vpid;
>>  
>>  	if (pid > 0) {
>>  		rcu_read_lock();
>> @@ -1395,8 +1395,12 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>>  
>>  	read_lock(&tasklist_lock);
>>  	if (pid != -1) {
>> +		if (pid == INT_MIN)
>> +			vpid = INT_MAX;
> Well, this probably needs a comment to explain that this is just "avoid ub".
>
> And if we really want the fix, to me
>
> 	if (pid == INT_MIN)
> 		return -ESRCH;
>
> at the start makes more sense...
>
> Oleg.
>
>
> .
>
 ok, I will motify it in v2 shortly,  Thanks

 Regards
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
