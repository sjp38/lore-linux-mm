Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC3C2C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 01:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C56221773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 01:05:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C56221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 020436B0273; Tue, 16 Apr 2019 21:05:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F117E6B0274; Tue, 16 Apr 2019 21:05:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E276D6B0275; Tue, 16 Apr 2019 21:05:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A68646B0273
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 21:05:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so14396438pll.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 18:05:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i8fswQ6Co7Q8rAuTvlt/QWn1tWxqFHVVElj+qq9qXsg=;
        b=oNxoqs4sBgmwH8R+m5ZqzxccgyWhY73glKDZ0gOmGen2fZPrvPmWOTaQPsb2NHfC/U
         6HrL3Uco+QBeuKrXEhtveaB1jiGo4cGv5wTK8VNfaBTZShHyUSvaGDX5OgLAA5rJ2Q4u
         mmwb4a+9HTFcOyNKE+D/Mi6b2zT6Y2BehlFT8oMeVwIvlUt//LiN/hPBOdPN5f8QVs7G
         gCDjFsSoSUKT0J9v7gk7/FqnYiJLxbhSKEtVCdZ3OnnOZcTvjZw9y8+EAF61oUf0O/i7
         u4FCdJdjN7eRTt7Zec0JXdd0KNgpu5nqJRVs2ViMeOTsQccxwmL6m3hcb7QKrHlCyV7V
         Tgpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWpIzPIDOrVT4AxXyHnUFalr3NfSwVGVANOIrfk8qoDrWxnclGD
	uHH5erVlKQRVc9DAgscw06r9o1sy1VMBpnBvCau+o/H/yC7QWnHoH1vxeombnDWCyCU3Vqq+oFc
	SXmc/QEosqC6OByTefFIJ4xUCHDcmunQ+W8MneRmbPsRF7HhSUNYZzYFu+3KmhGiQHA==
X-Received: by 2002:a17:902:8f92:: with SMTP id z18mr87710308plo.123.1555463105180;
        Tue, 16 Apr 2019 18:05:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQC9en4cAMgSWLYOpY4rPkhNvL7UKIyF2ThqvCjlL21lfQCNZYMq1YV17mKHTxYPrMrP3H
X-Received: by 2002:a17:902:8f92:: with SMTP id z18mr87710250plo.123.1555463104364;
        Tue, 16 Apr 2019 18:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555463104; cv=none;
        d=google.com; s=arc-20160816;
        b=lUYZSrvS0j5ueVTCuBnKzLgfqwyJwXp2hUUa2CEmWWJbY1mYxV9doq3nWi3zRfFY4F
         7NVwFsooizlWTdrGb/+wdp+mTYktpDEb9aQH2IgltDgPlwF1rPtn1TCvAWc1S/lMjJ1S
         gASqE8iAla5SRW7oZwvrrlV0Fn75YLN9Lw9qrh+IwPgNLc+abaxCAn9+Wtk131svv4mm
         nClm897Fguuw0XM6XBKAM/Qbxxav7XLKuFrdEKMfh0rvxuKo4l4NxCKMgSZUTZR6nV0m
         8ugcxzouDCL9LmHZjaRWFpVAm3vgV85eVIzM/b3V61NljCZ/JF1iNhoW/FEWETEBXyEG
         +K+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=i8fswQ6Co7Q8rAuTvlt/QWn1tWxqFHVVElj+qq9qXsg=;
        b=OiQzsQ8GdObbBl7DrBWiaSklEu3rRIU2poc18LcDK606pnHsQaWCpG8OfBwVmKmc9C
         Hd4T1H5SHMZ6f/MQVIuqaMrejZcEeiUzxNIMS6H79EVBc7/Y43qZjDu4I5JgUJBVIOBQ
         g/BV9foX3nLeu52esYAfWx0lYOKUubK26EqWVBWIdvKkHG/ssdmbVWCdMSuB3Ht7upUC
         ofR47/BdEZMb7ljlbD7dduwtpeR8olwEEv9t8mfsaw07pAzaL4bw0VrkmdrYnlxjzZAo
         ayDPNtcB3+h9yf46SpJvVYx8naTyTjt9cUvhl0NTySjbJOwGjFsVGpKh5CRlMRhJU6qE
         xVfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id v35si27162266plg.187.2019.04.16.18.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 18:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TPVWJz1_1555463088;
Received: from ali-186590e05fa3.local(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TPVWJz1_1555463088)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Apr 2019 09:04:49 +0800
Subject: Re: [PATCH v2] fs/fs-writeback: wait isw_nr_in_flight to be zero when
 umount
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 joseph.qi@linux.alibaba.com
References: <20190416120902.18616-1-jiufei.xue@linux.alibaba.com>
 <20190416150415.GB374014@devbig004.ftw2.facebook.com>
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Message-ID: <f3b2fbad-fc9e-d10d-9f81-9701bb387888@linux.alibaba.com>
Date: Wed, 17 Apr 2019 09:04:48 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190416150415.GB374014@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On 2019/4/16 下午11:04, Tejun Heo wrote:
> Hello, Jiufei.
> 
> On Tue, Apr 16, 2019 at 08:09:02PM +0800, Jiufei Xue wrote:
>> synchronize_rcu() didn't wait for call_rcu() callbacks, so inode wb
>> switch may not go to the workqueue after synchronize_rcu(). Thus
>> previous scheduled switches was not finished even flushing the
>> workqueue, which will cause a NULL pointer dereferenced followed below.
> 
> Isn't all that's needed replacing the synchronize_rcu() call with a
> rcu_barrier() call?
>

Yes, it can be fixed if we replace synchronize_rcu() with rcu_barrier().
However, I'm worried that rcu_barrier() is too heavyweight and we have
encountered some hung tasks that rcu_barrier() waiting for callbacks that
other drivers queued but not handled correctly.

Thanks,
Jiufei

> Thanks.
> 

