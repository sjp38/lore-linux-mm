Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CA1758D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:59:06 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2967770dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:59:06 -0800 (PST)
Message-ID: <50C0CED5.8050106@gmail.com>
Date: Fri, 07 Dec 2012 00:59:01 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <50B5EFE9.3040206@huawei.com> <1354128096.26955.276.camel@misato.fc.hp.com> <75241306.UQIr1RW8Qh@vostro.rjw.lan> <20121129113635.GC639@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20121129113635.GC639@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>, Hanjun Guo <guohanjun@huawei.com>, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On 11/29/2012 07:36 PM, Vasilis Liaskovitis wrote:
> On Thu, Nov 29, 2012 at 11:15:31AM +0100, Rafael J. Wysocki wrote:
>> On Wednesday, November 28, 2012 11:41:36 AM Toshi Kani wrote:
>>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
>>>> We met the same problem when we doing computer node hotplug, It is a good idea
>>>> to introduce prepare_remove before actual device removal.
>>>>
>>>> I think we could do more in prepare_remove, such as rollback. In most cases, we can
>>>> offline most of memory sections except kernel used pages now, should we rollback
>>>> and online the memory sections when prepare_remove failed ?
>>>
>>> I think hot-plug operation should have all-or-nothing semantics.  That
>>> is, an operation should either complete successfully, or rollback to the
>>> original state.
>>
>> That's correct.
>>
>>>> As you may know, the ACPI based hotplug framework we are working on already addressed
>>>> this problem, and the way we slove this problem is a bit like yours.
>>>>
>>>> We introduce hp_ops in struct acpi_device_ops:
>>>> struct acpi_device_ops {
>>>> 	acpi_op_add add;
>>>> 	acpi_op_remove remove;
>>>> 	acpi_op_start start;
>>>> 	acpi_op_bind bind;
>>>> 	acpi_op_unbind unbind;
>>>> 	acpi_op_notify notify;
>>>> #ifdef	CONFIG_ACPI_HOTPLUG
>>>> 	struct acpihp_dev_ops *hp_ops;
>>>> #endif	/* CONFIG_ACPI_HOTPLUG */
>>>> };
>>>>
>>>> in hp_ops, we divide the prepare_remove into six small steps, that is:
>>>> 1) pre_release(): optional step to mark device going to be removed/busy
>>>> 2) release(): reclaim device from running system
>>>> 3) post_release(): rollback if cancelled by user or error happened
>>>> 4) pre_unconfigure(): optional step to solve possible dependency issue
>>>> 5) unconfigure(): remove devices from running system
>>>> 6) post_unconfigure(): free resources used by devices
>>>>
>>>> In this way, we can easily rollback if error happens.
>>>> How do you think of this solution, any suggestion ? I think we can achieve
>>>> a better way for sharing ideas. :)
>>>
>>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
>>> have not looked at all your changes yet..), but in my mind, a hot-plug
>>> operation should be composed with the following 3 phases.
>>>
>>> 1. Validate phase - Verify if the request is a supported operation.  All
>>> known restrictions are verified at this phase.  For instance, if a
>>> hot-remove request involves kernel memory, it is failed in this phase.
>>> Since this phase makes no change, no rollback is necessary to fail.  
>>
>> Actually, we can't do it this way, because the conditions may change between
>> the check and the execution.  So the first phase needs to involve execution
>> to some extent, although only as far as it remains reversible.
>>
>>> 2. Execute phase - Perform hot-add / hot-remove operation that can be
>>> rolled-back in case of error or cancel.
>>
>> I would just merge 1 and 2.
> 
> I agree steps 1 and 2 can be merged, at least for the current ACPI framework.
> E.g. for memory hotplug, the mm function we call for memory removal
> (remove_memory) handles both these steps.
> 
> The new ACPI framework could perhaps expand the operations as Hanjun described,
> if it makes sense.
Hi Vasilis,
	We have worked some prototypes to split the memory hotplug logic in mem_hotplug.c
into minor steps, so it would be easier for error handling/cancellation. But we still
need to improve the code quality and merge with changes from Fujitsu.
Regards!

> 
> thanks,
> 
> - Vasilis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
