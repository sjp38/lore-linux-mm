Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5969C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 03:19:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D467218DE
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 03:19:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D467218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF7E88E0002; Sun, 17 Feb 2019 22:19:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4D68E0001; Sun, 17 Feb 2019 22:19:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6DD88E0002; Sun, 17 Feb 2019 22:19:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4A08E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 22:19:46 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d9so6537030edl.16
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 19:19:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ubo2RQYJ9A67uvcCS6oA4U8l4AKMOCFMRs8mhIlLBAU=;
        b=ZH4Lr9ZCLKv7LIT2inZ2oN9IA8nygNn+t+QRx5u8E9qegkRBQrCP+vhg02hZRCBUGD
         tgaf8phFnZ1EubDWbltIZwMK0FgGZogbmO4lW+v77uohMI0bq41oSzo8v2m957ojbjTE
         EFAAU681PSHxlGH0vXdayPkRw7zu8EtZzA8A9IQE5XkbT6gsi5RwYhw9TC2ykfKXuNnW
         S6iMw7N5ygS5M9xmXAjhKaN8if9fV1ra6ILkqiBELQp+wAhiVqQgYVi8whrqqfBYYDOD
         l17E+xRPamM/dslmuBswXcTuGc8pwYa7ksefarLbsjvfWGAQRgVDSF0dUywy6BFa1Elj
         BEUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubYORRibYlMM/Q/RLZLIsslJjrMRA6bGlf/Z/SY7smCSmZgD6V/
	T2GmAHjs//GKMkMi/9lqbjBIeb2dws99rwGABwlHIz/Y4GylnWuh9hj9MtwhWLCouyHa4uniBo1
	0WX1NEZAASLWFZNMvfkIjmksbx2PGOwpYugRABNSvRaJiBTYTmkxebQzfn7iMrvvESQ==
X-Received: by 2002:a50:b7ad:: with SMTP id h42mr17326232ede.210.1550459985830;
        Sun, 17 Feb 2019 19:19:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKz8c4j1z5GI5lPwY83T6voYlyjnMHi+k1Yg42NCb4Yfksl0BV27nznCJHdvAwD2OrY6PL
X-Received: by 2002:a50:b7ad:: with SMTP id h42mr17326205ede.210.1550459985008;
        Sun, 17 Feb 2019 19:19:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550459985; cv=none;
        d=google.com; s=arc-20160816;
        b=D7uVW99ZLUD81eP0OBavF3TAke3EA4WYX+wGG8DUzRfMLAn5Ypfn+xdMaXVF5co+q0
         qbyboDcpvRpRKlGmtVfv6zYrHxQHZ6EDp1OTW9YVgi+k554hRATbLGI+VNeK3tdUYktW
         +uOJxAxnhYpl41Hb0nixjlausri3qzE3EXvxN8gQ7jzfs7HT6o0MgnU/PXbD8ubUYnYd
         B5T6DvV925nVwujA4OZk0PnS4BwAYNrQKm3O38YL9vlL2+js0weFNEMWi2uDM6BAayyZ
         ImcZI9oDiiUrHGSWZ38oxpLKFvmBLM8CdwjixtvigELiJBvsiiOTmTRZNBroqK9LRghS
         z+cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ubo2RQYJ9A67uvcCS6oA4U8l4AKMOCFMRs8mhIlLBAU=;
        b=HXo0xs7Ll+c7WMY83338trrR1hJanR3JQ9KrP5rnXsL4jynAWPvz6hGpMEMN+A8/CI
         TdOxr6qtBE711gq4obOTR/6pwEd1lKf5vayIVRRV4YGiP5k5P/FrjCqmHA8uTE5rRhZM
         nWGnqJC8Eg6Q4Ry4ecs8hMZIHyvYwraZpGUxDBZKdXGQId6g9vF2PyEL+/KuAYZaOK26
         SBIm7qhqSQnAmDUDowR38llzqGoy3gG6+qT0yz4N9H+bbONR0wLkJ/QSQtR4PT5evRTS
         1Sf6RpqVH/g+2HB8lReDlU9GPhxP5WeNmwqvtJh8IYfTnPoo6rh6ARSfDytXEYlDsESh
         McTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a43si1175190edc.406.2019.02.17.19.19.44
        for <linux-mm@kvack.org>;
        Sun, 17 Feb 2019 19:19:44 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E3F6E80D;
	Sun, 17 Feb 2019 19:19:43 -0800 (PST)
Received: from [10.162.40.135] (p8cg001049571a15.blr.arm.com [10.162.40.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C48BF3F720;
	Sun, 17 Feb 2019 19:19:40 -0800 (PST)
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <92390cc9-3116-7b80-c2b1-5a7d29102a25@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <9ffc76ed-de95-fa6e-35b0-c0f2731ab0c4@arm.com>
Date: Mon, 18 Feb 2019 08:49:43 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <92390cc9-3116-7b80-c2b1-5a7d29102a25@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/14/2019 09:08 PM, Dave Hansen wrote:
> On 2/13/19 10:04 PM, Anshuman Khandual wrote:
>>> Are there any numbers to show the optimization impact?
>> This series transfers execution cost linearly with nr_pages from migration path
>> to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
>> is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
>> HugeTLB and THP migration enablement on arm64 platform.
>>
>> A. [Normal Pages]
>>
>> nr_pages	migration1 	migration2	execfault1	execfault2	
>>
>> 1000 		7.000000	3.000000	24.000000	31.000000
>> 5000 		38.000000 	18.000000	127.000000	153.000000
>> 10000 		80.000000 	40.000000	289.000000	343.000000
>> 15000		120.000000	60.000000	435.000000	514.000000
>> 19900 		159.000000	79.000000	576.000000	681.000000
> 
> Do these numbers comprehend the increased fault costs or just the
> decreased migration costs?

Both. It transfers cost from migration path to exec fault path.

