Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 274DBC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 09:16:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA95A2073F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 09:16:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA95A2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5935D6B0006; Thu, 29 Aug 2019 05:16:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5439E6B000C; Thu, 29 Aug 2019 05:16:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4313D6B000D; Thu, 29 Aug 2019 05:16:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0242.hostedemail.com [216.40.44.242])
	by kanga.kvack.org (Postfix) with ESMTP id 2303E6B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 05:16:58 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B89BB62D1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:16:57 +0000 (UTC)
X-FDA: 75874910874.14.hook04_1f94bd936613a
X-HE-Tag: hook04_1f94bd936613a
X-Filterd-Recvd-Size: 3913
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:16:56 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 68BD828;
	Thu, 29 Aug 2019 02:16:55 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 094843F246;
	Thu, 29 Aug 2019 02:16:53 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: split out a new pagewalk.h header from mm.h
To: Mike Rapoport <rppt@linux.ibm.com>, Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?Q?Thomas_Hellstr=c3=b6m?= <thomas@shipmail.org>,
 Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Thomas Hellstrom <thellstrom@vmware.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-2-hch@lst.de> <20190829090551.GB16471@rapoport-lnx>
From: Steven Price <steven.price@arm.com>
Message-ID: <ec851f20-b959-eff6-e91f-1a62619803c3@arm.com>
Date: Thu, 29 Aug 2019 10:16:52 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190829090551.GB16471@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29/08/2019 10:05, Mike Rapoport wrote:
> On Wed, Aug 28, 2019 at 04:19:53PM +0200, Christoph Hellwig wrote:
[...]
>> diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
>> new file mode 100644
>> index 000000000000..df278a94086d
>> --- /dev/null
>> +++ b/include/linux/pagewalk.h
>> @@ -0,0 +1,54 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +#ifndef _LINUX_PAGEWALK_H
>> +#define _LINUX_PAGEWALK_H
>> +
>> +#include <linux/mm.h>
>> +
>> +/**
>> + * mm_walk - callbacks for walk_page_range
>> + * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> 
> Sorry for jumping late, can we remove the level numbers here and below?
> PUD can be non-existent, 2nd or 3rd (from top) and PTE can be from 2nd to
> 5th...
> 
> I'd completely drop the numbers and mark PTE as "lowest level".

This patch is just moving the code between, so it seems right to leave
it alone for the moment. My series[1] (which I'm going to rebase on
this, hopefully soon) will rename this:

>  /**
>   * mm_walk - callbacks for walk_page_range
> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> - *	       this handler should only handle pud_trans_huge() puds.
> - *	       the pmd_entry or pte_entry callbacks will be used for
> - *	       regular PUDs.
> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> + * @p4d_entry: if set, called for each non-empty P4D entry
> + * @pud_entry: if set, called for each non-empty PUD entry
> + * @pmd_entry: if set, called for each non-empty PMD entry
>   *	       this handler is required to be able to handle
>   *	       pmd_trans_huge() pmds.  They may simply choose to
>   *	       split_huge_page() instead of handling it explicitly.
> - * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> + * @pte_entry: if set, called for each non-empty PTE (lowest-level) entry
>   * @pte_hole: if set, called for each hole at all levels
>   * @hugetlb_entry: if set, called for each hugetlb entry
>   * @test_walk: caller specific callback function to determine whether

Which matches your suggestion of just "top-level"/"lowest-level".

Steve

[1]
https://lore.kernel.org/lkml/20190731154603.41797-12-steven.price@arm.com/

