Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF326C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 12:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651602082C
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 12:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651602082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C599F8E0003; Tue,  5 Mar 2019 07:18:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0A2C8E0001; Tue,  5 Mar 2019 07:18:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF94C8E0003; Tue,  5 Mar 2019 07:18:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55A308E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 07:18:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so4309897eds.12
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 04:18:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xZq9NSP+uns1HJmbQgaMEfPcL4auQbxIoYtYgOqmDDU=;
        b=imf4koRe1wRSpsRKT6I75sPhfsg8p5MSeIJ9uGYYBxRuLjl0qzikRAop10hG/bpBWB
         r3fOK9r2vfAvvu59JU/NzKa0Gw/y5wYlX6uPH7x6uWaVU9tbESmPn+WGgWT1Ci3YXyNq
         /CCMLpXN74pDWK82bT6SBEUI5cVGtqHZS7FcB/NrFTVbc/a+17dGCvxSJlcBNDX7lsJb
         dWzanwZCE55y/uRhv5JKe+LRU+fcoVMNOrM76Z2aobAuY4GJH3aiNVviaytP5FTDm6Ik
         zF0AmjVTvouZRfP9TZBnSOAxHtj+i8VtCcphg0xcHRU1IjdzgxEzlKx9SS1yXysZFbga
         2E4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWAf57c+BMAmlysJ7fhkbO+YBHKLyczgBnAXdsO/MCEmF6GQXvX
	EHZvpU6wizmdbVDOr0PTRTYCz93Fn5kMucvkSZfFXOUL22LxD2z1Xjqrqj9MrwZIIdryPuua1W5
	tUpaUZNahZNCWx/uZxH7wyO5FYrEQLLMtpTw68fqn1MiNfFfQ9D/Ybw0GJZR7oYjdTg==
X-Received: by 2002:a50:b527:: with SMTP id y36mr19753593edd.83.1551788288812;
        Tue, 05 Mar 2019 04:18:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqx174Cm8G9cOf5IiaDIarg4Sx/Nqe/1OFwuef4XIZRZTB4gJELiu9aN0vtwyDAgunW/+0py
X-Received: by 2002:a50:b527:: with SMTP id y36mr19753521edd.83.1551788287831;
        Tue, 05 Mar 2019 04:18:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551788287; cv=none;
        d=google.com; s=arc-20160816;
        b=aBzYLP+v6YpcZEvOKoEIouq4ygu1Y2+uBSmu0jcuBAly7eHaJxFoHNWOx3nYxP3YO0
         MxX3BY9RJltLyTXXFnYB87g1XhdPi/SPVHaCie04YaMTCnDSZXHTqB8/vwyAAx4LwXQ2
         7VhAjMOm9S0pGDotCy/CmKgD3W7LBn+jpa+q9wt6CPC7WkmB0gg0jGw4RzADjnvOHOed
         PWEUJWxdDYMi0mbW1eCmvcfrE9XHdfb9XkYmCIMKM6vpj55v8DDvQCzIY8ZRNbkpBc6A
         +bQ1+Rf9hLyapSVa1tul6/F10zinUne/sBoXPoPfArlwQ98Rz1KpTzPqJBPTHh7pLzfb
         DF6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xZq9NSP+uns1HJmbQgaMEfPcL4auQbxIoYtYgOqmDDU=;
        b=NT82MV3Tyn36ZCR/ceIabv4GUIIvwQiFGwJzTvkxuPIJVGKAQxzZod69ZTWFC7mLLf
         YPcWbAd69xmwXKZcaeTiIIesJSrP6z2+RcxuIIuR/QvT3LaKi9tgiUcQ33w3ZgGOAHPa
         1qaoDbYoMYWd6sl4HoSdyCZxtCgL2Jd+I3zit8kCf1gb2PLx3yYU3Yh4zZzHZvVyLIjj
         4Mbi0329Dgm9WGTqXea6k0h4xPQI87jLrHmPZcMjyA2iEn4qjM4e8vBgWsFDW1I6QHfm
         CMrImC84eVQDPMBzBRRCANinehUQot10tih6SNGNzwGinG6yyvGrfpBsbc1nDhP6qch1
         JdHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z34si3058580ede.93.2019.03.05.04.18.07
        for <linux-mm@kvack.org>;
        Tue, 05 Mar 2019 04:18:07 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9C155A78;
	Tue,  5 Mar 2019 04:18:06 -0800 (PST)
Received: from [10.163.1.8] (unknown [10.163.1.8])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5C73A3F706;
	Tue,  5 Mar 2019 04:18:01 -0800 (PST)
Subject: Re: [PATCH] mm/hmm: fix unused variable warnings
To: Arnd Bergmann <arnd@arndb.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Ralph Campbell <rcampbell@nvidia.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>, John Hubbard <jhubbard@nvidia.com>,
 Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190304200026.1140281-1-arnd@arndb.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <be817f74-3441-47c1-6958-233d6e1172c4@arm.com>
Date: Tue, 5 Mar 2019 17:48:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190304200026.1140281-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/05/2019 01:30 AM, Arnd Bergmann wrote:
> When CONFIG_HUGETLB_PAGE is disabled, the only use of the variable 'h'
> is compiled out, and the compiler thinks it is unnecessary:
> 
> mm/hmm.c: In function 'hmm_range_snapshot':
> mm/hmm.c:1015:19: error: unused variable 'h' [-Werror=unused-variable]
>     struct hstate *h = hstate_vma(vma);

After doing some Kconfig hacks like (ARCH_WANT_GENERAL_HUGETLB = n) on an
X86 system I got (HUGETLB_PAGE = n and HMM = y) config. But was unable to
hit the build error. Helper is_vm_hugetlb_page() seems to always return
false when HUGETLB_PAGE = n. Would not the compiler remove the entire code
block including the declaration for 'h' ?

#ifdef CONFIG_HUGETLB_PAGE
#include <linux/mm.h>
static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
{
        return !!(vma->vm_flags & VM_HUGETLB);
}
#else
static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
{
        return false;
}
#endif

