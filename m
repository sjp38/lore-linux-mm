Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91490C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 440E420866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="VE7dlWqv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 440E420866
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE8D26B000A; Thu, 13 Jun 2019 03:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C99306B000C; Thu, 13 Jun 2019 03:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87AF6B000D; Thu, 13 Jun 2019 03:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 941E76B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:27:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v58so16776234qta.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:precedence;
        bh=Laetec4ccSCBOw8YMZruaBJ+PWt1iLta0CpWlGDAXuM=;
        b=WmmuvjAg3fIpdrN1jFH2TASOvUDcdj6VjryqCjBO/WZstyxNIRCKPe7EQY0aupOCoY
         GhYanX8qJ61oCoFW9nQWOYe+NjtMO3ttIASdmtRfKvGfK6dO37WvZV8qmCHAiJspmu5J
         GPMb4y0zUUInar+F+wlCCXovYypKCtXcDKTX6tyF28oALAMFCpJC/bqNsjCZwhcDmpsR
         2NWqVwGwq4R62600SwPupyBS1z1bCmyzRn/x+5CkyLVUPLL7ap38qwnW43Rj92Bs2hhf
         AmY5mcclytCDtIyABfCILtTyT7vgUEv2ppyz0RYLsUId3q/3gzqR6r8QaAavfJFm83BY
         DmpA==
X-Gm-Message-State: APjAAAUITQrItZzWqM7gS3FDKcTFyBzvjvxjRu/ljDV3ORPpdgCI9MPb
	R3YRgT9O4XoNhIm0czwV4QJezadwopK3CPFVQSgnNJvinfdDwhqWxwzFNq5wcsto1JK61/fBwbQ
	kejLk5dcuFZXNSuwonsPTmR4VekuXU4CxRxi+l87WSkn8p26BesvuriEAQ7tAg8gnRA==
X-Received: by 2002:a37:de18:: with SMTP id h24mr14983074qkj.147.1560410831373;
        Thu, 13 Jun 2019 00:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsC0Qkk01PY3a92rOvnjgOmb8pDjVESLEMUn5uhmi3RpXE5NSF1fxtZBXmXFQVmD2HogjE
X-Received: by 2002:a37:de18:: with SMTP id h24mr14983042qkj.147.1560410830796;
        Thu, 13 Jun 2019 00:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560410830; cv=none;
        d=google.com; s=arc-20160816;
        b=bCKo5X7slxB4VmBz3KVqq8fmr63sHtQlWmPYLAjWfDT5Ydn5dyjDLXKuWeRuIc7pCF
         NAkuPVCKo6MHT0fHMG6xdHw+CM3z35je1GONS3rOw0RCM9ZN42UHVNjO3MB6BBmOWe6s
         oKfFkeNAe7nJQ+jOaTBE+6mBkw6sACj6AIPFz6WbVB57KCoWgWwE8tKJMGt3x/7nLGRj
         ZginQEGHOOWizUkl3DXIHwl9wohQGPsSv9pS5KVWKc1yooAbHyNaFX6HpH7n7F5/81NN
         biJjixQT8fBXchI1iL/YkDcNkftg/YwIJCWzfXJCti5brLxhCYQOEKOUHbXVZcfifZCe
         Ucaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-language:content-transfer-encoding:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to
         :subject:dkim-signature;
        bh=Laetec4ccSCBOw8YMZruaBJ+PWt1iLta0CpWlGDAXuM=;
        b=vhwHi+mEAI6En9uOzOuLGxNh3rFo2RAzNc3oNQxl2f4ES1zESCSX30UHjt6l38nVYT
         NIhXv1W3KsQJ/Mx3zVT5EhzjMmIulQutJwkreYVwlS/BGwnZFoH9mx3gu0IiCdh6BxXV
         fMqQV7GH4lDjD+lTANwRP1gK1bGV6bVQw/kzENVMlqfnLHf+ihcKjrtDU7AnwnTnZ+Dz
         s7yUAuIlCZp1hUMYPta4uRvHHPPsX4LcwzViyLeVnFMWQSOxhy0pkvV2OMGjVfDJieLU
         x/DqYjdoVJAoXsjWVGVAsr2YNomjwiZkYhToWOHUxEVK5PezvjKIqjMTRVR64Zg03soG
         95Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=VE7dlWqv;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id w16si885760qvi.160.2019.06.13.00.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=060300392=graf@amazon.com designates 207.171.184.29 as permitted sender) client-ip=207.171.184.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=VE7dlWqv;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1560410830; x=1591946830;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=Laetec4ccSCBOw8YMZruaBJ+PWt1iLta0CpWlGDAXuM=;
  b=VE7dlWqvkizytsOoyQdjqbF18715cizu2shKsjdMRQzNmJ1v+kEmlcu/
   EeSpgTGxzQFrPBwtqCRIcLQeLGQaW/5fU9ByzJzCP7nAyCzVNMrlWEoO5
   5mgf1aYdBaVzD8lMsiD8acc4pu/Q2oaZxZSqWKHKCijwxlIqeJDVdw7AI
   c=;
X-IronPort-AV: E=Sophos;i="5.62,368,1554768000"; 
   d="scan'208";a="679674698"
Received: from sea3-co-svc-lb6-vlan3.sea.amazon.com (HELO email-inbound-relay-1a-67b371d8.us-east-1.amazon.com) ([10.47.22.38])
  by smtp-border-fw-out-9102.sea19.amazon.com with ESMTP; 13 Jun 2019 07:27:07 +0000
Received: from EX13MTAUWC001.ant.amazon.com (iad55-ws-svc-p15-lb9-vlan3.iad.amazon.com [10.40.159.166])
	by email-inbound-relay-1a-67b371d8.us-east-1.amazon.com (Postfix) with ESMTPS id 66CC3A24B7;
	Thu, 13 Jun 2019 07:27:05 +0000 (UTC)
Received: from EX13D20UWC001.ant.amazon.com (10.43.162.244) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:27:04 +0000
Received: from 38f9d3867b82.ant.amazon.com (10.43.160.177) by
 EX13D20UWC001.ant.amazon.com (10.43.162.244) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:27:02 +0000
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Dave Hansen <dave.hansen@intel.com>, Marius Hillenbrand
	<mhillenb@amazon.de>, <kvm@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>, David Woodhouse
	<dwmw@amazon.co.uk>, the arch/x86 maintainers <x86@kernel.org>, "Andy
 Lutomirski" <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
From: Alexander Graf <graf@amazon.com>
Message-ID: <54a4d14c-b19b-339e-5a15-adb10297cb30@amazon.com>
Date: Thu, 13 Jun 2019 09:27:00 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.43.160.177]
X-ClientProxiedBy: EX13D01UWA003.ant.amazon.com (10.43.160.107) To
 EX13D20UWC001.ant.amazon.com (10.43.162.244)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 12.06.19 21:55, Dave Hansen wrote:
> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
>> This patch series proposes to introduce a region for what we call
>> process-local memory into the kernel's virtual address space.
> It might be fun to cc some x86 folks on this series.  They might have
> some relevant opinions. ;)
>
> A few high-level questions:
>
> Why go to all this trouble to hide guest state like registers if all the
> guest data itself is still mapped?


(jumping in for Marius, he's offline today)

Glad you asked :). I hope this cover letter explains well how to achieve 
guest data not being mapped:

https://lkml.org/lkml/2019/1/31/933


> Where's the context-switching code?  Did I just miss it?


I'm not sure I understand the question. With this mechanism, the global 
linear map pages are just not present anymore, so there is no context 
switching needed. For the process local memory, the page table is 
already mm local, so we don't need to do anything special during context 
switch, no?


Alex

