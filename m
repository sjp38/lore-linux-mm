Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 354486B005D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:41:16 -0400 (EDT)
Message-ID: <507EFCC3.1050304@am.sony.com>
Date: Wed, 17 Oct 2012 11:45:23 -0700
From: Tim Bird <tim.bird@am.sony.com>
MIME-Version: 1.0
Subject: Re: [Q] Default SLAB allocator
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>  <m27gqwtyu9.fsf@firstfloor.org>  <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>  <m2391ktxjj.fsf@firstfloor.org>  <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>  <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>  <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>  <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>  <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>  <1350392160.3954.986.camel@edumazet-glaptop> <507DA245.9050709@am.sony.com>  <CALF0-+VLVqy_uE63_jL83qh8MqBQAE3vYLRX1mRQURZ4a1M20g@mail.gmail.com> <1350414968.3954.1427.camel@edumazet-glaptop>
In-Reply-To: <1350414968.3954.1427.camel@edumazet-glaptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On 10/16/2012 12:16 PM, Eric Dumazet wrote:
> On Tue, 2012-10-16 at 15:27 -0300, Ezequiel Garcia wrote:
> 
>> Yes, we have some numbers:
>>
>> http://elinux.org/Kernel_dynamic_memory_analysis#Kmalloc_objects
>>
>> Are they too informal? I can add some details...
>>
>> They've been measured on a **very** minimal setup, almost every option
>> is stripped out, except from initramfs, sysfs, and trace.
>>
>> On this scenario, strings allocated for file names and directories
>> created by sysfs
>> are quite noticeable, being 4-16 bytes, and produce a lot of fragmentation from
>> that 32 byte cache at SLAB.
>>
>> Is an option to enable small caches on SLUB and SLAB worth it?
> 
> Random small web server :
> 
> # free
>              total       used       free     shared    buffers     cached
> Mem:       7884536    5412572    2471964          0     155440    1803340
> -/+ buffers/cache:    3453792    4430744
> Swap:      2438140      51164    2386976

8G is a small web server?  The RAM budget for Linux on one of
Sony's cameras was 10M.  We're not merely not in the same ballpark -
you're in a ballpark and I'm trimming bonsai trees... :-)

> # grep Slab /proc/meminfo
> Slab:             351592 kB
> 
> # egrep "kmalloc-32|kmalloc-16|kmalloc-8" /proc/slabinfo 
> kmalloc-32         11332  12544     32  128    1 : tunables    0    0    0 : slabdata     98     98      0
> kmalloc-16          5888   5888     16  256    1 : tunables    0    0    0 : slabdata     23     23      0
> kmalloc-8          76563  82432      8  512    1 : tunables    0    0    0 : slabdata    161    161      0
> 
> Really, some waste on these small objects is pure noise on SMP hosts.
In this example, it appears that if all kmalloc-8's were pushed into 32-byte slabs,
we'd lose about 1.8 meg due to pure slab overhead.  This would not be noise
on my system.

> (Waste on bigger objects is probably more important by orders of magnitude)

Maybe.

I need to run some measurements on systems that are more similar to what
we're deploying in products.  I'll see if I can share them.
 -- Tim

=============================
Tim Bird
Architecture Group Chair, CE Workgroup of the Linux Foundation
Senior Staff Engineer, Sony Network Entertainment
=============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
