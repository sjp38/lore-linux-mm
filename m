Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A62CC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:56:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C6CD21743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:56:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C6CD21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D9D86B0003; Fri,  9 Aug 2019 10:56:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861B16B0006; Fri,  9 Aug 2019 10:56:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DAF36B0007; Fri,  9 Aug 2019 10:56:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1995F6B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:56:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k37so3720846eda.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:56:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=l1W+cYS0UtnE/8fq7KAP3l0ygkdu/iau07Uho/f7Dos=;
        b=VRutRCb5vBH2glzXjn0JQlazekiHFK4ohZmqXjKy490xPwG+3QWNIw5MC02GfKMqBO
         gn0xeAaGJtURXBP9Guptekc+4D0GU171U4pXu4qvDlZtgnpJyfL2zmFgqiIeOyp9LcZL
         zcZEulD/Dxcgcd2aQMGBh0e3jfsQuFjalARWTH/FEUCN+Gl6OwFFFA5dhQdvnvVB08tf
         my/vnsXQ7yo7avlvwBLIzJO1N0C3ZOEi8YfdUC1p46RonRXbTCN7zZ+RRaxwv/A/iPpc
         RvdnbLi1tK4Iht/kzlGnu86wT5vdMQs+UEgcp9OmUQG81IS0j7VgN6Y8CV71FmOqpX7c
         N5Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUGlrKupsS6l6wXAaWj6bUPYbfILyR+IGMREFyQ5cfymsjHz3yF
	6Gp+zLeO2Vs9oPUPvzxr/3oqnwnwYcCzmEVBdNubJmEE31hAfuDJ+t/cExDAoGnncqHPpy1030C
	zOc56SsX4GIjQk4qnXG+XXv6Ti8MihKNjAbNYUeLnURNOv9MsIPS3h2CkRccIHNrRCg==
X-Received: by 2002:a50:8752:: with SMTP id 18mr10453101edv.96.1565362590662;
        Fri, 09 Aug 2019 07:56:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfali664qeZ9TXuM7vwXOQbvxZ77JLnGUbx+MJYjAMgf9LuRMBh3xJsmirIch/9XQu7cnk
X-Received: by 2002:a50:8752:: with SMTP id 18mr10453030edv.96.1565362589913;
        Fri, 09 Aug 2019 07:56:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565362589; cv=none;
        d=google.com; s=arc-20160816;
        b=DIPMGOTr9igjph9SfZR77vXLNOz/zeIHdEpYP/GHGBnV1bRdgf55zlf0uweSp4QKPu
         k6wBx427VDQbmAfQOq7aOlCrREb3GTaY9Ai3WSjVDct5mKNeqh3/6mtP/3Gtv2GMAKG0
         muBamoTXQQWVgFygSSVEXFfNBjt9bHt6CVTbGARg1Syfa+PKZVtDh19yeFl814SkFt9l
         nMzal1rKT/jMpzDjlNvD0/H5BLUu7uL86RjlkcLJu2qqjkS73vZZbrBywvhlbw1CamlI
         fnuTzzH40IMk66y5IxCfNlEnSYBEC1PnvVhtK4VgV5Gg9py7WIvKpHU3n3+QgyCezv4N
         hH9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:cc:to
         :subject:from;
        bh=l1W+cYS0UtnE/8fq7KAP3l0ygkdu/iau07Uho/f7Dos=;
        b=JZ0SJDzSTrThpa2/MjcVi3R6+yFpQ5hObGy6oEARhDmSbIPOE8da/v2R7D278EVmDl
         EITkHnCeG7V4tN9yryxGP2zIJ5rXKsmM/mBxqwCM4MtVQ0buD5Q84IRZX5bzZESX50H4
         b/HroCwT85lXDSXTZo9q/h2A+23RKDe1+xy/mQUgHksNdOEZLmIFaLAhRwwf4m1DlrKl
         LPLv8G+6ZV//R2KGzZHPIUGYWRlEG3zBS6D46LyyNJz2AMxtTly+jrLUoGVxll1weYx+
         wMq02wOv9OXqutDUKD7Xs8CJedgWkRUexnHKgI1LgPeW+VRYbTW4h3dpl3HGfq37nlay
         9LpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r21si3050375eju.85.2019.08.09.07.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 07:56:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 31C3CAF38;
	Fri,  9 Aug 2019 14:56:29 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Suren Baghdasaryan <surenb@google.com>,
 "Artem S. Tashkinov" <aros@gmx.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
References: <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org> <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <e535fb6a-8af4-3844-34ac-3294eef26ca6@suse.cz>
 <20190808172725.GA16900@cmpxchg.org>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <6e7f0cd2-8b13-7534-1c0e-f3569f8b4c05@suse.cz>
Date: Fri, 9 Aug 2019 16:56:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808172725.GA16900@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 7:27 PM, Johannes Weiner wrote:
> On Thu, Aug 08, 2019 at 04:47:18PM +0200, Vlastimil Babka wrote:
>> On 8/7/19 10:51 PM, Johannes Weiner wrote:
>>> From 9efda85451062dea4ea287a886e515efefeb1545 Mon Sep 17 00:00:00 2001
>>> From: Johannes Weiner <hannes@cmpxchg.org>
>>> Date: Mon, 5 Aug 2019 13:15:16 -0400
>>> Subject: [PATCH] psi: trigger the OOM killer on severe thrashing
>>
>> Thanks a lot, perhaps finally we are going to eat the elephant ;)
>>
>> I've tested this by booting with mem=8G and activating browser tabs as
>> long as I could. Then initially the system started thrashing and didn't
>> recover for minutes. Then I realized sysrq+f is disabled... Fixed that
>> up after next reboot, tried lower thresholds, also started monitoring
>> /proc/pressure/memory, and found out that after minutes of not being
>> able to move the cursor, both avg10 and avg60 shows only around 15 for
>> both some and full. Lowered thrashing_oom_level to 10 and (with
>> thrashing_oom_period of 5) the thrashing OOM finally started kicking,
>> and the system recovered by itself in reasonable time.
> 
> It sounds like there is a missing annotation. The time has to be going
> somewhere, after all. One *known* missing vector I fixed recently is
> stalls in submit_bio() itself when refaulting, but it's not merged
> yet. Attaching the patch below, can you please test it?

It made a difference, but not enough, it seems. Before the patch I could
observe "io:full avg10" around 75% and "memory:full avg10" around 20%,
after the patch, "memory:full avg10" went to around 45%, while io stayed
the same (BTW should the refaults be discounted from the io counters, so
that the sum is still <=100%?)
As a result I could change the knobs to recover successfully with
thrashing detected for 10s of 40% memory pressure.

Perhaps being low on memory we can't detect refaults so well due to
limited number of shadow entries, or there was genuine non-refault I/O
in the mix. The detection would then probably have to look at both I/O
and memory?

Thanks,
Vlastimil

