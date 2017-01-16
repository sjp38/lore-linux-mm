Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 536266B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:35:10 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id x49so98124871qtc.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:35:10 -0800 (PST)
Received: from esa8.dell-outbound.iphmx.com (esa8.dell-outbound.iphmx.com. [68.232.149.218])
        by mx.google.com with ESMTPS id k3si3916919qte.163.2017.01.16.08.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 08:35:09 -0800 (PST)
From: "Michaud, Adrian" <Adrian.Michaud@dell.com>
Subject: RE: [LSF/MM TOPIC][LSF/MM ATTEND] Multiple Page Caches, Memory
 Tiering, Better LRU evictions,
Date: Mon, 16 Jan 2017 16:34:41 +0000
Message-ID: <61F9233AFAF8C541AAEC03A42CB0D8C7025D05B8@MX203CL01.corp.emc.com>
References: <61F9233AFAF8C541AAEC03A42CB0D8C7025D002B@MX203CL01.corp.emc.com>
 <20170113235656.GB26245@node.shutemov.name>
In-Reply-To: <20170113235656.GB26245@node.shutemov.name>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>-----Original Message-----
>From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf=
 Of Kirill A. Shutemov
>Sent: Friday, January 13, 2017 6:57 PM
>To: Michaud, Adrian <Adrian.Michaud@emc.com>
>Cc: lsf-pc@lists.linux-foundation.org; linux-mm@kvack.org
>Subject: Re: [LSF/MM TOPIC][LSF/MM ATTEND] Multiple Page Caches, Memory Ti=
ering, Better LRU evictions,
>
>On Fri, Jan 13, 2017 at 09:49:14PM +0000, Michaud, Adrian wrote:
>> I'd like to attend and propose one or all of the following topics at thi=
s year's summit.
>>=20
>> Multiple Page Caches (Software Enhancements)
>> --------------------------
>> Support for multiple page caches can provide many benefits to the kernel=
.
>> Different memory types can be put into different page caches. One page=20
>> cache for native DDR system memory, another page cache for slower=20
>> NV-DIMMs, etc.
>> General memory can be partitioned into several page caches of=20
>> different sizes and could also be dedicated to high priority processes=20
>> or used with containers to better isolate memory by dedicating a page=20
>> cache to a cgroup process.
>> Each VMA, or process, could have a page cache identifier, or page=20
>> alloc/free callbacks that allow individual VMAs or processes to=20
>> specify which page cache they want to use.
>> Some VMAs might want anonymous memory backed by vast amounts of slower=20
>> server class memory like NV-DIMMS.
>> Some processes or individual VMAs might want their own private page=20
>> cache.
>> Each page cache can have its own eviction policy and low-water markers=20
>> Individual page caches could also have their own swap device.
>
>Sounds like you're re-inventing NUMA.
>What am I missing?


Think of separate isolated page caches. Each page cache can have a dedicate=
d swap device if desired. Each page cache could have a different eviction p=
olicy (FIFO, LRU, custom-installed, etc.) Each page cache is fully isolated=
. You could have one page cache for the kernel and one or more page caches =
for individual processes or process groups if you want to fully isolate mem=
ory resources. You could dynamically create as many page caches as you like=
 and dedicate or share them among applications. If you have a noisy neighbo=
r, you could give them an appropriately sized dedicated page cache and they=
 become fully bound to the size and eviction policy of that page cache.=20


>
>> Memory Tiering (Software Enhancements)
>> --------------------
>> Using multiple page caches, evictions from one page cache could be=20
>> moved and remapped to another page cache instead of unmapped and=20
>> written to swap.
>> If a system has 16GB of high speed DDR memory, and 64GB of slower=20
>> memory, one could create a page cache with high speed DDR memory,=20
>> another page cache with slower 64GB memory, and evict/copy/remap from=20
>> the DDR page cache to the slow memory page cache. Evictions from the=20
> slow memory page cache would then get unmapped and written to swap.
>
>I guess it's something that can be done as part of NUMA balancing.

With support for multiple isolated page caches, you could simply tier them.=
 If a page cache has a ->next tier, then evicted pages are allocated/copied=
/PTE remapped to the ->next page cache tier instead of unmapped and swapped=
 out. Block I/O evictions only occur if the page cache doesn't have a ->nex=
t tier.=20

>
>> Better LRU evictions (Software and Hardware Enhancements)
>> -------------------------
>> Add a page fault counter to the page struct to help colorize page demand=
.
>> We could suggest to Intel/AMD and other architecture leaders that TLB=20
>> entries also have a translation counter (8-10 bits is sufficient)=20
>> instead of just an "accessed" bit.  Scanning/clearing access bits is=20
>> obviously inefficient; however, if TLBs had a translation counter=20
>> instead of a single accessed bit then scanning and recording the=20
>> amount of activity each TLB has would be significantly better and=20
>> allow us to bettern calculate LRU pages for evictions.
>>
>>Except that would make memory accesses slower.
>>
>>Even access bit handing is noticible performance hit: processor has to wr=
ite into page table entry on first access to the page.
>>What you're proposing is making 2^8-2^10 first accesses slower.
>>
>>Sounds like no-go for me.

Good point but the TLB with the translation counter would only need to be w=
ritten back to the page table when the TLB gets evicted, not for every tran=
slation. We would also want this to be an optional TLB feature with an enab=
le bit and only use it when it makes sense to. It would be a great memory p=
rofiling tool=20

>>
>> TLB Shootdown (Hardware Enhancements)
>> --------------------------
>> We should stomp our feet and demand that TLB shootdowns should be=20
>> hardware assisted in future architectures. Current TLB shootdown on=20
>> x86 is horribly inefficient and obviously doesn't scale. The QPI/UPI=20
>> local bus protocol should provide TLB range invalidation broadcast so=20
>> that a single CPU can concurrently notify other CPU/cores (with a=20
>> selection
>> mask) that a shared TLB entry has changed. Sending an IPI to each core=20
>> is horribly inefficient; especially with the core counts increasing=20
>> and the frequency of TLB unmapping/remapping also possibly increasing=20
>> shortly with new server class memory extension technology.
>
>IIUC, the best you can get from hardware is IPI behind the scene.
>I doubt it worth the effort.
>

Yes, that's why this discussion topic is about hardware enhancements for TL=
B shootdown. The existing cache coherent protocol over QPI/UPI could be ext=
ended to include TLB invalidation(s) along with new TLBINV instructions whi=
ch allow CPU/core masks and possible VA range(s). Consider how cool a new M=
OV CR3,EAX,EBX instruction would be where EAX is the Page directory pointer=
, and EBX is the CPU/CORE mask that selects which cores to broadcast to. Th=
e instruction would block until all cores have completed the CR3 update whi=
ch also invalidates their TLB. Compare this to having to sequentially send =
IPI interrupts to each core, wait for each core to context switch and execu=
te a TLB invalidate, then RTI and signal the originator.=20

Adrian Michaud

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
