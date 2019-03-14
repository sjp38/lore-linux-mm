Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B57EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:12:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBFF62184E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBFF62184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D6DB8E0003; Thu, 14 Mar 2019 10:12:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7852B8E0001; Thu, 14 Mar 2019 10:12:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69DED8E0003; Thu, 14 Mar 2019 10:12:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11A038E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:12:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i59so2454367edi.15
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:12:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5lvB8izfEMoAkCDQAuLlEU4fXWY647iGWhNKwihE/TU=;
        b=PmdQRwFZ+VQGgxT//JD2ogKPe3+WNuaNkJqHbhoXikFqy2a+x9dB0ygdyrYUnTO1j5
         FjW3hicF1G9dRqJU0LHvX+k3Fs6sE8f3tlFVaeNVVJKiKcd5t4kkvndx4wkY9l1f3rc5
         D82sFqju7NV3imCuzqfI8wPSRhpSmW/svY/xUNpOS+9c7eqioMpaByYokWU4i6uDKSwd
         vkMU9JaQH6UNJ9veByc+3fkgLkBZCNBmx1+nGC7HnxTPUUR9CL9agRnum4lby3qzrrLs
         4c2x2599qSXqN2ab2gfbErFa+krCgt2QIh0HhKKNcrzKrTXcKFam5Aw5j9TH8H9cU+TH
         KuRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
X-Gm-Message-State: APjAAAWLMV/U1SddLsxWadu0jRte9pOmB0NTm2fTMcXsV3U7n3XNkzO6
	0gum3We2pJJ0uk/hKgO5bQbYiB7pQ+3f1L6niAhfWffWgI+/mxTyTqBuFpJ0AFi4cU835HSN0FL
	yuFYLbIIsa7FtaM0vO1WiIMaZsyedHdqFn5/MnXCh26WJt/WWOJUzqxtN3g3W+GuZ8g==
X-Received: by 2002:a17:906:f28d:: with SMTP id gu13mr23398378ejb.104.1552572771575;
        Thu, 14 Mar 2019 07:12:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrC/UUPPM13ynFmc7gBAWeSJouokUSZG3Wb0L7TqT/8RO1UGKcczFDks5hVteD0IbDqf43
X-Received: by 2002:a17:906:f28d:: with SMTP id gu13mr23398315ejb.104.1552572770453;
        Thu, 14 Mar 2019 07:12:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552572770; cv=none;
        d=google.com; s=arc-20160816;
        b=LHWtQWwPFm2hdCDuthnNdpxmMAeT12nB8WjPInwWJqSoI96WhmxRRLZqzIqFktK5lN
         /ViC4l5D9HEsovQ2TmDHZvADm/LuWMR/9NlQbQISO3U83YRfE30bjg0zF8tmvV2xRW5r
         Xcn9PYUcZcqTBbEWVbNAuVO10Sq/7ZKxQ3KaJFNjErbtEcViAEsGH4X74AYgfYDA8d0A
         QqO0GQKQMLXbE2T0B3nCNvv4P4jPCAygkHVNLRm74qBMqcEfMAWFSZ2dDUipy/TiacrP
         kR34O3pif/9ueF6wFJzLwdjKKyIqbdmOy8MSCgPuXpliS0dFcv5U0ZuZVRx7QWXiN1Ds
         /gWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5lvB8izfEMoAkCDQAuLlEU4fXWY647iGWhNKwihE/TU=;
        b=LTO/RRs4m5vZ9WBQAbCVY0g6RxIecsR63DM4y86Jsak5TWJsCCl+YM2UGijU8NW5cp
         PVGjT6G16L0xHL7977pVB0Nd5L+K0DR8xTn3o/E7tjfVxJBtuHuajlbG+7cVolYZV/tE
         0MIERITTCcz0TK84Jc1JNSKpaf1uFfNtQ2lnVmxWb4ktNVkVVNwvzJFBzF3KQpgB5KHz
         XK0goIeOHj3e9olRxg/aJKSenDOOBZHo39hzvw1ISjczBRtwDiyXqLx7wRCfRYkDAC8a
         2Kgcu9TtNN82e2bsRcBpvOTQW8hDixc4a2fSWph7aP6hH4lOv38NSg/H95fPEAiflFhO
         tfkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b42si2005994edd.223.2019.03.14.07.12.50
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 07:12:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4017E80D;
	Thu, 14 Mar 2019 07:12:49 -0700 (PDT)
Received: from [10.37.12.84] (unknown [10.37.12.84])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CAC713F59C;
	Thu, 14 Mar 2019 07:12:45 -0700 (PDT)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Juergen Gross <jgross@suse.com>, David Hildenbrand <david@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>
Cc: k.khlebnikov@samsung.com, Stefano Stabellini <sstabellini@kernel.org>,
 Kees Cook <keescook@chromium.org>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "VMware, Inc." <pv-drivers@vmware.com>,
 osstest service owner <osstest-admin@xenproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Julien Freche <jfreche@vmware.com>,
 Nadav Amit <namit@vmware.com>, xen-devel@lists.xenproject.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
 <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
 <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
 <9a40e1ff-7605-e822-a1d2-502a12d0fba7@redhat.com>
 <6f8aca6c-355b-7862-75aa-68fe566f76fb@redhat.com>
 <ec71c03e-987d-2b73-9fe6-2604a3c32017@suse.com>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <cb525882-b52f-c142-8a6a-e5cb491e05d0@arm.com>
Date: Thu, 14 Mar 2019 14:12:43 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <ec71c03e-987d-2b73-9fe6-2604a3c32017@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 3/14/19 8:37 AM, Juergen Gross wrote:
> On 12/03/2019 20:46, David Hildenbrand wrote:
>> On 12.03.19 19:23, David Hildenbrand wrote:
>>
>> I guess something like this could do the trick if I understood it correctly:
>>
>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>> index 39b229f9e256..d37dd5bb7a8f 100644
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct
>> page **pages)
>>          while (pgno < nr_pages) {
>>                  page = balloon_retrieve(true);
>>                  if (page) {
>> +                       __ClearPageOffline(page);
>>                          pages[pgno++] = page;
>>   #ifdef CONFIG_XEN_HAVE_PVMMU
>>                          /*
>> @@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct
>> page **pages)
>>          mutex_lock(&balloon_mutex);
>>
>>          for (i = 0; i < nr_pages; i++) {
>> -               if (pages[i])
>> +               if (pages[i]) {
>> +                       __SetPageOffline(pages[i]);
>>                          balloon_append(pages[i]);
>> +               }
>>          }
>>
>>          balloon_stats.target_unpopulated -= nr_pages;
>>
>>
>> At least this way, the pages allocated (and thus eventually mapped to
>> user space) would not be marked, but the other ones would remain marked
>> and could be excluded by makedumptool.
>>
> 
> I think this patch should do the trick. Julien, could you give it a
> try? On x86 I can't reproduce your problem easily as dom0 is PV with
> plenty of unpopulated pages for grant memory not suffering from
> missing "offline" bit.

Sure. I managed to get the console working with the patch suggested by 
David. Feel free to add my tested-by if when you resend it as is.

Cheers,

-- 
Julien Grall

