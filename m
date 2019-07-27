Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00CA7C7618F
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 01:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92F6A2173C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 01:58:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92F6A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E056B0003; Fri, 26 Jul 2019 21:58:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3DA08E0003; Fri, 26 Jul 2019 21:58:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D056F8E0002; Fri, 26 Jul 2019 21:58:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0A7A6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 21:58:14 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m198so46567853qke.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:58:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=c7CB+rfFECYt0ajTPN6miUrq6o9XtuXTa3aW8yoJHuo=;
        b=XR9GgAVlkScFuEpDMfzUAK8TVbfil0y806+9GQc629hY2xWt5wQ9IVWXsN5vCsWbAk
         q85TJmncH6Y9mttxyIaaHVpt17X4k3HLYj42PhE42AaRmT2s9T04pLjALHc6afejEGul
         U7jecpzE0wx0xY76R/y3JwaKEQas2u1lt4v2zRMC4di3/jr/o/8SeBVOlEyyGtCPxKzQ
         xaqje7x1xpeG9ycl8jffRsd+aHNvTBOeOIOXJ5WKiHg74DJ8YaTR73UfY8mvfbYojgal
         5+yo26FC4OFOwGevYsUlftBUYqaKliLDKRH5HiXESPGKaY3jehfX/GGFc5vZKWF4FGND
         A1eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVy+HKwhCQtWoxqPswaSI1ChXiZMFAlll2h2eETL6LEZxhYczxu
	LH3KJhgNT90czMjfOgBG8CHzly2AbKvXgb1iS8Snqyiz7Ed3R7GLrvXUPjkHQgoOczdgHKlqEVG
	ox9pjM6kURZxJNDlB1uRi03ZB+HMqP6iS0ZD/X+U5uBRfaT09l0rNci9fkyIQx3hJPw==
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr20628308qkj.357.1564192694417;
        Fri, 26 Jul 2019 18:58:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXQSb9E7KizFx8SkvwqOpGxmffAD+luTdV9Isyrpux2ssMMVPhLiaV7MKoynA6/nNlHow5
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr20628285qkj.357.1564192693782;
        Fri, 26 Jul 2019 18:58:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564192693; cv=none;
        d=google.com; s=arc-20160816;
        b=BsDXo7cl2tcZ8Kqpyyb4R9NybFUZqA3LMG5u7dYQ3LPjySBsseQhq59ZcYxISrvUjI
         nFtWfHjVxI9nSzdYwqnL+U8B1EN+hkgMkvoxgHW+jLB5t+DfcyL+wgwy6Ivh820PeR+u
         v/3fzW5r5RomiF5PZ3SZVGN/RJzX0N6e0zMnCdzrIy/dZWKX9PHDjsVodcqiap6f/PgJ
         yEaW8W8abr6q3kX02trxNWEp/A4NPk/4SzDzw6k6pmu0c03IvkhVCBQu6tsLIP0WZ5P+
         5pIXQBIF95XzoEwNfeWeN826wX2/Ek5+T6+UQpmDeSlLcdOnjmpvPsd/Q0ip33NJ6FgE
         mQTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=c7CB+rfFECYt0ajTPN6miUrq6o9XtuXTa3aW8yoJHuo=;
        b=m+W5jhPWsrYCOkhNr9fQoHUoOkHGBdW30bx19sF1d++7oCKV6kGI7jrbe9yiKhG+Ct
         MLooU5arXn1KJRN+r9LLNXeArZCEId2Vyqalp7WceW/QhFDmC8yXOBDwurwHUfAhpmuy
         aoVema0fitzrZOWPPmaT89SypIsjht1fdoXkujrBs0o76gZtToBhRRMDgOlZy5bHGNgb
         X0FOgMM7+ftzVdps96HEs3DrgSLhFWsc90VCpb+vWvKjUXGtY10gksWYKZzEa8KT/alt
         Fg5s5JTVwMRcUctEeV6t49LvLM/abdXqDCfm5XT7koALqN+fevV4EcROJp7VN2bJDAlt
         ui6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w15si36809286qvc.73.2019.07.26.18.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 18:58:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D2AA03082141;
	Sat, 27 Jul 2019 01:58:12 +0000 (UTC)
Received: from llong.remote.csb (ovpn-124-85.rdu2.redhat.com [10.10.124.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E001C60A35;
	Sat, 27 Jul 2019 01:58:11 +0000 (UTC)
Subject: Re: [PATCH] sched/core: Don't use dying mm as active_mm for kernel
 threads
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>
References: <20190726234541.3771-1-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <b89697ed-a7f0-bb41-25ae-8e9727875d33@redhat.com>
Date: Fri, 26 Jul 2019 21:58:11 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726234541.3771-1-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Sat, 27 Jul 2019 01:58:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/19 7:45 PM, Waiman Long wrote:
> It was found that a dying mm_struct where the owning task has exited can
> stay on as active_mm of kernel threads as long as no other user tasks
> run on those CPUs that use it as active_mm. This prolongs the life time
> of dying mm holding up memory and other resources that cannot be freed.
>
> Fix that by forcing the kernel threads to use init_mm as the active_mm
> if the previous active_mm is dying.
>
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  kernel/sched/core.c | 13 +++++++++++--
>  mm/init-mm.c        |  2 ++
>  2 files changed, 13 insertions(+), 2 deletions(-)


Sorry, I didn't realize that mm->owner depends on CONFIG_MEMCG. I will
need to refresh the patch and send out v2 when I am done testing.

Cheers,
Longman

