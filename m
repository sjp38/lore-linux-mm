Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F74EC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7698920881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7698920881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 232358E0004; Tue, 29 Jan 2019 05:44:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3108E0001; Tue, 29 Jan 2019 05:44:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122858E0004; Tue, 29 Jan 2019 05:44:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE44E8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:44:09 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w124so10646270oif.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:44:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1Tqi37HP9mPnihzMYQj5eW8A7xelvMeutivY1c5N0Zs=;
        b=FvoxAOp0yY5jwkZT5wW7ste/t6R/6OKPeVZ/36F09M99WMuf8lOU0dMEBIN6mlVGYp
         YgaTa4o+AFRFnBiigO+9Mr1YV1Dp22VQibDAi7yBspwLDJsJa7QKpqVOFY1ZoyehP2qr
         aVizyNaXUO1yI7ZGREjh5fb2m+JdXVvJ0w+qZXkrSRNFpdW2Rxb/EqInGEXE/+p1e+VG
         ISipPSUoGxEfXVP/Sn3noG55XE6agsI6/SbU/qgLK50S3VEpli1pe/vPKHJuHxygpZ1m
         tz6qaTFF2xJ70cWwosLYr0+3S+98YSyakXQLnZz6t7poNWhDUuiegiFtycm5CNtXxFfw
         pRuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukfaHh7X5IRS6654tyTEzMi+HRiKwhGvg16NqSWhqsE1ChYIb5vB
	YX3YWIXHqmyutREojQnMDu+lRWJr+PKF+OY9FTFynxkuGrYlXguqG4DZzyp/ErXTXniEysj3/3t
	Ww/y1a9pPn4BqtGWjpR4GiYbrnYJYrdugubfbEgHRuLhJiHGnLeKytJHu+Sam8B+YBw==
X-Received: by 2002:a9d:781:: with SMTP id 1mr18240376oto.250.1548758649665;
        Tue, 29 Jan 2019 02:44:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7UYxMOoybr7TQbqUkBROh1o0HYMd50a4n1HM//++2RTBL4qEeClbwR6G79U93HjhUWqq5Z
X-Received: by 2002:a9d:781:: with SMTP id 1mr18240326oto.250.1548758648048;
        Tue, 29 Jan 2019 02:44:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758648; cv=none;
        d=google.com; s=arc-20160816;
        b=w1xyOTrA2ObXDTe4jC3APA2c+D3MD5Akmlehp8o3sVrwRVGumd9fJQ+N28Gg3OKhhj
         RJQn2bnTPZAfS91mD0LXdV1j+TJLzXXZLc6MsQ/8M89TrPeOGmtGQ09zkdEedVmmTbp8
         uOny+rH3Z2am7wFzHXndGjsgy4iQtqwrQ+vIM2M0vDztEp2t1bzr2jjX9NDyqhjdM5bX
         kLw7MnFmGSrewTmLtBaXqLfPcV8guv8dPOFZVeri7PCQtrht7kNVmTJ0uP0gq4OLb139
         Z+2dkpTgv6eDYLTwaBr9+CLq1x+EYGGETlFZ6aD6YnMR4DUF2Zrm2xquQlNuHOH0Mfrq
         lqYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1Tqi37HP9mPnihzMYQj5eW8A7xelvMeutivY1c5N0Zs=;
        b=RfD+2vEuyV7noH84H8iAPafVoffYZ4caXTX207SV1vwYhLX2uPP6ctykwevf9bGuSe
         HSTcFLb6CS7sUxCc1IYTW9oCQu4+FoVlRbuy5Gx2KvzkBKVDO3UPuxkj2Qd5QvcIKXm9
         bD/yA58qMoJJhjhAZuJmIeHW7C2Hz5Khjj7N1wKHJ379v5m6Ixo+Q0Gu8FUcIEIKmcKr
         6H1yTm/fgz7xLEsyHKTk6lnL2zQ5KF0WD+lFFg9O5FlEAl6+8Ib4/tYxRbzYtuTDy8m4
         mZAQuhx9ZIvbJxFJ5+LgxDNfxgZCTguvJd3YktFsP6bfQzsS6PAMcBW4uUkosEqWmcEy
         eYRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id t4si5942812otq.281.2019.01.29.02.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:44:07 -0800 (PST)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R231e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01451;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TJDFCqW_1548758633;
Received: from JosephdeMacBook-Pro.local(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TJDFCqW_1548758633)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 29 Jan 2019 18:43:54 +0800
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Aaron Lu <aaron.lu@linux.alibaba.com>,
 Jiufei Xue <jiufei.xue@linux.alibaba.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
 Vasily Averin <vvs@virtuozzo.com>
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
 <f174c414-ed81-11a7-02cd-b024ef75d61f@linux.alibaba.com>
From: Joseph Qi <joseph.qi@linux.alibaba.com>
Message-ID: <d1bb1729-e742-6d30-539d-5b45cc1ddb72@linux.alibaba.com>
Date: Tue, 29 Jan 2019 18:43:53 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:60.0)
 Gecko/20100101 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <f174c414-ed81-11a7-02cd-b024ef75d61f@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 19/1/29 16:53, Aaron Lu wrote:
> On 2019/1/29 15:21, Jiufei Xue wrote:
>> Trinity reports BUG:
>>
>> sleeping function called from invalid context at mm/vmalloc.c:1477
>> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
>>
>> [ 2748.573460] Call Trace:
>> [ 2748.575935]  dump_stack+0x91/0xeb
>> [ 2748.578512]  ___might_sleep+0x21c/0x250
>> [ 2748.581090]  remove_vm_area+0x1d/0x90
>> [ 2748.583637]  __vunmap+0x76/0x100
>> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
>> [ 2748.598973]  do_syscall_64+0x60/0x210
>> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>
>> This is triggered by calling kvfree() inside spinlock() section in
>> function alloc_swap_info().
>> Fix this by moving the kvfree() after spin_unlock().
> 
> The fix looks good to me.
> 
> BTW, swap_info_struct's size has been reduced to its original size:
> 272 bytes by commit 66f71da9dd38("mm/swap: use nr_node_ids for
> avail_lists in swap_info_struct"). I didn't use back kzalloc/kfree
> in that commit since I don't see any any harm by keep using
> kvzalloc/kvfree, but now looks like they're causing some trouble.
> 
> So what about using back kzalloc/kfree for swap_info_struct instead?
> Can save one local variable and using kvzalloc/kvfree for a struct
> that is 272 bytes doesn't really have any benefit.
> 
avail_lists in swap_info_struct is dynamic allocated.
So if we use back kzalloc/kfree, how to deal with the case that
nr_node_ids is big?

Thanks,
Joseph

> Thanks,
> Aaron
> 
>>
>> Fixes: 873d7bcfd066 ("mm/swapfile.c: use kvzalloc for swap_info_struct allocation")
>> Cc: <stable@vger.kernel.org>
>> Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
>> Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
>> ---
>>  mm/swapfile.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index dbac1d49469d..d26c9eac3d64 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -2810,7 +2810,7 @@ late_initcall(max_swapfiles_check);
>>  
>>  static struct swap_info_struct *alloc_swap_info(void)
>>  {
>> -	struct swap_info_struct *p;
>> +	struct swap_info_struct *p, *tmp = NULL;
>>  	unsigned int type;
>>  	int i;
>>  	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
>> @@ -2840,7 +2840,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>>  		smp_wmb();
>>  		nr_swapfiles++;
>>  	} else {
>> -		kvfree(p);
>> +		tmp = p;
>>  		p = swap_info[type];
>>  		/*
>>  		 * Do not memset this entry: a racing procfs swap_next()
>> @@ -2853,6 +2853,8 @@ static struct swap_info_struct *alloc_swap_info(void)
>>  		plist_node_init(&p->avail_lists[i], 0);
>>  	p->flags = SWP_USED;
>>  	spin_unlock(&swap_lock);
>> +	kvfree(tmp);
>> +
>>  	spin_lock_init(&p->lock);
>>  	spin_lock_init(&p->cont_lock);
>>  
>>

