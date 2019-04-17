Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 991FDC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:38:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48BAF206B6
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:38:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48BAF206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E19F66B0006; Wed, 17 Apr 2019 09:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC7096B0007; Wed, 17 Apr 2019 09:37:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C90C76B0008; Wed, 17 Apr 2019 09:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7691A6B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:37:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z29so9909774edb.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:37:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=msF/Sao4z5Oo7cE3fJrWPB5A6IW9D4IqRbGsSPoJZk8=;
        b=afqvcnGRPUGNP3piOY5aRQJVV8vYAkB3DWa2Nw1/oeCN5YqsHyqcHB21cKxZgnSncE
         C6VvM4/WwPr0qaLANM9SsXrb8/oOWB9fuLGd/LqVglRWQH50vMuYB7O9oikdbkXkKnr2
         YfK/lSjudruW6XoiTcmDB6T6XhKq3Zedztb7BQM7ttuT8r8nqkV4zcgj+lCzhSFUJEl+
         utbxdJTKhvgcZmZ1zqWfIAZ4LNrAY0DFWIxW1eKZ0wG6I0EAl2Zm1fEmeT4yNQxr/Qty
         Q42j74gLINdu+3Cm9pLVX4zHkV52iWwT/SccJSTmCe0faeI2G6lHf+QbKtP+Ds63SPpf
         z6CQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXXKmZ0mjmZWXaadzXAtB4qRyqOYrA6XnRZAo+lApMclW7nAN6P
	E7ilip8iICVD3JadUXCXJzsMj+uGBLtX6/0qM7TaFKL7GiAXqvcuQuOFz9YRZUoTRg/Gu0+gayg
	chn/fAoFXPImrwPwhbrZKAZa6xo988gh14xx/QvcUq4e+NjnnvWmlMC0PmvOjlokzfg==
X-Received: by 2002:a50:94dc:: with SMTP id t28mr29349891eda.152.1555508278979;
        Wed, 17 Apr 2019 06:37:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwS79cy6u9QPThLcHhie24Y+F/85zhuYT0mOtsymK6T29T8AK52/28rFTwfRcX43C/zi/Ho
X-Received: by 2002:a50:94dc:: with SMTP id t28mr29349832eda.152.1555508277955;
        Wed, 17 Apr 2019 06:37:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555508277; cv=none;
        d=google.com; s=arc-20160816;
        b=0w70bBAL+e1p3IUqjlTnkrSAfx8t21XdBol5nrHzSHjxH5eWWe/S+B/V9W2uDOjpBY
         ByZSGfj5T+vnl8uSLgBWwW2ObvO6xygsBzOitSYoaikL1J4KoG3lclMWT5jirjs0QokF
         htGlsL52y6po3+1WmfshL8vlozdaT4X/RCRmYSJUvQ83XYM3/TRDg/nQ58NyDCa3iyPC
         QE91WUUVJuWiYJeJes3Lq9KkI4AJbIhTp5jIPCIqb5khQZatSTmp/QK7Xi7yBU3BRMEn
         JUjGkEFA3edjW4XMisNqq90i4NLGSNFIqipd0VW0OU4U4tCpQU9lfIlOAT4sFTthwDX5
         0lWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:cc:to:from
         :subject;
        bh=msF/Sao4z5Oo7cE3fJrWPB5A6IW9D4IqRbGsSPoJZk8=;
        b=0dtNqzDoj/MqkEoFhFIDHBPcUYcUAcMOa1aBlTgD2NU9e43IsMXm9Xevf1x74JReWk
         VV4q06gMaWKteRBRT3G1OTJykj99z5AFUNAELbU1axyEiaXKy1kVEsOLt1EDWq/ib9k2
         MybTzlfbxS4QL+YxlTyFkHz6m3ZAD0jOdMRuhgHdIxB/uqEaT5ItSkipYXc7gU7bjKxN
         g+j8KIwDdx7RQe02nlGnOud9rJAqJQWNAaLOaGRm4qmuetY7n32IfEmRW1fYG/ilzWK9
         Tt8noLl5ir36tFzgpAqXmiwJTJ+TPgmpbCZgL9Hwi5ssg1nCR0RnaQbS5uDw4AQp4N3Q
         E1LA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s22si3488764edx.1.2019.04.17.06.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:37:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FCD0B173;
	Wed, 17 Apr 2019 13:37:57 +0000 (UTC)
Subject: Re: [PATCH 3/3] mm: show number of vmalloc pages in /proc/meminfo
From: Vlastimil Babka <vbabka@suse.cz>
To: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
 Johannes Weiner <hannes@cmpxchg.org>, kernel-team@fb.com,
 Roman Gushchin <guro@fb.com>, Linus Torvalds
 <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-4-guro@fb.com>
 <3321e666-acb7-d037-0140-ee107625e5a6@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <7f7c3a0d-429e-a3de-abce-514ea6b52a4d@suse.cz>
Date: Wed, 17 Apr 2019 15:34:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3321e666-acb7-d037-0140-ee107625e5a6@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/1/19 4:05 PM, Vlastimil Babka wrote:
> On 2/25/19 9:30 PM, Roman Gushchin wrote:
>> Vmalloc() is getting more and more used these days (kernel stacks,
>> bpf and percpu allocator are new top users), and the total %
>> of memory consumed by vmalloc() can be pretty significant
>> and changes dynamically.
>>
>> /proc/meminfo is the best place to display this information:
>> its top goal is to show top consumers of the memory.
>>
>> Since the VmallocUsed field in /proc/meminfo is not in use
>> for quite a long time (it has been defined to 0 by the
>> commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
>> /proc/meminfo")), let's reuse it for showing the actual
> 
> Hm that commit is not that old (2015) and talks about two caching
> approaches from Linus and Ingo, so CCing them here for input, as
> apparently it was not deemed worth the trouble at that time.

No reply, so I've dug up the 2015 threads [1] [2] and went through them
quickly. Seems like the idea was to keep the expensive
get_vmalloc_info() implementation but cache its results. Dunno why a
continuously updated atomic counter was not proposed, like you did now.
Perhaps the implementation changed since then. Anyway it makes a lot of
sense to me. The updates shouldn't be too frequent to cause contention.

[1]
https://lore.kernel.org/lkml/CA+55aFxzOAx7365Mx2o55TZOS+bZGh_Pfr=vVF3QGg0btsDumg@mail.gmail.com/T/#u
[2]
https://lore.kernel.org/lkml/20150825125951.GR16853@twins.programming.kicks-ass.net/T/#e25cc3fd84ccfc5f03a347ba31fa99a132e8c8ca3

> 
>> physical memory consumption of vmalloc().
>>
>> Signed-off-by: Roman Gushchin <guro@fb.com>
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>> ---
>>  fs/proc/meminfo.c       |  2 +-
>>  include/linux/vmalloc.h |  2 ++
>>  mm/vmalloc.c            | 10 ++++++++++
>>  3 files changed, 13 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
>> index 568d90e17c17..465ea0153b2a 100644
>> --- a/fs/proc/meminfo.c
>> +++ b/fs/proc/meminfo.c
>> @@ -120,7 +120,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>  	show_val_kb(m, "Committed_AS:   ", committed);
>>  	seq_printf(m, "VmallocTotal:   %8lu kB\n",
>>  		   (unsigned long)VMALLOC_TOTAL >> 10);
>> -	show_val_kb(m, "VmallocUsed:    ", 0ul);
>> +	show_val_kb(m, "VmallocUsed:    ", vmalloc_nr_pages());
>>  	show_val_kb(m, "VmallocChunk:   ", 0ul);
>>  	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
>>  
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 398e9c95cd61..0b497408272b 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -63,10 +63,12 @@ extern void vm_unmap_aliases(void);
>>  
>>  #ifdef CONFIG_MMU
>>  extern void __init vmalloc_init(void);
>> +extern unsigned long vmalloc_nr_pages(void);
>>  #else
>>  static inline void vmalloc_init(void)
>>  {
>>  }
>> +static inline unsigned long vmalloc_nr_pages(void) { return 0; }
>>  #endif
>>  
>>  extern void *vmalloc(unsigned long size);
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index f1f19d1105c4..3a1872ee8294 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -340,6 +340,13 @@ static unsigned long cached_align;
>>  
>>  static unsigned long vmap_area_pcpu_hole;
>>  
>> +static atomic_long_t nr_vmalloc_pages;
>> +
>> +unsigned long vmalloc_nr_pages(void)
>> +{
>> +	return atomic_long_read(&nr_vmalloc_pages);
>> +}
>> +
>>  static struct vmap_area *__find_vmap_area(unsigned long addr)
>>  {
>>  	struct rb_node *n = vmap_area_root.rb_node;
>> @@ -1566,6 +1573,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
>>  			BUG_ON(!page);
>>  			__free_pages(page, 0);
>>  		}
>> +		atomic_long_sub(area->nr_pages, &nr_vmalloc_pages);
>>  
>>  		kvfree(area->pages);
>>  	}
>> @@ -1742,12 +1750,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>>  		if (unlikely(!page)) {
>>  			/* Successfully allocated i pages, free them in __vunmap() */
>>  			area->nr_pages = i;
>> +			atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
>>  			goto fail;
>>  		}
>>  		area->pages[i] = page;
>>  		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
>>  			cond_resched();
>>  	}
>> +	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
>>  
>>  	if (map_vm_area(area, prot, pages))
>>  		goto fail;
>>
> 

