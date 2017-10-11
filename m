Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3D66B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:15:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s144so1365856oih.5
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:15:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k65sor3371370oif.46.2017.10.11.07.15.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 07:15:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011074320.GG3667@quack2.suse.cz>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150764694114.16882.5128952296874418457.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171011074320.GG3667@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 07:15:16 -0700
Message-ID: <CAPcyv4iVpnce_LTCuprmbeOk9zh7O4Q7O4_V8u4RzHTuO=S02g@mail.gmail.com>
Subject: Re: [PATCH v8 01/14] mm: introduce MAP_SHARED_VALIDATE, a mechanism
 to safely define new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Arnd Bergmann <arnd@arndb.de>, linux-rdma@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Wed, Oct 11, 2017 at 12:43 AM, Jan Kara <jack@suse.cz> wrote:
> On Tue 10-10-17 07:49:01, Dan Williams wrote:
>> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
>> mechanism to define new behavior that is known to fail on older kernels
>> without the support. Define a new MAP_SHARED_VALIDATE flag pattern that
>> is guaranteed to fail on all legacy mmap implementations.
>>
>> It is worth noting that the original proposal was for a standalone
>> MAP_VALIDATE flag. However, when that  could not be supported by all
>> archs Linus observed:
>>
>>     I see why you *think* you want a bitmap. You think you want
>>     a bitmap because you want to make MAP_VALIDATE be part of MAP_SYNC
>>     etc, so that people can do
>>
>>     ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED
>>                   | MAP_SYNC, fd, 0);
>>
>>     and "know" that MAP_SYNC actually takes.
>>
>>     And I'm saying that whole wish is bogus. You're fundamentally
>>     depending on special semantics, just make it explicit. It's already
>>     not portable, so don't try to make it so.
>>
>>     Rename that MAP_VALIDATE as MAP_SHARED_VALIDATE, make it have a value
>>     of 0x3, and make people do
>>
>>     ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED_VALIDATE
>>                   | MAP_SYNC, fd, 0);
>>
>>     and then the kernel side is easier too (none of that random garbage
>>     playing games with looking at the "MAP_VALIDATE bit", but just another
>>     case statement in that map type thing.
>>
>>     Boom. Done.
>>
>> Similar to ->fallocate() we also want the ability to validate the
>> support for new flags on a per ->mmap() 'struct file_operations'
>> instance basis.  Towards that end arrange for flags to be generically
>> validated against a mmap_supported_mask exported by 'struct
>> file_operations'. By default all existing flags are implicitly
>> supported, but new flags require MAP_SHARED_VALIDATE and
>> per-instance-opt-in.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Suggested-by: Christoph Hellwig <hch@lst.de>
>> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  arch/alpha/include/uapi/asm/mman.h           |    1 +
>>  arch/mips/include/uapi/asm/mman.h            |    1 +
>>  arch/mips/kernel/vdso.c                      |    2 +
>>  arch/parisc/include/uapi/asm/mman.h          |    1 +
>>  arch/tile/mm/elf.c                           |    3 +-
>>  arch/xtensa/include/uapi/asm/mman.h          |    1 +
>>  include/linux/fs.h                           |    2 +
>>  include/linux/mm.h                           |    2 +
>>  include/linux/mman.h                         |   39 ++++++++++++++++++++++++++
>>  include/uapi/asm-generic/mman-common.h       |    1 +
>>  mm/mmap.c                                    |   21 ++++++++++++--
>>  tools/include/uapi/asm-generic/mman-common.h |    1 +
>>  12 files changed, 69 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
>> index 3b26cc62dadb..92823f24890b 100644
>> --- a/arch/alpha/include/uapi/asm/mman.h
>> +++ b/arch/alpha/include/uapi/asm/mman.h
>> @@ -14,6 +14,7 @@
>>  #define MAP_TYPE     0x0f            /* Mask for type of mapping (OSF/1 is _wrong_) */
>>  #define MAP_FIXED    0x100           /* Interpret addr exactly */
>>  #define MAP_ANONYMOUS        0x10            /* don't use a file */
>> +#define MAP_SHARED_VALIDATE 0x3              /* share + validate extension flags */
>
> Just a nit but I'd put definition of MAP_SHARED_VALIDATE close to the
> definition of MAP_SHARED and MAP_PRIVATE where it logically belongs (for
> all archs).

Will do.

>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index f8c10d336e42..5c4c98e4adc9 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2133,7 +2133,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
>>
>>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>>       unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
>> -     struct list_head *uf);
>> +     struct list_head *uf, unsigned long map_flags);
>>  extern unsigned long do_mmap(struct file *file, unsigned long addr,
>>       unsigned long len, unsigned long prot, unsigned long flags,
>>       vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
>
> I have to say I'm not very keen on passing down both vm_flags and map_flags
> - vm_flags are almost a subset of map_flags but not quite and the ambiguity
> which needs to be used for a particular check seems to open a space for
> errors. Granted you currently only care about MAP_DIRECT in ->mmap_validate
> and just pass map_flags through mmap_region() so there's no space for
> confusion but future checks could do something different.

I was hoping the fact that one can't trigger a call to
->mmap_validate() unless they specify a flag outside of
LEGACY_MAP_MASK makes it clearer that validation is only for new
flags. Old flags get the existing "may be silently ignored" behavior.

> But OTOH I don't
> see a cleaner way of avoiding the need to allocate vma flag for something
> you need to check down in ->mmap_validate so I guess I'll live with that
> and if problems really happen, we may have cleaner idea what needs to be
> done.
>
> So overall feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks Jan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
