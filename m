Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525FCC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:29:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EB0D216B7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:29:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EB0D216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B07236B0003; Tue, 21 May 2019 04:29:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7316B0005; Tue, 21 May 2019 04:29:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3696B0006; Tue, 21 May 2019 04:29:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 415F76B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:29:23 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id p125so3001162lfa.0
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:29:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SzKeNXo1uWmpaQfgrlLRWkXgwfJYRKDRl5/eKV7Kdrg=;
        b=JRsHg5W1xZeegvyTUWNfr/FM8nmCydT6YIFcaaOge4wdcH5EnyXDL2FhLn792q3xTz
         3WMLg6vp1qeeLswa+XAk/crxTbOw2ifeEQRQbj3ALBhCPmmJ7xVT2hZQEETMpW83DPwn
         bdmv91JOQNZ8GwfwrICyO1mz5M5GqrlMFGEOc6baiMvs22CGjGI0xSoMqS0V0mW/hkas
         IZGsJLokIyd3vqWJhmJmKzS7USFE1yoFmK08xFLmjE42f5tjrtb4bzhqqFV07aJo3c9N
         3s3z89XgqtAScGe/7q4sp19Lv6DTJU1UOuLgoOOdT4LJH0O9VVMjsXUEaE+QLM2cKD1q
         jLHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWX4v74dzjnFf2jxLMOmaK9MvPGraJrmr2FCm2G0cUvii0Xx0zO
	LKrkBSflfY9o8G2ElPfaFQjaPmJMSzNnTblRF9jA2kXPtRl3eioF0XITa5qqYXVloCAAGwFvnvq
	SFCVP4owyoWph3CHtneAl0bwbv+EZU9fYJPiKfQpsE0OntGtQ73EBEks5ZXmvKIfBIw==
X-Received: by 2002:ac2:5c48:: with SMTP id s8mr39078524lfp.126.1558427362681;
        Tue, 21 May 2019 01:29:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1U4b8dHnu53UPGuk9gG3vOKkMTwOf2F3WBgvyqExAQbLjRkQKxkTn+DrOGbtE8TmeAjYj
X-Received: by 2002:ac2:5c48:: with SMTP id s8mr39078488lfp.126.1558427361926;
        Tue, 21 May 2019 01:29:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558427361; cv=none;
        d=google.com; s=arc-20160816;
        b=MNYCtp6ZpN/hI+7yI5ZNGtyqmMvDOzeLVioamytb+1qpU1zAV2YYejtVMnoEla6r1b
         ukcTKt4dYhgnx9GzbyFcq1SZyqq0k1FYylEhrerSuYOy8Uh+zSNi/dMDQFlq+KghVny/
         YoAkc227PPlyfh0IecbboTTUxkmTwCfzqNgOUOXUpHEXiUr8nbRWQfIggz3CmFFTI4YL
         6IrI4Gf1NvZ3HGAsxyG7jOfvi8+xcj207MqWgV7tuASOrLvyczQ8BSu9za6cM5iJnNWt
         ABru0r6Ox/hNT4cca4yVsBQ8BcS1WfZ7pghRp56s8IV/VQAH2i5yi0K4fNOwp7DaGzY7
         PBHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SzKeNXo1uWmpaQfgrlLRWkXgwfJYRKDRl5/eKV7Kdrg=;
        b=Bh14z7IOd1nJXkooIJJnqFkMDeSV34cty2m1AwxkmtHfcezC5TSlDycfKqZbLAnnSN
         UT7TN/z13nnvRLbgcZqk4JWmWSndxZGlD6CLBi9ADRnb+0sMrSgrlw6rqirPB+TxAvq3
         tvIpSFfpf13UweBTWI2XABjjMcW0Rio/PvgMB7pld3+NYwyTTfMmsJz70rSJXV+ucVBm
         KKdE9xRFx1ZxALn80pWIx03dsUHKu5iS7HM7bWfWop7ntbgpRI4gB/yTHzAyCdaTPDpr
         3CyiI/AimubuLYO9frMZlB4hahF+DlSbHbD21U39O7tX/t1dqkv4Y0wSTIpLha6Fcf0j
         yNNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e21si14099277ljl.207.2019.05.21.01.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 01:29:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hT08z-0003cM-KX; Tue, 21 May 2019 11:29:09 +0300
Subject: Re: [PATCH v2 1/7] mm: Add process_vm_mmap() syscall declaration
To: Ira Weiny <ira.weiny@intel.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <155836080726.2441.11153759042802992469.stgit@localhost.localdomain>
 <20190521002827.GA30518@iweiny-DESK2.sc.intel.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4c35e953-5f59-0202-3f75-f9ccf7df798f@virtuozzo.com>
Date: Tue, 21 May 2019 11:29:09 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190521002827.GA30518@iweiny-DESK2.sc.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Ira,

On 21.05.2019 03:28, Ira Weiny wrote:
> On Mon, May 20, 2019 at 05:00:07PM +0300, Kirill Tkhai wrote:
>> Similar to process_vm_readv() and process_vm_writev(),
>> add declarations of a new syscall, which will allow
>> to map memory from or to another process.
> 
> Shouldn't this be the last patch in the series so that the syscall is actually
> implemented first?

It looks like there is no dependencies in the last patch to declarations made
in the first patch, so we really can move it.

I'll make this after there are accumulated some commentaries about the logic
to reduce number of patch series.

[...]

Thanks,
Kirill

