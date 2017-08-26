Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69F986810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 15:57:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t82so3960143wmd.10
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 12:57:24 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id k23si2500801wrd.26.2017.08.26.12.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Aug 2017 12:57:22 -0700 (PDT)
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org>
 <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
 <20170825130011.GA30072@infradead.org>
 <20170825155803.4km7wttzadfqw2vb@node.shutemov.name>
 <20170825160236.GA2561@infradead.org>
 <20170825161607.6v6beg4zjktllt2z@node.shutemov.name>
 <4de21e8d-5e10-ec40-c731-0c079953cf48@gmx.de>
 <CAPcyv4jeZc8P+E0aHNChzy-wfNpOx3GehKck1nXqJ1b9JdydFA@mail.gmail.com>
 <20170826074047.GA6292@ls3530.fritz.box>
 <CAPcyv4ic0zxQzWEipZ=1LpDC8VnmphGzVSYmrFcjOAgX7esfUw@mail.gmail.com>
From: Helge Deller <deller@gmx.de>
Message-ID: <35692b04-eb4f-740c-e35c-8ccbf69e0e97@gmx.de>
Date: Sat, 26 Aug 2017 21:50:59 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ic0zxQzWEipZ=1LpDC8VnmphGzVSYmrFcjOAgX7esfUw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org

On 26.08.2017 17:15, Dan Williams wrote:
> On Sat, Aug 26, 2017 at 12:40 AM, Helge Deller <deller@gmx.de> wrote:
>> * Dan Williams <dan.j.williams@intel.com>:
>>> On Fri, Aug 25, 2017 at 9:19 AM, Helge Deller <deller@gmx.de> wrote:
>>>> On 25.08.2017 18:16, Kirill A. Shutemov wrote:
>>>>> On Fri, Aug 25, 2017 at 09:02:36AM -0700, Christoph Hellwig wrote:
>>>>>> On Fri, Aug 25, 2017 at 06:58:03PM +0300, Kirill A. Shutemov wrote:
>>>>>>> Not all archs are ready for this:
>>>>>>>
>>>>>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_TYPE    0x03            /* Mask for type of mapping */
>>>>>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_FIXED   0x04            /* Interpret addr exactly */
>>>>>>
>>>>>> I'd be happy to say that we should not care about parisc for
>>>>>> persistent memory.  We'll just have to find a way to exclude
>>>>>> parisc without making life too ugly.
>>>>>
>>>>> I don't think creapling mmap() interface for one arch is the right way to
>>>>> go. I think the interface should be universal.
>>>>>
>>>>> I may imagine MAP_DIRECT can be useful not only for persistent memory.
>>>>> For tmpfs instead of mlock()?
>>>>
>>>> On parisc we have
>>>> #define MAP_SHARED      0x01            /* Share changes */
>>>> #define MAP_PRIVATE     0x02            /* Changes are private */
>>>> #define MAP_TYPE        0x03            /* Mask for type of mapping */
>>>> #define MAP_FIXED       0x04            /* Interpret addr exactly */
>>>> #define MAP_ANONYMOUS   0x10            /* don't use a file */
>>>>
>>>> So, if you need a MAP_DIRECT, wouldn't e.g.
>>>> #define MAP_DIRECT      0x08
>>>> be possible (for parisc, and others 0x04).
>>>> And if MAP_TYPE needs to include this flag on parisc:
>>>> #define MAP_TYPE        (0x03 | 0x08)  /* Mask for type of mapping */
>>>
>>> The problem here is that to support new the mmap flags the arch needs
>>> to find a flag that is guaranteed to fail on older kernels. Defining
>>> MAP_DIRECT to 0x8 on parisc doesn't work because it will simply be
>>> ignored on older parisc kernels.
>>>
>>> However, it's already the case that several archs have their own
>>> sys_mmap entry points. Those archs that can't follow the common scheme
>>> (only parsic it seems) will need to add a new mmap syscall. I think
>>> that's a reasonable tradeoff to allow every other architecture to add
>>> this support with their existing mmap syscall paths.
>>
>> I don't want other architectures to suffer just because of parisc.
>> But adding a new syscall just for usage on parisc won't work either,
>> because nobody will add code to call it then.
> 
> I don't understand this comment, if / when parisc gets around to
> adding pmem and dax support why wouldn't libc grow support for the new
> parisc mmap variant? Also, it's not just MAP_DIRECT you would also
> need space for a MAP_SYNC flag.
> 
>>> That means MAP_DIRECT should be defined to MAP_TYPE on parisc until it
>>> later defines an opt-in mechanism to a new syscall that honors
>>> MAP_DIRECT as a valid flag.
>>
>> I'd instead propose to to introduce an ABI breakage for parisc users
>> (which aren't many). Most parisc users update their kernel regularily
>> anyway, because we fixed so many bugs in the latest kernel.
>>
>> With the following patch pushed down to the stable kernel series,
>> MAP_DIRECT will fail as expected on those kernels, while we can
>> keep parisc up with current developments regarding MAP_DIRECT.
> 
> The whole point is to avoid an ABI regression and the chance for false
> positive results. We're immediately stuck if some application was
> expecting 0x8 to be ignored, or conversely an application that
> absolutely needs to rely on MAP_SYNC/MAP_DIRECT semantics assumes the
> wrong result on a parisc kernel where they are ignored.
> 
> I have not seen any patches for parisc pmem+dax enabling so it seems
> too early to worry about these "last mile" enabling features of
> MAP_DIRECT and MAP_SYNC. In particular parisc doesn't appear to have
> ARCH_ENABLE_MEMORY_HOTPLUG, so as far as I can see it can't yet
> support the ZONE_DEVICE scheme that is a pre-requisite for MAP_DIRECT.

I see, but then it's probably best to not to define any MAP_DIRECT or 
MAP_SYNC at all in the headers of those arches which don't support
pmem+dax (parisc, m68k, alpha, and probably quite some others).
That way applications can detect at configure time if the platform
supports that, and can leave out the functionality completely.

Helge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
