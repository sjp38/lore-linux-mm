Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3D136810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 11:15:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l185so1667473oib.4
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 08:15:45 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id w12si47441oia.263.2017.08.26.08.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Aug 2017 08:15:44 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id k77so18596450oib.2
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 08:15:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170826074047.GA6292@ls3530.fritz.box>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org> <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
 <20170825130011.GA30072@infradead.org> <20170825155803.4km7wttzadfqw2vb@node.shutemov.name>
 <20170825160236.GA2561@infradead.org> <20170825161607.6v6beg4zjktllt2z@node.shutemov.name>
 <4de21e8d-5e10-ec40-c731-0c079953cf48@gmx.de> <CAPcyv4jeZc8P+E0aHNChzy-wfNpOx3GehKck1nXqJ1b9JdydFA@mail.gmail.com>
 <20170826074047.GA6292@ls3530.fritz.box>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 26 Aug 2017 08:15:43 -0700
Message-ID: <CAPcyv4ic0zxQzWEipZ=1LpDC8VnmphGzVSYmrFcjOAgX7esfUw@mail.gmail.com>
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Helge Deller <deller@gmx.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org

On Sat, Aug 26, 2017 at 12:40 AM, Helge Deller <deller@gmx.de> wrote:
> * Dan Williams <dan.j.williams@intel.com>:
>> On Fri, Aug 25, 2017 at 9:19 AM, Helge Deller <deller@gmx.de> wrote:
>> > On 25.08.2017 18:16, Kirill A. Shutemov wrote:
>> >> On Fri, Aug 25, 2017 at 09:02:36AM -0700, Christoph Hellwig wrote:
>> >>> On Fri, Aug 25, 2017 at 06:58:03PM +0300, Kirill A. Shutemov wrote:
>> >>>> Not all archs are ready for this:
>> >>>>
>> >>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_TYPE    0x03            /* Mask for type of mapping */
>> >>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_FIXED   0x04            /* Interpret addr exactly */
>> >>>
>> >>> I'd be happy to say that we should not care about parisc for
>> >>> persistent memory.  We'll just have to find a way to exclude
>> >>> parisc without making life too ugly.
>> >>
>> >> I don't think creapling mmap() interface for one arch is the right way to
>> >> go. I think the interface should be universal.
>> >>
>> >> I may imagine MAP_DIRECT can be useful not only for persistent memory.
>> >> For tmpfs instead of mlock()?
>> >
>> > On parisc we have
>> > #define MAP_SHARED      0x01            /* Share changes */
>> > #define MAP_PRIVATE     0x02            /* Changes are private */
>> > #define MAP_TYPE        0x03            /* Mask for type of mapping */
>> > #define MAP_FIXED       0x04            /* Interpret addr exactly */
>> > #define MAP_ANONYMOUS   0x10            /* don't use a file */
>> >
>> > So, if you need a MAP_DIRECT, wouldn't e.g.
>> > #define MAP_DIRECT      0x08
>> > be possible (for parisc, and others 0x04).
>> > And if MAP_TYPE needs to include this flag on parisc:
>> > #define MAP_TYPE        (0x03 | 0x08)  /* Mask for type of mapping */
>>
>> The problem here is that to support new the mmap flags the arch needs
>> to find a flag that is guaranteed to fail on older kernels. Defining
>> MAP_DIRECT to 0x8 on parisc doesn't work because it will simply be
>> ignored on older parisc kernels.
>>
>> However, it's already the case that several archs have their own
>> sys_mmap entry points. Those archs that can't follow the common scheme
>> (only parsic it seems) will need to add a new mmap syscall. I think
>> that's a reasonable tradeoff to allow every other architecture to add
>> this support with their existing mmap syscall paths.
>
> I don't want other architectures to suffer just because of parisc.
> But adding a new syscall just for usage on parisc won't work either,
> because nobody will add code to call it then.

I don't understand this comment, if / when parisc gets around to
adding pmem and dax support why wouldn't libc grow support for the new
parisc mmap variant? Also, it's not just MAP_DIRECT you would also
need space for a MAP_SYNC flag.

>> That means MAP_DIRECT should be defined to MAP_TYPE on parisc until it
>> later defines an opt-in mechanism to a new syscall that honors
>> MAP_DIRECT as a valid flag.
>
> I'd instead propose to to introduce an ABI breakage for parisc users
> (which aren't many). Most parisc users update their kernel regularily
> anyway, because we fixed so many bugs in the latest kernel.
>
> With the following patch pushed down to the stable kernel series,
> MAP_DIRECT will fail as expected on those kernels, while we can
> keep parisc up with current developments regarding MAP_DIRECT.

The whole point is to avoid an ABI regression and the chance for false
positive results. We're immediately stuck if some application was
expecting 0x8 to be ignored, or conversely an application that
absolutely needs to rely on MAP_SYNC/MAP_DIRECT semantics assumes the
wrong result on a parisc kernel where they are ignored.

I have not seen any patches for parisc pmem+dax enabling so it seems
too early to worry about these "last mile" enabling features of
MAP_DIRECT and MAP_SYNC. In particular parisc doesn't appear to have
ARCH_ENABLE_MEMORY_HOTPLUG, so as far as I can see it can't yet
support the ZONE_DEVICE scheme that is a pre-requisite for MAP_DIRECT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
