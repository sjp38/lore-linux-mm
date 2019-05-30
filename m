Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC9D6C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99529253F6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:27:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99529253F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 437F36B000E; Thu, 30 May 2019 03:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C1336B026B; Thu, 30 May 2019 03:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2886B6B026D; Thu, 30 May 2019 03:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08B6B6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 03:27:12 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z66so4315440itc.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 00:27:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=czxjwus0QLnI3QefmAMsRih0AAcaK03za0MHRUZN1Ts=;
        b=d1cjXqzWYEmctcD5Prh0knepD5dPs65PzIWDf8LpQLE5hm2kfRTcnsh3QYkvF93X+7
         28hzg7kOJ/rS6jWTjfJp/l9x01ZPYXZg/9Uu8q7ySVaafn/+hYR82tlEZNDfxI4tjhXZ
         DT3d2ypav5O4wnMpicamRWkA1iAl5ktTfHQbQDUQOKYjv0DVXvEEdkEZ2gHQImIF0PF/
         fJA2qvnSM4HiheZylAWUNo7FhAFAuKBjLi18RtRvpkxRnCltodTlz1u/ys13ahAp9ifx
         ti9xrnGXGmf5IbqzslxSaKASCKVP8CqoF+bgtdJTpc7GrXYD4z10GR8qnqutg+MNMCNn
         tdDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW9kdsCojfGTRnO5DxmRnlC/CpzyEdU4hLTU1gSE16iajPyf2mf
	YO9q/txH8P7E+7GjtVyjVEo9fAv01dd0R/nNjrLZhNFYjc25QxJC7DPBhcia31Mw7kN/li6+f2V
	EIHWxl9CD+YcSfN44vwIZj7YRaADFUb9Xvaz25+CNTft+Qwca1yWwgPtMokKEBugsTw==
X-Received: by 2002:a24:3643:: with SMTP id l64mr1814264itl.148.1559201231800;
        Thu, 30 May 2019 00:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiyL88B+x5m0kYqXkSCZJzkLxmHI01cezeNQqknPNXsP19ccIXANzhhorNf8bBOo6/gKS7
X-Received: by 2002:a24:3643:: with SMTP id l64mr1814244itl.148.1559201231203;
        Thu, 30 May 2019 00:27:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559201231; cv=none;
        d=google.com; s=arc-20160816;
        b=aQ7xz5PfInviiHtWguFgvD76mECSWT1TBjDb5nt8deOO3dkSrtxC1QUhAKY7gAn4Yo
         p07WvOTZOvCeub7FEpCrUnPvs3f1zvzdYcbHxyH5UiGnbkiDkwWkJdPv3NUB3laVsOUE
         /I8+hU/2vg4duFj1USv/MaIsUNae/Qze1pXxrtg4R7o2rmRB05LBUtxve4vC6LSHtWUe
         /2et/kpqa/8q4oO6gAaf1MVtcLHm/X5EYK+aslrEUCnn+9MZtULB6CnlGjD3DaejwA6v
         pMtBteo/fkhrnMXr9eOwCilbWEWdbqAUlhsXJNgzfC5gNc6z/YEg1QUeSwMwVw0ZNywK
         U5+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=czxjwus0QLnI3QefmAMsRih0AAcaK03za0MHRUZN1Ts=;
        b=0WEmZaMtNpVxftfqfDbSVxwuPO2tBgKoG024b/9RpWHyics0y0eGySIhbY/QANUD1W
         dNIzV6200M/s9YrgeRnP4xMijwqu4ULBlnW9nu89HIO7u7pRo8p/Vv99ML2sQPfxXgCd
         dtscW8Qw6cd6L4MtE0S6ONvoHxl7REQM+wc0q3EmYMDNCZ75lF2uGlZ64gBLcjZNBDYp
         5E0USabb4wLfDOwLC/WfY33gjntFEYmnRvsG23wHHBzgN9EdvYa6gBmBjhOiydil36He
         wiDQWdJpNQCd/uiMN5d4V2MI8bpngQFh25nE5OCMzLdQcuZpZSB7zUOhrWtZqwF2gags
         DlSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id a20si1203129ioc.19.2019.05.30.00.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 00:27:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TT.Ho-Y_1559201205;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT.Ho-Y_1559201205)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 30 May 2019 15:26:46 +0800
Subject: Re: [HELP] How to get task_struct from mm
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
References: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
Message-ID: <aa26006e-eec7-73f1-e111-6e2c2090d244@linux.alibaba.com>
Date: Thu, 30 May 2019 15:26:44 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/30/19 2:57 PM, Yang Shi wrote:
> Hi folks,
>
>
> As what we discussed about page demotion for PMEM at LSF/MM, the 
> demotion should respect to the mempolicy and allowed mems of the 
> process which the page (anonymous page only for now) belongs to.
>
>
> The vma that the page is mapped to can be retrieved from rmap walk 
> easily, but we need know the task_struct that the vma belongs to. It 
> looks there is not such API, and container_of seems not work with 
> pointer member.
>
>
> Any suggestion?

mm->owner is defined for CONFIG_MEMCG only, I'm wondering whether we can 
extend this to !CONFIG_MEMCG case or not?

>
>
> Thanks,
>
> Yang
>

