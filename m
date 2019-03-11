Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82F9EC10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:55:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 270572084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:55:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 270572084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E978E0011; Mon, 11 Mar 2019 05:55:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC4098E0002; Mon, 11 Mar 2019 05:55:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 964F78E0011; Mon, 11 Mar 2019 05:55:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7130A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:55:52 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r9so4062462qkl.4
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:55:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=riAe35dqr9XQmqofZYHOORqZBc5MrE2sNaC4T6C5hF0=;
        b=ejGdCWRIrD4/EsHhRPj4GgzF+TKpuzypeEC2I4m7On7DK4vtabp6JJzmuN5EBCASqJ
         0uwb6iH2IG1Or8UCfG0Asqb93tnYZjoz6XZwfne59jY4xghWBM3SE/WQdHxSPcKAN2KC
         1MeD8666QuQaIMzySX7itLyc38CrXTj0VLiniLmqQDj4qwgdiBHhCRbGp+Mx44gp2oWk
         oDwTPQU7DgsV7oev6yyUj6CAco6nLr2c4diKkZB3kXrwCbZhQhqeG/9cYab/tL0egRcU
         boi8wf3stBk8XcGYxutZpDlO6mmEBcrK7k3jMjXPPl+bVQyXjhQt5y5O+Y+M7kISqFb1
         ksQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUiQRTtT1m769t58VskwrCcU4FmD4xn+3ulVwp4OG6v/NDMzV9T
	xiXqC/DvSyiMbBtRBLWr3XTdgp/1G0OHcxxnBuHbvxwKKFIDeCynvsSvik2C2INNaSnQj2XcEVE
	I+xMRgJLyXdAeRqnue3SeEu6l3K46ogf1oJq6VguSzrfi+zWBV+ha7hpTmD4SloXc6w==
X-Received: by 2002:a0c:c906:: with SMTP id r6mr25196117qvj.121.1552298152223;
        Mon, 11 Mar 2019 02:55:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlBhlzD/8hJCmLhJMZoGc82OAWjeLZ+fUFW0Q8fW4qAXpywlIbcBV4MdvvHToYtXl6Uxu0
X-Received: by 2002:a0c:c906:: with SMTP id r6mr25196085qvj.121.1552298151434;
        Mon, 11 Mar 2019 02:55:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552298151; cv=none;
        d=google.com; s=arc-20160816;
        b=v0VzFy6iverfZSQKMAy3288ji3MxszZS0ZQGhLdMxV5AL7XoYGtdTS8AgG70CAbKQn
         NMf3jcz808w/jcCBXOnJAjPgrauGIvNjjci/8uqI7WCtNZkCfQ9G8m0A/FF8YaCuJdwx
         THD1uCvQb4hfG6LC6hI1fayPxP6kRrlrysyx/GzjIHMT/avz17K4fClsWTTGOiW4f/2j
         KjGAxX1hcGhpH4gQ/ym6cltiJ95kToMg+uC6vcIQd7wd1JcGV06m4PWR6OIk+W/eXaj0
         Lj1wWtibNLMPKUN1rcirK9euHSthGdR+8sQLY6YArVyTOoyTbCmoVTiZ0uZfl/F4i8kJ
         PNiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=riAe35dqr9XQmqofZYHOORqZBc5MrE2sNaC4T6C5hF0=;
        b=HH97yOLg2AcuiWBBzAMO5kXbbnCUEq5WCaLEbrMK15jqMuQG1KF+9nf7rQVLJtYihh
         A1pKRhuDAHpf/DSY9HROGExEq44CkepdfhWDVFvgVKZob7n0OQTL3F5PqaqO/QJcfzBd
         A0iToHIR0xOfAMntsTPS+DktPhh547vjU+LeRlVwHMcGic14XKlUDvbf8804zLSUlTfs
         kP6Aq8eocu4LOQFvgvJZTQC8ShHuC2yF5GWAuLsf9ckM9CB/xaGYm1xfyasWasHmsGLS
         UkqScYZh6IXhUabeyqkCKxAQ+qStalmPOgEnfE0oVASsjP37JOOoqB+eum2EKwIwx1HG
         Imag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v74si1645330qkl.213.2019.03.11.02.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:55:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3832CC057F3F;
	Mon, 11 Mar 2019 09:55:50 +0000 (UTC)
Received: from [10.36.117.207] (ovpn-117-207.ams2.redhat.com [10.36.117.207])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CCD605D706;
	Mon, 11 Mar 2019 09:55:41 +0000 (UTC)
Subject: Re: [PATCH v2 3/8] kexec: export PG_offline to VMCOREINFO
To: Dave Young <dyoung@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, devel@linuxdriverproject.org,
 linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org,
 xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>,
 pv-drivers@vmware.com, Andrew Morton <akpm@linux-foundation.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>,
 Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 Lianbo Jiang <lijiang@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Kazuhito Hagio <k-hagio@ab.jp.nec.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100627.5189-4-david@redhat.com>
 <20190311090402.GA12071@dhcp-128-65.nay.redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d9e578c3-5ae6-5e82-a0a8-14c7e12c729f@redhat.com>
Date: Mon, 11 Mar 2019 10:55:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190311090402.GA12071@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 11 Mar 2019 09:55:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.03.19 10:04, Dave Young wrote:
> Hi David,
> On 11/22/18 at 11:06am, David Hildenbrand wrote:
>> Right now, pages inflated as part of a balloon driver will be dumped
>> by dump tools like makedumpfile. While XEN is able to check in the
>> crash kernel whether a certain pfn is actuall backed by memory in the
>> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
>> other balloon inflated memory will essentially result in zero pages getting
>> allocated by the hypervisor and the dump getting filled with this data.
>>
>> The allocation and reading of zero pages can directly be avoided if a
>> dumping tool could know which pages only contain stale information not to
>> be dumped.
>>
>> We now have PG_offline which can be (and already is by virtio-balloon)
>> used for marking pages as logically offline. Follow up patches will
>> make use of this flag also in other balloon implementations.
>>
>> Let's export PG_offline via PAGE_OFFLINE_MAPCOUNT_VALUE, so
>> makedumpfile can directly skip pages that are logically offline and the
>> content therefore stale. (we export is as a macro to match how it is
>> done for PG_buddy. This way it is clearer that this is not actually a flag
>> but only a very specific mapcount value to represent page types).
>>
>> Please note that this is also helpful for a problem we were seeing under
>> Hyper-V: Dumping logically offline memory (pages kept fake offline while
>> onlining a section via online_page_callback) would under some condicions
>> result in a kernel panic when dumping them.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Dave Young <dyoung@redhat.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Baoquan He <bhe@redhat.com>
>> Cc: Omar Sandoval <osandov@fb.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Lianbo Jiang <lijiang@redhat.com>
>> Cc: Borislav Petkov <bp@alien8.de>
>> Cc: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
>> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> Acked-by: Dave Young <dyoung@redhat.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  kernel/crash_core.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
>> index 933cb3e45b98..093c9f917ed0 100644
>> --- a/kernel/crash_core.c
>> +++ b/kernel/crash_core.c
>> @@ -464,6 +464,8 @@ static int __init crash_save_vmcoreinfo_init(void)
>>  	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
>>  #ifdef CONFIG_HUGETLB_PAGE
>>  	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
>> +#define PAGE_OFFLINE_MAPCOUNT_VALUE	(~PG_offline)
>> +	VMCOREINFO_NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE);
>>  #endif
>>  
>>  	arch_crash_save_vmcoreinfo();
> 
> The patch has been merged, would you mind to send a documentation patch
> for the vmcoreinfo, which is added recently in Documentation/kdump/vmcoreinfo.txt
> 
> A brief description about how this vmcoreinfo field is used is good to
> have.
> 

Turns out, it was already documented

PG_lru|PG_private|PG_swapcache|PG_swapbacked|PG_slab|PG_hwpoision
|PG_head_mask|PAGE_BUDDY_MAPCOUNT_VALUE(~PG_buddy)
|PAGE_OFFLINE_MAPCOUNT_VALUE(~PG_offline)
-----------------------------------------------------------------

Page attributes. These flags are used to filter various unnecessary for
dumping pages.


Thanks!

> Thanks
> Dave
> 


-- 

Thanks,

David / dhildenb

