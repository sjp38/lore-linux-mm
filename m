Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4786B0032
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:05:58 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so2396391pbc.39
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 04:05:57 -0700 (PDT)
Received: by mail-ea0-f179.google.com with SMTP id b10so1129018eae.38
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 04:05:54 -0700 (PDT)
Date: Fri, 27 Sep 2013 13:05:49 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 6/6] mem-hotplug: Introduce movablenode boot option
Message-ID: <20130927110549.GA10214@gmail.com>
References: <5241D897.1090905@gmail.com>
 <5241DB62.2090300@gmail.com>
 <20130926145326.GH3482@htj.dyndns.org>
 <52446413.50504@gmail.com>
 <20130927062633.GB6726@gmail.com>
 <CANBD6kGStR-4dJRjoveNv7CtUu04gpsZZhBd=B6_=gMqrDZX6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANBD6kGStR-4dJRjoveNv7CtUu04gpsZZhBd=B6_=gMqrDZX6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>


* Yanfei Zhang <zhangyanfei.yes@gmail.com> wrote:

> > Also, more importantly, please explain why this needs to be a boot 
> > option. In terms of user friendliness boot options are at the bottom 
> > of the list, and boot options also don't really help feature tests.
> >
> > Presumably the feature is safe and has no costs, and hence could be 
> > added as a regular .config option, with a boot option only as an 
> > additional configurability option?
> 
> 
> Yeah, the kernel already has config MOVABLE_NODE, which is the config 
> enabing this feature, and we introduce this boot option to expand the 
> configurability.

So if this is purely a boot option to disable CONFIG_MOVABLE_NODE=y then 
this:

> +     movablenode             [KNL,X86] This parameter enables/disables the
> +                     kernel to arrange hotpluggable memory ranges recorded
> +                     in ACPI SRAT(System Resource Affinity Table) as
> +                     ZONE_MOVABLE. And these memory can be hot-removed when
> +                     the system is up.
> +                     By specifying this option, all the hotpluggable memory
> +                     will be in ZONE_MOVABLE, which the kernel cannot use.
> +                     This will cause NUMA performance down. For users who
> +                     care about NUMA performance, just don't use it.
> +                     If all the memory ranges in the system are hotpluggable,
> +                     then the ones used by the kernel at early time, such as
> +                     kernel code and data segments, initrd file and so on,
> +                     won't be set as ZONE_MOVABLE, and won't be hotpluggable.
> +                     Otherwise the kernel won't have enough memory to boot.
> +
>       MTD_Partition=  [MTD]

should be something like:

> +     movablenode     [KNL,X86] Boot-time switch to disable the effects of
> +                     CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.

And make sure that the description in mm/Kconfig is uptodate.

Having the same feature described twice in two different places will only 
create documentation bitrot and confusion. Also, the boot flag is only 
about disabling the feature, right?

Also, because the feature is named MOVABLE_NODE, the boot option should 
match that and be called movable_node - not movablenode.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
