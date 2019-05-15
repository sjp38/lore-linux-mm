Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F1AC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:36:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D0CB2084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:36:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="fG6szY4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D0CB2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E71E6B0006; Wed, 15 May 2019 04:36:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2979B6B0007; Wed, 15 May 2019 04:36:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1872B6B0008; Wed, 15 May 2019 04:36:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7D676B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:36:35 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y62so429060lfc.16
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:36:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+V/qixzhLPwbC9jsVHGnQ96lDXhr7tMgZ+aRfAzVw2k=;
        b=kWnCovMlJ3WqCDMfIvs0xhgeaeePqKxo703PuXdo0SHuI5tkVTtkgPeQXVF6yuYyII
         BCNXXcYdMTzDx8YEw0YmzXiyuoz9j9jCirXWj1smMAAJ3d0iBzKr9Lgzhsn/Dqss4KUk
         xJwQVCS1WMARNLAN+p+YbPSsBxvh4nNlfMSt0l5wENzr1zQc2qq+sAppI9GEWkcXKec7
         FFyYtmHsOXH8mQteiWv24ZQDsapo2z0/zIgclzMy9hSN3Q4Y11Ul0aZzeK2kC1iRurRx
         v7PCLQTAjKT3YIymytSFPQ3v1BopWCQ1HbsMLFJrCdBzaL6YDuYOB5X04sfKCzy6+9yV
         hddQ==
X-Gm-Message-State: APjAAAWDwsf6C3499HyGU6pzBl1VcPW2mO3ZqVs/liIEakibD1I6qYSx
	XW2ocY+NAchBnMZKhYfDWl4272+NKGY7dZ/V3szr2PHYkFGHKASGHrP8Zkc0gpJz1ln0cLoZt64
	HanJWGLyHKNcto4tYs1P4zY0vJVtKYi/WO0Luf8VcBYWhvCITjzC4pzAKMFiHuoK/oA==
X-Received: by 2002:ac2:5a04:: with SMTP id q4mr7892262lfn.90.1557909395091;
        Wed, 15 May 2019 01:36:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzrz2RYofjs8kkVtgZ6KYglBIF2qVAwoluRPJAPXJ2BedUGxZO5GWgZfI0K2AT4RZSZM/Z
X-Received: by 2002:ac2:5a04:: with SMTP id q4mr7892226lfn.90.1557909394343;
        Wed, 15 May 2019 01:36:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909394; cv=none;
        d=google.com; s=arc-20160816;
        b=RMtc0eAax/9gbgiYQefzNxizN4nEpeoaLxuUop/iiA8VVZc2oc5MpfbqzOn4aG7axq
         Y3VyjOIf2iCJPR+L0dTIfMu80DrtzICJFFaQACSXwSpkLhYjlaBntj+Kv/xMYfxqwXef
         CtahgtPHCX64JBZ5YfwyOYkN+UQZ2p7FEuDGg9x2lKtnwr34XmV0jA0HsbhRNY1uWnA2
         3WjE8DaIu5rQAAELhKbD+k6Pzi5E8pZPGVASLUQDU/KMr0RXH3BLj0EvBWMbUZbfQEas
         gWdOFRACblW41Gl5PZGc7EvEc9P55ZhZ7GJrUTO+PD0k++743dj8K4ST6c5DWw/PNwKZ
         pWqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=+V/qixzhLPwbC9jsVHGnQ96lDXhr7tMgZ+aRfAzVw2k=;
        b=WHbQVj9zNftzhaFcPW7c/F+sKdly6SXudA6XCkJxzIHoqqxJiK0kR2FZGL+5s5yNdn
         6LLC1PYOH+tV71CGD5TUdqPEXwkKDeqsx8sJZVug1O5VnXAv3phfKYU4WMWwNac9Iin6
         g1jgxMQrjBa61Fc3XREvzn3EU4Q0xVXiqpj+oELmbP0OvcPVeWgSW058iNhrGpV5TC9b
         YesKjtrkIpETy7Jl/zgMz+Lc0gTGWlDII+z9N9Fv0Mu6yLD2OSVVYlmEr3gN0hSe4p8i
         lfXuZAmWcg/87gY1lz9vACfL9METxaDRCmBHMiYHPv41XOL0Nr27cq00OjYMjknjCHK3
         J4kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fG6szY4A;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTP id x9si890625ljx.110.2019.05.15.01.36.34
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:36:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fG6szY4A;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id BEA8F2E14C9;
	Wed, 15 May 2019 11:36:33 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id FiL44lb1Xj-aXwiN7Xh;
	Wed, 15 May 2019 11:36:33 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909393; bh=+V/qixzhLPwbC9jsVHGnQ96lDXhr7tMgZ+aRfAzVw2k=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=fG6szY4AI+sLKK0Ror9iZxVfH8KcIEIjDFDqPEpGgy5aw9sgoY4eXQrnKLKdMCUVp
	 lkCjNFVFoGT6SsD+bCEIXfiPtyQuzbVhAGbwy2/3uAj0l8Gx4i7QqeF9OZsIcCqirl
	 E6oaDZeudZXfcsdJP8n7pE7CsY9JkJr2vQ+sYzCM=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id elKpxPcxty-aW8q7Dnp;
	Wed, 15 May 2019 11:36:33 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH] mm: fix protection of mm_struct fields in get_cmdline()
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
 Yang Shi <yang.shi@linux.alibaba.com>, mkoutny@suse.com
References: <155790813764.2995.13706842444028749629.stgit@buzz>
 <20190515082222.GA21259@linux>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <e86ce7c9-5093-816d-3141-1cc0d3ba8ad9@yandex-team.ru>
Date: Wed, 15 May 2019 11:36:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190515082222.GA21259@linux>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 15.05.2019 11:22, Oscar Salvador wrote:
> On Wed, May 15, 2019 at 11:15:37AM +0300, Konstantin Khlebnikov wrote:
>> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|
>> end and env_start|end in mm_struct") related mm fields are protected with
>> separate spinlock and mmap_sem held for read is not enough for protection.
>>
>> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> This was already addressed by [1]?

Yep.

> 
> [1] https://patchwork.kernel.org/patch/10923003/
> 
>> ---
>>   mm/util.c |    4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/util.c b/mm/util.c
>> index e2e4f8c3fa12..540e7c157cf2 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -717,12 +717,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>>   	if (!mm->arg_end)
>>   		goto out_mm;	/* Shh! No looking before we're done */
>>   
>> -	down_read(&mm->mmap_sem);
>> +	spin_lock(&mm->arg_lock);
>>   	arg_start = mm->arg_start;
>>   	arg_end = mm->arg_end;
>>   	env_start = mm->env_start;
>>   	env_end = mm->env_end;
>> -	up_read(&mm->mmap_sem);
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	len = arg_end - arg_start;
>>   
>>
> 

