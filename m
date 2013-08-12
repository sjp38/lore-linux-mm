Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DCC356B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 14:23:31 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7859208pad.19
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:23:31 -0700 (PDT)
Message-ID: <52092811.3020105@gmail.com>
Date: Tue, 13 Aug 2013 02:23:13 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <5208FBBC.2080304@zytor.com> <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com> <20130812164650.GN15892@htj.dyndns.org>
In-Reply-To: <20130812164650.GN15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On 08/13/2013 12:46 AM, Tejun Heo wrote:
> Hello, Tang.
......
>
>> But, different users have different ways to use memory hotplug.
>>
>> Hotswaping any particular chunk of memory is the goal we will reach
>> finally. But it is on specific hardware. In most current machines, we
>> can use movable node to manage resource in node unit.
>>
>> And also, without this movablenode boot option, the MOVABLE_NODE
>> functionality, which is already in the kernel, will not be able to
>> work. All nodes has kernel memory means no movable node.
>>
>> So, how about this: Just like MOVABLE_NODE functionality, introduce
>> a new config option. When we have better solutions for memory hotplug,
>> we shutoff or remove the config and related code.
>>
>> For now, at least make movable node work.

Hi tj,
cc hpa,

I explained above because hpa said he thought the whole approach is
wrong. I think node hotplug is meaningful for users. And without this
patch-set, MOVABLE_NODE means nothing. This is all above.

Since you replied his email in previous emails, I just replied to
answer both of you. Sorry for the misunderstanding. :)

>
> We are talking completely past each other.  I'll just try to clarify
> what I was saying.  Can you please do the same?  Let's re-sync on the
> discussion.
>
> * Adding an option to tell the kernel to try to stay away from
>    hotpluggable nodes is fine.  I have no problem with that at all.

Agreed.

>
> * The patchsets upto this point have been somehow trying to reorder
>    operations shomehow such that *no* memory allocation happens before
>    memblock is populated with hotplug information.

Yes, this is exactly what I want to do.

>
> * However, we already *know* that the memory the kernel image is
>    occupying won't be removeable.  It's highly likely that the amount
>    of memory allocation before NUMA / hotplug information is fully
>    populated is pretty small.  Also, it's highly likely that small
>    amount of memory right after the kernel image is contained in the
>    same NUMA node, so if we allocate memory close to the kernel image,
>    it's likely that we don't contaminate hotpluggable node.  We're
>    talking about few megs at most right after the kernel image.  I
>    can't see how that would make any noticeable difference.

This point, I don't quite agree. What you said is highly likely, but
not definitely. Users may find they lost hotpluggable memory.

The node the kernel resides in won't be removable. This is agreed.
But I still want SRAT earlier for the following reasons:

1. For a production provided to users, the firmware specified how
    many nodes are hotpluggable. When the system is up, if users
    found they lost movable nodes, I think it could be messy.

2. Reorder SRAT parsing earlier is not that difficult to do. The
    only procedures reordered are acpi tables initialization and
    acpi_initrd_override. The acpi part patches are being reviewed.
    And it is better solution. If possible, I think we should do it.

In summary, I don't want early memory allocation with hotpluggable
memory to be opportunistic.

>
> * Once hotplug information is available, allocation can happen as
>    usual and the kernel can report the nodes which are actually
>    hotpluggable - marked as hotpluggable by the firmware&&  didn't get
>    contaminated during early alloc&&  didn't get overflow allocations
>    afterwards.  Note that we need such mechanism no matter what as the
>    kernel image can be loaded into hotpluggable nodes and reporting
>    that to userland is the only thing the kernel can do for cases like
>    that short of denying memory unplug on such nodes.

Agreed.

>
> The whole thing would be a lot simpler and generic.  It doesn't even
> have to care about which mechanism is being used to acquire all those
> information.  What am I missing here?

Sorry for the misunderstanding.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
