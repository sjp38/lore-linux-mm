Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23CD2C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 03:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E237021955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 03:44:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E237021955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78E246B0003; Sun, 21 Jul 2019 23:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73FA96B0006; Sun, 21 Jul 2019 23:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6069C8E0001; Sun, 21 Jul 2019 23:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 284D76B0003
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 23:44:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so22802340pgg.15
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 20:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=FKjJ2x6eylvtxhTWn2qpi9fRjkop69ztlt4O4HX4lvA=;
        b=BEAL8fnji94RBtAgvSNunp8Sp4+9k+fw8gn+/ZmUEYxy2ttbRh4VV9YvkHP8s7s2df
         TRaR1C6u1ykfPtbEtiA4mYgy22F0O6UB+3a7x8WKbVMYI4Jlngzm3yezl9tywFiBVwfO
         GETa6SvASFUCYC3yPbOgLeczwdKrtqYrRASw1rle1SLCMqKWIMJYwgKcLvVfgyJ96clN
         fQ5AYyQeildI3MDpHHby+/Rzltey3tdH4RIOIFSVZbw0g8o+hGu8mtPxzjq8MKMwDIWN
         y4CDzLlzVh5nB/RCv3ZNwRj0GSHPbGwN83rgz0709T+HfGUK2cX5jHmQcov61TbtNpbM
         G4nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUXi3CrTYaF2yQSVnkwH72UJUnzYwWYFYmon2UOWx5KQM41ig7M
	jgVv6MdItSwTr71o9RHGj7HRtbQuHLdV9eQuczXivaYJuBp+RCk+46npZeLU+hAViXsoiaRj5vj
	Ob+vaUuT/HBJC8xWLzKNiO5ODXAKOQE1J5Q0aGfJPwlwg7Eu1iSzmcrraLHd4FlXxmw==
X-Received: by 2002:a17:902:6b86:: with SMTP id p6mr74759990plk.14.1563767093722;
        Sun, 21 Jul 2019 20:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNjGDQU4rIkFWVtWHh3gOoEPKmP/y+ogV5AobGCHDWxmK3ljlxABOGGDCLH3WFRQBBC7Bu
X-Received: by 2002:a17:902:6b86:: with SMTP id p6mr74759944plk.14.1563767092976;
        Sun, 21 Jul 2019 20:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563767092; cv=none;
        d=google.com; s=arc-20160816;
        b=i3XtMWYfiSpBfvzKvTLttD2z4tkqtBqOs9B4RPJDMt1NZmfEtggB5lxOEfCfSHbe/N
         0AG3SWyoxVsy+Vbax34n7siImt0Vsiic3ujw0kwTyFpQzOD6poRXQPwUCDm9jLo8CUSp
         HYP+vv7M6u5G1pMpOtt0Z0iov1Hrf3prPsa3bRhlqMcXjTTENaN0fyjBwfm8t/taxKga
         KMMs53GEu2BomvXmph4hwCkj/e32rDeCh3+qv01sLjh/5qlx5/Ajr8DB7oZ3LIJRQ9/Y
         +gQNKUQO6M+p5ArYuObXxVE2IV6g/n6bpM8PmMuSwf4bNw1jhCJTuFNgx6WGpESsBal4
         +W5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=FKjJ2x6eylvtxhTWn2qpi9fRjkop69ztlt4O4HX4lvA=;
        b=At7Lmvv8snT2bcmZTclHiMBXCkuX1LqEN4Ls65HDbsyBcGHBubNjYJOmKiEugGP0oh
         4hF4fuc1Dc6Dk/3ZqH5mWammphOTSvpUjJkhLohs9LPIaGJnmUOEKVIWuxF2FOkGmZ3g
         aJAl3eZ2hzU2r6hSTRKg2ZGiVNSDa6Ya6kcZmGvh3de2XgSiZ+seNawCXO06MtL7b9KF
         75lsa+27TH9WbVC0Mkk0/5PGOWVBK4W7uS2aHct8FnKFbV2K7a0kCxAuwR9p/hsW3Qgu
         mJ71Fsh+Lh4bwfhXhi9BiTPl0/7Ili+LowH8ByUBNTTMEAASEPSNfjtpT4h0/xR/F9Ds
         D1Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id t19si7371214pjr.68.2019.07.21.20.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 20:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TXSDwvJ_1563767088;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TXSDwvJ_1563767088)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Jul 2019 11:44:49 +0800
Subject: Re: [PATCH 4/4] numa: introduce numa cling feature
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
 <20190711142728.GF3402@hirez.programming.kicks-ass.net>
 <82f42063-ce51-dd34-ba95-5b32ee733de7@linux.alibaba.com>
 <20190712075318.GM3402@hirez.programming.kicks-ass.net>
 <0a5066be-ac10-5dce-c0a6-408725bc0784@linux.alibaba.com>
Message-ID: <c85b5868-150f-7114-18cd-a5e9cd55f406@linux.alibaba.com>
Date: Mon, 22 Jul 2019 11:44:48 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0a5066be-ac10-5dce-c0a6-408725bc0784@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/12 下午4:58, 王贇 wrote:
[snip]
> 
> I see, we should not override the decision of select_idle_sibling().
> 
> Actually the original design we try to achieve is:
> 
>   let wake affine select the target
>   try find idle sibling of target
>   if got one
> 	pick it
>   else if task cling to prev
> 	pick prev
> 
> That is to consider wake affine superior to numa cling.
> 
> But after rethinking maybe this is not necessary, since numa cling is
> also some kind of strong wake affine hint, actually maybe even a better
> one to filter out the bad cases.
> 
> I'll try change @target instead and give a retest then.

We now leave select_idle_sibling() untouched, instead prevent numa swap
with task cling to dst, and stop wake affine when curr & prev cpu are on
different node and wakee cling to prev.

Retesting show a even better results, benchmark like dbench also show 1%~5%
improvement, not stable but always improved now :-)

Regards,
Michael Wang

> 
> Regards,
> Michael Wang
> 

