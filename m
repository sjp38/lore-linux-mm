Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63F9EC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B09821873
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:17:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B09821873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8BA6B0005; Fri, 19 Jul 2019 12:17:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77B876B0006; Fri, 19 Jul 2019 12:17:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B5508E0001; Fri, 19 Jul 2019 12:17:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3664B6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:17:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 8so13631397pgl.3
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:17:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Q6xK+/fXZmTe4SzwMeq32WbRYdVxf1j/4BRUCbdNg88=;
        b=P5qoRqr0DSfqIODlBNFcfOJ3fFgY/IIvWMuMnhEtWLUa30oTdMY6suANRBmJ2AFGnB
         Xf6DmLJiWzMJ1+HueEiCkXTnBEIga6KVHsbsuGShffI+Yl6PvV1GURepJNLjO3NMncs3
         Rxcm8WjF9KRlvEqw+pCrB6YqcyYip1RWaqs33v2TdpLOhdFuep6olyvEIL1QiQySOuab
         Sc2fcleypIwvhia58P8gOmTP/K9AOtu+WYaFfmeVbsZwXPG7e31V9MscYjEZcvedEFjI
         E1BxtshhmjQViuw2M0JVXYDu3M+RNiaJ4XYlX4o+4PN2mbeQADI1VKWDxWyseHqcd22g
         x8OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXfEC88P+jyOyHVHzVivhLB/5wF+Vi3RE22e96BnZQph5F30+uy
	zODouomYqplcms+hOFo6aX3h2+nB88qwKL14hZOmZLyCTAbHZgdhEBJ9AxHEGhMdVCANIrYQbHN
	oRcFnvmaAEdXO9BOOuezv8wkjGJ1Sz74PxGCC43HNx8r8iYgM1ubXr3FLG6sG2b2j9A==
X-Received: by 2002:a63:e948:: with SMTP id q8mr53250812pgj.93.1563553063775;
        Fri, 19 Jul 2019 09:17:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1ak6w3T/QEVWT3rQxMLB0Q0ZHQ6Etv7rjpcczzyj71R5WQmfxWAApRGaBlFZNPwTZdCM2
X-Received: by 2002:a63:e948:: with SMTP id q8mr53250736pgj.93.1563553062513;
        Fri, 19 Jul 2019 09:17:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563553062; cv=none;
        d=google.com; s=arc-20160816;
        b=jZybnIjs1TQdYD39Sa5Tk9I7RjgGuPOlaieDd8YA+eBZjhaiwUfQRmXvdTB/O68iQU
         1gs8YY2rQyemzm5X+UhcldQX6rhDW5CmNmgw6TjcAbXALojHysnAz+lhbG7ZWK8ff7Tz
         pKe2TArjPa6bq4c1SUegC+lfOof4YEJhk5Kr/34p9OXCxL4cTE9BeaIkJPesecYlh/x0
         HtAOC6zZsYWIldxjeaJ52N1mKktgqkOo6eJNISCPNDntoaNxbo5EUvwSdM5q4U14kymt
         fwlm4sAqfwcs0YoFkOQCTdUascoqOYpRsr1XGezjetlr/fhkKETAejmK/1tM2tQeWcIb
         VkYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Q6xK+/fXZmTe4SzwMeq32WbRYdVxf1j/4BRUCbdNg88=;
        b=PG1pD7fysk358GthEkhdUL9bauDCnMLi35WAQR96fURQBx50+IKVDVIm4MwTRAYgIY
         SpLgT3n3qJAX1JZCuEGIA7MO3dGcVcBm2WCX5RhsC84/sRvT9Z4ztZZ87jTEqSeWNtlr
         0oufFnEcAp1APSBvP5l2KcG1/m2E2S9osO7PNhuLDEpA7uMWca8mK4JJqMRgz48bEc1z
         DJy4g3cMLkqApqpmAWFo6nU0sROaepwxPzQDNLH8rce6uFAusCQcwYAiKcVlZfuvK4PQ
         gHVPef0I1E3fn3ZiAoAKbiAAhmSV6PkqcOyrSGyO1HNRNet0vgBrN+aEI21nEVMt/VuG
         a25w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id s11si459175pgp.326.2019.07.19.09.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 09:17:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R511e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TXIWw-t_1563553057;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXIWw-t_1563553057)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Jul 2019 00:17:39 +0800
Subject: Re: [v3 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org
References: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563470274-52126-3-git-send-email-yang.shi@linux.alibaba.com>
 <6ba72e56-9f62-36bf-ded7-f337522715d5@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2a753062-a6bd-d767-085a-0bf9847ea067@linux.alibaba.com>
Date: Fri, 19 Jul 2019 09:17:35 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <6ba72e56-9f62-36bf-ded7-f337522715d5@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/19/19 6:01 AM, Vlastimil Babka wrote:
> On 7/18/19 7:17 PM, Yang Shi wrote:
>> When running syzkaller internally, we ran into the below bug on 4.9.x
>> kernel:
>>
>> kernel BUG at mm/huge_memory.c:2124!
>> invalid opcode: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>     (ftrace buffer empty)
>> Modules linked in:
>> CPU: 0 PID: 1518 Comm: syz-executor107 Not tainted 4.9.168+ #2
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.5.1 01/01/2011
>> task: ffff880067b34900 task.stack: ffff880068998000
>> RIP: 0010:[<ffffffff81895d6b>]  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
>> RSP: 0018:ffff88006899f980  EFLAGS: 00010286
>> RAX: 0000000000000000 RBX: ffffea00018f1700 RCX: 0000000000000000
>> RDX: 1ffffd400031e2e7 RSI: 0000000000000001 RDI: ffffea00018f1738
>> RBP: ffff88006899f9e8 R08: 0000000000000001 R09: 0000000000000000
>> R10: 0000000000000000 R11: fffffbfff0d8b13e R12: ffffea00018f1400
>> R13: ffffea00018f1400 R14: ffffea00018f1720 R15: ffffea00018f1401
>> FS:  00007fa333996740(0000) GS:ffff88006c600000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000020000040 CR3: 0000000066b9c000 CR4: 00000000000606f0
>> Stack:
>>   0000000000000246 ffff880067b34900 0000000000000000 ffff88007ffdc000
>>   0000000000000000 ffff88006899f9e8 ffffffff812b4015 ffff880064c64e18
>>   ffffea00018f1401 dffffc0000000000 ffffea00018f1700 0000000020ffd000
>> Call Trace:
>>   [<ffffffff818490f1>] split_huge_page include/linux/huge_mm.h:100 [inline]
>>   [<ffffffff818490f1>] queue_pages_pte_range+0x7e1/0x1480 mm/mempolicy.c:538
>>   [<ffffffff817ed0da>] walk_pmd_range mm/pagewalk.c:50 [inline]
>>   [<ffffffff817ed0da>] walk_pud_range mm/pagewalk.c:90 [inline]
>>   [<ffffffff817ed0da>] walk_pgd_range mm/pagewalk.c:116 [inline]
>>   [<ffffffff817ed0da>] __walk_page_range+0x44a/0xdb0 mm/pagewalk.c:208
>>   [<ffffffff817edb94>] walk_page_range+0x154/0x370 mm/pagewalk.c:285
>>   [<ffffffff81844515>] queue_pages_range+0x115/0x150 mm/mempolicy.c:694
>>   [<ffffffff8184f493>] do_mbind mm/mempolicy.c:1241 [inline]
>>   [<ffffffff8184f493>] SYSC_mbind+0x3c3/0x1030 mm/mempolicy.c:1370
>>   [<ffffffff81850146>] SyS_mbind+0x46/0x60 mm/mempolicy.c:1352
>>   [<ffffffff810097e2>] do_syscall_64+0x1d2/0x600 arch/x86/entry/common.c:282
>>   [<ffffffff82ff6f93>] entry_SYSCALL_64_after_swapgs+0x5d/0xdb
>> Code: c7 80 1c 02 00 e8 26 0a 76 01 <0f> 0b 48 c7 c7 40 46 45 84 e8 4c
>> RIP  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
>>   RSP <ffff88006899f980>
> ...
>
>> @@ -532,7 +531,14 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>>   				has_unmovable |= true;
>>   				break;
>>   			}
>> -			migrate_page_add(page, qp->pagelist, flags);
>> +
>> +			/*
>> +			 * Do not abort immediately since there may be
>> +			 * temporary off LRU pages in the range.  Still
>> +			 * need migrate other LRU pages.
>> +			 */
>> +			if (migrate_page_add(page, qp->pagelist, flags))
>> +				has_unmovable |= true;
> Also = instead of |=

OK

>
>>   		} else
>>   			break;
>>   	}
>> @@ -961,10 +967,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>>   /*
>>    * page migration, thp tail pages can be passed.
>>    */
>> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
>> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				unsigned long flags)
>>   {
>>   	struct page *head = compound_head(page);
>> +
>> +	/*
>> +	 * Non-movable page may reach here.  And, there may be
>> +	 * temporary off LRU pages or non-LRU movable pages.
>> +	 * Treat them as unmovable pages since they can't be
>> +	 * isolated, so they can't be moved at the moment.  It
>> +	 * should return -EIO for this case too.
>> +	 */
>> +	if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
>> +		return -EIO;
> As this test is racy, why not just use the result of isolate_lru_page().

Sounds good to me. Will fix in v4.

Thanks,
Yang

>
>> +
>>   	/*
>>   	 * Avoid migrating a page that is shared with others.
>>   	 */
>> @@ -976,6 +993,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				hpage_nr_pages(head));
>>   		}
>>   	}
>> +
>> +	return 0;
>>   }
>>   
>>   /* page allocation callback for NUMA node migration */
>> @@ -1178,9 +1197,10 @@ static struct page *new_page(struct page *page, unsigned long start)
>>   }
>>   #else
>>   
>> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
>> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				unsigned long flags)
>>   {
>> +	return -EIO;
>>   }
>>   
>>   int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>>

