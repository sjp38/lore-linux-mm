Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F657C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E549626758
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:06:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E549626758
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opteya.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52C5D6B0270; Fri, 31 May 2019 06:06:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DD1F6B0272; Fri, 31 May 2019 06:06:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A4586B0273; Fri, 31 May 2019 06:06:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E56106B0270
	for <linux-mm@kvack.org>; Fri, 31 May 2019 06:06:57 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id j3so465234wmh.3
        for <linux-mm@kvack.org>; Fri, 31 May 2019 03:06:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :from:to:cc:date:in-reply-to:references:organization:user-agent
         :mime-version:content-transfer-encoding:subject;
        bh=Hjel8ftPf7fIqP7GXdPO6G4ghABoq5L1dKrd72Rx5Ws=;
        b=AuuJujZqYwQFtb00tPNGJLHzWaxfbB1HBWK07gfeIKio0ESspYLcLzOb8+T7TM+Pj8
         6bk7fL31GHZ8dBSWv67jU/8gE76xflzkX3fXsn20jGE4yCLbJWEmJ1YDXfi4BhBFOasz
         sUxe7Zj42GmHYqN8BLT1yCdiuZT5lb+jyHmjzsGQBR/LJWFqYBKpCT/W5UyJFqv14t1S
         AouihHXqqN0ZDN6lX6efBSoPIC6TbUAoqE6kPq3fTvrRfTsbr+yz19tkPlVKIFsGOanj
         HuCqfQOJAvMlVuAVI2CM/Pob+7JFk5J9QhPaEwOrXZRx11ZVrOjkV19UF7h9HlrKrjNj
         EbXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ydroneaud@opteya.com designates 2001:bc8:3541:100::1 as permitted sender) smtp.mailfrom=ydroneaud@opteya.com
X-Gm-Message-State: APjAAAWGTW0AzCVVs7k5qSMXFH9i1sYZaXjQOfGo8DCLHUHqxkEEYZPm
	DVEiUqCOtstkGSm9YrH4GBLOd8K6zHtbFZ3pMM3fIlWpxlqoEV0qg7el8puHBkDVsZlOejl9Kfw
	n7OjOWbsMGTtWYOkNe2RbYDByMa+OOYr8L7fzIPT4JUlU7PL+v45WAviYBr+HS3B/2A==
X-Received: by 2002:a5d:6b49:: with SMTP id x9mr6065817wrw.170.1559297217165;
        Fri, 31 May 2019 03:06:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyORL+6pHr8FSOe9JcV3QCWbjxoU/XtCm1F48RR6/1L1emY1Fv36pnNu3x/1w2I6DdaG3Y4
X-Received: by 2002:a5d:6b49:: with SMTP id x9mr6065754wrw.170.1559297216267;
        Fri, 31 May 2019 03:06:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559297216; cv=none;
        d=google.com; s=arc-20160816;
        b=zdw78mpkfCaWtYjWutIQ1YBm2FHoBBgV/O4OmCmrsG36+1EAyici4jAm426QGMIGkx
         L1KW0eoxmHAXP61J3+vlwlQmf24r+F+tYOCDclerjmrrnPZR/qx73XBat9GtiQBh+tW0
         gapp9gLSS2s2Iyg8kZyM1m8/bJjRjO0t5DpR8qvxlcM7ZawRpVtNlLY7IxSd8pJxbIn2
         ifkPkyWKVx5kZbkZ4BcppSq83EEhAJX+qjwZYgtX5dVytlVQQBMK+mftGqS5bth5ufJb
         YoWwimtU5fn3jiI/hC26FwtfrWn01nHcROJ/cWKvR1MQWTpQBN+lWuk+9oqC+9r9G4nj
         u4tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:mime-version:user-agent
         :organization:references:in-reply-to:date:cc:to:from:message-id;
        bh=Hjel8ftPf7fIqP7GXdPO6G4ghABoq5L1dKrd72Rx5Ws=;
        b=kcD+z13/9tl74HU8X+UarpY52A+x+NGeR21lzeHFk++XwIl+j36P+ev5Qh+U9Gg5ZA
         TG+Fz9YclCRVBrh+M/52Z+ezPHHnlZF7n0lvzm+lxMK6p+qQZOV+m9+Rz7qof9An47JL
         H175ofq4JNmL1u5vsjBYiWETNKB2avRDuiZ+2t2QYKeO4qOIoU3jzO0b8kw2SsDGxlQg
         umRg9ZxHNs8iOQgzeTONILk1nTiviW8pmHsjx/+z7zuT05EPLCr+7BsQ/kxARUqIVCYk
         OdgUZr3T3mNkRV5OIk9X7uc8kJjrn8wZuMh2osss1080OYTrZYntA+oMYFJTh+26ji2o
         KknA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ydroneaud@opteya.com designates 2001:bc8:3541:100::1 as permitted sender) smtp.mailfrom=ydroneaud@opteya.com
Received: from ou.quest-ce.net ([2001:bc8:3541:100::1])
        by mx.google.com with ESMTPS id b4si4057004wrv.404.2019.05.31.03.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 31 May 2019 03:06:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ydroneaud@opteya.com designates 2001:bc8:3541:100::1 as permitted sender) client-ip=2001:bc8:3541:100::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ydroneaud@opteya.com designates 2001:bc8:3541:100::1 as permitted sender) smtp.mailfrom=ydroneaud@opteya.com
Received: from [2a01:e35:39f2:1220:9dd7:c176:119b:4c9d] (helo=opteyam2)
	by ou.quest-ce.net with esmtpsa (TLS1.1:RSA_AES_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <ydroneaud@opteya.com>)
	id 1hWeR2-000GJh-Nm; Fri, 31 May 2019 12:06:52 +0200
Message-ID: <2fd5d462449f24b04adad2bbdf0e272647e62247.camel@opteya.com>
From: Yann Droneaud <ydroneaud@opteya.com>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
 linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner
 <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, Joel Fernandes
 <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, Daniel
 Colascione <dancol@google.com>, Shakeel Butt <shakeelb@google.com>, Sonny
 Rao <sonnyrao@google.com>,  Brian Geffon <bgeffon@google.com>,
 jannh@google.com, oleg@redhat.com, christian@brauner.io, 
 oleksandr@redhat.com, hdanton@sina.com
Date: Fri, 31 May 2019 12:06:52 +0200
In-Reply-To: <20190531064313.193437-7-minchan@kernel.org>
References: <20190531064313.193437-1-minchan@kernel.org>
	 <20190531064313.193437-7-minchan@kernel.org>
Organization: OPTEYA
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 2a01:e35:39f2:1220:9dd7:c176:119b:4c9d
X-SA-Exim-Mail-From: ydroneaud@opteya.com
Subject: Re: [RFCv2 6/6] mm: extend process_madvise syscall to support
 vector arrary
X-SA-Exim-Version: 4.2.1 (built Mon, 26 Dec 2011 16:24:06 +0000)
X-SA-Exim-Scanned: Yes (on ou.quest-ce.net)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Le vendredi 31 mai 2019 à 15:43 +0900, Minchan Kim a écrit :
> 
> diff --git a/include/uapi/asm-generic/mman-common.h
> b/include/uapi/asm-generic/mman-common.h
> index 92e347a89ddc..220c2b5eb961 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -75,4 +75,15 @@
>  #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
>  				 PKEY_DISABLE_WRITE)
>  
> +struct pr_madvise_param {
> +	int size;		/* the size of this structure */
> +	int cookie;		/* reserved to support atomicity */
> +	int nr_elem;		/* count of below arrary fields */

Those should be unsigned.

There's an implicit hole here on ABI with 64bits aligned pointers

> +	int __user *hints;	/* hints for each range */
> +	/* to store result of each operation */
> +	const struct iovec __user *results;
> +	/* input address ranges */
> +	const struct iovec __user *ranges;

Using pointer type in uAPI structure require a 'compat' version of the
syscall need to be provided.

If using iovec too.

> +};
> +
>  #endif /* __ASM_GENERIC_MMAN_COMMON_H */

Regards.

-- 
Yann Droneaud
OPTEYA


