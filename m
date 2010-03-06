Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 233FB6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 21:33:08 -0500 (EST)
Message-ID: <4B91BE93.8000401@kernel.org>
Date: Fri, 05 Mar 2010 18:31:47 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com> <4B915074.4020704@kernel.org> <20100305235812.GA15249@cmpxchg.org> <4B91B4EF.5090502@kernel.org> <20100306022415.GB16967@cmpxchg.org>
In-Reply-To: <20100306022415.GB16967@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/05/2010 06:24 PM, Johannes Weiner wrote:
> On Fri, Mar 05, 2010 at 05:50:39PM -0800, Yinghai Lu wrote:
>> On 03/05/2010 03:58 PM, Johannes Weiner wrote:
>>> Hello Yinghai,
>>>
>>> On Fri, Mar 05, 2010 at 10:41:56AM -0800, Yinghai Lu wrote:
>>>> On 03/04/2010 09:17 PM, Greg Thelen wrote:
>>>>> On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>>>>> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>>>>>>> On several systems I am seeing a boot panic if I use mmotm
>>>>>>> (stamp-2010-03-02-18-38).  If I remove
>>>>>>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen.  I
>>>>>>> find that:
>>>>>>> * 2.6.33 boots fine.
>>>>>>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fine.
>>>>>>> * 2.6.33 + mmotm (including
>>>>>>> bootmem-avoid-dma32-zone-by-default.patch): panics.
>>>> ...
>>>>>
>>>>> Note: mmotm has been recently updated to stamp-2010-03-04-18-05.  I
>>>>> re-tested with 'make defconfig' to confirm the panic with this later
>>>>> mmotm.
>>>>
>>>> please check
>>>>
>>>> [PATCH] early_res: double check with updated goal in alloc_memory_core_early
>>>>
>>>> Johannes Weiner pointed out that new early_res replacement for alloc_bootmem_node
>>>> change the behavoir about goal.
>>>> original bootmem one will try go further regardless of goal.
>>>>
>>>> and it will break his patch about default goal from MAX_DMA to MAX_DMA32...
>>>> also broke uncommon machines with <=16M of memory.
>>>> (really? our x86 kernel still can run on 16M system?)
>>>>
>>>> so try again with update goal.
>>>
>>> Thanks for the patch, it seems to be correct.
>>>
>>> However, I have a more generic question about it, regarding the future of the
>>> early_res allocator.
>>>
>>> Did you plan on keeping the bootmem API for longer?  Because my impression was,
>>> emulating it is a temporary measure until all users are gone and bootmem can
>>> be finally dropped.
>>
>> that depends on every arch maintainer.
>>
>> user can compare them on x86 to check if...
> 
> Humm, now that is a bit disappointing.  Because it means we will never get rid
> of bootmem as long as it works for the other architectures.  And your changeset
> just added ~900 lines of code, some of it being a rather ugly compatibility
> layer in bootmem that I hoped could go away again sooner than later.
> 
> I do not know what the upsides for x86 are from no longer using bootmem but it
> would suck from a code maintainance point of view to get stuck half way through
> this transition and have now TWO implementations of the bootmem interface we
> would like to get rid of.

some data, and others can compare them more on x86 systems...

I didn't plan to post this data before you said ....

for my 1T system

nobootmem:
   text    data     bss     dec     hex filename
19185736        4148404 12170736        35504876        21dc2ec vmlinux.nobootmem
Memory: 1058662820k/1075838976k available (11388k kernel code, 2106480k absent, 15069676k reserved, 8589k data, 2744k init
[  220.947157] calling  ip_auto_config+0x0/0x24d @ 1


bootmem:
   text    data     bss     dec     hex filename
19188441        4153956 12170736        35513133        21de32d vmlinux.bootmem
Memory: 1058662796k/1075838976k available (11388k kernel code, 2106480k absent, 15069700k reserved, 8589k data, 2752k init)
[  236.765364] calling  ip_auto_config+0x0/0x24d @ 1

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
