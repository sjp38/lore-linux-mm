Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7939DC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35ABC20861
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:55:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oYn2ijJx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35ABC20861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7B5E8E0006; Mon, 17 Jun 2019 20:55:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2B148E0005; Mon, 17 Jun 2019 20:55:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B429B8E0006; Mon, 17 Jun 2019 20:55:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0888E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:55:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so8065051pfb.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:55:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jvspeZjBeLt0bsAmMkRof9WD3FK7zgzFpqZd2Yr4DSQ=;
        b=ucMzD1sfmZ+xbv/e0YWs/pHa7Q3XhvuplQ2GfRHdq7iMQ/kj+ubbIQVs5UQ+u4vqbP
         sFX3JTrgOJwRkDpadaeW55gqJz/DYw+ykmm4S7VoVfZpq1/y4ZalBCuhds632B59usd5
         uy02xEukJZhwlbypfzSB1/377iXfG9mm0sKJz9tsN5zeMAzp1AvZRHueGUcbvdFI78CP
         JVWMFTYFKspeqeuMVuxVz7sXZcWOPpWf/sPVCcp2zPMhIho+Fg7fG3bdMumZ6hApclAW
         rJV8M4EZDGavBI0vqQF4nid84u4AjR0OyEtwmsK38/fZYx5AJFlEceZhEuTaPD51nI2e
         E8Zw==
X-Gm-Message-State: APjAAAU+7WP3ZEsYwlwzUaW8lD+l5gQSWvtk68wkMOW0Nj3dbvC1CMln
	9424qQ6PaxdbFy+Nj+NkSjQpcHqLVNsZr+6IytXcVRWUKDx4qhraRcoRqL7SWyE0Ke0IpxdlVm+
	CQB4k83lLnaAIyP+SZcvIg8+5ADCxDqDNR5kmG8pxYOWwvjZz7Vh00VRWgwQU1z5zng==
X-Received: by 2002:a17:90a:d34f:: with SMTP id i15mr2164693pjx.1.1560819315114;
        Mon, 17 Jun 2019 17:55:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjDsuTDD+5Ptn3gb9NnGhr1Q8K2lft0OKulXbcqzIEiGIJSuvwBfQ3FxSyYbxu+A7Bz6Ft
X-Received: by 2002:a17:90a:d34f:: with SMTP id i15mr2164663pjx.1.1560819314402;
        Mon, 17 Jun 2019 17:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560819314; cv=none;
        d=google.com; s=arc-20160816;
        b=dmrNMpqdEE6QJaxGKwkUN4PtQVm1NLc578VTw3llUepsR/G5tMwwm7on7SFL6oCbAi
         +R1lGZBpXEKgdHkLkcAip/j/7Up2EB5O1YzFHZRI39PiCs/2M9I2IzwVmucGCD1Ogw9L
         7ksLwGMc4SxYVKMK/ZNELk1xCRAUjdePtjEAN5P8Epl8yTET5FM4X2En/fj0Posd5pJz
         JrpV8XdC+L/ULlBrVjXCgjpe7wQ4NXIrVBzFBjaLM81XACjbuADBbiLICzmSEHynAByV
         +NNzUUKIzq/ubWC3j1Jpa4hlUVYO+a7L8iCUKMagXGulZX4GaOAWF0BDV85xyp+CSo7b
         KKdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=jvspeZjBeLt0bsAmMkRof9WD3FK7zgzFpqZd2Yr4DSQ=;
        b=YSr+2IQNiT+ZfmSomfhCJBUhp06h+X6utUM9RKXx7QETQqQG7xEPKZcXLiJlldWYJs
         IEQytn1jxJ+UBm4+NLXQT+Z45kdphw7VOM4MrpNY5lf2H3AuEXaA2/y0ffqGMWlf6h0f
         +DBhdhg37W51SxY2q2RGTXBMNkoPn7yby1TmeN/ZhediaDpOYK/f9mbfTpggunhmquTA
         BSYRwhBR0iTXvMpm3sI2Bry4xRqv1yOPpYf14VQUl8c6qw/5mBtqjIwDPl7Lra64WBYZ
         B7YDLw0pA78Xf7oHX1KAh/VB73SNlJ+ZxvSO5/fnmt51mglc+vOWZMA5Cvb5EschRzEq
         za+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oYn2ijJx;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y14si11015861plp.242.2019.06.17.17.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:55:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oYn2ijJx;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B089320833;
	Tue, 18 Jun 2019 00:55:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560819314;
	bh=LngrchH4I/IBN3Zh6OPsxtvSRQcY1UhYSAdzmmrSMZI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oYn2ijJx2tyO/bwbH/NumDeIYuwoNhxc+WEvJdQ3tRhRtrnjbJZED4nHzzNDovMfg
	 he7lamj91s07bXu4cRiBZDOjDkCsVNcfnoqnniZvSwuaIT3b4wFSvVSYEb8RwvVW6W
	 13yAsZGMAoZL5Co54QcVOqiHELUx4VfuqjzqGSRg=
Date: Mon, 17 Jun 2019 20:55:12 -0400
From: Sasha Levin <sashal@kernel.org>
To: Nadav Amit <namit@vmware.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Message-ID: <20190618005512.GC2226@sasha-vm>
References: <20190613045903.4922-2-namit@vmware.com>
 <20190615221557.CD1492183F@mail.kernel.org>
 <549284C3-6A1C-4434-B716-FF9B0C87EE45@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <549284C3-6A1C-4434-B716-FF9B0C87EE45@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 07:14:53PM +0000, Nadav Amit wrote:
>> On Jun 15, 2019, at 3:15 PM, Sasha Levin <sashal@kernel.org> wrote:
>>
>> Hi,
>>
>> [This is an automated email]
>>
>> This commit has been processed because it contains a "Fixes:" tag,
>> fixing commit: ff3cc952d3f0 resource: Add remove_resource interface.
>>
>> The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181.
>>
>> v5.1.9: Build OK!
>> v4.19.50: Failed to apply! Possible dependencies:
>>    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
>>    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")
>>
>> v4.14.125: Failed to apply! Possible dependencies:
>>    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
>>    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
>>    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
>>    4ac2aed837cb ("resource: Consolidate resource walking code")
>>    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")
>>
>> v4.9.181: Failed to apply! Possible dependencies:
>>    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
>>    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
>>    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
>>    4ac2aed837cb ("resource: Consolidate resource walking code")
>>    60fe3910bb02 ("kexec_file: Allow arch-specific memory walking for kexec_add_buffer")
>>    a0458284f062 ("powerpc: Add support code for kexec_file_load()")
>>    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")
>>    da6658859b9c ("powerpc: Change places using CONFIG_KEXEC to use CONFIG_KEXEC_CORE instead.")
>>    ec2b9bfaac44 ("kexec_file: Change kexec_add_buffer to take kexec_buf as argument.")
>
>Is there a reason 010a93bf97c7 ("resource: Fix find_next_iomem_res()
>iteration issue”) was not backported?

Mostly because it's not tagged for stable :)

--
Thanks,
Sasha

