Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 9A5896B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 02:17:24 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id 4so5883412pdd.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 23:17:23 -0700 (PDT)
Date: Wed, 19 Jun 2013 23:17:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130620061719.GA16114@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618020357.GZ32663@mtj.dyndns.org>
 <51BFF464.809@cn.fujitsu.com>
 <20130618172129.GH2767@htj.dyndns.org>
 <51C298B2.9060900@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C298B2.9060900@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Tang.

On Thu, Jun 20, 2013 at 01:52:50PM +0800, Tang Chen wrote:
> 1. It is difficult to tell which memory allocation is temporary and
>    which one is permanent when memblock is allocating memory. So, we
>    can only wait till boot is complete, and see which remains.
>    But, we have the second difficulty.
> 
> 2. In memblock.reserve[], we cannot tell why we allocated this memory
>    just from the array item, right?  So it is difficult to do the
>    relocation. If in the future, we have to allocate permanent memory
>    for other new purposes, we have to do the relocation again and again.
>    (Not sure if I understand the point correctly. I think there isn't
>     a generic way to relocate memory used for different purposes.)

I was suggesting two separate things.

* As memblock allocator can relocate itself.  There's no point in
  avoiding setting NUMA node while parsing and registering NUMA
  topology.  Just parse and register NUMA info and later tell it to
  relocate itself out of hot-pluggable node.  A number of patches in
  the series is doing this dancing - carefully reordering NUMA
  probing.  No need to do that.  It's really fragile thing to do.

* Once you get the above out of the way, I don't think there are a lot
  of permanent allocations in the way before NUMA is initialized.
  Re-order the remaining ones if that's cleaner to do.  If that gets
  overly messy / fragile, copying them around or freeing and reloading
  afterwards could be an option too.  There isn't much point in being
  super-efficient about ACPI override table.  Being cleaner and more
  robust is far more important.

As for distinguishing temporary / permanent, it shouldn't be difficult
to make memblock track all allocations before NUMA info becomes online
and then verify that those areas are free by the time boot is
complete.  Just mark the reserved areas allocated before NUMA info is
fully available.

> If you also had a look at the Part2 patches, you will see that I
> introduced a flags member into memblock to specify different types
> of memory, which will help to recognize hotpluggable memory. My
> thinking is that ensure memblock will not allocate hotpluggable
> memory. I think this is the most safe and easy way to satisfy hotplug
> requirement.

And you can use exactly the same mechanism to track memory areas which
were allocated before NUMA info was fully available, right?

> So you don't agree to serialize the operations at boot time.

No, I'm not disagreeing that some ordering is necessary.  My point is
that things seem to be going that way too far.  Sure, some reordering
is necessary but it doesn't have to be this fragile.  Careful
reordering isn't the only way to achieve it.

> About this patch-set from Yinghai, actually he is doing a job that I
> failed to do. And he also included a lot of other things in the
> patch-set, such as extend max number of overridable acpi tables, local
> node pagetable, and so on.

Doing multiple things to achieve a goal in a patchset might not be
optimal but is usually okay if properly explained.  What's not okay is
not explaining the overall goal, approach and design in the head
message, poor quality of patch description and code documentation.

This part of code is almost inherently fragile and difficult to debug
and patchset like this would degrade the maintainability and I really
don't want to spend hours trying to decipher what the overall approach
is by trying to navigate maze of poorly documented patches only to
find out that some of the basic approaches are not very agreeable.  We
could have had this exact discussion way earlier if the head message
properly described what was going on and the review process would have
been much more pleasant for all involved parties.

I don't think it matters whose patches go in how as long as they are
attributed correctly.  The end result - what goes in the git tree as
log and code changes - matters, and it needs to be whole lot better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
