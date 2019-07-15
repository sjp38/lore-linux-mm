Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A83C7618A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:47:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1176220868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1176220868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68F8D6B0003; Sun, 14 Jul 2019 23:47:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640616B0006; Sun, 14 Jul 2019 23:47:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5304C6B0007; Sun, 14 Jul 2019 23:47:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEC86B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:47:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so9617672pfy.20
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 20:47:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=pRIOLTj14InRChOhSXXifW2h5qvWL/LGTx3Bdv0Ebjw=;
        b=N+956R8FKo8vN/WhMZowX15aJoseAwjBPJ2YxFDNSfAtb/WxGESQypDjdPfDBKoF/E
         ggyafySL3ftUNuWSBEZ8MWE7WR6PsRuid3jX83386acjLaUTYkFBpM6cIiswErIIdkKU
         2SeHCoQSm7mbFuB67bGi5Dsb4Bky48ibwruuTdyiQwW22W4upIuazdrO/5gKXCVcAt7e
         JEKyVTs6f7GdMa06+JjQePXSpUjHYCNHRESrd8vbtv/QiEvDV7zGYVCAQc91PIdGPnPD
         bxoHdotEU4+ZqHMTYycqc+2dwwsoHda2Ajsc7teBsabt5bZ+XXbtwebcYIO+V6crktsE
         o08w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVxd3AmCSOkfvIQXaxDA3tbU4u1yRBFQkF/u2nmMUeeAyJrkmXz
	T+VZhtSNrVyp3ZZSquj6WjvFcreXGjqSKQQoXBFxDzYhOLatCq40CUeaYKoPOmU8TNMhAz+xW5o
	Tqv7jfNNVx6K1AVLt6DDQWQVorB53+jgGKZSRsUfIw7fTLHPaz1f1eOZWnIfw7DfxVQ==
X-Received: by 2002:a63:b46:: with SMTP id a6mr13843718pgl.235.1563162436682;
        Sun, 14 Jul 2019 20:47:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+0pq7A4T3INjhdnEDUglams6LX2YUqfvCWLbGLrSz6Ynq739iG1fjNHSfdaVqXbboYMrP
X-Received: by 2002:a63:b46:: with SMTP id a6mr13843685pgl.235.1563162436030;
        Sun, 14 Jul 2019 20:47:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563162436; cv=none;
        d=google.com; s=arc-20160816;
        b=r7W6wiA+H9GqQigP8WmM7+qV/mVFUvVm7DL2Iux9/qRsY/xlS6UzSfmMwSkArlPGHf
         5CLGLoqr1aj3XypZuG1SMtm2g/wciPYKgKj+Gjy9MERYSEqo6kkk0LfrgzDZSWpUsA6e
         GxjX3smeLuIB10KMsKYcXEc97LlJ/YRKVqWH4g/tNRzWibjGrEmc+7tYugncpp0IiY4c
         DpAihiSa16DqoFwja/80NKcrdaJICC/TrdhsbAYN+VC+GT/P12eaWJpqtwyjq9Kp6wX3
         df3ipwGvxTHTiMaI4X3DTCoiApSEaZT4C32eojfHZhn5veRNhXqcwv6bC2EjvztsU172
         y2/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=pRIOLTj14InRChOhSXXifW2h5qvWL/LGTx3Bdv0Ebjw=;
        b=hNikxV4d+r3IyodWRvTTFs+AgJ42N2y4pI9Ggz25Z0fte54jbzrqbiex1+P8Av6srR
         oL6mnWAU3jazl25JLsMGpAZSIRw5hexI92sAvBFRrij+oILo4xBzqXQZWqqhrg9yQ8Yl
         hOKrpfUe2+lHkwJlQTyBF5FcEKf4mp++Nq+y9vrcO2+KBgN2stfpnLrhfZ/4shk7Qukg
         ynBuaEpj5DOjB6BrEOFSM6e/CKu7pDPI4TKxixu8TipYmS7fCYhm3I86Wqjh3xMC/Mx8
         A6Jldyz+86jAYhyFcwIS2QJPu6cBFh05gGUxQdJ7hgddvRL7TuD3PzxRt7ys61kDLZsh
         Gnvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id 64si14314363plw.37.2019.07.14.20.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 20:47:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R961e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TWuAKbH_1563162430;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWuAKbH_1563162430)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 15 Jul 2019 11:47:13 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190713212548.GZ32320@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <4b4eb1f9-440c-f4cd-942c-2c11b566c4c0@linux.alibaba.com>
Date: Sun, 14 Jul 2019 20:47:07 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190713212548.GZ32320@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/13/19 2:25 PM, Matthew Wilcox wrote:
> On Sat, Jul 13, 2019 at 04:49:04AM +0800, Yang Shi wrote:
>> When running ltp's oom test with kmemleak enabled, the below warning was
>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>> passed in:
> There are lots of places where kmemleak will call kmalloc with
> __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM (including the XArray code, which
> is how I know about it).  It needs to be fixed to allow its internal
> allocations to fail and return failure of the original allocation as
> a consequence.

Do you mean kmemleak internal allocation? It would fail even though 
__GFP_NOFAIL is passed in if GFP_NOWAIT is specified. Currently buddy 
allocator will not retry if the allocation is non-blockable.


