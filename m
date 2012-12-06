Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2E1808D0011
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 15:25:13 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
Date: Thu, 06 Dec 2012 21:30:06 +0100
Message-ID: <1759496.HMVHC2ECHC@vostro.rjw.lan>
In-Reply-To: <50C0CA90.7010608@gmail.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <1354579848.21585.54.camel@misato.fc.hp.com> <50C0CA90.7010608@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, Huxinwei <huxinwei@huawei.com>

On Friday, December 07, 2012 12:40:48 AM Jiang Liu wrote:
> On 12/04/2012 08:10 AM, Toshi Kani wrote:
> > On Mon, 2012-12-03 at 12:25 +0800, Hanjun Guo wrote:
> >> On 2012/11/30 6:27, Toshi Kani wrote:
> >>> On Thu, 2012-11-29 at 12:48 +0800, Hanjun Guo wrote:
> >>>> On 2012/11/29 2:41, Toshi Kani wrote:
> >>>>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
> >>>>>> On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
> >>>>>> As you may know, the ACPI based hotplug framework we are working on already addressed
> >>>>>> this problem, and the way we slove this problem is a bit like yours.
> >>>>>>
> >>>>>> We introduce hp_ops in struct acpi_device_ops:
> >>>>>> struct acpi_device_ops {
> >>>>>> 	acpi_op_add add;
> >>>>>> 	acpi_op_remove remove;
> >>>>>> 	acpi_op_start start;
> >>>>>> 	acpi_op_bind bind;
> >>>>>> 	acpi_op_unbind unbind;
> >>>>>> 	acpi_op_notify notify;
> >>>>>> #ifdef	CONFIG_ACPI_HOTPLUG
> >>>>>> 	struct acpihp_dev_ops *hp_ops;
> >>>>>> #endif	/* CONFIG_ACPI_HOTPLUG */
> >>>>>> };
> >>>>>>
> >>>>>> in hp_ops, we divide the prepare_remove into six small steps, that is:
> >>>>>> 1) pre_release(): optional step to mark device going to be removed/busy
> >>>>>> 2) release(): reclaim device from running system
> >>>>>> 3) post_release(): rollback if cancelled by user or error happened
> >>>>>> 4) pre_unconfigure(): optional step to solve possible dependency issue
> >>>>>> 5) unconfigure(): remove devices from running system
> >>>>>> 6) post_unconfigure(): free resources used by devices
> >>>>>>
> >>>>>> In this way, we can easily rollback if error happens.
> >>>>>> How do you think of this solution, any suggestion ? I think we can achieve
> >>>>>> a better way for sharing ideas. :)
> >>>>>
> >>>>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
> >>>>> have not looked at all your changes yet..), but in my mind, a hot-plug
> >>>>> operation should be composed with the following 3 phases.
> >>>>
> >>>> Good idea ! we also implement a hot-plug operation in 3 phases:
> >>>> 1) acpihp_drv_pre_execute
> >>>> 2) acpihp_drv_execute
> >>>> 3) acpihp_drv_post_execute
> >>>> you may refer to :
> >>>> https://lkml.org/lkml/2012/11/4/79
> >>>
> >>> Great.  Yes, I will take a look.
> >>
> >> Thanks, any comments are welcomed :)
> > 
> > If I read the code right, the framework calls ACPI drivers differently
> > at boot-time and hot-add as follows.  That is, the new entry points are
> > called at hot-add only, but .add() is called at both cases.  This
> > requires .add() to work differently.
> > 
> > Boot    : .add()
> > Hot-Add : .add(), .pre_configure(), configure(), etc.
> > 
> > I think the boot-time and hot-add initialization should be done
> > consistently.  While there is difficulty with the current boot sequence,
> > the framework should be designed to allow them consistent, not make them
> > diverged.
> Hi Toshi,
> 	We have separated hotplug operations from driver binding/unbinding interface
> due to following considerations.
> 1) Physical CPU and memory devices are initialized/used before the ACPI subsystem
>    is initialized. So under normal case, .add() of processor and acpi_memhotplug only
>    figures out information about device already in working state instead of starting
>    the device.
> 2) It's impossible to rmmod the processor and acpi_memhotplug driver at runtime 
>    if .remove() of CPU and memory drivers do really remove the CPU/memory device
>    from the system. And the ACPI processor driver also implements CPU PM funcitonality
>    other than hotplug.
> 
> And recently Rafael has mentioned that he has a long term view to get rid of the
> concept of "ACPI device". If that happens, we could easily move the hotplug
> logic from ACPI device drivers into the hotplug framework if the hotplug logic
> is separated from the .add()/.remove() callbacks. Actually we could even move all
> hotplug only logic into the hotplug framework and don't rely on any ACPI device
> driver any more. So we could get rid of all these messy things. We could achieve
> that by:
> 1) moving code shared by ACPI device drivers and the hotplug framework into the core.
> 2) moving hotplug only code to the framework.
> 
> Hi Rafael, what's your thoughts here?

I think that sounds good at the high level, but we need to get there
incrementally.  This way it will be easier to maintain backwards
compatibility and follow the changes.  Also, it will be easier for all of
the interested people from different companies to participate in the
development and make sure that everyones needs are going to be met this
way.

At this point, I'd like to see where the Toshi Kani's proposal is going to
take us.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
