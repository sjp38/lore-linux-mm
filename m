Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 25C7A6B0034
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:13:09 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so7567871pad.23
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:13:08 -0700 (PDT)
Message-ID: <5208FB70.5010503@gmail.com>
Date: Mon, 12 Aug 2013 23:12:48 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 1/7] x86: get pg_data_t's memory from other node
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <1375956979-31877-2-git-send-email-tangchen@cn.fujitsu.com> <20130812143910.GH15892@htj.dyndns.org>
In-Reply-To: <20130812143910.GH15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 08/12/2013 10:39 PM, Tejun Heo wrote:
> Hello,
>
> The subject is a bit misleading.  Maybe it should say "allow getting
> ..." rather than "get ..."?

Ok, followed.

>
> On Thu, Aug 08, 2013 at 06:16:13PM +0800, Tang Chen wrote:
......
>
> I suppose the above three paragraphs are trying to say
>
> * A hotpluggable NUMA node may be composed of multiple memory devices
>    which individually are hot-pluggable.
>
> * pg_data_t and page tables the serving a NUMA node may be located in
>    the same node they're serving; however, if the node is composed of
>    multiple hotpluggable memory devices, the device containing them
>    should be the last one to be removed.
>
> * For physical memory hotplug, whole NUMA node hotunplugging is fine;
>    however, in virtualizied environments, finer grained hotunplugging
>    is desirable; unfortunately, there currently is no way to which
>    specific memory device pg_data_t and page tables are allocated
>    inside making it impossible to order unpluggings of memory devices
>    of a NUMA node.  To avoid the ordering problem while allowing
>    removal of subset fo a NUMA node, it has been decided that pg_data_t
>    and page tables should be allocated on a different non-hotpluggable
>    NUMA node.
>
> Am I following it correctly?  If so, can you please update the
> description?  It's quite confusing.

Yes, you are right. I'll update the description.

> Also, the decision seems rather
> poorly made.  It should be trivial to allocate memory for pg_data_t
> and page tables in one end of the NUMA node and just record the
> boundary to distinguish between the area which can be removed any time
> and the other which can only be removed as a unit as the last step.

We have tried, but the hot-remove path is difficult to fix.

Please refer to:
https://lkml.org/lkml/2013/6/13/249

Actually, the above patch-set can achieve movable node, what you said.
But we have the following problems:

1. The device holding pagetable cannot be removed before other devices.
    In virtualization environment, it could be prlblematic.
    (https://lkml.org/lkml/2013/6/18/527)

2. It will break the semanteme of memory_block online/offline. If part
    of the memory_block is pagetable, and it is offlined, what status
    it should have ? My patches set it to offline, but the kernel
    is still using the memory.


I'm not saying it is not fixable. But we finally came to that we
may do the movable node in the current way and then improve it,
including local pgdat and pagetable. We need more discussion on that.
But it should not block the memory hotplug developping.

I suggest to do movable node in the current way first, and improve
it after this is done.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
