Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 0719E6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 16:20:35 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id n1so1119911qcw.2
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 13:20:35 -0700 (PDT)
Date: Mon, 12 Aug 2013 16:20:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130812202029.GB8288@mtj.dyndns.org>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130812145016.GI15892@htj.dyndns.org>
 <5208FBBC.2080304@zytor.com>
 <20130812152343.GK15892@htj.dyndns.org>
 <52090D7F.6060600@gmail.com>
 <20130812164650.GN15892@htj.dyndns.org>
 <52092811.3020105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52092811.3020105@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <imtangchen@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

Hello,

On Tue, Aug 13, 2013 at 02:23:13AM +0800, Tang Chen wrote:
> >* However, we already *know* that the memory the kernel image is
> >   occupying won't be removeable.  It's highly likely that the amount
> >   of memory allocation before NUMA / hotplug information is fully
> >   populated is pretty small.  Also, it's highly likely that small
> >   amount of memory right after the kernel image is contained in the
> >   same NUMA node, so if we allocate memory close to the kernel image,
> >   it's likely that we don't contaminate hotpluggable node.  We're
> >   talking about few megs at most right after the kernel image.  I
> >   can't see how that would make any noticeable difference.
> 
> This point, I don't quite agree. What you said is highly likely, but
> not definitely. Users may find they lost hotpluggable memory.

I'm having difficult time buying that.  NUMA node granularity is
usually pretty large - it's in the range of gigabytes.  By comparison,
the area occupied by the kernel image is *tiny* and it's just highly
unlikely that allocating a bit more memory afterwards would lead to
any meaningful difference in hotunplug support.  The amount of memory
we're talking about is likely to be less than a meg, right?

> The node the kernel resides in won't be removable. This is agreed.
> But I still want SRAT earlier for the following reasons:
> 
> 1. For a production provided to users, the firmware specified how
>    many nodes are hotpluggable. When the system is up, if users
>    found they lost movable nodes, I think it could be messy.

How is that different from the memory occupied by kernel image?
Simply allocating early memory near kernel image is extremely unlikely
to change the situation.  Again, we're talking about tiny allocation
here.  It should be no different from having *slightly* larger kernel
image.  How is that material in any way?

> 2. Reorder SRAT parsing earlier is not that difficult to do. The
>    only procedures reordered are acpi tables initialization and
>    acpi_initrd_override. The acpi part patches are being reviewed.
>    And it is better solution. If possible, I think we should do it.

I don't think it's a better solution.  It's fragile and fiddly and
without much, if any, additional benefit.  Why should we do that when
we can almost trivially solve the problem almost in memblock proper in
a way which is completely firmware-agnostic?

But, what's the extra benefit of doing that?  Why would reserving less
than a megabyte after the kernel be so problematic to require this
invasive solution?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
