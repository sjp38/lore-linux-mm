Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 184616B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 02:12:01 -0400 (EDT)
Message-ID: <51C14C5E.6090501@cn.fujitsu.com>
Date: Wed, 19 Jun 2013 14:14:54 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part2 PATCH v4 08/15] x86, numa: Save nid when reserve memory
 into memblock.reserved[].
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com> <1371128619-8987-9-git-send-email-tangchen@cn.fujitsu.com> <20130618165753.GB4553@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20130618165753.GB4553@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasilis,

Thanks for reviewing. :)

On 06/19/2013 12:57 AM, Vasilis Liaskovitis wrote:
......
>
> However, patches 21,22 of part1 and all part3 patches increase kernel usage
> of local node memory by putting pagetables local to those nodes. Are these
> pagetable pages accounted in part2's memblock_kernel_nodemask? It looks like

No, they are not. What I wanted to acheve was that the local pagetable pages
are transparent to users. For a movable node (all memory is hotpluggable),
seeing from users level, they think all the node's memory is not used by 
the
kernel. Actually pagetable pages are used by the kernel, but users don't 
know
it, and they don't care about it.

And also, memblock_kernel_nodemask is only used at very early time. When 
the
system is up, it is useless.

This is just my approach for this problem. It is not good enough, and we can
improve it.

> part1 and part3 of these patchsets contradict or make the goal of part2 more
> difficult to achieve. (I will send more comments for part3 separately).
>

I think allocating pagetable to local node really makes thing a little more
difficult than before. But I also think Yinghai's work is reasonable 
because
it helps to improve the performance.

What I am thinking now is to allocate things like pagetable pages to local
device. (Seems I mentioned this before.)

If a node has more than one memory device, and all the pagetable pages are
allocated in one device. Then this device cannot be hot-removed unless all
the other memory devices are hot-removed.

So I think allocating pagetable pages to local device is more reasonable.
But as you said, this could be more complex.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
