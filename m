Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F808C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:33:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF2D2081B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:33:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF2D2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 889608E0006; Thu,  7 Mar 2019 11:33:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 839028E0002; Thu,  7 Mar 2019 11:33:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 728328E0006; Thu,  7 Mar 2019 11:33:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05B9A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 11:33:00 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id h14so3647309lja.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 08:32:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RiQ8pHh1Q5auGmeQ1VAumpFkjTv6HITHLxc+Gt1bcGE=;
        b=Jjm8GHFkSzeVPPfOJvZxKVvm+Pe5lTX365siAWOzlfk9JISQYlvfMbbuCqKPg8brLS
         edcz8+3C4ftKSuQKiaQU7Owejxkt0wvfS4Py7sVWOEjNRt2E/Yz/tHznxqJ+6wa+fNQV
         jQI8NQVD5WgGgyN/hO5UeY7mmRZA/i0KpdRadvE87baScuXqCtKww53475oFcKoVvpWe
         jmcpM7o71Rpj02qBuR6hHU0RrALCEfqTZYY+frpGAE242YcfLJc0vab4JWwnGyNaFvRQ
         aj0d7Z3cW+c60ARjFxa1KV7QsF0l9PuG0OyvL2JCfb4M7novuTF2LEVychNEb/cUavG0
         nAvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWUeoxP5eM7kWU0jO3C951eNb/AVt4Vo/ao+oFPQzT1cIV1G6Rg
	RgggPUFuuQnr7cKX5vbzU9d2TltUKqU52ZGshgnIuIJBto+9xPFOr690puX/ZYqZMclPqIBztzI
	qWIPTau5vdDzGedHXTy6ABckEXyO9CqOb3hHz1rvaYQyLJKCjioWao1rF7OWFCR1WXg==
X-Received: by 2002:ac2:569e:: with SMTP id 30mr7696117lfr.93.1551976379292;
        Thu, 07 Mar 2019 08:32:59 -0800 (PST)
X-Google-Smtp-Source: APXvYqzAR8v2xeyVaJfI9tJPzbL9MTsam5EDOBFcAIwvkfHKHFTXPA1ojoCPq4PWBauD7QZi/c4S
X-Received: by 2002:ac2:569e:: with SMTP id 30mr7696059lfr.93.1551976378066;
        Thu, 07 Mar 2019 08:32:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551976378; cv=none;
        d=google.com; s=arc-20160816;
        b=u5ypC2licg1IigICLshby/mOFErgBxdEwiJbkXL+Se/gmc40A4D1W7lMAsxZ+Mi5/6
         97ImVJbKSzZZsSO56Q/DME9Ww4GE8i8X78RBovpcJARKuCqVgd2QC8vSPxfc60mwH4ck
         o+PIA5dTiCX0sMzImex/e71uZIs3P9O3ilTA3xYf0uGIFfeBaEAGKso2o2RZNi1rrD6c
         CzynWNJd/P683vTb13/YOlFL9kwWcPLsSx+4hOffV1zxnykaYGpKfQK8g+SnG68kUE++
         +1QwwcXbdQ/Fqwm7/YaHJD5OwvStsjzb1zPVVxCIwglesILDpcDxjWuOn+7Xi1903Ik0
         mvhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RiQ8pHh1Q5auGmeQ1VAumpFkjTv6HITHLxc+Gt1bcGE=;
        b=Ze5GjCB9kVoUNSRawPO7wurMkNifzHGrrmobaD7riXIC/tyuCdIN/DOAgrqGUdEXAj
         XYNGzOQ7QFuzugH4hH+tecc1AfgcLs3agUW7+DXXVCFwHknpoqkPoTeALuJTzR98Wxrn
         SMhTUANI3jj2tNSzJPuLO3/J2CsjMPGXsWs5svv22iLAPFFgW+jEnL/d22s+K8AKXsP9
         8+IHrQTgCok1n7rrWIe976XFQqdJf2+mk50bGu27KjfEUigcZBxiMs8XGj2mGy93Jrvk
         fcQO8MLQqSkU9W8TEH5NIFSJpL4MJqWnKCu1kH7BUdoeg5x39wu6D4Yjum1WUIN31CX6
         jPFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q29si3383019lfb.114.2019.03.07.08.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 08:32:58 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1h1vwz-0002uH-SI; Thu, 07 Mar 2019 19:32:54 +0300
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Aaron Lu <aaron.lu@linux.alibaba.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Yang Shi <shy828301@gmail.com>, Jiufei Xue <jiufei.xue@linux.alibaba.com>,
 Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
 Linus Torvalds <torvalds@linux-foundation.org>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <20190307144329.GA124730@h07e11201.sqa.eu95>
 <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
 <20190307152446.GA37687@h07e11201.sqa.eu95>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <afce7abf-dbc3-3b3e-9b61-a8de96fcaa2d@virtuozzo.com>
Date: Thu, 7 Mar 2019 19:33:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190307152446.GA37687@h07e11201.sqa.eu95>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/7/19 6:24 PM, Aaron Lu wrote:
> On Thu, Mar 07, 2019 at 05:47:13PM +0300, Andrey Ryabinin wrote:
>>
>>
>> On 3/7/19 5:43 PM, Aaron Lu wrote:
>>> On Tue, Jan 29, 2019 at 05:01:50PM -0800, Andrew Morton wrote:
>>>> On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>>>
>>>>>>>
>>>>>>> If we want to allow vfree() to sleep, at least we need to test with
>>>>>>> kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
>>>>>>> vmalloc()/vfree() path). For now, reverting the
>>>>>>> "Context: Either preemptible task context or not-NMI interrupt." change
>>>>>>> will be needed for stable kernels.
>>>>>>
>>>>>> So, the comment for vfree "May sleep if called *not* from interrupt
>>>>>> context." is wrong?
>>>>>
>>>>> Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
>>>>>
>>>>>     We are going to use sleeping lock for freeing vmap.  However some
>>>>>     vfree() users want to free memory from atomic (but not from interrupt)
>>>>>     context.  For this we add vfree_atomic() - deferred variation of vfree()
>>>>>     which can be used in any atomic context (except NMIs).
>>>>>
>>>>> and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
>>>>>
>>>>>     - * Context: Any context except NMI.
>>>>>     + * Context: Either preemptible task context or not-NMI interrupt.
>>>>>
>>>>> change. But I think that we converted kmalloc() to kvmalloc() without checking
>>>>> context of kvfree() callers. Therefore, I think that kvfree() needs to use
>>>>> vfree_atomic() rather than just saying "vfree() might sleep if called not in
>>>>> interrupt context."...
>>>>
>>>> Whereabouts in the vfree() path can the kernel sleep?
>>>
>>> (Sorry for the late reply.)
>>>
>>> Adding Andrey Ryabinin, author of commit 52414d3302577bb6
>>> ("kvfree(): fix misleading comment"), maybe Andrey remembers
>>> where vfree() can sleep.
>>>
>>> In the meantime, does "cond_resched_lock(&vmap_area_lock);" in
>>> __purge_vmap_area_lazy() count as a sleep point?
>>
>> Yes, this is the place (the only one) where vfree() can sleep.
> 
> OK, thanks for the quick confirm.
> 
> So what about this: use __vfree_deferred() when:
>  - in_interrupt(), because we can't use mutex_trylock() as pointed out
>    by Tetsuo;
>  - in_atomic(), because cond_resched_lock();
>  - irqs_disabled(), as smp_call_function_many() will deadlock.
> 
> An untested diff to show the idea(not sure if warn is needed):
> 

It was discussed before. You're not the first one suggesting something like this.
There is the comment near in_atomic() explaining  well why and when your patch won't work.

The easiest way of making vfree() to be safe in atomic contexts is this patch:
http://lkml.kernel.org/r/20170330102719.13119-1-aryabinin@virtuozzo.com

But the final decision at that time was to fix caller so the call vfree from sleepable context instead:
 http://lkml.kernel.org/r/20170330152229.f2108e718114ed77acae7405@linux-foundation.org

 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index e86ba6e74b50..28d200f054b0 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1578,7 +1578,7 @@ void vfree_atomic(const void *addr)
>  
>  static void __vfree(const void *addr)
>  {
> -	if (unlikely(in_interrupt()))
> +	if (unlikely(in_interrupt() || in_atomic() || irqs_disabled()))
>  		__vfree_deferred(addr);
>  	else
>  		__vunmap(addr, 1);
> @@ -1606,8 +1606,6 @@ void vfree(const void *addr)
>  
>  	kmemleak_free(addr);
>  
> -	might_sleep_if(!in_interrupt());
> -
>  	if (!addr)
>  		return;
>  
> 

