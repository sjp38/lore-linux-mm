Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87685C4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 09:12:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BD23218AE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 09:12:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BD23218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C526B028D; Wed, 18 Sep 2019 05:12:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71D696B028E; Wed, 18 Sep 2019 05:12:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60EC56B028F; Wed, 18 Sep 2019 05:12:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB596B028D
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 05:12:42 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CCED12A4AB
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:12:41 +0000 (UTC)
X-FDA: 75947476122.15.cloth53_8bdc48e6dad1c
X-HE-Tag: cloth53_8bdc48e6dad1c
X-Filterd-Recvd-Size: 4418
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:12:41 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 098C5337;
	Wed, 18 Sep 2019 02:12:40 -0700 (PDT)
Received: from [10.162.40.136] (p8cg001049571a15.blr.arm.com [10.162.40.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A4B083F59C;
	Wed, 18 Sep 2019 02:12:33 -0700 (PDT)
Subject: Re: [PATCH V7 2/3] arm64/mm: Hold memory hotplug lock while walking
 for kernel page table dump
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org
Cc: mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com, broonie@kernel.org, valentin.schneider@arm.com,
 Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-3-git-send-email-anshuman.khandual@arm.com>
 <66922798-9de7-a230-8548-1f205e79ea50@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8e47831f-c28e-a174-24b3-b3bbf1f365ec@arm.com>
Date: Wed, 18 Sep 2019 14:42:47 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <66922798-9de7-a230-8548-1f205e79ea50@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/15/2019 08:05 AM, Balbir Singh wrote:
> 
> 
> On 3/9/19 7:45 pm, Anshuman Khandual wrote:
>> The arm64 page table dump code can race with concurrent modification of the
>> kernel page tables. When a leaf entries are modified concurrently, the dump
>> code may log stale or inconsistent information for a VA range, but this is
>> otherwise not harmful.
>>
>> When intermediate levels of table are freed, the dump code will continue to
>> use memory which has been freed and potentially reallocated for another
>> purpose. In such cases, the dump code may dereference bogus addresses,
>> leading to a number of potential problems.
>>
>> Intermediate levels of table may by freed during memory hot-remove,
>> which will be enabled by a subsequent patch. To avoid racing with
>> this, take the memory hotplug lock when walking the kernel page table.
>>
>> Acked-by: David Hildenbrand <david@redhat.com>
>> Acked-by: Mark Rutland <mark.rutland@arm.com>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  arch/arm64/mm/ptdump_debugfs.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/arch/arm64/mm/ptdump_debugfs.c b/arch/arm64/mm/ptdump_debugfs.c
>> index 064163f25592..b5eebc8c4924 100644
>> --- a/arch/arm64/mm/ptdump_debugfs.c
>> +++ b/arch/arm64/mm/ptdump_debugfs.c
>> @@ -1,5 +1,6 @@
>>  // SPDX-License-Identifier: GPL-2.0
>>  #include <linux/debugfs.h>
>> +#include <linux/memory_hotplug.h>
>>  #include <linux/seq_file.h>
>>  
>>  #include <asm/ptdump.h>
>> @@ -7,7 +8,10 @@
>>  static int ptdump_show(struct seq_file *m, void *v)
>>  {
>>  	struct ptdump_info *info = m->private;
>> +
>> +	get_online_mems();
>>  	ptdump_walk_pgd(m, info);
>> +	put_online_mems();
> 
> Looks sane, BTW, checking other arches they might have the same race.

The problem can be present on other architectures which can dump kernel page
table during memory hot-remove operation where it actually frees up page table
pages. If there is no freeing involved the race condition here could cause
inconsistent or garbage information capture for a given VA range. Same is true
even for concurrent vmalloc() operations as well. But removal of page tables
pages can make it worse. Freeing page table pages during hot-remove is a platform
decision, so would be adding these locks while walking kernel page table during
ptdump.

> Is there anything special about the arch?

AFAICS, no.

> 
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> 
> 

