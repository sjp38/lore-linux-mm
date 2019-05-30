Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF28C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:23:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 411682536E
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:23:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 411682536E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3136B000E; Thu, 30 May 2019 03:23:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A533E6B026B; Thu, 30 May 2019 03:23:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F5116B026D; Thu, 30 May 2019 03:23:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 650946B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 03:23:15 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t17so2389604otp.19
        for <linux-mm@kvack.org>; Thu, 30 May 2019 00:23:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=tZgrinfxR3+AnaOr0WOg5D7dfXSYVuetuAIQ+zig6xw=;
        b=SlqhaKce98FlIpXDZFfmRDxlF/uxNch5uwxfNPrfTeu7jzizjVvRB9NR/hcRSbfcQ4
         8TJRql4KzCKAJI+1YvVZOOXElT4PsZYnkiwN1oLIRik835sdCGuf0Jr5rIUATLcjJ6Ch
         iIiSaIE0z08hu1+T5BjcDeoFTRpqMvDG334ZIPxlktaaD4mPyc8TzHqzlqfdkBumkeet
         sjID6OuKYJew5UKI7DzWm8yFDIHDnTJFqfTmtFmrBDB0ixv7Xx4DnLVDx9/tYaklA+iN
         Ig6IKtCoyYTkeon2YXTj19uuED2ctaPKjCfv+BDoc36psQ/9gc8DJoVYOEOXJdOGVJ13
         /Dng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXvfQ+OKvkc94JREIyN3euW3FQ4vuKMn2WXfx6FdPQGTtcTfeiK
	dS6QotDgBL944TeeDIyVREFlFX2qtGCPhu6ia1+Jb8mKZcHf9z9QstqIPwI8cY7Mo2QPNASPASK
	1PB6DQZFgPyviOznSEKLoEjaT8SI1Suiea/ejczCmDqnRTnlnb1nTSjy6COpnAtG+BQ==
X-Received: by 2002:aca:6748:: with SMTP id b8mr1491727oiy.31.1559200995112;
        Thu, 30 May 2019 00:23:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+gWAFBCC7zIPpB3B8fyZY8kHJH4AFv5kjuPXOeQdxn4d75ReIuSVUdQsI1BOnx7bRlgMz
X-Received: by 2002:aca:6748:: with SMTP id b8mr1491702oiy.31.1559200994433;
        Thu, 30 May 2019 00:23:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559200994; cv=none;
        d=google.com; s=arc-20160816;
        b=NuyesF/hlgt8zkICP2gkvN22qwFNiabfEVSZCtSu5QJbecKpo4aBSrez5eRs4JsMsg
         RAfRmvYqmV9PGelOwl1yxN+/FGfqQKQ7NpaTNGZUvcwU33UvAA4ntr+Iy3BG/BjSSPCv
         KAEuYqyei+tLACmllW0inFf3FJ5j54SeiOXQjlZqXGeO77mClAFIyBbiC13bDpOhDqMr
         /MzFMlpGb7Umw+yWk8YExXMMPzdGelaKgloJtnl45wAsjdjAO7yDw/GjGhRUSC2SxQ7f
         xsD5amMzq+ZeJG+N3yPmRhO5gawiIQD8/NFeqXVfVMvlIoI+lexjGj9BJNbL0zhSmSj6
         6Plg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=tZgrinfxR3+AnaOr0WOg5D7dfXSYVuetuAIQ+zig6xw=;
        b=AMk6rcWDdtU6ZALJea89xQjpc3UdX6mZf5piASNzPnkHtRH89o3g5tuQmLlo32TuEP
         28Hdp+n2dbHaLtfRwClOFfd2y3LMtWBWhdeM1UDX/InR3obrxf3YxLrO2OOispEMn2kT
         MUoNqpVAkKqLRnMBbrATzi6cimNW4fYldsysTNXbMm8L8va7sl47pReSFPnvXbQZXVoR
         eFbgQChbD0c5YJZ5DJKxEB+YsP+TaoW/aDmsHYFNlqw6Te5b5VKVVi/i9ynoh0uJl+bG
         1VwoSYmrhiFkbR/4uI/+QuCmTjyLmiqszTQJvJwDdbLbBzfduKC/cAyYvGrNHGYe25+t
         n1Ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si1135201ots.288.2019.05.30.00.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 00:23:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38DF73179172;
	Thu, 30 May 2019 07:23:12 +0000 (UTC)
Received: from [10.36.117.30] (ovpn-117-30.ams2.redhat.com [10.36.117.30])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3188B2E189;
	Thu, 30 May 2019 07:23:03 +0000 (UTC)
Subject: Re: [PATCH V5 0/3] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, mark.rutland@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, cai@lca.pw, logang@deltatee.com, james.morse@arm.com,
 cpandya@codeaurora.org, arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <20190529150611.fc27dee202b4fd1646210361@linux-foundation.org>
 <c6e3af6e-27f4-ec3e-5ced-af4f62a9cdff@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a6f05e1d-4153-ece3-a910-024c428be93b@redhat.com>
Date: Thu, 30 May 2019 09:23:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <c6e3af6e-27f4-ec3e-5ced-af4f62a9cdff@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 30 May 2019 07:23:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.05.19 06:23, Anshuman Khandual wrote:
> 
> 
> On 05/30/2019 03:36 AM, Andrew Morton wrote:
>> On Wed, 29 May 2019 14:46:24 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>
>>> This series enables memory hot remove on arm64 after fixing a memblock
>>> removal ordering problem in generic __remove_memory() and one possible
>>> arm64 platform specific kernel page table race condition. This series
>>> is based on latest v5.2-rc2 tag.
>>
>> Unfortunately this series clashes syntactically and semantically with
>> David Hildenbrand's series "mm/memory_hotplug: Factor out memory block
>> devicehandling".  Could you and David please figure out what we should
>> do here?
>>
> 
> Hello Andrew,
> 
> I was able to apply the above mentioned V3 series [1] from David with some changes
> listed below which tests positively on arm64. These changes assume that the arm64
> hot-remove series (current V5) gets applied first.
> 
> Changes to David's series
> 
> A) Please drop (https://patchwork.kernel.org/patch/10962565/) [v3,04/11]
> 
> 	- arch_remove_memory() is already being added through hot-remove series
> 
> B) Rebase (https://patchwork.kernel.org/patch/10962575/) [v3, 06/11]
> 
> 	- arm64 hot-remove series adds CONFIG_MEMORY_HOTREMOVE wrapper around
> 	  arch_remove_memory() which can be dropped in the rebased patch
> 
> C) Rebase (https://patchwork.kernel.org/patch/10962589/) [v3, 09/11]
> 
> 	- hot-remove series moves arch_remove_memory() before memblock_[free|remove]()
> 	- So remove_memory_block_devices() should be moved before arch_remove_memory()
> 	  in it's new position
> 
> David,
> 
> Please do let me know if the plan sounds good or you have some other suggestions.

That's exactly what I had in mind :)

Andrew, you can drop my series and pick up Anshumans series first. I can
then rebase and resend.
Cheers!

-- 

Thanks,

David / dhildenb

