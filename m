Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 681636B0010
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 05:57:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5-v6so7045193pgs.13
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:57:40 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t64-v6si18001763pfj.338.2018.08.13.02.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 02:57:39 -0700 (PDT)
Subject: Re: [PATCH V3 3/4] mm: add a function to differentiate the pages is
 from DAX device memory
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <2b7856596e519130946c834d5d61b00b7f592770.1533811181.git.yi.z.zhang@linux.intel.com>
 <872818364.892078.1533806608252.JavaMail.zimbra@redhat.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <5ea50e63-b55a-c1e1-50be-6e2d951c04cf@linux.intel.com>
Date: Tue, 14 Aug 2018 01:41:40 +0800
MIME-Version: 1.0
In-Reply-To: <872818364.892078.1533806608252.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>



On 2018a1'08ae??09ae?JPY 17:23, Pankaj Gupta wrote:
>> DAX driver hotplug the device memory and move it to memory zone, these
>> pages will be marked reserved flag, however, some other kernel componet
>> will misconceive these pages are reserved mmio (ex: we map these dev_dax
>> or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
>> MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
>> is DAX device memory or not.
>>
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
>> ---
>>  include/linux/mm.h | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 68a5121..de5cbc3 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -889,6 +889,13 @@ static inline bool is_device_public_page(const struct
>> page *page)
>>  		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
>>  }
>>  
>> +static inline bool is_dax_page(const struct page *page)
>> +{
>> +	return is_zone_device_page(page) &&
>> +		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
>> +		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
>> +}
> I think question from Dan for KVM VM with 'MEMORY_DEVICE_PUBLIC' still holds?
> I am also interested to know if there is any use-case.
>
> Thanks,
> Pankaj
Yes, it is, thanks for your remind, Pankaj.
Adding Jerome for Dan's questions on V1:
[Dan]:

Jerome, might there be any use case to pass MEMORY_DEVICE_PUBLIC
memory to a guest vm?

>
>> +
>>  #else /* CONFIG_DEV_PAGEMAP_OPS */
>>  static inline void dev_pagemap_get_ops(void)
>>  {
>> @@ -912,6 +919,11 @@ static inline bool is_device_public_page(const struct
>> page *page)
>>  {
>>  	return false;
>>  }
>> +
>> +static inline bool is_dax_page(const struct page *page)
>> +{
>> +	return false;
>> +}
>>  #endif /* CONFIG_DEV_PAGEMAP_OPS */
>>  
>>  static inline void get_page(struct page *page)
>> --
>> 2.7.4
>>
>>
