Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A4B396B0038
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:15:12 -0400 (EDT)
Message-ID: <5208FBBC.2080304@zytor.com>
Date: Mon, 12 Aug 2013 08:14:04 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org>
In-Reply-To: <20130812145016.GI15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On 08/12/2013 07:50 AM, Tejun Heo wrote:
> 
> * Why can't it be opportunistic?  It's silly, for example, to fail
>   boot because ACPI tells the kernel that all memory is hotpluggable
>   especially as there'd be plenty of memory sitting around doing
>   nothing and failing to boot is one of the most grave failure mode.
>   The HOTPLUG flag can be advisory, right?  Try to allocate
>   !hotpluggable memory first, but if that fails, ignore it and
>   allocate from anywhere, much like the try_nid allocations.
> 
> * Similar to the point hpa raised.  If this can be made opportunistic,
>   do we need the strict reordering to discover things earlier?
>   Shouldn't it be possible to configure memblock to allocate close to
>   the kernel image until hotplug and numa information is available?
>   For most sane cases, the memory allocated will be contained in
>   non-hotpluggable node anyway and in case they aren't hotplug
>   wouldn't work but the system will boot and function perfectly fine.
> 

It gets really messy if it is advisory.  Suddenly you have the user
thinking they can hotswap a memory bank and they just can't.

Overall, I'm getting convinced that this whole approach is just doomed
to failure -- it will not provide the user what they expect and what
they need, which is to be able to hotswap any particular chunk of
memory.  This means that there has to be a remapping layer, either using
the TLBs (perhaps leveraging the Xen machine page number) or using
things like QPI memory routing.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
