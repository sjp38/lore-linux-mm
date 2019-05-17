Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 157D8C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 06:44:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C91F8206A3
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 06:44:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C91F8206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A26D6B0005; Fri, 17 May 2019 02:44:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 579BA6B0006; Fri, 17 May 2019 02:44:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 468176B0007; Fri, 17 May 2019 02:44:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED3556B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 02:44:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h12so9084791edl.23
        for <linux-mm@kvack.org>; Thu, 16 May 2019 23:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YmGK8JduJwg65c/pejZ0jkLmyfYiQXzVq3PRHPoCd5g=;
        b=LlGpPxH1JuD56+NjiL4tLvlSgBXdCHWO46/2XGQ98RjDT9PDuTgx6vCBuyqbB2KL/M
         4BK1bxdamAdW8YAJNA4JuXJwDicHdjzi8V6AOlVUwYyKxP7tTT3vAU/h8y88zGDgjbV6
         Koe5UhYUUAlSd6OKbF5s5ZSPkd6GQcVzyTsm2Tf/pmL/Lu2ug8cK/IfzE6hz8wWcHRhO
         s4IE88SIEw9Pk5C6GyMj6G4aBCSCv61d5A3cwOlk5T5MBvAFBEvNW51h5v5AG3ZoLSAb
         RpCWbbDlESpLe2rG0soYnf9n/FnZ61wS2l32vN1DlFXfHlLANbTOUbOuzlcf8t+c/9Mo
         MzVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXT5X2m6wEm1rzDhYPUdOdHQILoGHrANMPu8UVQlCX9ee4g64Y6
	LTRtixzgV9vZEJfoHSwRIcDW7CnMMaLYRPw75kP1niDHfJrOCWomJ+tPppnfequdluze9QNhPhP
	q5ZY4vA5DNugvjBN2xQ2uRYSfQ92GtI3tv5gVbNH9pxyEjYUYLGl9ECh/VEO7ux/WrQ==
X-Received: by 2002:a50:a535:: with SMTP id y50mr55844998edb.249.1558075446550;
        Thu, 16 May 2019 23:44:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyubYPl5Y4pGFJZrJkWKG2LrSMwqU+lzYfhLmBrMIlL8+VlX7RfMbTzKLlTw3w+kW08hWuX
X-Received: by 2002:a50:a535:: with SMTP id y50mr55844938edb.249.1558075445776;
        Thu, 16 May 2019 23:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558075445; cv=none;
        d=google.com; s=arc-20160816;
        b=DAi6iyjzSgEzYPxRLV7GW+DwDmVNLpoKmjsOKyZTsNmdkFK2M9TsoHloQNJc1MQAQa
         7HtkBrloIaSv1fWazYrvwru1X0LJAPZ2wGqF9+4FhkUOxwTokAX/eF9yVrwhSnZ/KwSG
         q57kXXnuDvFUxaVwhmKNH5Y9I54otgTCO3QOgDqcATWOn0s4GOafcCRC8pGZp6tHFEO0
         xnmZMsP6sif9m+hzbjjdrYdKIOhnzdpqHZdzbkNAN6BgTrZl51D3m+xYXN7FBswDhtPF
         YimLYM2gFivIDlxyaFiCILmPGBBOsG+/olXXBdRczrcmCwQ6aG1bLHTXUGB/MA3T88Qk
         sqUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=YmGK8JduJwg65c/pejZ0jkLmyfYiQXzVq3PRHPoCd5g=;
        b=b8uYR2gZ03FieYaDfzGEPwuT4/ba10VPh5UyN7y3HEfsYZ/R8qoISiS5O3rhaXEp/A
         X4NqNmZqnEPAD3IpH8P5a5XLpjut+qP5Cz9cfYTQzLei0ng8eoljdCnG91x4uIy5Vf5P
         NhV/rgpT52SsCFZbuJznxAdWjCPHOKVm7cgO9paU0+B4LyNQ0jv4d5fipMEY3yiLUci6
         UCsgzSofIfdH+HCReiv03VhGekkcxxnr2jVua5FF/zdVy5trQ3ApnEGe3oH7aT0T8RCx
         cagNIGPHR2CjnO5yLYTqxNYZxML0dJ11Kz3wp8ByuzRdNATRLoUMD3q6dqvnzoBHQHlI
         JW+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si5017589ejm.141.2019.05.16.23.44.04
        for <linux-mm@kvack.org>;
        Thu, 16 May 2019 23:44:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D56E915AD;
	Thu, 16 May 2019 23:44:03 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 71D183F5AF;
	Thu, 16 May 2019 23:43:58 -0700 (PDT)
Subject: Re: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
To: Mel Gorman <mgorman@techsingularity.net>,
 Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Bruce ZHANG <bo.zhang@nxp.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
 "vbabka@suse.cz" <vbabka@suse.cz>, "jannh@google.com" <jannh@google.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
 <20190510184900.tf5r74rtiblmifyq@ca-dmjordan1.us.oracle.com>
 <20190513085304.GJ18914@techsingularity.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ddaeff3a-3de3-2969-9ef4-9bf0b2db8e8d@arm.com>
Date: Fri, 17 May 2019 12:14:08 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190513085304.GJ18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/13/2019 02:23 PM, Mel Gorman wrote:
> On Fri, May 10, 2019 at 02:49:00PM -0400, Daniel Jordan wrote:
>> On Fri, May 10, 2019 at 12:36:48PM +0000, Bruce ZHANG wrote:
>>> The "Free pages count per migrate type at order" are shown with the
>>> order from 0 ~ (MAX_ORDER-1), while "Page block order" just print
>>> pageblock_order. If the macro CONFIG_HUGETLB_PAGE is defined, the
>>> pageblock_order may not be equal to (MAX_ORDER-1).
>>
>> All of this is true, but why do you think it's wrong?
>>
> 
> Indeed, why is this wrong?
> 
>> It makes sense that "Page block order" corresponds to pageblock_order,
>> regardless of whether pageblock_order == MAX_ORDER-1.
>>
> 
> Page block order is related to the PMD huge page size, it's not directly
> related to MAX_ORDER other than MAX_ORDER is larger than
> pageblock_order.

Right.

> 
>> Cc Mel, who added these two lines.
>>
>>> Signed-off-by: Zhang Bo <bo.zhang@nxp.com>
> 
> What's there is correct so unless there is a great explanation as to why
> it should be different;

Agreed.

