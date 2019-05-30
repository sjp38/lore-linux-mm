Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BA4EC46470
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:20:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 019F22596C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:20:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 019F22596C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F9DF6B026E; Thu, 30 May 2019 09:20:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A95D6B026F; Thu, 30 May 2019 09:20:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7711E6B0270; Thu, 30 May 2019 09:20:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0A46B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:20:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g5so4563352pfb.20
        for <linux-mm@kvack.org>; Thu, 30 May 2019 06:20:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=FRwX17U44K4DSIcYi4xCD768jM0gNRhEMGshqeDBuTc=;
        b=kli4vneFR8JOf/2RG35Nti0nIzdKRYiaVGPRy7xJvFPK88wMfRGI+h7flQe1CeVchh
         Jkk0WWLBEBpU7EMUK5BBHc7JnXK9o7R+aHnQppzQrUxTazaBWGwj2/MigozEefMPfT9m
         GUtTsG/8nTVZGAaCzkVTjekRHIHHpIprdrO9wBM5jRd6mvSKoZY3hLDmpipdBRASypVp
         iUVOl5HhcL4hrij6hPu2V1Vpti1NnDObmy+n7Ivr629lMbS5vqrsMLPIB9XgesAF47XM
         G3cyiaQE/xgknlhnQneTdPbRVnipCnwEmrk4ttmtIxlFiTm+yde6w7B/5sgzGhESK6oU
         t9Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVSMdw/enxf8lbiyFaM83UaDEkf+YI4bseVWIYRvTaLejA5Pusc
	AvW4iluRDbjeiNibp46EmzaXMBrghlC+ncf8XjaqB9cIBtZ10O0IgcYMx/ji+xpoXag5AZz+dcN
	0JY8Us1dHNFyKrFdB36N6fNmwmHvcdXp45tHcRXT9NdfQCqBfx45LFGrpq8t2sOpSgw==
X-Received: by 2002:a17:90a:840c:: with SMTP id j12mr3440478pjn.23.1559222417930;
        Thu, 30 May 2019 06:20:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvZT19OdtW0CXSPeY4WOIYpJ1hql5FPa6uHZXYYfD+fMINOIq3NS3bL+LEgrOBfZBRXnf0
X-Received: by 2002:a17:90a:840c:: with SMTP id j12mr3440402pjn.23.1559222416959;
        Thu, 30 May 2019 06:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559222416; cv=none;
        d=google.com; s=arc-20160816;
        b=uoS/IKIbztZWOHtVbPNAmIq9JN2nal/edN/SxoTObyTIBzQ94wsEKh0dMRTSd/FPq6
         1ri48332+nO/jcMNcvIjQ5sBjCkYfM2zCMz3Wq1Qkn5OD9jB36kd6InbgDv/sYd5oetK
         VWHH8/qKlkQrmH51c6IZ8ecFejgQ8IlpWAs9/q0IeVAcWHRT58dW7RnFTeSBxwe1RLk8
         zqaquYryx7u/QinunaYxQJA7bf6Bi47nh1KCYcCptLmLNnCwDOe06nv6kzHOQSD2d+6k
         kP4V+qBe7TCIbumauN4qe1y2x0q8zOFW7TV3X5i7qLDGBpCzYNZWly8GhBmM4x1LuyDa
         aHgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FRwX17U44K4DSIcYi4xCD768jM0gNRhEMGshqeDBuTc=;
        b=VXqucxCOia6AuHmM7vpr7O9gEabuU24eRG10k5HeqrOTV26nhDA4dYJWeO/0A6jZfG
         cRLrDbdD6Blpw1cCXA6vHBVKVgOXNNowKpHmIilPEaQNh9dsh5U4kFgrscZtB58G0T88
         cDXQ4UzTaz2+B6IXS3bf56KfSckUc4enf3w2jpPUTHzu/MeXgHmCfXcsV3yAWZqfaTrf
         floe0iZuy/Bo9hcARcYf7BnuUdoBQmgVjnAtday1OEBFM61DnK+eM7KVRNk4KX+CpQIJ
         koJ3/gcUDti/5z56u5PyeiRqroXHOJ5j/rLzsR1SZKmIIcJuw5W4UjiyUNNepu2ba8vz
         5hXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id h65si2907586pje.26.2019.05.30.06.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 06:20:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R671e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TT0Pbqg_1559222413;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT0Pbqg_1559222413)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 30 May 2019 21:20:14 +0800
Subject: Re: [PATCH 3/3] mm: shrinker: make shrinker not depend on memcg kmem
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
 kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-4-git-send-email-yang.shi@linux.alibaba.com>
 <20190530120820.l5crrblgybcii63f@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a19af445-8830-285c-2fbc-a5425ca06a6b@linux.alibaba.com>
Date: Thu, 30 May 2019 21:20:12 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190530120820.l5crrblgybcii63f@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/30/19 8:08 PM, Kirill A. Shutemov wrote:
> On Tue, May 28, 2019 at 08:44:24PM +0800, Yang Shi wrote:
>> @@ -81,6 +79,7 @@ struct shrinker {
>>   /* Flags */
>>   #define SHRINKER_NUMA_AWARE	(1 << 0)
>>   #define SHRINKER_MEMCG_AWARE	(1 << 1)
>> +#define SHRINKER_NONSLAB	(1 << 3)
> Why 3?

My fault, it is a typo. Should be 2.

>

