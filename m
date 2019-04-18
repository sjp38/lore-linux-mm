Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D57DCC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA5B20835
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:28:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA5B20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 241906B0007; Thu, 18 Apr 2019 10:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0586B0008; Thu, 18 Apr 2019 10:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BAF86B000A; Thu, 18 Apr 2019 10:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8E5C6B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:28:08 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id w16so1689771ybp.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:28:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=v2J1mL+BBR5vVrjvIXBxi3ajx5DlHtaXwlO12NucBWw=;
        b=GyRU6IGYEulKcqjoeWbqhxsDONlJD5B0Ks3ebFPvPa1hFdBX5QGp/hyYlFR6+WeUBu
         4VhQvA2TrA/2oopE4/bjfrPJSFYEJfL/5i8FfAafUZATtn9Ef37s8OjXlM/wR3m+Sa2f
         KVHQgIs6IWLd80/zgjPYO69YXzS/42ia6DsPZoB5Ps9MsaBthr1SazvnqBrIUAI/lQ31
         j/TfgIMCTq0xjCZArnkmkamhrBn3xu4JdK2mO1LArWY0tgfyOTVpTcZiy3Qo2R6aXWZW
         zA3SLprxBGIyBcSLSMiiLxumAzWv8rYQupgNt1Yn/cVS3/NxT5xJ/YoSveCYvPhbnVUv
         j7Eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUgBTbOSbI+NmvE88fEsiHn87c/e/SXT386eIfFw/svLzS3keQu
	KH+JftroD9PKzn93iVK3GgzjMqMepW6xdYbqFoZ8gkjBRnl9H6oOwGH0r4Dl1bCsge1Jx9Uwt+j
	TnxGeSI9G5sPeBQUjYG/kuqNCZHZZ5Z+D0NeRPJyZmCL8+bI1rrkGSFYCDo+WGVcZHQ==
X-Received: by 2002:a25:4403:: with SMTP id r3mr56216239yba.80.1555597687767;
        Thu, 18 Apr 2019 07:28:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlWZuvBNOBLMD8ddyqWRUBeVXOEe4RCeE9HSnrttPdA7MHUIxXtbGb1gfpV5WZi32b/m+z
X-Received: by 2002:a25:4403:: with SMTP id r3mr56216011yba.80.1555597684508;
        Thu, 18 Apr 2019 07:28:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555597684; cv=none;
        d=google.com; s=arc-20160816;
        b=I9BHsmBbVE1L03ScJeUxbOzd+t5ksBJayQZ82XJSuhN8nbtjjAtZlWqLUL9b7oyuEL
         7jnbD1tNM8rLpxFTLMKOwzGpQvj0S4vd8oh8M9+WnSD4BrMvKg7gBIdEZl9s6Nzu3sJC
         WmlB0QcvaVeEIm9b5mNJlN8FNh8zRXHEYxTaAP8dC9ktLlWfG1b7/XO61kuUz1rsyhOD
         jR7LY+1wNDyJHqQO4M8wL/pbbwghycr5wtoBAYlDF3Dkark6gUHtON/tnDRU+h9No1DE
         xtt+FdCO0WVrb0Ikh5UfZ2jaImCAnUF7Gq+F2qLQDJCm3VnWg3rt4k9ucjYF/9i4YXO/
         43Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=v2J1mL+BBR5vVrjvIXBxi3ajx5DlHtaXwlO12NucBWw=;
        b=xeFDvakaDH5vyFh1TFJsbBUgrFCllxj3uFI3t0tK0oCjCgYExiLYRJTpkDPDd8/RZ7
         84KZHXv7CxWZiu0UVFE/3PSLxE1vh6YulVwpfTFqJ/f45Lw6rg/qhzbo8t1EDmmQAPnB
         4Jpn0pHXdzETvXvb9OrIsXwu41Oj4pmtleSAH5bczQ9T5WZ5/ps2+Ckx9g5bTtphKx0r
         fMyCpzuic6dL0CaZxgRce6G+a0tvC9uxoKehepIMZ/COOWU0PqXik4oTrgOyOJaY+wWu
         GjaxbilnBWvxzubsKTc/pcUklTgIcaXYB4nyB2xHr4sWf2m6KON6k3r/5qGJwiCUV88J
         y3jA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b10si1473607yba.142.2019.04.18.07.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:28:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3IEJCwP051386
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:28:03 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rxqyu9ddw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:28:03 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Thu, 18 Apr 2019 15:28:00 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Apr 2019 15:27:56 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3IERteW53149868
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 14:27:55 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 91AC611C06E;
	Thu, 18 Apr 2019 14:27:55 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8C83311C058;
	Thu, 18 Apr 2019 14:27:54 +0000 (GMT)
Received: from [9.145.32.15] (unknown [9.145.32.15])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 18 Apr 2019 14:27:54 +0000 (GMT)
Subject: Re: [PATCH] prctl_set_mm: downgrade mmap_sem to read lock
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
        Cyrill Gorcunov <gorcunov@gmail.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, arunks@codeaurora.org,
        brgl@bgdev.pl, geert+renesas@glider.be, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, mguzik@redhat.com, rppt@linux.ibm.com,
        vbabka@suse.cz
References: <20190417145548.GN5878@dhcp22.suse.cz>
 <20190418135039.19987-1-mkoutny@suse.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Thu, 18 Apr 2019 16:27:53 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418135039.19987-1-mkoutny@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041814-4275-0000-0000-000003294817
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041814-4276-0000-0000-0000383881C8
Message-Id: <27defd37-7e4e-f919-fe0c-64e1efdafdcf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904180098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 18/04/2019 à 15:50, Michal Koutný a écrit :
> I learnt, it's, alas, too late to drop the non PRCTL_SET_MM_MAP calls
> [1], so at least downgrade the write acquisition of mmap_sem as in the
> patch below (that should be stacked on the previous one or squashed).
> 
> Cyrill, you mentioned lock changes in [1] but the link seems empty. Is
> it supposed to be [2]? That could be an alternative to this patch after
> some refreshments and clarifications.
> 
> 
> [1] https://lore.kernel.org/lkml/20190417165632.GC3040@uranus.lan/
> [2] https://lore.kernel.org/lkml/20180507075606.870903028@gmail.com/
> 
> ========
> 
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
> arg_start|end and env_start|end in mm_struct") we use arg_lock for
> boundaries modifications. Synchronize prctl_set_mm with this lock and
> keep mmap_sem for reading only (analogous to what we already do in
> prctl_set_mm_map).
> 
> Also, save few cycles by looking up VMA only after performing basic
> arguments validation.
> 
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> ---
>   kernel/sys.c | 12 +++++++++---
>   1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 12df0e5434b8..bbce0f26d707 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2125,8 +2125,12 @@ static int prctl_set_mm(int opt, unsigned long addr,
>   
>   	error = -EINVAL;
>   
> -	down_write(&mm->mmap_sem);
> -	vma = find_vma(mm, addr);
> +	/*
> +	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
> +	 * a) concurrent sys_brk, b) finding VMA for addr validation.
> +	 */
> +	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>   
>   	prctl_map.start_code	= mm->start_code;
>   	prctl_map.end_code	= mm->end_code;
> @@ -2185,6 +2189,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
>   	if (error)
>   		goto out;
>   
> +	vma = find_vma(mm, addr);

Why is find_vma() called while holding the arg_lock ?

To limit the time the spinlock is held, would it be better to
    	read_lock(mmap_sem)
    	find_vma()
    	spin_lock(arg_lock)
    	..
out:
	spin_unlock()
	up_read(mmap_sem)

Not sure this would change a lot the performance anyway.

>   	switch (opt) {
>   	/*
>   	 * If command line arguments and environment
> @@ -2218,7 +2223,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>   
>   	error = 0;
>   out:
> -	up_write(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
> +	up_read(&mm->mmap_sem);
>   	return error;
>   }
>   
> 

