Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53D4BC10F07
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 03:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDE12146E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 03:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDE12146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 905F38E005A; Wed, 20 Feb 2019 22:17:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DA438E0002; Wed, 20 Feb 2019 22:17:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77B198E005A; Wed, 20 Feb 2019 22:17:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34D3A8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 22:17:54 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f5so18427503pgh.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:17:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=rx1IG+NnPMS3pbsQbpGb/lRBXALmtkVuqTYLdmWteo0=;
        b=H8OMt4Ibj9v4p5PJ0k1DPAcjSheOKPtEbwjvDFr5j6j6TKs9W0/F1XAY+z49xqO+EY
         ooKM0vclUXBrys86QQCeMD5uy4ELampBgqeJw/B725ozQGLViTqxbpSpRSWIRdR0Jy8s
         JImrb38qzUvnuLjOeNaRpLgQaK4YEJYCfwvHcBRJOznmBh6BXmzBcc6cDhJxogGjt8nY
         aieZRdbId4ghLuZMXDepGKmXF/F7mnNB+QJdrA8gbHllDJUKZyuZ6HqDiScLvJRfUh32
         NCYTOMGN3xgnbGCp72uoKHYuyosLb9g5byUGtt/e4yvuPYWxw+IJLW7SLbCBpTbL6BQt
         rh1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZPY7qIKbE5Olxy/RPw9DORTOIZbibQkf0fTix+8bUV1kus5+pH
	vqHQf6+C1UQzzxWylC+GZ+JjIl+FPNROv1LRTW3p+FPs+bo34arUZLNmzD6aGeg4ogVfoZwHU1G
	Gs+oS5NX6SWKWrEJ06i6805TgHqKM1NtxxoNwaqRYORmq5OLmXWkcQ9CX1RbxGdatFw==
X-Received: by 2002:a17:902:6804:: with SMTP id h4mr2986756plk.115.1550719073853;
        Wed, 20 Feb 2019 19:17:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5k+nqliMRKFKehUNJs35vn3GkYPLYwMYSZL0Gt3zxQZFHBoMJGm8Nj6tl7YXsE0uCubMP
X-Received: by 2002:a17:902:6804:: with SMTP id h4mr2986695plk.115.1550719073060;
        Wed, 20 Feb 2019 19:17:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550719073; cv=none;
        d=google.com; s=arc-20160816;
        b=P+irEUs69LeZm3HYJUWZuB2HVzAU7RgCSAjoHagNAWIfcMw6dq7a7kdKv/CmmjES5Y
         //uh2xUptenoacGdXVr1XTqEfjXUukp4TT4bkz3oCz68LQUwm4/l+5QUW1PL8Qk0ruqz
         e0n9aGsv6PuuVNbmh3NcGADBXka7JfqOygGimTaDJWgkF7fE+W9GltJec4NAoEEx4xKh
         GzwHkFLuGNWb8aWDBTodAeME5fhLtHRp45zQmuSP/cozTtQSHyfp3ugcu1t2Aj0L3Aa/
         E7lqSfp5AUwBy7A5daqgwypz2TksdmX22e0A+YQsYavlj+WPE8/RXAl3q/RUCMiNWHZF
         1kfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rx1IG+NnPMS3pbsQbpGb/lRBXALmtkVuqTYLdmWteo0=;
        b=g+cXpcZqM0nvboJSDsoxYthSvCS4tbQfR3NxTOSwv9AxWz+VGqgUnLRNUeWWZCzW6D
         6MTvMKT1aITlLIl1Ndv2TG649tbEaqONoOw+qba+/8P42yuFEV2rzPISbnE8vJ557Keg
         7bmWNeDn5knnuS/vZUp8V6jcIzHtH3QRb6dHCfH8WrZO+mg/OzKJm12Vtl3uYenmOcpt
         Hv+ikhHrYhrKgNSGKp12W5Mbo0RbPsYbAxdLx1AIBhrY4mIrsv+T+yDl532c45f1QpvJ
         m8ifr+8YTpIerR6mu5K/kLv0o13wVNjyC17juJ47bwkmx2WzF28ghO/SHo8PPtmH3oBS
         uwbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p7si20170929pgp.284.2019.02.20.19.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 19:17:53 -0800 (PST)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 19:17:52 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,393,1544515200"; 
   d="scan'208";a="140330388"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.107]) ([10.239.13.107])
  by orsmga001.jf.intel.com with ESMTP; 20 Feb 2019 19:17:50 -0800
Subject: Re: [LKP] [RFC PATCH] mm, memory_hotplug: fix off-by-one in
 is_pageblock_removable
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>,
 Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org
References: <20190218052823.GH29177@shao2-debian>
 <20190218181544.14616-1-mhocko@kernel.org>
 <20190220125732.GB4525@dhcp22.suse.cz>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <e3fc1372-f3bb-d734-9e3f-d715b85d781d@intel.com>
Date: Thu, 21 Feb 2019 11:18:07 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190220125732.GB4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch can fix the issue for me.

Best Regards,
Rong Chen

On 2/20/19 8:57 PM, Michal Hocko wrote:
> Rong Chen,
> coudl you double check this indeed fixes the issue for you please?
>
> On Mon 18-02-19 19:15:44, Michal Hocko wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> Rong Chen has reported the following boot crash
>> [   40.305212] PGD 0 P4D 0
>> [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
>> [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
>> [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [   40.330813] RIP: 0010:page_mapping+0x12/0x80
>> [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
>> [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
>> [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
>> [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
>> [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
>> [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
>> [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
>> [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
>> [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
>> [   40.426951] Call Trace:
>> [   40.429843]  __dump_page+0x14/0x2c0
>> [   40.433947]  is_mem_section_removable+0x24c/0x2c0
>> [   40.439327]  removable_show+0x87/0xa0
>> [   40.443613]  dev_attr_show+0x25/0x60
>> [   40.447763]  sysfs_kf_seq_show+0xba/0x110
>> [   40.452363]  seq_read+0x196/0x3f0
>> [   40.456282]  __vfs_read+0x34/0x180
>> [   40.460233]  ? lock_acquire+0xb6/0x1e0
>> [   40.464610]  vfs_read+0xa0/0x150
>> [   40.468372]  ksys_read+0x44/0xb0
>> [   40.472129]  ? do_syscall_64+0x1f/0x4a0
>> [   40.476593]  do_syscall_64+0x5e/0x4a0
>> [   40.480809]  ? trace_hardirqs_off_thunk+0x1a/0x1c
>> [   40.486195]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>
>> and bisected it down to efad4e475c31 ("mm, memory_hotplug:
>> is_mem_section_removable do not pass the end of a zone"). The reason for
>> the crash is that the mapping is garbage for poisoned (uninitialized) page.
>> This shouldn't happen as all pages in the zone's boundary should be
>> initialized. Later debugging revealed that the actual problem is an
>> off-by-one when evaluating the end_page. start_pfn + nr_pages resp.
>> zone_end_pfn refers to a pfn after the range and as such it might belong
>> to a differen memory section. This along with CONFIG_SPARSEMEM then
>> makes the loop condition completely bogus because a pointer arithmetic
>> doesn't work for pages from two different sections in that memory model.
>>
>> Fix the issue by reworking is_pageblock_removable to be pfn based and
>> only use struct page where necessary. This makes the code slightly
>> easier to follow and we will remove the problematic pointer arithmetic
>> completely.
>>
>> Fixes: efad4e475c31 ("mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone")
>> Reported-by: <rong.a.chen@intel.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>   mm/memory_hotplug.c | 27 +++++++++++++++------------
>>   1 file changed, 15 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 124e794867c5..1ad28323fb9f 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1188,11 +1188,13 @@ static inline int pageblock_free(struct page *page)
>>   	return PageBuddy(page) && page_order(page) >= pageblock_order;
>>   }
>>   
>> -/* Return the start of the next active pageblock after a given page */
>> -static struct page *next_active_pageblock(struct page *page)
>> +/* Return the pfn of the start of the next active pageblock after a given pfn */
>> +static unsigned long next_active_pageblock(unsigned long pfn)
>>   {
>> +	struct page *page = pfn_to_page(pfn);
>> +
>>   	/* Ensure the starting page is pageblock-aligned */
>> -	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
>> +	BUG_ON(pfn & (pageblock_nr_pages - 1));
>>   
>>   	/* If the entire pageblock is free, move to the end of free page */
>>   	if (pageblock_free(page)) {
>> @@ -1200,16 +1202,16 @@ static struct page *next_active_pageblock(struct page *page)
>>   		/* be careful. we don't have locks, page_order can be changed.*/
>>   		order = page_order(page);
>>   		if ((order < MAX_ORDER) && (order >= pageblock_order))
>> -			return page + (1 << order);
>> +			return pfn + (1 << order);
>>   	}
>>   
>> -	return page + pageblock_nr_pages;
>> +	return pfn + pageblock_nr_pages;
>>   }
>>   
>> -static bool is_pageblock_removable_nolock(struct page *page)
>> +static bool is_pageblock_removable_nolock(unsigned long pfn)
>>   {
>> +	struct page *page = pfn_to_page(pfn);
>>   	struct zone *zone;
>> -	unsigned long pfn;
>>   
>>   	/*
>>   	 * We have to be careful here because we are iterating over memory
>> @@ -1232,13 +1234,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
>>   /* Checks if this range of memory is likely to be hot-removable. */
>>   bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>>   {
>> -	struct page *page = pfn_to_page(start_pfn);
>> -	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
>> -	struct page *end_page = pfn_to_page(end_pfn);
>> +	unsigned long end_pfn, pfn;
>> +
>> +	end_pfn = min(start_pfn + nr_pages,
>> +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
>>   
>>   	/* Check the starting page of each pageblock within the range */
>> -	for (; page < end_page; page = next_active_pageblock(page)) {
>> -		if (!is_pageblock_removable_nolock(page))
>> +	for (pfn = start_pfn; pfn < end_pfn; pfn = next_active_pageblock(pfn)) {
>> +		if (!is_pageblock_removable_nolock(pfn))
>>   			return false;
>>   		cond_resched();
>>   	}
>> -- 
>> 2.20.1
>>

