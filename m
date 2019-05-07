Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B3C4C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D256A20675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:22:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D256A20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612F36B0007; Tue,  7 May 2019 15:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C33A6B0008; Tue,  7 May 2019 15:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48BDE6B000A; Tue,  7 May 2019 15:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24E1E6B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 15:22:12 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id p190so11530478qke.10
        for <linux-mm@kvack.org>; Tue, 07 May 2019 12:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=gDxsrjot+Fi8OT6wBkeZfKTdaXPx9kSA0GHow9ezAVA=;
        b=fSD+v4OU3lVLPGf/XaQXzUi9KHRfEIi8+to+Q5TP2iDW4mN6L3o+n8GAPiJhxrYMps
         OKHCwlU4FeCUElKjOzGKfjNzBy/Gie3a/XHY5hw0ldLUihsnyfsJA/L3hAamfGOfzbiJ
         k0JJQ6aQsKn4GnRPBX256tYoiOQPpNmxA5P/sC4rYJ10QKtWz5aqoDt0DTDuETGKiDTE
         naTqdbx3OHUlEV5kNM4XN7Tn4oNgaSl55eiRie+i21okiTx+2+QH95Ah4q8adkcg1NyK
         1pRG31pCvBCZOPj1R9baPBmLY/DEQrQX5t3Cn3RtFS8VCgsWeZPiMwUimVnOisfwlpbp
         R73A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBamlUhc5Gnh7dQT4rQhIq3z46vxSKquijKHOaH4RMqse+Pqkv
	qD+F5jaqiewjIEAlPjNR6HVm5JnvTsdCdrCJXHdlxulaa+dSkj6fAIBWWi/EfyKWpi/C3QvLVKR
	+YtLMS28WJFcm4z25L79xOdNwUL8SEgnfimKO9Hyz4jKE2bbiqA7uy2nIsqA1P71BFA==
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr28172087qtj.310.1557256931836;
        Tue, 07 May 2019 12:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWZeBINjSFSdhIrEqhwlUiNi18D06HBM3lvVf5OKb4EyWqHaI0abwF3EqLBMzDH9dq1W34
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr28172010qtj.310.1557256930819;
        Tue, 07 May 2019 12:22:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557256930; cv=none;
        d=google.com; s=arc-20160816;
        b=V7ghIDbQPx7Iz8Najw6xeuxGLQjq4pNoWiT837R3c5796x9ZW1XzQVDI9SzVdltvB1
         77bAb2mbOzytxAWE8yOiNf9ZZCGsDZalZxR3g2IRYr5ZJmEgPsiAYuqn5USDPE3W3S5S
         3Ba3MNuKfYNBzs4/b5zR3t81eQPdxPZhLu4EfsoFzTUQsEAEf7uawa6JJ6PHc5BnB+ac
         Gpra65dluxmYJTbLHgtk79KFhVnP8C1cKhBZLv/OsgLa3qJKv4FseIVdodi9nBFVp9AT
         A0/5w6omuqSw4e9xDYUa/Wt+8ftXkkIRIz8wUbhc/i5iYt3TkS/J7Q/TMyrfhvYqLcDJ
         RYdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=gDxsrjot+Fi8OT6wBkeZfKTdaXPx9kSA0GHow9ezAVA=;
        b=qYm2WAnC+VMzKiOkLwKA3gkC10ULvvp7qSLUNRh6c701eiUEKEGLOxITHFUDxh0kPY
         NdUU3a90znsc7sTDno/c5jAtSjqi8zN0pV4TTvEwVO8+3/MtWM3fjVoWQqJTRtW4gcYS
         cM8LstL+vUuUwrfZr3zNg31udk+5LWS8AYn64koC3vBGx6YbaCfkEtZy5xQOcdcSpxWp
         Et8+OW13z7pcAv0do4U5Ql2czE1t4Q8uYfteTGGSvtW7oX0EhLpu9nUakp/118JdbpEL
         iYCsMP42TMCHBZJNyo72g1DDt1OQgf0uQID5e1+TQjbjNN2GepgZYtc6buMwZFn7pJum
         qMWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si6207646qvn.86.2019.05.07.12.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 12:22:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ED249308FEE2;
	Tue,  7 May 2019 19:22:08 +0000 (UTC)
Received: from [10.36.116.95] (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6DA6F5D9D2;
	Tue,  7 May 2019 19:21:57 +0000 (UTC)
Subject: Re: [PATCH v2 0/8] mm/memory_hotplug: Factor out memory block device
 handling
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 Andrew Banman <andrew.banman@hpe.com>, Andy Lutomirski <luto@kernel.org>,
 Arun KS <arunks@codeaurora.org>, Baoquan He <bhe@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Christophe Leroy <christophe.leroy@c-s.fr>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Logan Gunthorpe <logang@deltatee.com>, Mark Brown <broonie@kernel.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>,
 Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Rich Felker <dalias@libc.org>,
 Rob Herring <robh@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Wei Yang <richard.weiyang@gmail.com>,
 Wei Yang <richardw.yang@linux.intel.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>
References: <20190507183804.5512-1-david@redhat.com>
 <CAPcyv4gxwhsiZ8Hjm4cNbjmLXV2m4s=t14ZoH0uf8AADP2nOtA@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6f69e615-2b4a-ff31-5d2a-e1711c564f9b@redhat.com>
Date: Tue, 7 May 2019 21:21:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gxwhsiZ8Hjm4cNbjmLXV2m4s=t14ZoH0uf8AADP2nOtA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 07 May 2019 19:22:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 21:04, Dan Williams wrote:
> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> We only want memory block devices for memory to be onlined/offlined
>> (add/remove from the buddy). This is required so user space can
>> online/offline memory and kdump gets notified about newly onlined memory.
>>
>> Only such memory has the requirement of having to span whole memory blocks.
>> Let's factor out creation/removal of memory block devices. This helps
>> to further cleanup arch_add_memory/arch_remove_memory() and to make
>> implementation of new features easier. E.g. supplying a driver for
>> memory block devices becomes way easier (so user space is able to
>> distinguish different types of added memory to properly online it).
>>
>> Patch 1 makes sure the memory block size granularity is always respected.
>> Patch 2 implements arch_remove_memory() on s390x. Patch 3 prepares
>> arch_remove_memory() to be also called without CONFIG_MEMORY_HOTREMOVE.
>> Patch 4,5 and 6 factor out creation/removal of memory block devices.
>> Patch 7 gets rid of some unlikely errors that could have happened, not
>> removing links between memory block devices and nodes, previously brought
>> up by Oscar.
>>
>> Did a quick sanity test with DIMM plug/unplug, making sure all devices
>> and sysfs links properly get added/removed. Compile tested on s390x and
>> x86-64.
>>
>> Based on git://git.cmpxchg.org/linux-mmots.git
>>
>> Next refactoring on my list will be making sure that remove_memory()
>> will never deal with zones / access "struct pages". Any kind of zone
>> handling will have to be done when offlining system memory / before
>> removing device memory. I am thinking about remove_pfn_range_from_zone()",
>> du undo everything "move_pfn_range_to_zone()" did.
>>
>> v1 -> v2:
>> - s390x/mm: Implement arch_remove_memory()
>> -- remove mapping after "__remove_pages"
>>
>>
>> David Hildenbrand (8):
>>   mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
>>   s390x/mm: Implement arch_remove_memory()
>>   mm/memory_hotplug: arch_remove_memory() and __remove_pages() with
>>     CONFIG_MEMORY_HOTPLUG
>>   mm/memory_hotplug: Create memory block devices after arch_add_memory()
>>   mm/memory_hotplug: Drop MHP_MEMBLOCK_API
> 
> So at a minimum we need a bit of patch staging guidance because this
> obviously collides with the subsection bits that are built on top of
> the existence of MHP_MEMBLOCK_API. What trigger do you envision as a
> replacement that arch_add_memory() use to determine that subsection
> operations should be disallowed?
> 

Looks like we now have time to sort it out :)


Looking at your series

[PATCH v8 08/12] mm/sparsemem: Prepare for sub-section ranges

is the "single" effectively place using MHP_MEMBLOCK_API, namely
"subsection_check()". Used when adding/removing memory.


+static int subsection_check(unsigned long pfn, unsigned long nr_pages,
+		unsigned long flags, const char *reason)
+{
+	/*
+	 * Only allow partial section hotplug for !memblock ranges,
+	 * since register_new_memory() requires section alignment, and
+	 * CONFIG_SPARSEMEM_VMEMMAP=n requires sections to be fully
+	 * populated.
+	 */
+	if ((!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
+				|| (flags & MHP_MEMBLOCK_API))
+			&& ((pfn & ~PAGE_SECTION_MASK)
+				|| (nr_pages & ~PAGE_SECTION_MASK))) {
+		WARN(1, "Sub-section hot-%s incompatible with %s\n", reason,
+				(flags & MHP_MEMBLOCK_API)
+				? "memblock api" : "!CONFIG_SPARSEMEM_VMEMMAP");
+		return -EINVAL;
+	}
+	return 0;
 }


(flags & MHP_MEMBLOCK_API)) && ((pfn & ~PAGE_SECTION_MASK) || (nr_pages
& ~PAGE_SECTION_MASK)))

sounds like something the caller (add_memory()) always has to take care
of. No need to check. The one imposing this restriction is the only caller.

In my opinion, that check/function can go completely.

Am I missing something / missing another user?

-- 

Thanks,

David / dhildenb

