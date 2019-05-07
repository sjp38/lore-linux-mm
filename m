Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2F8AC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BBE920825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:12:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GZ/H3rR/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BBE920825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18BEC6B0003; Tue,  7 May 2019 14:12:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13E1F6B0006; Tue,  7 May 2019 14:12:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0053C6B0007; Tue,  7 May 2019 14:12:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB0196B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:12:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so10756870pgn.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:12:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=4sryYpBiNg4XxjM8zLEdkqZ8Dj/ZnD7DO4AYpsXPphY=;
        b=LLddF5jnUY+J08otaRFP8sMuqtNtpXfqDErfh0/9MfyzO2kDVCz8yE38KerKvlnT+N
         koQb9R9pjL7qGruJz5IvNI7SvdkPHVdvI+Iu+R+Mq/9oZZnGWoFaHRsyHy2NLfaTOOGb
         lJU6xeQO/eeatLiKMAhT4WU6iJn4Fw+v5IhjEZx+HxCEtO8DQvmJdSzzr63soXL6tA6y
         gC4LQxeHwt5+B7+28P8XL15jViHEGwMFK8othXU9J58y3lvsFvbqz3nMn6NtBLAAkC0E
         s+s22m5TJpefY7iflyUTPh6czAzMFikbRKwvyUjYPS9+jS2OPgBV98Xbdf3dM9YOyPqZ
         GPTg==
X-Gm-Message-State: APjAAAWSwa1UsZUEhAOasSlVeESKE5BLf4+ut3D5jnswvmVcJ150bDAN
	CFcdA7gmBzhPJ50OOmNehxUKEmir4UJ0XM6T7u9g56fw3Ifab7ldU6EfyYSbihmoqNDgLmT4zxB
	+TmiOHbJzRLD+z8UYYBDQtgqXz0LOjrAigIusc2b29ahfO2TmpMY03ihzd8lZ/U918Q==
X-Received: by 2002:a17:902:a614:: with SMTP id u20mr41763375plq.117.1557252737039;
        Tue, 07 May 2019 11:12:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwukc2xiX0LPXJ+T+qiBS3GCtTKrCuSPEiUGPZn4YH/BsksN5lvFwwUU9B3ss47vvcitQgg
X-Received: by 2002:a17:902:a614:: with SMTP id u20mr41763266plq.117.1557252736069;
        Tue, 07 May 2019 11:12:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557252736; cv=none;
        d=google.com; s=arc-20160816;
        b=sDiH0+0qXfnFGTKg8HOvEbetD+qLmrYWob1jnB9qKVhYnTPP/q8eZPoiubaey3CbMN
         4LVFeq0UjoMzf7OQHjy9npND7cYKtadUW4rLWDYxULHOb2aBYwzKvbCIm8wQrgq2nR36
         54DfpyiPDZDj1VnJgaNebUiXmZslnHzLnvhUB2pHiuZffsCB5Tsq7hAnnbCZzJNpmgXX
         qK4dNiTeiaboIKn9Lacm2+LNO5kuyN0+rzfEn1OgOe87AfX90ikyIp5DhMkXsXHVTBgG
         V2xd3t+UsLOpCH/iQtsSuBFHCbDcP1UT7yzS8PftbS6YvG4VfVuxGA5h6GC9weV41AQU
         D/qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=4sryYpBiNg4XxjM8zLEdkqZ8Dj/ZnD7DO4AYpsXPphY=;
        b=b/Ej4HqCPzpFUMILbv1SbWQXaHG8Xop/kry6eZ0xhyPN/2TIiSWL8I3lJQ3Zk3YTI/
         c6rhCMeC/8P/FDRF9xkT3dPQK4pOkIxOCtF2vTkUX5w95GCaUbjdvSR5B/mscqHhJF8V
         UvIrqqFfUgDg2RlGCLrCJrHfIaLI3c20To2NG4FBNzfD90QLeCXUi8GdDUyP4cn0gxph
         uS3gOBWke9chBlz/mD5eLyp0FtamhwRDlQKHyDf9nCDWvPHco7KChgd7A40+x8/1hwUS
         nEu2ViF8NpMb9a1tCC1rMVG8rtxPqQJ7Z1ceGgHsvVtG9HxX0xXl/idxHhGcmoDatuNz
         5KdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="GZ/H3rR/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id ba5si19329011plb.24.2019.05.07.11.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:12:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="GZ/H3rR/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd1ca870000>; Tue, 07 May 2019 11:12:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 07 May 2019 11:12:15 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 07 May 2019 11:12:15 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 7 May
 2019 18:12:15 +0000
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
To: Souptick Joarder <jrdr.linux@gmail.com>
CC: Linux-MM <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John
 Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, Matthew
 Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
Date: Tue, 7 May 2019 11:12:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557252743; bh=4sryYpBiNg4XxjM8zLEdkqZ8Dj/ZnD7DO4AYpsXPphY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=GZ/H3rR/FDVS4uZ/9gaPXJwIfOeK9Rc/JUQV331+m673Nrcdfxw9Ri+Pv003fgeT/
	 NnX9BCVqu86s9oVw8qBofRpZhewvm9GsINKZzZ8Cax3R0DFaui9YYJIfXGvh9DeUci
	 aYDoX3nzO4jYeNxx2EtZYEy5wxuosyjMLorsS+vFOaoEMUlVuxiIqMh/LkqpmP4RVp
	 aJ4gBG2V/AJzS5U0XxSkYNWAdQ/8h/idPLKj82lrCOynwUrcJgJZdsQON5OprxwU/M
	 KwId2544mF3Ku5qM9XmHl6pAWwLBcdvVAIZDY0DS2dkJPFxHFiJlFguYJeH4Rlx//6
	 Q8i2Qus/oydqQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/7/19 6:15 AM, Souptick Joarder wrote:
> On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
>>
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> The helper function hmm_vma_fault() calls hmm_range_register() but is
>> missing a call to hmm_range_unregister() in one of the error paths.
>> This leads to a reference count leak and ultimately a memory leak on
>> struct hmm.
>>
>> Always call hmm_range_unregister() if hmm_range_register() succeeded.
> 
> How about * Call hmm_range_unregister() in error path if
> hmm_range_register() succeeded* ?

Sure, sounds good.
I'll include that in v2.

>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: John Hubbard <jhubbard@nvidia.com>
>> Cc: Ira Weiny <ira.weiny@intel.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Balbir Singh <bsingharora@gmail.com>
>> Cc: Dan Carpenter <dan.carpenter@oracle.com>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>   include/linux/hmm.h | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>> index 35a429621e1e..fa0671d67269 100644
>> --- a/include/linux/hmm.h
>> +++ b/include/linux/hmm.h
>> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>>                  return (int)ret;
>>
>>          if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
>> +               hmm_range_unregister(range);
>>                  /*
>>                   * The mmap_sem was taken by driver we release it here and
>>                   * returns -EAGAIN which correspond to mmap_sem have been
>> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>>
>>          ret = hmm_range_fault(range, block);
>>          if (ret <= 0) {
>> +               hmm_range_unregister(range);
> 
> what is the reason to moved it up ?

I moved it up because the normal calling pattern is:
     down_read(&mm->mmap_sem)
     hmm_vma_fault()
         hmm_range_register()
         hmm_range_fault()
         hmm_range_unregister()
     up_read(&mm->mmap_sem)

I don't think it is a bug to unlock mmap_sem and then unregister,
it is just more consistent nesting.

>>                  if (ret == -EBUSY || !ret) {
>>                          /* Same as above, drop mmap_sem to match old API. */
>>                          up_read(&range->vma->vm_mm->mmap_sem);
>>                          ret = -EBUSY;
>>                  } else if (ret == -EAGAIN)
>>                          ret = -EBUSY;
>> -               hmm_range_unregister(range);
>>                  return ret;
>>          }
>>          return 0;
>> --
>> 2.20.1
>>

