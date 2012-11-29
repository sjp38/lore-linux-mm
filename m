Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id CEEA56B004D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:35:37 -0500 (EST)
Message-ID: <1354228028.7776.56.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 29 Nov 2012 15:27:08 -0700
In-Reply-To: <50B6E936.2080308@huawei.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	  <50B5EFE9.3040206@huawei.com>
	 <1354128096.26955.276.camel@misato.fc.hp.com> <50B6E936.2080308@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, Huxinwei <huxinwei@huawei.com>

On Thu, 2012-11-29 at 12:48 +0800, Hanjun Guo wrote:
> On 2012/11/29 2:41, Toshi Kani wrote:
> > On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
> >> On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
> >>> As discussed in https://patchwork.kernel.org/patch/1581581/
> >>> the driver core remove function needs to always succeed. This means we need
> >>> to know that the device can be successfully removed before acpi_bus_trim / 
> >>> acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> >>> or SCI-initiated eject of memory devices fail e.g with:
> >>> echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> >>>
> >>> since the ACPI core goes ahead and ejects the device regardless of whether the
> >>> the memory is still in use or not.
> >>>
> >>> For this reason a new acpi_device operation called prepare_remove is introduced.
> >>> This operation should be registered for acpi devices whose removal (from kernel
> >>> perspective) can fail.  Memory devices fall in this category.
> >>>
> >>> acpi_bus_remove() is changed to handle removal in 2 steps:
> >>> - preparation for removal i.e. perform part of removal that can fail. Should
> >>>   succeed for device and all its children.
> >>> - if above step was successfull, proceed to actual device removal
> >>
> >> Hi Vasilis,
> >> We met the same problem when we doing computer node hotplug, It is a good idea
> >> to introduce prepare_remove before actual device removal.
> >>
> >> I think we could do more in prepare_remove, such as rollback. In most cases, we can
> >> offline most of memory sections except kernel used pages now, should we rollback
> >> and online the memory sections when prepare_remove failed ?
> > 
> > I think hot-plug operation should have all-or-nothing semantics.  That
> > is, an operation should either complete successfully, or rollback to the
> > original state.
> 
> Yes, we have the same point of view with you. We handle this problem in the ACPI
> based hot-plug framework as following:
> 1) hot add / hot remove complete successfully if no error happens;
> 2) automatic rollback to the original state if meets some error ;
> 3) rollback to the original if hot-plug operation cancelled by user ;

Cool!
 
> >> As you may know, the ACPI based hotplug framework we are working on already addressed
> >> this problem, and the way we slove this problem is a bit like yours.
> >>
> >> We introduce hp_ops in struct acpi_device_ops:
> >> struct acpi_device_ops {
> >> 	acpi_op_add add;
> >> 	acpi_op_remove remove;
> >> 	acpi_op_start start;
> >> 	acpi_op_bind bind;
> >> 	acpi_op_unbind unbind;
> >> 	acpi_op_notify notify;
> >> #ifdef	CONFIG_ACPI_HOTPLUG
> >> 	struct acpihp_dev_ops *hp_ops;
> >> #endif	/* CONFIG_ACPI_HOTPLUG */
> >> };
> >>
> >> in hp_ops, we divide the prepare_remove into six small steps, that is:
> >> 1) pre_release(): optional step to mark device going to be removed/busy
> >> 2) release(): reclaim device from running system
> >> 3) post_release(): rollback if cancelled by user or error happened
> >> 4) pre_unconfigure(): optional step to solve possible dependency issue
> >> 5) unconfigure(): remove devices from running system
> >> 6) post_unconfigure(): free resources used by devices
> >>
> >> In this way, we can easily rollback if error happens.
> >> How do you think of this solution, any suggestion ? I think we can achieve
> >> a better way for sharing ideas. :)
> > 
> > Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
> > have not looked at all your changes yet..), but in my mind, a hot-plug
> > operation should be composed with the following 3 phases.
> 
> Good idea ! we also implement a hot-plug operation in 3 phases:
> 1) acpihp_drv_pre_execute
> 2) acpihp_drv_execute
> 3) acpihp_drv_post_execute
> you may refer to :
> https://lkml.org/lkml/2012/11/4/79

Great.  Yes, I will take a look.
 
> > 1. Validate phase - Verify if the request is a supported operation.  All
> > known restrictions are verified at this phase.  For instance, if a
> > hot-remove request involves kernel memory, it is failed in this phase.
> > Since this phase makes no change, no rollback is necessary to fail. 
> 
> Yes, we have done this in acpihp_drv_pre_execute, and check following things:
> 
> 1) Hot-plugble or not. the instance kernel memory you mentioned is also checked
>    when memory device remove;

Agreed.

> 2) Dependency check involved. For instance, if hot-add a memory device,
>    processor should be added first, otherwise it's not valid to this operation.

I think FW should be the one that assures such dependency.  That is,
when a memory device object is marked as present/enabled/functioning, it
should be ready for the OS to use.

> 3) Race condition check. if the device and its dependent device is in hot-plug
>    process, another request will be denied.

I agree that hot-plug operation should be serialized.  I think another
request should be either queued or denied based on the caller's intent
(i.e. wait-ok or no-wait). 

> No rollback is needed for the above checks.

Great.

> > 2. Execute phase - Perform hot-add / hot-remove operation that can be
> > rolled-back in case of error or cancel.
> 
> In this phase, we introduce a state machine for the hot-plugble device,
> please refer to:
> https://lkml.org/lkml/2012/11/4/79
> 
> I think we have the same idea for the major framework, but the ACPI based
> hot-plug framework implement it differently in detail, right ?

Yes, I am surprised with the similarity.  What I described is something
we had implemented for other OS.  I am still studying how best we can
improve the Linux hotplug code. :)

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
