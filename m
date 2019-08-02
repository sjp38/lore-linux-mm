Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A463C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 059F6206A2
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 059F6206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9D6E6B0003; Thu,  1 Aug 2019 23:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A28E36B0005; Thu,  1 Aug 2019 23:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EFA96B027E; Thu,  1 Aug 2019 23:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5566B6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 23:37:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so46132115eda.2
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 20:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dj8To32GNozkdDcD7uBRLcebbsMWwJlpoJHR1dabDtE=;
        b=WILrufSFmA62uSrliGi4NX+/tyu513Jxpr6Rrz0uFVEs/EwTZ1bBorAMJYszv/+2P7
         m2vbd/lY0yoVEKBupViS9QVmS/ipkuSRO+BlQJ92iEou9tseXrnlDAk3MctyTatUQY/G
         OW9sdx03LsDEL1/iiJyhSxGkv6EKmlh9y4lthdtW/2AGAK5FizaaurZce7lHb4IoJcvH
         F4UAg7mR5HcZ7B68YIyshOh8VDp5rGBsxEDwH/vqiNOu1w8/i6o9Wuo49cfyKq7/rWYr
         PsbTN68I3R/R64yWGQ/csSJKFRi0ND4lXwPHNM8XaG6vq71QI95bcAzUNzIZ4fL1QZZb
         aYfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXhgr+ECEZbvvrAHBA3fr6T0VchDP+5DeKS54nXBQ97jKli9wKo
	Rmmbjh07RCF1JasCXyJxh9yOxeV9Jlux7ajltI12p7pgVWzY/s6ip13G0npPCbO9zQN490IDD7M
	JTf1f3rbgCjwjq2czkhmpYXCtjXZb5lZ0k8pDxZ1vpdTHwBJbmUkozowq5yIUMgB+HQ==
X-Received: by 2002:a50:c35b:: with SMTP id q27mr117432229edb.98.1564717037899;
        Thu, 01 Aug 2019 20:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmsqnF/tekTQfD5GriX+Xy7yngHKyvH8WkWOCITQI6zIc1l78DNO6Je3Y2wMcblbEnWwhO
X-Received: by 2002:a50:c35b:: with SMTP id q27mr117432198edb.98.1564717037117;
        Thu, 01 Aug 2019 20:37:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564717037; cv=none;
        d=google.com; s=arc-20160816;
        b=zH/W2IFs4FJvsHevL/NznKaKDN6eMvltZ9SW86xEDyDMkQDvzsDE6o7peI3dZEFof2
         ZFdno694wSgJr3l8wuBu+1MQpI/Ley+H/oSQj8Ua0YuXkksHsVfypnJuPwY+VS8Xysdt
         poOIcxEHvI5xWHEqQV8pOpWTV63h3PuuFIt2QgaMbifrD5oHlM/xlD1JR8RPNoLd8f5E
         kF6soA+YpZMINk+ehV1xTmZcsXFVy5iCUD9WfGt2Mo6yj7S6SLLhsbRSwytpmLLPfiw/
         phuzBCyUo64VQZRllvvAKhSLIt7ME19twCY1JXj0PIsFcl84LuMa0SGw9pdbU5mylVqR
         kf3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dj8To32GNozkdDcD7uBRLcebbsMWwJlpoJHR1dabDtE=;
        b=fRlICosvhnEqeKS6TRChryZbnTXuQkUzjHujH/KuQHY6DyrukhH3tN6omJDn+ysvXI
         57xqrNELXXV9MaI9Cxl1lxktBxU85YhqLCIIisrk4vLVcpLwo20qFmcjKHyIVSPbyJFl
         k5Taa68r489n+g/GuC/DgEaPNGo4r56hZSjzUQDkQhj7p2HRWXQHWOsFY7TzYrgvb474
         1csrM1rKEj+9rudohwUgN9yMA3Uz1M+JqUfswRi6pSFuZslJwhqny3szIs82qtilzOW6
         83D7xfdqDG9p9llW4o0oYye4TCg9iOS0ZKl6O52DwvAt3458IlE0YK+0XAw5uULx+y3m
         Ckrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b5si23456641edb.259.2019.08.01.20.37.16
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 20:37:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2A7C1570;
	Thu,  1 Aug 2019 20:37:15 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EFD503F71F;
	Thu,  1 Aug 2019 20:37:13 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: reduce code duplication in error handling
 paths
To: Mike Rapoport <rppt@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1564640896-1210-1-git-send-email-rppt@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <aeb49e1a-5a21-57bb-04b8-6439620d12eb@arm.com>
Date: Fri, 2 Aug 2019 09:07:55 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1564640896-1210-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 08/01/2019 11:58 AM, Mike Rapoport wrote:
> The madvise_behavior() function converts -ENOMEM to -EAGAIN in several
> places using identical code.
> 
> Move that code to a common error handling path.
> 
> No functional changes.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

