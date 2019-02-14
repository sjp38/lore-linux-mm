Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E228EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6BFF222D2
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:52:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6BFF222D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 226EA8E0003; Thu, 14 Feb 2019 04:52:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D49F8E0001; Thu, 14 Feb 2019 04:52:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076ED8E0003; Thu, 14 Feb 2019 04:52:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF328E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:52:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so2197100edt.23
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:52:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=qf8tV+OLTvvfDB6K9fe0Z04/CovSwO3s0qE34ZkDNQ4=;
        b=OCHY2jrzbBSjYyDkubq8f23AXme2uxaCwAizVtlI6XQMf+MszBw2LRIndGZeUfovaV
         cjSRZYENrhhN5bEQERP7SiCbZWWYigXe6DG1PR3AZ2VHIhcrshZnlCV+0mOuQVGBDZ2I
         W0dVPq7ex+FREVfhnjKTxYlkdwJghZIeBygR9qZXGjgrXpE0+gR4VASxH7a7iAq0SlQQ
         ypN6dT/TD2BTrcA5vURFKMMrcP5ndCJ3ZTywb0Fc4OEsUYYf0lsgYcxF76JHSTRIyJ0i
         C2JXgpxi9zDCm18KrETy8Myoo0I5SGGN6B57kI70pYZ1B8DoVK2kEwidYXiz+E8XSV8I
         p4OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuZOzcaF3cuc6sgkSOrgsiLYDO6aQMRU6MYx5rC9p1v5ey0VULQ/
	LTAKK0O3EtSn/kjRxZ26tH5juwZVoOU4AJTPYNxbIelc67QIdf0tNQBke/2B4VY/isGvL6OHLy3
	3YS8Y2DSqHvPqmFcmwyICF4b9m1YE+M+PXQXyvW6X2fcSkG1zXI5quvuL2Wvlmu0kRA==
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr2428513edm.80.1550137931194;
        Thu, 14 Feb 2019 01:52:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0WQMPJcq3nRzwUvYqzBuYXcDt8YQEwDmBI1YDUIBfZGzlPVcFTHv+u6mhhaaa6CQDnX4z
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr2428453edm.80.1550137930201;
        Thu, 14 Feb 2019 01:52:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550137930; cv=none;
        d=google.com; s=arc-20160816;
        b=F7GYiECDDXmBPaBxge9w8iIoipSSTX4FDJQys3AjpRKhC6NxOiTcA1xB7YuZ+or5U5
         79wG//d76TXXNkaek+vXkSS3f8TBjaIe8susEkQVOjJt1qRoJLcwoXEiCZpgGR8Qgh+X
         q+vg5lXCZr+73nrvF5QkknAzIQ7aTssPb+DkIUp5m2J7PtSGy2epQzUhFV96KydMOJXw
         xKduMxelVVU2MgcolTogvRyqbiq/ebsb744JXjBz737vV7903MjTLiRjrwOOFNvRYaig
         9kC/yuS+fVy6ogwlnNGWACDnc/BIS/TepNPFzZ+/rM6SEGQMjGH3kgBHDEX2Y99VCPCW
         ZWaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:to:subject;
        bh=qf8tV+OLTvvfDB6K9fe0Z04/CovSwO3s0qE34ZkDNQ4=;
        b=k15HXIOFsO97LsXKWnLc9Er4VjpE+JoUVX9fmYUA2xErlQw7jlcM3AMa0FG4B9UQjf
         CPQBo1iqz+CSKrUzZBHg8v8Z0MP8xoWUs+epMXek575sIBv3C9z0TYuRFq4yTX/KNWGI
         SvVXJ1BlJIoUGdbfKWK3BlqPnB03+0BV7nrYHQG0O2jd18/BC3r7fDQCKsuvgevEP16m
         dCgQWl5BmZdxEAUWdrAy4l9gMbZukwtl7xuG1RtAGM5Xp1G3HAo1RpCsEz/Nhg/PS1dI
         Vzq4eNWzDO8KV2gDaKX7Gs5HHO6mbzrIuQBmzs35nDJgJpBGIjnKUf3443u3sXNaK5R9
         20+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si768947eju.171.2019.02.14.01.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 01:52:09 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2349EADF1;
	Thu, 14 Feb 2019 09:52:08 +0000 (UTC)
Subject: Re: [PATCH v2] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Dave Hansen <dave.hansen@intel.com>, Alexandre Ghiti <alex@ghiti.fr>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190213192610.17265-1-alex@ghiti.fr>
 <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <bcffa37e-22cd-f0d7-ee85-769c0d54520a@suse.cz>
Date: Thu, 14 Feb 2019 10:52:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 8:30 PM, Dave Hansen wrote:
>> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>> +#ifdef CONFIG_COMPACTION_CORE
>>  static __init int gigantic_pages_init(void)
>>  {
>>  	/* With compaction or CMA we can allocate gigantic pages at runtime */
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index ac474a61be37..8fecd3ea5563 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -207,8 +207,9 @@ config HUGETLB_PAGE
>>  config MEMFD_CREATE
>>  	def_bool TMPFS || HUGETLBFS
>>  
>> -config ARCH_HAS_GIGANTIC_PAGE
>> +config COMPACTION_CORE
>>  	bool
>> +	default y if (MEMORY_ISOLATION && MIGRATION) || CMA
> 
> This takes a hard dependency (#if) and turns it into a Kconfig *default*
> that can be overridden.  That seems like trouble.
> 
> Shouldn't it be:
> 
> config COMPACTION_CORE
> 	def_bool y
> 	depends on (MEMORY_ISOLATION && MIGRATION) || CMA

Agreed. Also I noticed that it now depends on MIGRATION instead of
COMPACTION. That intention is correct IMHO, but will fail to
compile/link when both COMPACTION and CMA are disabled, and would need
more changes in mm/internal.h and mm/compaction.c (possibly just
replacing CMA in all "if defined CONFIG_COMPACTION || defined
CONFIG_CMA" instances with COMPACTION_CORE, but there might be more
problems, wanna try? :)

Also, I realized that COMPACTION_CORE is a wrong name, sorry about that.
What the config really provides is alloc_contig_range(), so it should be
named either CONFIG_CMA_CORE (as it provides contiguous memory
allocation, but not the related reservation and accounting), or
something like CONFIG_CONTIG_ALLOC. I would also move it from fs/Kconfig
to mm/Kconfig.

Thanks!

