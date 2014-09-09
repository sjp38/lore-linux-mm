Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 166CF6B0093
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 12:29:57 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so7367993pdb.39
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 09:29:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fv3si16468124pbb.222.2014.09.09.09.29.55
        for <linux-mm@kvack.org>;
        Tue, 09 Sep 2014 09:29:56 -0700 (PDT)
Message-ID: <540F2ADF.8040106@intel.com>
Date: Tue, 09 Sep 2014 09:29:19 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com> <53F75562.7040100@intel.com> <540F27D4.3000709@plexistor.com>
In-Reply-To: <540F27D4.3000709@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 09/09/2014 09:16 AM, Boaz Harrosh wrote:
> On 08/22/2014 05:36 PM, Dave Hansen wrote:
>> Is there a reason you don't just do this at boot and have to use hotplug
>> at runtime for it?  
> 
> This is a plug and play thing. This memory region is not reached via memory
> controller, it is on the ACPI/SBUS device with physical address/size specified
> there. On load of block-device this will be called. Also a block device can
> be unloaded and should be able to cleanup.

OK, cool.

>> What are the ratio of pmem to RAM?  Is it possible
>> to exhaust all of RAM with 'struct page's for pmem?
> 
> Yes! in the not very distant future there will be systems that have only pmem.
> yes no RAM. This is because once available some pmem has much better power
> efficiency then DRAM, because of the no refresh thing. So even cellphones and
> embedded system first.
...
> So the Admin/setup will need to calculate and configure the proper ratio of
> volatile vs non-volatile portions of its system for proper usage.

I'm just worried that somebody will plug a card in, and immediately OOM
the system.  Or, even worse, a card gets plugged in and 98% of the RAM
gets used by this prd driver and the kernel performs horribly.

I think we probably need to have some tracking of how much memory is
getting used for these mem_map[]s, and make sure they don't get out of hand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
