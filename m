Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 3F1EA6B0068
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:11:50 -0400 (EDT)
Message-ID: <5146E521.1040708@cn.fujitsu.com>
Date: Mon, 18 Mar 2013 17:57:53 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 part1 0/9] Introduce movablemem_map boot option.
References: <1363430142-14563-1-git-send-email-tangchen@cn.fujitsu.com> <51450D93.1090303@gmail.com>
In-Reply-To: <51450D93.1090303@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Will,

On 03/17/2013 08:25 AM, Will Huck wrote:
>
> http://marc.info/?l=linux-mm&m=136014458829566&w=2
>
> It seems that Mel don't like this idea.
>

Thank you for reminding me this.

And yes, I have read that email. :)

And about this boot option, we have had a long discussion before.
Please refer to: https://lkml.org/lkml/2012/11/29/190

The situation is:

For now, Linux kernel cannot migrate kernel direct mapping memory. And
there is no way to ensure that ZONE_NORMAL has no kernel memory. So we
can only use ZONE_MOVABLE to ensure the memory device could be removed.

For now, I have the following reasons that movablemem_map boot option is
necessary. Some may be mentioned before, but here, I think I need to say
them again:

1) If we want to hot-remove a memory device, the device should only have
    memory of two types:
    - kernel memory whose life cycle is the same as the memory device.
      such as pagetables, vmemmap
    - user memory that could be migrated.

    For type1: we can allocate it on local node, just like Yinghai's work,
               and free it when hot-removing.
    For type2: we can migrate it at run time. But it must be in ZONE_MOVABLE
               because we cannot ensure ZONE_NORMAL has no kernel memory.

    So we need a way to limit hotpluggable memory in ZONE_MOVABLE.

2) We have the following ways to do it:
    a) use SRAT, which I have already implemented
    b) specify physical address ranges, which I have implemented too, but
       obviously very few guys like it.
    c) specify node id. But nid could be changed on some platform by 
firmware.

    Because of c), we chose to use physical address ranges. To satisfy all
    users, I also implemented a).

3) Even if we don't specify physical address in command line, we use SRAT,
    we still need the logic in this patch-set to achieve the same goal.

4) Since setting a whole node as movable will cause NUMA performance down,
    no matter which way we use, we always need an interface to open or close
    this functionality.
    The boot option itself is an interface. If users don't specify it in
    command line, the kernel will work as before.

So I do want to try again to push this boot option.  :)

With this boot option, memory hotplug will work now.


It's true that if we reimplement the whole mm in Linux to make kernel
memory migratable, but we need to handle a lot of problems. I agree with 
Mel.
But it is a long way to go in the future.

And the work in the near future:
1) Allocate pagetables and vmemmap on local node, as Yinghai said.
2) Do the proper modification for hot-add and hot-remove.
    - Reserve memory for pagetables and vmemmap when hot-add, maybe use
      memblock.
    - Free all pagetables and vmemmap before hot-remove.
3) And about Mel's advice, modify memory management in Linux to migrate
    kernel pages, it is a long way to go in the future. I think we can
    discuss more.

Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
