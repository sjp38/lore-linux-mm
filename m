Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 722E76B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 11:54:24 -0500 (EST)
Received: by ykfs79 with SMTP id s79so14451098ykf.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 08:54:24 -0800 (PST)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id o85si32423448ywd.263.2015.12.01.08.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 08:54:23 -0800 (PST)
Received: by ykdv3 with SMTP id v3so14356331ykd.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 08:54:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151201135000.GB4341@pd.tnic>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
	<1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
	<20151201135000.GB4341@pd.tnic>
Date: Tue, 1 Dec 2015 08:54:23 -0800
Message-ID: <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Dec 1, 2015 at 5:50 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Nov 24, 2015 at 03:33:36PM -0700, Toshi Kani wrote:
>> region_intersects() checks if a specified region partially overlaps
>> or fully eclipses a resource identified by @name.  It currently sets
>> resource flags statically, which prevents the caller from specifying
>> a non-RAM region, such as persistent memory.  Add @flags so that
>> any region can be specified to the function.
>>
>> A helper function, region_intersects_ram(), is added so that the
>> callers that check a RAM region do not have to specify its iomem
>> resource name and flags.  This interface is exported for modules,
>> such as the EINJ driver.
>>
>> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Vishal Verma <vishal.l.verma@intel.com>
>> ---
>>  include/linux/mm.h |    4 +++-
>>  kernel/memremap.c  |    5 ++---
>>  kernel/resource.c  |   23 ++++++++++++++++-------
>>  3 files changed, 21 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 00bad77..c776af3 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -362,7 +362,9 @@ enum {
>>       REGION_MIXED,
>>  };
>>
>> -int region_intersects(resource_size_t offset, size_t size, const char *type);
>> +int region_intersects(resource_size_t offset, size_t size, const char *type,
>> +                     unsigned long flags);
>> +int region_intersects_ram(resource_size_t offset, size_t size);
>>
>>  /* Support for virtually mapped pages */
>>  struct page *vmalloc_to_page(const void *addr);
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index 7658d32..98f52f1 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -57,7 +57,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
>>   */
>>  void *memremap(resource_size_t offset, size_t size, unsigned long flags)
>>  {
>> -     int is_ram = region_intersects(offset, size, "System RAM");
>
> Ok, question: why do those resource things types gets identified with
> a string?! We have here "System RAM" and next patch adds "Persistent
> Memory".
>
> And "persistent memory" or "System RaM" won't work and this is just
> silly.
>
> Couldn't struct resource have gained some typedef flags instead which we
> can much easily test? Using the strings looks really yucky.
>

At least in the case of region_intersects() I was just following
existing strcmp() convention from walk_system_ram_range.

We could define 'const char *system_ram = "System RAM"' somewhere and
then do pointer comparisons to cut down on the thrash of adding new
flags to 'struct resource'?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
