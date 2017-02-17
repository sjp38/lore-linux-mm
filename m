Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6FCF681021
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 22:28:59 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s36so40843685otd.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 19:28:59 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id d21si466440oig.82.2017.02.16.19.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 19:28:58 -0800 (PST)
Received: by mail-oi0-x230.google.com with SMTP id u143so18787067oif.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 19:28:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170217030802.GA27382@linux.intel.com>
References: <148728202805.38457.18028105614854319884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <148728203880.38457.1158394701925100383.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170217030802.GA27382@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 16 Feb 2017 19:28:57 -0800
Message-ID: <CAPcyv4grRsV1XH-w1GG0q4aNEJCUsPm4SNL280V=X_8w7X1TXQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm: validate device_hotplug is held for memory hotplug
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux MM <linux-mm@kvack.org>, Ben Hutchings <ben@decadent.org.uk>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Feb 16, 2017 at 7:08 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Thu, Feb 16, 2017 at 01:53:58PM -0800, Dan Williams wrote:
>> mem_hotplug_begin() assumes that it can set mem_hotplug.active_writer
>> and run the hotplug process without racing another thread. Validate this
>> assumption with a lockdep assertion.
>>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Toshi Kani <toshi.kani@hpe.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Logan Gunthorpe <logang@deltatee.com>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Reported-by: Ben Hutchings <ben@decadent.org.uk>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  drivers/base/core.c    |    5 +++++
>>  include/linux/device.h |    1 +
>>  mm/memory_hotplug.c    |    2 ++
>>  3 files changed, 8 insertions(+)
>>
>> diff --git a/drivers/base/core.c b/drivers/base/core.c
>> index 8c25e68e67d7..3050e6f99403 100644
>> --- a/drivers/base/core.c
>> +++ b/drivers/base/core.c
>> @@ -638,6 +638,11 @@ int lock_device_hotplug_sysfs(void)
>>       return restart_syscall();
>>  }
>>
>> +void assert_held_device_hotplug(void)
>> +{
>> +     lockdep_assert_held(&device_hotplug_lock);
>> +}
>> +
>>  #ifdef CONFIG_BLOCK
>>  static inline int device_is_not_partition(struct device *dev)
>>  {
>> diff --git a/include/linux/device.h b/include/linux/device.h
>> index 491b4c0ca633..815965ee55dd 100644
>> --- a/include/linux/device.h
>> +++ b/include/linux/device.h
>> @@ -1135,6 +1135,7 @@ static inline bool device_supports_offline(struct device *dev)
>>  extern void lock_device_hotplug(void);
>>  extern void unlock_device_hotplug(void);
>>  extern int lock_device_hotplug_sysfs(void);
>> +void assert_held_device_hotplug(void);
>>  extern int device_offline(struct device *dev);
>>  extern int device_online(struct device *dev);
>>  extern void set_primary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index b8c11e063ff0..1635a2a085e5 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -126,6 +126,8 @@ void put_online_mems(void)
>>
>>  void mem_hotplug_begin(void)
>>  {
>> +     assert_held_device_hotplug();
>
> What's the benefit to defining assert_held_device_hotplug() as a one line
> wrapper, instead of just calling lockdep_assert_held(&device_hotplug_lock)
> directly?
>

This allows us to keep device_hotplug_lock statically defined and an
internal implementation detail of the device core.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
