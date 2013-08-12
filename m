Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8FCFE6B0037
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:50:21 -0400 (EDT)
Received: by mail-vb0-f46.google.com with SMTP id p13so5797592vbe.19
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 07:50:20 -0700 (PDT)
Date: Mon, 12 Aug 2013 10:50:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130812145016.GI15892@htj.dyndns.org>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Thu, Aug 08, 2013 at 06:16:12PM +0800, Tang Chen wrote:
> [How we do this]
> 
> In ACPI, SRAT(System Resource Affinity Table) contains NUMA info. The memory
> affinities in SRAT record every memory range in the system, and also, flags
> specifying if the memory range is hotpluggable.
> (Please refer to ACPI spec 5.0 5.2.16)
> 
> With the help of SRAT, we have to do the following two things to achieve our
> goal:
> 
> 1. When doing memory hot-add, allow the users arranging hotpluggable as
>    ZONE_MOVABLE.
>    (This has been done by the MOVABLE_NODE functionality in Linux.)
> 
> 2. when the system is booting, prevent bootmem allocator from allocating
>    hotpluggable memory for the kernel before the memory initialization
>    finishes.
>    (This is what we are going to do. See below.)

I think it's in a much better shape than before but there still are a
couple things bothering me.

* Why can't it be opportunistic?  It's silly, for example, to fail
  boot because ACPI tells the kernel that all memory is hotpluggable
  especially as there'd be plenty of memory sitting around doing
  nothing and failing to boot is one of the most grave failure mode.
  The HOTPLUG flag can be advisory, right?  Try to allocate
  !hotpluggable memory first, but if that fails, ignore it and
  allocate from anywhere, much like the try_nid allocations.

* Similar to the point hpa raised.  If this can be made opportunistic,
  do we need the strict reordering to discover things earlier?
  Shouldn't it be possible to configure memblock to allocate close to
  the kernel image until hotplug and numa information is available?
  For most sane cases, the memory allocated will be contained in
  non-hotpluggable node anyway and in case they aren't hotplug
  wouldn't work but the system will boot and function perfectly fine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
