Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC38EC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 826392083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 826392083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 231346B0007; Thu, 20 Jun 2019 12:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E2B08E0003; Thu, 20 Jun 2019 12:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2D18E0001; Thu, 20 Jun 2019 12:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E00966B0007
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:37:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e39so4313504qte.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Y7djfo9C72oSddDkps99xsZfZZx1VsJ71gM3u+PP48M=;
        b=jjM8x9JKtC1Yzugpdj7UbCSzaB2PW0lOpgihEywI4Rq3TTB4zu+P36PctdhqS8VFrM
         TVsCvnNLwTI0LmBioyR+ITkAiXQYMUw4X9pbooUtlmnOI04vTE+tuO3PPgLypKCUOowG
         E103uz+D9Yv4R7/JYJ89P6hHtHTWQRTE2az/m9c4y9Sqj8S18jKx9uLCxCcJuHwlODPW
         RhTRQvsGv35GAOZUvLV7t4NNtTRnAEDQjQPA90wGeYasylIa9YdAs5OLah0n626za6F2
         8yJH57UvongTIPxuIaq4QHr1dzxve5Ih6lBLZN2KXHgoWAf1RZEpGtTG2/FV+ZMo3ueQ
         A/UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAhUB0J44DWgqpeF8tAlx+q5KiuSB5TnnZ1Df3bY6tgpANG8xe
	GYXVwvod6gBY2rne+s6ocg/wHmbMZ/Fh5B1MXxCaX6euL7EvUfwumNwvVYxbqMA/QMwTlQYbojS
	VcL4v7plUaZAZKqDl3RdYNeriT9CuTHm+cxCsjCMvvyijUHAJDZZQvUbKMFnIbJeV3A==
X-Received: by 2002:ac8:2439:: with SMTP id c54mr80370396qtc.160.1561048669680;
        Thu, 20 Jun 2019 09:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq65PG/rN6ErNK4IThtYRduOWBe8S5bl52hlQqe2TadXgHTwdpYgxH4FqytKpq1AqpEfO1
X-Received: by 2002:ac8:2439:: with SMTP id c54mr80370356qtc.160.1561048669103;
        Thu, 20 Jun 2019 09:37:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561048669; cv=none;
        d=google.com; s=arc-20160816;
        b=B9qVDQkyyHGXzWRGkS4Fmu8KYmWsuih5qx1rvQJicyHvOA7kXfNro/NCEncG9mCAgQ
         DCxT+63/tCA/lWGDftuAlQLu6cW3SsLEayMJmzuV9gHiezEEkVu2tlXmxGjRZw2Fwq+X
         X4Mxu7380nMoElr5aQirTcL3fQNwnmjaOH2SPPEjiArmh1lA3a+YOir+4L/1cRg4mBap
         P3bvNKiJN0PuFSHzrANMEHLpbcT7gML+mNOwpgMnU5hwxBqYDC1zaTvsxzNBUcykzUEd
         X9q+CV3R2GzLk+nUAQ5peIYsz9ENpDKBtaoxhmeQDNThNPzqTpg6blgsDjn3bzvaH0zV
         HlXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Y7djfo9C72oSddDkps99xsZfZZx1VsJ71gM3u+PP48M=;
        b=iSeuvpsazIW7cM3SYmeuGpkOtmIwY1Tj5V5XfEjqDpqzZCsKAPc/bL21DHUSv5Bhuy
         GUnKZSOlR3NQ/NiMhBbgFJYzMCZbvB17WTbZ8QIz62vNIXRK5tgtBugUdASl2akb8nAh
         WKaviW47RUT3P2mWdUtjjBahskaG+x74/38zdVk9NCFwL52ObLnUHQC4oAHYbCu1MDiN
         GbPWyeWVUcBT2GzrUqCWfyFxx72QjAFzZRXP5iCbDTG5+12cEIJYhJMOzX/oOHsuXPlN
         4QF0Vmzrcewt7BnFHpodj+a43rWQPDJP7wQw2KCT0+7FOVHVjhvI8gCMOWQHd83m3iWV
         6auA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si67741qtb.258.2019.06.20.09.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:37:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 294E2307D8E3;
	Thu, 20 Jun 2019 16:37:32 +0000 (UTC)
Received: from [10.36.116.54] (ovpn-116-54.ams2.redhat.com [10.36.116.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 91D98100194A;
	Thu, 20 Jun 2019 16:37:11 +0000 (UTC)
Subject: Re: [PATCH v2 4/6] mm/memory_hotplug: Rename walk_memory_range() and
 pass start+size instead of pfns
To: Nathan Chancellor <natechancellor@gmail.com>
Cc: linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rashmica Gupta <rashmica.g@gmail.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Michael Neuling <mikey@neuling.org>, Thomas Gleixner <tglx@linutronix.de>,
 Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
 Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>
References: <20190620103520.23481-1-david@redhat.com>
 <20190620103520.23481-5-david@redhat.com>
 <20190620160507.GA34841@archlinux-epyc>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bffe90e6-81fa-e8d5-5fb2-b54539f45c5d@redhat.com>
Date: Thu, 20 Jun 2019 18:37:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190620160507.GA34841@archlinux-epyc>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 20 Jun 2019 16:37:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 18:05, Nathan Chancellor wrote:
> On Thu, Jun 20, 2019 at 12:35:18PM +0200, David Hildenbrand wrote:
>> walk_memory_range() was once used to iterate over sections. Now, it
>> iterates over memory blocks. Rename the function, fixup the
>> documentation. Also, pass start+size instead of PFNs, which is what most
>> callers already have at hand. (we'll rework link_mem_sections() most
>> probably soon)
>>
>> Follow-up patches wil rework, simplify, and move walk_memory_blocks() to
>> drivers/base/memory.c.
>>
>> Note: walk_memory_blocks() only works correctly right now if the
>> start_pfn is aligned to a section start. This is the case right now,
>> but we'll generalize the function in a follow up patch so the semantics
>> match the documentation.
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> Cc: Len Brown <lenb@kernel.org>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Rashmica Gupta <rashmica.g@gmail.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>> Cc: Michael Neuling <mikey@neuling.org>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Juergen Gross <jgross@suse.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  arch/powerpc/platforms/powernv/memtrace.c | 22 ++++++++++-----------
>>  drivers/acpi/acpi_memhotplug.c            | 19 ++++--------------
>>  drivers/base/node.c                       |  5 +++--
>>  include/linux/memory_hotplug.h            |  2 +-
>>  mm/memory_hotplug.c                       | 24 ++++++++++++-----------
>>  5 files changed, 32 insertions(+), 40 deletions(-)
>>
>> diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
>> index 5e53c1392d3b..8c82c041afe6 100644
>> --- a/arch/powerpc/platforms/powernv/memtrace.c
>> +++ b/arch/powerpc/platforms/powernv/memtrace.c
>> @@ -70,23 +70,24 @@ static int change_memblock_state(struct memory_block *mem, void *arg)
>>  /* called with device_hotplug_lock held */
>>  static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
>>  {
>> +	const unsigned long start = PFN_PHYS(start_pfn);
>> +	const unsigned long size = PFN_PHYS(nr_pages);
>>  	u64 end_pfn = start_pfn + nr_pages - 1;
> 
> This variable should be removed:
> 
> arch/powerpc/platforms/powernv/memtrace.c:75:6: warning: unused variable 'end_pfn' [-Wunused-variable]
>         u64 end_pfn = start_pfn + nr_pages - 1;
>             ^
> 1 warning generated.
> 
> https://travis-ci.com/ClangBuiltLinux/continuous-integration/jobs/209576737
> 
> Cheers,
> Nathan
> 

Indeed, thanks!


-- 

Thanks,

David / dhildenb

