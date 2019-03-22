Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EDA1C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:16:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C095920830
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:16:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C095920830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56BC46B0003; Fri, 22 Mar 2019 11:16:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A2E6B0006; Fri, 22 Mar 2019 11:16:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A646B0007; Fri, 22 Mar 2019 11:16:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C265A6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:16:50 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id t9so729015lji.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:16:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ywL9z7ntA6u+x6YmbqlJFZmhar9s03dzPgwmh4x78os=;
        b=syvrHSOgE2SIZpaYb5nQv9VflBCpN8AJdN9UIKMmZFtDn9zMJIpADh1Ib/NQ9JDMH7
         uG0B9XHdjr5L4jGQuFGJPfG5VIqccEa+DsH1DFpKHXxLH+ZbO+huf8+DBm0ZCyd4sZg+
         yHn819IMaWcMVDLy3ZpFOhXbCbcWyybWy54gElburTA7Q7IQG7NcscS+Keagg0hnBCu0
         nU+yTpWC18SDYDKbONi/9wE3JyNaG98jjTu196iWzziYYM5NOkFmtExwWvC2DPHWKyHJ
         WhfFqySrfvWT7QeUnS+yiRLdxZob+dsYwGjrYytcbAyoJQb+siJYpEvBipbWy9WKyUMW
         +8nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUNXTMxukN/jNouF2028s428Mi7qS1bf3OQkWazwKWzO2YdFcuW
	EYr56lV20nQb4fwgxclC2jnG0/w+SimxGBNYR6kFViT+xvXxy7mkdqD69fbfn+q5XNtDRyTZ234
	qqN9go0o26ksgZT+6+s26RPCnBMgUm/DpDvTTXteyu4TJHpTNStsE81RGGYNO7iZq5A==
X-Received: by 2002:a2e:9e9a:: with SMTP id f26mr5483747ljk.67.1553267810053;
        Fri, 22 Mar 2019 08:16:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhxqmp8vIivxiCZgX6MN2vhscDU5hU8FobhrtKhJVVNdpLWpdTtgIiPuI05Bbl1HGtdXvt
X-Received: by 2002:a2e:9e9a:: with SMTP id f26mr5483705ljk.67.1553267809095;
        Fri, 22 Mar 2019 08:16:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553267809; cv=none;
        d=google.com; s=arc-20160816;
        b=EkxxHCJvaR8XAu4gwUhAva6WQq+VROJd5j1uNUg1woXftNoxzqGOTsB74Fmdc4mVID
         ap5gkZCwByTreEE0QASwymNGogJ2uexVEPKLSTGvtFv12uqB4j3K39RMRgWj+/lUAnSy
         z55UyN30oWYM/0D6jbxmUsy9mTpejx5+hhjzi6f4ZYS8OmKhx1hJP5DWGoGVgMJ+MfyS
         kp1dEip/wfz5bmgIIB12++dWWTD69wN/IY0M0KHxNrCVPaa2+dRiNitaMThJyZ+8dqmL
         6LFgMRTz8e7VpcVgJIjeyGF31H7yhspzTaLu7De8yp678lIM56XpgI62gwD7Oqy1bYdF
         k/MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ywL9z7ntA6u+x6YmbqlJFZmhar9s03dzPgwmh4x78os=;
        b=ad9p3yhILiTbjgHRagLSO5gmm6nBXzjy1nWKj3VEPLmZx3PEdnCxz0c1PolxA2Xmil
         Ku94Y8LyQav6U32tAB7dJkTZBhF/gK4yeDfcVApcB5061P+9ZbhRwqrODM2NHiXkwRoI
         o3Fksz4G/qCK1xkftdti8Sy7ptfupW0eH/KOXGqtb4UiuMX2bF22xAtUsMqvTPIoxS2Z
         Yl2QMn/FB0gpMxf+rl7Ax/28Floh6XQfz+BkMOhfw2gaoc00ZcwJPCkgE7ox7BZN8PiE
         GKsgQf8EEspdwWo28Zl9QVSxLSH7zwm1lzQ4HorftYI4nvyWVYFGOaibjBlcxar/TQ4v
         Ag8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s25si5862105ljg.183.2019.03.22.08.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 08:16:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h7LuX-00037y-LP; Fri, 22 Mar 2019 18:16:45 +0300
Subject: Re: [PATCH] fixup: vmscan: Fix build on !CONFIG_MEMCG from
 nr_deactivate changes
To: Chris Down <chris@chrisdown.name>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org,
 kernel-team@fb.com
References: <20190322150513.GA22021@chrisdown.name>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <bf777760-083f-4297-9805-b355c65ab080@virtuozzo.com>
Date: Fri, 22 Mar 2019 18:16:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190322150513.GA22021@chrisdown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.03.2019 18:05, Chris Down wrote:
> "mm: move nr_deactivate accounting to shrink_active_list()" uses the
> non-irqsaved version of count_memcg_events (__count_memcg_events), but
> we've only exported the irqsaving version of it to userspace, so the
> build breaks:
> 
>     mm/vmscan.c: In function ‘shrink_active_list’:
>     mm/vmscan.c:2101:2: error: implicit declaration of function ‘__count_memcg_events’; did you mean ‘count_memcg_events’? [-Werror=implicit-function-declaration]
> 
> This fixup makes it build with !CONFIG_MEMCG.

Yeah, thanks, Chris.

> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---
>  include/linux/memcontrol.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 534267947664..b226c4bafc93 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1147,6 +1147,12 @@ static inline void count_memcg_events(struct mem_cgroup *memcg,
>  {
>  }
>  
> +static inline void __count_memcg_events(struct mem_cgroup *memcg,
> +					enum vm_event_item idx,
> +					unsigned long count)
> +{
> +}
> +
>  static inline void count_memcg_page_event(struct page *page,
>  					  int idx)
>  {
> 

