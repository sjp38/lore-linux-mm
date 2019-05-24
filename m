Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B7A1C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 599B12075E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 599B12075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8B0F6B0003; Fri, 24 May 2019 09:18:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D61A36B0005; Fri, 24 May 2019 09:18:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C509C6B0006; Fri, 24 May 2019 09:18:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAD36B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 09:18:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so14156153edi.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 06:18:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=P3WEO7XdWpPQOIQFdmlSajd36rQXTZ5LXLDFEp3QIDQ=;
        b=dt85cVCxSqrWo8sP4/ufdatCfLjXbwQNAS/NlG7s23wAVXzsBb8UceDzwJc1Oa3e7X
         fShQF7+23mJVONYCshtp963424EJokJydps6fwsz6h/Pk9tzPjDn43VQBL8N2KjO+NLe
         diJKUTq38sg2ajln3SfHPNyYe0IlboZJPM5tvczumz1u0Sh/Wt2NbQQa4rMjP9HXF7B8
         FzVEAGL7R84LGXqIJCg+hA5B/R71EPNDk1TMWJegnh+S0iXZHvIsfarp8qCquCixDJHb
         1//9fVXbDFaV9AAp/kjBr/XnLiGBRXsYmI/wr/y2QJtmzbPnpiKSIuF5tr+TD15DMshR
         cTJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWmKIFc8qMTBVVnm0y2+/DpSqjncqC4Cz1goGHJ6ezcMOx5OVTV
	cdPA8gUrmSJSUIi88zoKHa3Ix/K3dNy6oWYtIo7A6ZfE9SFn0RvtfdMXKma/5L9XUPJ57jGJ7XT
	A5SQwqKv46CzGvU0gjN5JBHW71Jclen/OTNbor2BEpSzjao2DkVS3kEmLVUHx5lM7Tw==
X-Received: by 2002:a17:906:14d3:: with SMTP id y19mr58390250ejc.76.1558703933156;
        Fri, 24 May 2019 06:18:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhuAMWh8zIxqFvVmlb+7hr+Yjhs1Rqadzqa2oE+1GNj7eslMC4ORI20WmstdCrAfJ3GS4M
X-Received: by 2002:a17:906:14d3:: with SMTP id y19mr58390182ejc.76.1558703932316;
        Fri, 24 May 2019 06:18:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558703932; cv=none;
        d=google.com; s=arc-20160816;
        b=xTTRLXSLusUgsjh0vDrNlvVHLfQ2KtOZHb5BA3GQSQEqiHO+qg2LLSwVGEsV64j4US
         V5UjqhLXqGhFUHS3JeMW1yewmgnP0DkFcUsZQBAmjFTRmKFNg/8WsuLXrDaFGokjsK/9
         TDM5LZoSM1tzcMuNAimtLMKhVfoWW3AqHO+BIJXXQUvG8HPw6X9i0tboOKSUQr7nSzUx
         Z3q8B+EVTJVVlLYdGhnHGtqxL+5OYwWzLlNz7xN2BbJplT9Tt/D8QaqOuRWChUWThyMZ
         MCH8dUKLjVcfImht5X1GGANbwsiXxbSrGarHMnT3Neu9SYDcmlFT2Euzae64xZEqFiPL
         ozKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=P3WEO7XdWpPQOIQFdmlSajd36rQXTZ5LXLDFEp3QIDQ=;
        b=HmSEx0oolDY1FRRLLjBWstmHimz2l4MnBBh3YQ1NphOnX/7VH/BQEI7pC2fQGwPDdU
         nvW/sEX3mNT+L/EhamxVxpm6oBHowK25Cr7CHHdPzRf3IiepF59kXi6pL/V3SW4EaJ14
         HHwi6Qfc+YZZ8CZxJxDoWT6uXVtQF8ZccZcUZQFU1H2I3pE4o6xe1dZTuUCh5aau9/ZJ
         mD1WWUfaqNMKN3W2VLZC6oB1JLB98pdm/U62wCWIfBW5V26l8K5dwXhUGuTkymEyaUHN
         8W74i6tk8SIiR/zn46KwAIyEXdqUwR3WRKL6wugnIwuTvMlCv8tO7C17g1E/4rlDMFd0
         rsYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o52si1077076edc.421.2019.05.24.06.18.52
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 06:18:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4539FA78;
	Fri, 24 May 2019 06:18:51 -0700 (PDT)
Received: from [10.162.42.134] (p8cg001049571a15.blr.arm.com [10.162.42.134])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A70B83F5AF;
	Fri, 24 May 2019 06:18:49 -0700 (PDT)
Subject: Re: [PATCH] mm: trivial clean up in insert_page()
To: Miklos Szeredi <miklos@szeredi.hu>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
References: <20190523134024.GC24093@localhost.localdomain>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <138635e2-bb9b-c6ec-5e00-42b0c347ec7f@arm.com>
Date: Fri, 24 May 2019 18:48:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190523134024.GC24093@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/23/2019 07:10 PM, Miklos Szeredi wrote:
> Make the success case use the same cleanup path as the failure case.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

