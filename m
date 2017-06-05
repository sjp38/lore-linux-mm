Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB0B56B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 09:50:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h191so24150786lfh.11
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 06:50:30 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 26si17982941ljo.162.2017.06.05.06.50.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 06:50:29 -0700 (PDT)
Message-ID: <59355A43.7000706@huawei.com>
Date: Mon, 5 Jun 2017 21:18:59 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] signal: Avoid undefined behaviour in kill_something_info
References: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com> <20170605130903.GP9248@dhcp22.suse.cz>
In-Reply-To: <20170605130903.GP9248@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, oleg@redhat.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On 2017/6/5 21:09, Michal Hocko wrote:
> On Mon 05-06-17 20:53:27, zhongjiang wrote:
>> diff --git a/kernel/signal.c b/kernel/signal.c
>> index ca92bcf..63148f7 100644
>> --- a/kernel/signal.c
>> +++ b/kernel/signal.c
>> @@ -1395,6 +1395,12 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>>  
>>  	read_lock(&tasklist_lock);
>>  	if (pid != -1) {
>> +		/*
>> +	 	 * -INT_MIN is undefined, it need to exclude following case to 
>> + 		 * avoid the UBSAN detection.
>> +		 */
>> +		if (pid == INT_MIN)
>> +			return -ESRCH;
> this will obviously keep the tasklist_lock held...
 oh, it is my fault.   Thank you for clarify.

 Thanks
zhongjiang
>>  		ret = __kill_pgrp_info(sig, info,
>>  				pid ? find_vpid(-pid) : task_pgrp(current));
>>  	} else {
>> -- 
>> 1.7.12.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
