Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDCD9C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 989EF204FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:01:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 989EF204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 460318E0003; Tue, 30 Jul 2019 17:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4104A8E0001; Tue, 30 Jul 2019 17:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FFA58E0003; Tue, 30 Jul 2019 17:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB0B8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:01:43 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id l7so8950022vkm.21
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=/vHFQeDLDQ0GR+ivEM/w25bmqJW77wPOipEg2rr6GT8=;
        b=CrLCbu7GUAmUveLjvN+/JSGaL1HdzngyjYjLPrXaj7fDsGCR6MmhrVzjRV4D6HimHs
         bMKINGN2s140IZ3eHoD44kfFrSuYQ04R7PSk8xW3NJe9avfagA0ySdyZFvqCCgjrOuZR
         9MWve37L7yAk5Svvh+bQSi+MJ2Q2DC84L9A5VH2uVsThh4IhtA1JJ0lboOGNANm5X0gL
         g3n6Ni7Sl2GDuWS8uWCNfdjZ9+EcZ15HMGExjjpfJaWRDgol84ovoSw5mkd0SnUaWPeb
         pZ+nk6FnDzA+CrUsnme8usxVv2Nexx4QISVzbn2+dIga7OgrAaOde/A+RwPLk7z7arFz
         XBNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUXMiQvgXgZKvigmIViv4juEUO1oUdAoH7u/3ovCeQdD6OW5+/y
	7A2NnhAoi34CurDsq+AeNzS28bV2TCnotQt2Vie8gdjgzWpZk68y/nX0+IyCbwu63FSZcQZLKLs
	OB1khxxDbpqjPSS7WXFYYzXGcQdpwUA5O+chgR9nTM9ZkVR7fhe+NBl81ZhxsTYpqPw==
X-Received: by 2002:ab0:55c4:: with SMTP id w4mr24230275uaa.35.1564520502822;
        Tue, 30 Jul 2019 14:01:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp6ybn+4a4gORWcmRQ0sw48sf06TahQ51swUBdY4GeRm89mLGIan/dCTvnAyfSGAN8zFnh
X-Received: by 2002:ab0:55c4:: with SMTP id w4mr24230215uaa.35.1564520502176;
        Tue, 30 Jul 2019 14:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520502; cv=none;
        d=google.com; s=arc-20160816;
        b=fgnM8zPDugTGgi6E3YCHdHXyQSek5CkgeV7Y7mPix2EOr1dS32+JX+sE7BWrRmGGxD
         w1xH3e4VEn1A5yNkNwk6y8VIkbIZdhBNS0dqAgHp8aAqH1tTSxnYGh5dlg1EpPJrzwFy
         SRFs+TmYU9eU+6U7+TYO69EZxbaj9oP0GXtzVoo2ukRuqUhk9ndBwKDH05xm1rzghGKM
         aqnQjyH3ViRYQAsWLBWPN/PMLS5CN6FpDYuHt6O05ETTiYbz+7PBzkA7BlGsv79k4Ihe
         r2kIXtlEvTvxwpE+Lz+DnaFqUWByRuL/fIjxM7qaNwISOxtEkaYKXN4/uIihqxjtm4ad
         7OiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=/vHFQeDLDQ0GR+ivEM/w25bmqJW77wPOipEg2rr6GT8=;
        b=cXBUsNjt2qJjrRN+LlUSEbZnvZFUxFB4yshRGRvGwwOdyoJ9g+w1KNg/j3XzapAebX
         LsCatbegmxEn7ijB7eDAjyk3qZ/pa50+fdtep6v+/V5sUxpycPdfJk6uASOCpjosTQJe
         XOSEG0d9mlTgxmtDCObtsyELAMWBB8AaCxTiyTzn+ouIJWa5DJY8cQoI9rxNhoXu9ZXs
         kEx0ec79fcyU+A6gQMU/RmWnb5stvdSuoOl8SuomuCFRlt1li1RIfdKYjX0QcqLxOydd
         NOsQInh46VanQ6/JznpqMaoNzGcN0IPXhO8CbiCiHOWaLcyhiKyT5SvboOK9xVoMfDmV
         C8Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u25si13768967vsi.86.2019.07.30.14.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:01:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 85ACC85A07;
	Tue, 30 Jul 2019 21:01:40 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AA2B05D9C5;
	Tue, 30 Jul 2019 21:01:38 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Michal Hocko <mhocko@kernel.org>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
 <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
Date: Tue, 30 Jul 2019 17:01:38 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 30 Jul 2019 21:01:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 8:26 PM, Rik van Riel wrote:
> On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:
>
>> What I have found is that a long running process on a mostly idle
>> system
>> with many CPUs is likely to cycle through a lot of the CPUs during
>> its
>> lifetime and leave behind its mm in the active_mm of those CPUs.  My
>> 2-socket test system have 96 logical CPUs. After running the test
>> program for a minute or so, it leaves behind its mm in about half of
>> the
>> CPUs with a mm_count of 45 after exit. So the dying mm will stay
>> until
>> all those 45 CPUs get new user tasks to run.
> OK. On what kernel are you seeing this?
>
> On current upstream, the code in native_flush_tlb_others()
> will send a TLB flush to every CPU in mm_cpumask() if page
> table pages have been freed.
>
> That should cause the lazy TLB CPUs to switch to init_mm
> when the exit->zap_page_range path gets to the point where
> it frees page tables.
>
I was using the latest upstream 5.3-rc2 kernel. It may be the case that
the mm has been switched, but the mm_count field of the active_mm of the
kthread is not being decremented until a user task runs on a CPU.


>>> If it is only on the CPU where the task is exiting,
>>> would the TASK_DEAD handling in finish_task_switch()
>>> be a better place to handle this?
>> I need to switch the mm off the dying one. mm switching is only done
>> in
>> context_switch(). I don't think finish_task_switch() is the right
>> place.
> mm switching is also done in flush_tlb_func_common,
> if the CPU received a TLB shootdown IPI while in lazy
> TLB mode.
>
I see.

Cheers,
Longman

