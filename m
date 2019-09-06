Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 567E5C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26C0620650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26C0620650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92316B0006; Fri,  6 Sep 2019 11:17:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1AEA6B000D; Fri,  6 Sep 2019 11:17:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B316E6B000E; Fri,  6 Sep 2019 11:17:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 901146B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:17:32 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 35963181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:17:32 +0000 (UTC)
X-FDA: 75904849944.02.start83_781fbe70ae20
X-HE-Tag: start83_781fbe70ae20
X-Filterd-Recvd-Size: 2692
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:17:31 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9C4CC1576;
	Fri,  6 Sep 2019 08:17:30 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5F5F13F59C;
	Fri,  6 Sep 2019 08:17:27 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 02/17] arm64, hibernate: use get_safe_page directly
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-3-pasha.tatashin@soleen.com>
Message-ID: <dc6506a0-9b66-f633-8319-9c8a9dc93d4f@arm.com>
Date: Fri, 6 Sep 2019 16:17:25 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-3-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

Nit: The pattern for the subject prefix should be "arm64: hibernate:"..
Its usually possible to spot the pattern from "git log --oneline $file".

On 21/08/2019 19:31, Pavel Tatashin wrote:
> create_safe_exec_page is a local function that uses the
> get_safe_page() to allocate page table and pages and one pages
> that is getting mapped.

I can't parse this.

create_safe_exec_page() uses hibernate's allocator to create a set of page table to map a
single page that will contain the relocation code.


> Remove the allocator related arguments, and use get_safe_page
> directly, as it is done in other local functions in this
> file.
... because kexec can't use this as it doesn't have a working allocator.
Removing this function pointer makes it easier to refactor the code later.

(this thing is only a function pointer so kexec could use it too ... It looks like you're
creating extra work. Patch 7 moves these new calls out to a new file... presumably so
another patch can remove them again)

As stand-alone cleanup the patch looks fine, but you probably don't need to do this.


Thanks,

James

