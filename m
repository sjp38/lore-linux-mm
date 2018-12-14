Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 637558E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:56:22 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id v184so2564592oie.6
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:56:22 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u6si2559582otj.171.2018.12.14.05.56.20
        for <linux-mm@kvack.org>;
        Fri, 14 Dec 2018 05:56:20 -0800 (PST)
Subject: Re: [PATCH v7 04/25] ACPI / APEI: Make hest.c manage the estatus
 memory pool
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-5-james.morse@arm.com>
 <20181211164802.GI27375@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <ad48f9a1-404e-7878-3173-f8a4a417a723@arm.com>
Date: Fri, 14 Dec 2018 13:56:16 +0000
MIME-Version: 1.0
In-Reply-To: <20181211164802.GI27375@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi Boris,

On 11/12/2018 16:48, Borislav Petkov wrote:
> On Mon, Dec 03, 2018 at 06:05:52PM +0000, James Morse wrote:
>> ghes.c has a memory pool it uses for the estatus cache and the estatus
>> queue. The cache is initialised when registering the platform driver.
>> For the queue, an NMI-like notification has to grow/shrink the pool
>> as it is registered and unregistered.
>>
>> This is all pretty noisy when adding new NMI-like notifications, it
>> would be better to replace this with a static pool size based on the
>> number of users.
>>
>> As a precursor, move the call that creates the pool from ghes_init(),
>> into hest.c. Later this will take the number of ghes entries and
>> consolidate the queue allocations.
>> Remove ghes_estatus_pool_exit() as hest.c doesn't have anywhere to put
>> this.
>>
>> The pool is now initialised as part of ACPI's subsys_initcall():
>> (acpi_init(), acpi_scan_init(), acpi_pci_root_init(), acpi_hest_init())
>> Before this patch it happened later as a GHES specific device_initcall().

>> diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
>> index b1e9f81ebeea..da5fabaeb48f 100644
>> --- a/drivers/acpi/apei/hest.c
>> +++ b/drivers/acpi/apei/hest.c
>> @@ -32,6 +32,7 @@
>>  #include <linux/io.h>
>>  #include <linux/platform_device.h>
>>  #include <acpi/apei.h>
>> +#include <acpi/ghes.h>
>>  
>>  #include "apei-internal.h"
>>  
>> @@ -200,6 +201,10 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
>>  	if (!ghes_arr.ghes_devs)
>>  		return -ENOMEM;
>>  
>> +	rc = ghes_estatus_pool_init();
>> +	if (rc)
>> +		goto out;
> 
> Right, this happens before...
> 
>> +
>>  	rc = apei_hest_parse(hest_parse_ghes, &ghes_arr);
> 
> ... this but do we even want to do any memory allocations if we don't
> have any HEST tables or we've been disabled by hest_disable?

I agree we shouldn't,


> IOW, we should swap those two calls, methinks.

/me digs a bit,

ghes_estatus_pool_init() allocates memory from hest_ghes_dev_register().
Its caller is behind a 'if (!ghes_disable)' in acpi_hest_init(), and is after
another 2 calls to apei_hest_parse().

If ghes_disable is set, we don't call this thing.
If hest_disable is set, acpi_hest_init() exits early.
If we don't have a HEST table, acpi_hest_init() exits early.

... if the HEST table doesn't have any GHES entries, hest_ghes_dev_register() is
called with ghes_count==0, and does nothing useful. (kmalloc_alloc_array(0,...)
great!) But we do call ghes_estatus_pool_init().

I think a check that ghes_count is non-zero before calling
hest_ghes_dev_register() is the cleanest way to avoid this.

I wanted the estatus pool to be initialised before creating the platform devices
in case the order of these things is changed in the future and they get probed
immediately, before the pool is initialised.


Thanks,

James
