Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 637B5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 06:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 235792183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 06:54:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 235792183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5F316B000C; Fri, 29 Mar 2019 02:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0E0E6B000D; Fri, 29 Mar 2019 02:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FDC76B000E; Fri, 29 Mar 2019 02:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5115E6B000C
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:54:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so587390edo.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 23:54:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=pOJFoJonfWtNPBHwpfk47vSoBEstbsrtygsePP9eGLk=;
        b=ZHIakUnLbDxsM2tNFiSjDt+hBCmzHrzc1R8AYivIYSdlZ1dKm7u9dUjBcGCFLCGGUy
         lEXa7btTXVPztBI/QbgTPEOIdYieNe43iq995h3vHg4PtdsQVf9BbbXhR3hqNO0zN9PD
         thowx/Htsz9+EqqGFap6nmD87yF0LQSfR/U9fUhjMBLlFw83iYvpS0nDsg2TbYCGeQfn
         UkJylrZyxtpDOiCGhvTnYTQTBS8dpqWCcATzvZaXyotCvEcWch32R6zrSdCsbsMGYR9+
         mYSzbgz0zzZ0arIMZEOLeie4LChfRMSzbYKjHKwqaGU5qe5mu2uadXVgKzdP/kZUxBmq
         PO5w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXS0M2Cs76E6GKqnOJDTSzQQO1kPp/ZHNz0yihXbxK0dR1k+9Uj
	bAcTNatyAsvka7tmM+IlyhLdI8YCM3dteY8APg7Bv3mhii/RB4c7PhClp4Xi1L/mJveZEzAKTLt
	wF+kdBsTGcMxVjFJQYFC5/soQhbOMPif7/J55nvDZT2+/WjvhOmYnzK2ZGGyTQYU=
X-Received: by 2002:a50:9485:: with SMTP id s5mr30072579eda.223.1553842478886;
        Thu, 28 Mar 2019 23:54:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWd9vTWrPCbKsKlkPajHoOAIFB5fyCoXgqp7RE8YCifGSIJrRprPAjBrxfiGosc5S2r8SX
X-Received: by 2002:a50:9485:: with SMTP id s5mr30072547eda.223.1553842478158;
        Thu, 28 Mar 2019 23:54:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553842478; cv=none;
        d=google.com; s=arc-20160816;
        b=UU6x1aLZrKQzoLs6C7LZuB2akm8UG6I3dkTJR3Q0/2LaJdilgyXTy9X8F7wmo1Sz50
         3FaEBN9tCPGHbfhKMqp9sydWm4vHlOX9mAD4l1f35oZ3H8ff4eoiS6+9mCZQMpwJiAPX
         DVhPC4MXbAB6PqsDSIcJrVdgjVSqO37ci/L10A5pRnJ4W78MfcU+KHh822AaKy/mB6Xa
         B3Pvd77CLr9TwO/kms+WHzjc6vVmXqKmQBzysODietkps29A0xJa4j//aN6uahUb7HcZ
         igDyZLOrNmm+7PCHeKGUvDs/mkpiHZkUlHpeJwvLMRHg6xoW5r22n/6QwwMUPR46USp3
         vI6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=pOJFoJonfWtNPBHwpfk47vSoBEstbsrtygsePP9eGLk=;
        b=Utwvv/JB5HjgB5DFbwrKUWW5Dy5s8HMQ20wMeGbwVCHQa7Co85+qEUDE4qwuXaFhe+
         DoGvxSwPW08YSzwbaKYWwKQ7VdMI2TC+KG8hjZVNDUCsqHXAh23AqP8sYrJoRHxKrwNy
         wIdBnGRv43Kr5Q9a0fOixGRdegwYVytgOAshMDCleQLjJAFF523TH6PljqkQPxwXwLKf
         5WaEb4LtDwQrzFB5C7nMVCh20oUJY8PkGhIdsVtsXSTx2VUvEuBpluBSlO+elZWSWjum
         Jht8atSFDMdETV1cWHJ4Kr+E8G6H+fmKHvkAMu83xemB2KL/n/0nWfeBNzs7FLNxu3gd
         zQRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id l19si518495ejq.281.2019.03.28.23.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 23:54:38 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id D603320000A;
	Fri, 29 Mar 2019 06:54:27 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: aneesh.kumar@linux.ibm.com, mpe@ellerman.id.au,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
 <c6a93f46-4d8a-e7fd-3f39-4c3c5a9ed514@oracle.com>
Message-ID: <206f6cc5-51a8-05cb-0d4d-4d07bbdadc7d@ghiti.fr>
Date: Fri, 29 Mar 2019 02:54:26 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <c6a93f46-4d8a-e7fd-3f39-4c3c5a9ed514@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 4:43 PM, Mike Kravetz wrote:
> On 3/26/19 11:36 PM, Alexandre Ghiti wrote:
>> On systems without CONTIG_ALLOC activated but that support gigantic pages,
>> boottime reserved gigantic pages can not be freed at all. This patch
>> simply enables the possibility to hand back those pages to memory
>> allocator.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
> Thanks for all the updates
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks for all your reviews :)

Alex

