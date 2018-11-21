Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A20E6B2540
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:50:49 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v74so5899586qkb.21
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:50:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si3949498qvm.119.2018.11.21.00.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 00:50:48 -0800 (PST)
Subject: Re: [PATCH v1 3/8] kexec: export PG_offline to VMCOREINFO
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-4-david@redhat.com>
 <20181121060458.GC7386@MiWiFi-R3L-srv>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ddd5a6f4-59d0-474b-45d5-3589a21ebcd4@redhat.com>
Date: Wed, 21 Nov 2018 09:50:17 +0100
MIME-Version: 1.0
In-Reply-To: <20181121060458.GC7386@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>, linux-pm@vger.kernel.org, pv-drivers@vmware.com, Borislav Petkov <bp@alien8.de>, linux-doc@vger.kernel.org, kexec-ml <kexec@lists.infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Omar Sandoval <osandov@fb.com>, Kazuhito Hagio <k-hagio@ab.jp.nec.com>, "Michael S. Tsirkin" <mst@redhat.com>, xen-devel@lists.xenproject.org, linux-fsdevel@vger.kernel.org, devel@linuxdriverproject.org, Dave Young <dyoung@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lianbo Jiang <lijiang@redhat.com>

On 21.11.18 07:04, Baoquan He wrote:
> On 11/19/18 at 11:16am, David Hildenbrand wrote:
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
> 
> This solution looks good to me. One small concern is why we don't
> export PG_offline to vmcoreinfo directly, then define
> PAGE_OFFLINE_MAPCOUNT_VALUE in makedumpfile. We have been exporting
> kernel data/MACRO directly, why this one is exceptional.
> 

1. We are much more similar to PG_buddy (in contrast to actual page
flags), and for PG_buddy it is historically handled like this (and I
think it makes sense to expose these as actual MAPCOUNT_VALUEs).

2. Right now only one page type per page is supported. Therefore only
exactly one value in mapcount indicates e.g. PageBuddy()/PageOffline().

Now, if we ever decide to change this (e.g. treat them like real flags),
it is much easier to switch to PG_offline/PG_buddy then. We can directly
see in makedumpfile that .*_MAPCOUNT_VALUE is no longer available but
instead e.g. PG_offline and PG_buddy. Instead we would no see a change
in makedumpfile and would have to rely on other properties.

If there are no strong opinions I will leave it like this.

Thanks!

> Thanks
> Baoquan
> 


-- 

Thanks,

David / dhildenb
