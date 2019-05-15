Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AB32C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C91A220862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C91A220862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CE076B0008; Wed, 15 May 2019 05:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47ECE6B000A; Wed, 15 May 2019 05:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36D2A6B000C; Wed, 15 May 2019 05:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 186706B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 05:03:58 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g7so1718107qkb.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 02:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=J+gXJQWxT/hR9z4iu4w14V3+DWHyoS7ReZIypiNlIbI=;
        b=su6Hksb6/Aot27UmJ9iFbv/mqKr3+EyMeODAs6JqUXjAFDjeySk2AOOyRayz0btC6j
         E8fTnKfpJdJPbGVJc06WQQaAJLJ3KpUdTyBB1JuNikwZ/s3PbNw48MOU86xanxgsAZEM
         jvExq5jMmUNKUu8S77yeg/fJYOs+quhlBMI0DETecE4yJSRYQFYArgcWxjaEEZ5s/ifm
         NBnXSFB1EVWZ5KqrFtWf46V8IHUZT/6VRf3NdMdAoaW3SQDu0nuLJAKiFAd8uyAtz05u
         GvWiGWmuK8ypwEAchjlXGcf9vsKlymgwUWNBMI7/522p8leH1tx3gyhLv8taonePYcrW
         3jvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVo0uOpvAxFMFbzFAsuGmy14n/ZImoFDPbMjoY0rerALbq6EQYs
	5dmRU0L+Ix2DQlCE52Ys5HKTv8i+A4D2HE+DQtI0q85YTqi7XCLWj/O5bqAiazvcs5TK5YI7lvf
	1EWRo+ZmoOnVdNoyU6HoKzOqXolVxv/2dfl2+GxmxWKKcWI58MSz59SarsuD1vmi0Lw==
X-Received: by 2002:ac8:2291:: with SMTP id f17mr34624891qta.330.1557911037781;
        Wed, 15 May 2019 02:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhvz2wr/RF7mTRcm+Ohlj5J5XIg+IZv1xA9t6cZt/O+OOEjejYQdV9woYEXoTzN4iSSv51
X-Received: by 2002:ac8:2291:: with SMTP id f17mr34624827qta.330.1557911036902;
        Wed, 15 May 2019 02:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557911036; cv=none;
        d=google.com; s=arc-20160816;
        b=cnLhxSIKEtNgj3FYbCeSCzjtphrz87HP2yIEedqhsOdJB4Ccmy7pb6rVu86JuztXaj
         BYhmtr9bkYN1XA16uDN49hbZX0QQBs6gmidwY/a47VoRJq8K5nIgii/3CKi7J+g5cwDG
         pb1qQKtBYfnv72sqFS1E0/HyYfanFpyM16K7FqEU0QGBB4fgWRoNfGkub+y3rfiQKXGY
         4uTeHGgZyN7QoqUtrQq28GlstJO30fIqBM9fhOorfF5EDVaPCavBsmCjznx6MJ6n8hxV
         /6EvBaEPO3R3Hd0uLz9BQJGCWeAx0idmTyaADY6PqPnVLL6v8sBmrvT9Hgch28M+ADYd
         k4Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=J+gXJQWxT/hR9z4iu4w14V3+DWHyoS7ReZIypiNlIbI=;
        b=llXuqUKPVVNqBNmYMIVAs3IXTIUSZ/ijvyz7Na1EM2do8J22pTybnt2vLfyqi921Ic
         r6IirxqMiFe0jpMbITLl9poJd6ex6beMWDzcUxs+UTK4X5b4brkoQ496PttYZqWB+Tt2
         O8s94lgv7df8sY3NOYVgGHHJmRPE7a5JLxPw73qIPn1alil41gDyARDxdFkFMOVzTF9C
         a0/WnxQ8yggfTYhePSKDECgtFvD4//tHVVYJHdEY8Tv7P4sdyRf90yrT8eidByhHsbOO
         dq84rE4A1OYJRmfL5xepyy9tWPKxPMcD5Ea/TFpINoMMFjLlimO2+Qn/dqT86MyiabCQ
         fspA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v39si908973qvc.173.2019.05.15.02.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 02:03:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2A1067BEE3;
	Wed, 15 May 2019 09:03:56 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1EC105D9DC;
	Wed, 15 May 2019 09:03:56 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 0B78F18089C9;
	Wed, 15 May 2019 09:03:56 +0000 (UTC)
Date: Wed, 15 May 2019 05:03:55 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Naresh Kamboju <naresh.kamboju@linaro.org>
Cc: ltp@lists.linux.it, linux-mm@kvack.org, 
	open list <linux-kernel@vger.kernel.org>, 
	lkft-triage@lists.linaro.org, dengke du <dengke.du@windriver.com>, 
	petr vorel <petr.vorel@gmail.com>
Message-ID: <543317293.22835729.1557911035979.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+G9fYu254sYc77jOVifOmxrd_jNmr4wNHTrqnW54a8F=EQZ6Q@mail.gmail.com>
References: <CA+G9fYu254sYc77jOVifOmxrd_jNmr4wNHTrqnW54a8F=EQZ6Q@mail.gmail.com>
Subject: Re: LTP: mm: overcommit_memory01, 03...06 failed
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.43.17.163, 10.4.195.10]
Thread-Topic: overcommit_memory01, 03...06 failed
Thread-Index: nXsr2eOmSs8GKetOjInAzndms9fFPA==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 15 May 2019 09:03:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> ltp-mm-tests failed on Linux mainline kernel  5.1.0,
>   * overcommit_memory01 overcommit_memory
>   * overcommit_memory03 overcommit_memory -R 30
>   * overcommit_memory04 overcommit_memory -R 80
>   * overcommit_memory05 overcommit_memory -R 100
>   * overcommit_memory06 overcommit_memory -R 200
> 
> mem.c:814: INFO: set overcommit_memory to 0
> overcommit_memory.c:185: INFO: malloc 8094844 kB successfully
> overcommit_memory.c:204: PASS: alloc passed as expected
> overcommit_memory.c:189: INFO: malloc 32379376 kB failed
> overcommit_memory.c:210: PASS: alloc failed as expected
> overcommit_memory.c:185: INFO: malloc 16360216 kB successfully
> overcommit_memory.c:212: FAIL: alloc passed, expected to fail
> 
> Failed test log,
> https://lkft.validation.linaro.org/scheduler/job/726417#L22852
> 
> LTP version 20190115
> 
> Test case link,
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/tunable/overcommit_memory.c#L212
> 
> First bad commit:
> git branch master
> git commit e0654264c4806dc436b291294a0fbf9be7571ab6
> git describe v5.1-10706-ge0654264c480
> git repo https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> 
> Last good commit:
> git branch master
> git commit 7e9890a3500d95c01511a4c45b7e7192dfa47ae2
> git describe v5.1-10326-g7e9890a3500d
> git repo https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Heuristic changed a bit in:
  commit 8c7829b04c523cdc732cb77f59f03320e09f3386
  Author: Johannes Weiner <hannes@cmpxchg.org>
  Date:   Mon May 13 17:21:50 2019 -0700
    mm: fix false-positive OVERCOMMIT_GUESS failures

LTP tries to allocate "mem_total + swap_total":
  alloc_and_check(sum_total, EXPECT_FAIL);
which now presumably falls short to trigger failure.

> 
> Best regards
> Naresh Kamboju
> 

