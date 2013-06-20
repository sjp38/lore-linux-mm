Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 74FBA6B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 01:49:54 -0400 (EDT)
Message-ID: <51C298B2.9060900@cn.fujitsu.com>
Date: Thu, 20 Jun 2013 13:52:50 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <20130618020357.GZ32663@mtj.dyndns.org> <51BFF464.809@cn.fujitsu.com> <20130618172129.GH2767@htj.dyndns.org>
In-Reply-To: <20130618172129.GH2767@htj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, yinghai@kernel.org
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi tj, Yinghai,

On 06/19/2013 01:21 AM, Tejun Heo wrote:
> Hey, Tang.
>
> On Tue, Jun 18, 2013 at 01:47:16PM +0800, Tang Chen wrote:
>> [approach]
>> Parse SRAT earlier before memblock starts to work, because there is a
>> bit in SRAT specifying which memory is hotpluggable.
>>
>> I'm not saying this is the best approach. I can also see that this
>> patch-set touches a lot of boot code. But i think parsing SRAT earlier
>> is reasonable because this is the only way for now to know which memory
>> is hotpluggable from firmware.
>
> Touching a lot of code is not a problem but it feels like it's trying
> to boot strap itself while walking and achieves that by carefully
> sequencing all operations which may allocate from memblock before NUMA
> info is available without any way to enforce or verify that.

Yes, the current implementation has no way to verify if there is
anything violating the hotplug requirement. This is weak and should
be improved.

>
>>> Can't you just move memblock arrays after NUMA init is complete?
>>> That'd be a lot simpler and way more robust than the proposed changes,
>>> no?
>>
>> Sorry, I don't quite understand the approach you are suggesting. If we
>> move memblock arrays, we need to update all the pointers pointing to
>> the moved memory. How can we do this ?
>
> So, there are two things involved here - memblock itself and consumers
> of memblock, right?

Yes.

>I get that the latter shouldn't allocate memory
> from memblock before NUMA info is entered into memblock, so please
> reorder as necessary *and* make sure memblock complains if something
> violates that.  Temporary memory areas which are return are fine.
> Just complain if there are memory regions remaining which are
> allocated before NUMA info is available after boot is complete.  No
> need to make booting more painful than it currently is.

I think there are two difficulties to do this job in your way.

1. It is difficult to tell which memory allocation is temporary and
    which one is permanent when memblock is allocating memory. So, we
    can only wait till boot is complete, and see which remains.
    But, we have the second difficulty.

2. In memblock.reserve[], we cannot tell why we allocated this memory
    just from the array item, right?  So it is difficult to do the
    relocation. If in the future, we have to allocate permanent memory
    for other new purposes, we have to do the relocation again and again.
    (Not sure if I understand the point correctly. I think there isn't
     a generic way to relocate memory used for different purposes.)

If you also had a look at the Part2 patches, you will see that I
introduced a flags member into memblock to specify different types
of memory, which will help to recognize hotpluggable memory. My
thinking is that ensure memblock will not allocate hotpluggable
memory. I think this is the most safe and easy way to satisfy hotplug
requirement.

(not finished, please see below)

>
> As for memblock itself, there's no need to walk carefully around it.
> Just let it do its thing and implement
> memblock_relocate_to_numa_node_0() or whatever after NUMA information
> is available.  memblock already does relocate itself whenever it's
> expanding the arrays anyway, so implementation should be trivial.

Yes, this is easy.

>
> Maybe I'm missing something but having a working memory allocator as
> soon as possible is *way* less painful than trying to bootstrap around
> it.  Allow boot path to allocate memory areas from memblock as soon as
> possible but just ensure that none of the ones which may violate the
> hotplug requirements is remaining once boot is complete.  Temporaray
> regions won't matter then and the few which need persistent areas can
> either be reordered to happen after NUMA init or they can allocate a
> new area and move to there after NUMA info is available.  Let's please
> minimize this walking-and-trying-to-tie-shoestrings-at-the-same-time
> thing.  It's painful and extremely fragile.

IIUC, I know what you are worrying about:

1. No way to ensure parsing numa info is early enough in the future.
    Someone could have a chance to use memblock before parsing SRAT
    in the future.

2. memblock won't complain if anything violates the hotplug requirement.
    This is not safe.

So you don't agree to serialize the operations at boot time.

But I think ensuring memblock won't allocate hotpluggable memory to
the kernel (which is the current way in Part2 patches) is the safest
way to satisfy memory hotplug requirement. And this is right a working
memory allocator at boot time. Not checking or relocating after system
boots.

About this patch-set from Yinghai, actually he is doing a job that I
failed to do. And he also included a lot of other things in the
patch-set, such as extend max number of overridable acpi tables, local
node pagetable, and so on.

Maybe all these things are done at the same time looks a little messy.
So, how about we do it this way:

1. Improvements for ACPI_TABLE_OVERRIDE, such as increase the number
    of overridable tables.

2. Move forward parsing SRAT.

3. local device pagetable (not local node), I mentioned in Part3
    patch-set discussion. I'm now also working on it.

I'm not trying to do thing half way. I just think maybe smaller patch-set
will be easy to understand and review.


PS:
More info about local device pagetable:

There could be more than on memory device in a numa node. If we allocate
local node pagetable, the pagetable pages of one memory device could be
in another memory device. So the memory device containing pagetable have
to be hot-removed in the last place. This is hard to handle in hot-remove
path. So maybe local device pagetable is more reasonable.

Thanks. :)







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
