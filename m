Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 115EEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57803214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:53:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57803214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9588E0003; Tue, 29 Jan 2019 03:53:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D596C8E0001; Tue, 29 Jan 2019 03:53:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFA928E0003; Tue, 29 Jan 2019 03:53:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79EC88E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:53:41 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g12so13750455pll.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:53:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8nLcguaCCar/dmVUQc74nPOT96+yhj5jRyM1RHls9PU=;
        b=ev0IQUgqpOk927x5vGAqATAUqko/aUkK/Z+lZEnleVSUFB8G+09UYFxOibPOMerOg3
         jrf2oMITJ7n/PVWIobu7SY4wul0bPAXe/IH6kJTAIf3HVb1G0lMWdOhraG1GFz1zUaMB
         7yXMe+6dLAbbGLn6MJ6PcL7Sn1qLnkNxe4amtUQ/NHYr3n73yDIRkBNhGH1stF5TMa4L
         tgFgJIVsA6EwSFJ0Fj4jM14z7v2+14vKM+qDfUzXT4G3HE2DyywUPqcgS3LkI0u2Dz6m
         X3h7iWMBYs+IQxsyieuAGSFisCsCVCFCpORBPAU6Ybh4MZreEhwW5BMa34/axcaCFFa0
         jAgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukeBSck3nWONmWtxkgXqjd+gDUeIglNeF4nnAlxkjFU0PceF5WTO
	EbtvDrVE/caDuYcnKEenzL0pVXguND9DTfQwq8AqyKdllphO9uYann/XQ61WcACCcbaGWsPK/1f
	HpFkNXVm+BLSfHcUFx711ZU+HOmZpLYccwm+0l9sruKKiNrRuHqlF606wn2cr0BsFmQ==
X-Received: by 2002:a62:5c1:: with SMTP id 184mr25047866pff.165.1548752021030;
        Tue, 29 Jan 2019 00:53:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN79ILCJKQlRxpWfHdTGc0a5nLhn0+7eKUjfHrEJ110Ql9MQOmFxSuROnw0nDQpCxCNE6TsF
X-Received: by 2002:a62:5c1:: with SMTP id 184mr25047832pff.165.1548752020229;
        Tue, 29 Jan 2019 00:53:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548752020; cv=none;
        d=google.com; s=arc-20160816;
        b=iiq3Ce2L25rLKvyi6L8LIoMzuVsbXe+/FwJ/R9y6V4CN89b6H9hHwew0AFzZBJMayz
         v7203ZGT7kCA49Ku9Ge1xcDMoo0QumDWvQH0zRcaLZU1VquZeS+r3QDCsAK8g6TFjRFS
         /N7MkB9e/OFibtHyu7+LlXCzjAUrilnZRbGIWJRMnNbJLQOHQ5j8Lgv4pc/LjAVjrADm
         2r+IKdVPJRmLKRC1V00x/QY3E21zMG+culslIFLjjCVl96K88IKXRtoLTSkaYYPwusAW
         7/OXHHhkv3Hq7Hmu31w48tGhep3EYDYJP6RKi9zMsHx1SQjnqo32QG5iiKrCGmSpWKo0
         OP4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8nLcguaCCar/dmVUQc74nPOT96+yhj5jRyM1RHls9PU=;
        b=rHUAnwVkAZQrzouVtXeXrfbdSEStTqRNzacAzUaV4KcbJG6chKmyT0oJj5VyHa9nrt
         ZZn5b3UtCGP9o1ilRnL3FdnMEMj4JdTsBoEeBM1/zs2agV8dUpcX+qr7jho24O8CG2F0
         Z807IEtJqzSvI5euP2MNRDGJNowyG2RWkB4bnFC5r9I47uAcdYIW/zI6aiDIcDS0tMbM
         IWD5Cls/bxe8uqmnr4ns8rGMLvI5iTCgVuDei234l5EpsCxbIkZm2tGx/eUwsR6kqpav
         Jj3eBP++TMVKgiaH7bOVXL4ciDg7NZmF30VR1Id+OW4lnwXRjs+RTXLBaWku8/hc4k/7
         bnvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id z128si20046406pgb.372.2019.01.29.00.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 00:53:40 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TJD2vQd_1548752015;
Received: from 30.17.232.157(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TJD2vQd_1548752015)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 29 Jan 2019 16:53:38 +0800
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, joseph.qi@linux.alibaba.com,
 Michal Hocko <mhocko@suse.com>, Vasily Averin <vvs@virtuozzo.com>
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
From: Aaron Lu <aaron.lu@linux.alibaba.com>
Message-ID: <f174c414-ed81-11a7-02cd-b024ef75d61f@linux.alibaba.com>
Date: Tue, 29 Jan 2019 16:53:35 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/1/29 15:21, Jiufei Xue wrote:
> Trinity reports BUG:
> 
> sleeping function called from invalid context at mm/vmalloc.c:1477
> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> 
> [ 2748.573460] Call Trace:
> [ 2748.575935]  dump_stack+0x91/0xeb
> [ 2748.578512]  ___might_sleep+0x21c/0x250
> [ 2748.581090]  remove_vm_area+0x1d/0x90
> [ 2748.583637]  __vunmap+0x76/0x100
> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> [ 2748.598973]  do_syscall_64+0x60/0x210
> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> This is triggered by calling kvfree() inside spinlock() section in
> function alloc_swap_info().
> Fix this by moving the kvfree() after spin_unlock().

The fix looks good to me.

BTW, swap_info_struct's size has been reduced to its original size:
272 bytes by commit 66f71da9dd38("mm/swap: use nr_node_ids for
avail_lists in swap_info_struct"). I didn't use back kzalloc/kfree
in that commit since I don't see any any harm by keep using
kvzalloc/kvfree, but now looks like they're causing some trouble.

So what about using back kzalloc/kfree for swap_info_struct instead?
Can save one local variable and using kvzalloc/kvfree for a struct
that is 272 bytes doesn't really have any benefit.

Thanks,
Aaron

> 
> Fixes: 873d7bcfd066 ("mm/swapfile.c: use kvzalloc for swap_info_struct allocation")
> Cc: <stable@vger.kernel.org>
> Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
> Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
> ---
>  mm/swapfile.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index dbac1d49469d..d26c9eac3d64 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2810,7 +2810,7 @@ late_initcall(max_swapfiles_check);
>  
>  static struct swap_info_struct *alloc_swap_info(void)
>  {
> -	struct swap_info_struct *p;
> +	struct swap_info_struct *p, *tmp = NULL;
>  	unsigned int type;
>  	int i;
>  	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
> @@ -2840,7 +2840,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>  		smp_wmb();
>  		nr_swapfiles++;
>  	} else {
> -		kvfree(p);
> +		tmp = p;
>  		p = swap_info[type];
>  		/*
>  		 * Do not memset this entry: a racing procfs swap_next()
> @@ -2853,6 +2853,8 @@ static struct swap_info_struct *alloc_swap_info(void)
>  		plist_node_init(&p->avail_lists[i], 0);
>  	p->flags = SWP_USED;
>  	spin_unlock(&swap_lock);
> +	kvfree(tmp);
> +
>  	spin_lock_init(&p->lock);
>  	spin_lock_init(&p->cont_lock);
>  
> 

