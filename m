Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A22C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 12:19:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BCDA20675
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 12:19:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BCDA20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC6F66B0003; Wed, 22 May 2019 08:19:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B77E86B0006; Wed, 22 May 2019 08:19:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67BD6B0007; Wed, 22 May 2019 08:19:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4B66B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 08:19:15 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id m4so331520lji.5
        for <linux-mm@kvack.org>; Wed, 22 May 2019 05:19:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+9fW0PRxz+4bfLfbCFiuVFbnUn0YIXpiH5KfbMS39MA=;
        b=tdFfMqttGi4bdFa+yY5IARMLyT0TTSJ3RXVGkfeCLHfrtMjHKjp0DxRAWvLTxGmiLO
         4YVgJsn+M/BRTNeawF0HRHrxkJ5Cl+liGOmYYCdqil17AcN9ukIEHmWtLQtgRmvtMWan
         wh2IffDpjxgNIc21oo/3u9ekQ3YYPASqc3CjLltHwr1cTdeVabjD0h9lLlr+kZPwnXei
         rYxtA8PSwgiEDYlscmGX9D5QOIye+l4maaCcSqk+z2ivzeK/XZIJJyAjVh7M5Pka8yS0
         h2nlD5UNkPAE04RH/s7Ie1bd+iy4P3WH7UE1YKMBfh6yN+Ecs50YjpR1VrLFf5q1lPei
         fEng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUq2zwe3DP7pYN2U2NzfKE5FpttMT+RQwtOpdnsuJYCprAPG2C2
	GeswIUsfHSgWVEHB9SiFpsZtxsqCK3JSFnCYfD715x3o929j/bgwVUK7sJ6DSEOmH1sLxuoMnxP
	y+GbGKohDP88x/bKn4141+cV8gy3zh1cJcWRK4Cp+GqqnSdkwghn+WQimKbN5s/e7Cg==
X-Received: by 2002:a19:2b4d:: with SMTP id r74mr32022053lfr.96.1558527554540;
        Wed, 22 May 2019 05:19:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrChk1VmtV21Na0rCgEwmGqz+eFqwzjY1Qp9rC6e6twDDZif/ltcVGa1lh/42w/+LagUnl
X-Received: by 2002:a19:2b4d:: with SMTP id r74mr32022013lfr.96.1558527553456;
        Wed, 22 May 2019 05:19:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558527553; cv=none;
        d=google.com; s=arc-20160816;
        b=lA2nT8wTJ8kr2QUqaiqvqp6cchq+IuXhXP49MGdkVQ9XL2PzQw0XvSaFiacV0TWmSO
         JN5j0U8Oj8W6JZdSEH3qg9VQGa6CxOMZTt02w8l93KhZF2BCSmXa+dDwwuQlenHQ9N2a
         64/TEi4kVIjK2M0SV4Ibbns8KTAPtbMp1AFcrDSe2U66kq6pkENQ31phCScvP9O2v70K
         A6eghIt+X5QKVX7N5r/+axIExu9gvY8OOXb+CvK32fGBON887dOPVT1SQe+V4aXJwgsD
         MnQjHaMMlywe8RYmSpVEU83/1CLa8Eq4lcHSc9nywOcjYjQ4iGBakH0vlhQd2SEFbQg+
         BEpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+9fW0PRxz+4bfLfbCFiuVFbnUn0YIXpiH5KfbMS39MA=;
        b=R0SWrCeZTn9nLShOGJTO27p7KHKDgpuQV9qrWn2rTQO7fB4bw3JD/Kcedfi/InZX8S
         n7kgju6vrXmqYXkWI4oedHzEQESBTTI9Fncnvk0rsTf57c239Lf5iGq6MeDiHZiIt+yt
         wvBsUqPjDKmX960GtflpvqkIf6R1J30P4DM9MuksGdcg8yc4qmFPkg0BuDsZkr1EgYGS
         kE9v8MT6Sax4dam/IYFCwIceI9vcCTeoFMCv0egEAt/hdw14MxJKgFB/qV5eCig0IBFQ
         1VjZ/uiGX3b+RreTHTnlyFkl4LsB1/NT/CFpOlPZnvhV9stMYi1krU5Snv3KwjysIv9i
         OzpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t10si11249698lji.37.2019.05.22.05.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 05:19:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hTQDA-0003Xw-1H; Wed, 22 May 2019 15:19:12 +0300
Subject: Re: [PATCH v3] mm/kasan: Print frame description for stack bugs
To: Marco Elver <elver@google.com>, dvyukov@google.com, glider@google.com,
 andreyknvl@google.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kasan-dev@googlegroups.com
References: <20190522100048.146841-1-elver@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e607a134-bea0-f662-2aa7-4755708c8aa5@virtuozzo.com>
Date: Wed, 22 May 2019 15:19:30 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190522100048.146841-1-elver@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/22/19 1:00 PM, Marco Elver wrote:
> This adds support for printing stack frame description on invalid stack
> accesses. The frame description is embedded by the compiler, which is
> parsed and then pretty-printed.
> 
> Currently, we can only print the stack frame info for accesses to the
> task's own stack, but not accesses to other tasks' stacks.
> 
> Example of what it looks like:
> 
> [   17.924050] page dumped because: kasan: bad access detected
> [   17.924908]
> [   17.925153] addr ffff8880673ef98a is located in stack of task insmod/2008 at offset 106 in frame:
> [   17.926542]  kasan_stack_oob+0x0/0xf5 [test_kasan]
> [   17.927932]
> [   17.928206] this frame has 2 objects:
> [   17.928783]  [32, 36) 'i'
> [   17.928784]  [96, 106) 'stack_array'
> [   17.929216]
> [   17.930031] Memory state around the buggy address:
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=198435
> Signed-off-by: Marco Elver <elver@google.com>

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

