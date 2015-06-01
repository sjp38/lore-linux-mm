Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6B78C900015
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 12:22:15 -0400 (EDT)
Received: by wizo1 with SMTP id o1so112035299wiz.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:22:15 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id h5si25578499wjz.65.2015.06.01.09.22.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 09:22:13 -0700 (PDT)
Received: by wifw1 with SMTP id w1so112190015wif.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:22:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <556C4477.8090803@plexistor.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150530185940.32590.37804.stgit@dwillia2-desk3.amr.corp.intel.com>
	<556C4477.8090803@plexistor.com>
Date: Mon, 1 Jun 2015 09:22:09 -0700
Message-ID: <CAPcyv4jW7emFWnaj9zur28fFK_h9KQW6HPW+PfZpYA28-7Xr9w@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] arch, x86: cache management apis for persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis Rodriguez <mcgrof@suse.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 1, 2015 at 4:39 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 05/30/2015 09:59 PM, Dan Williams wrote:
>> From: Ross Zwisler <ross.zwisler@linux.intel.com>
>>
>> Based on an original patch by Ross Zwisler [1].
>>
>> Writes to persistent memory have the potential to be posted to cpu
>> cache, cpu write buffers, and platform write buffers (memory controller)
>> before being committed to persistent media.  Provide apis
>> (persistent_copy() and persistent_sync()) to copy data and assert that
>> it is durable in PMEM (a persistent linear address range).
>>
>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000932.html
>>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> [djbw: s/arch_persistent_flush()/io_flush_cache_range()/]
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  arch/x86/Kconfig                  |    1
>>  arch/x86/include/asm/cacheflush.h |   24 ++++++++++
>>  arch/x86/include/asm/io.h         |    6 ++
>>  drivers/block/pmem.c              |   58 ++++++++++++++++++++++-
>>  include/linux/pmem.h              |   93 +++++++++++++++++++++++++++++++++++++
>>  lib/Kconfig                       |    3 +
>>  6 files changed, 183 insertions(+), 2 deletions(-)
>>  create mode 100644 include/linux/pmem.h
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 73a4d0330ad0..6412d92e6f1e 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -102,6 +102,7 @@ config X86
>>       select HAVE_ARCH_TRANSPARENT_HUGEPAGE
>>       select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
>>       select ARCH_HAS_SG_CHAIN
>> +     select ARCH_HAS_PMEM_API
>>       select CLKEVT_I8253
>>       select ARCH_HAVE_NMI_SAFE_CMPXCHG
>>       select GENERIC_IOMAP
>> diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
>> index b6f7457d12e4..6b8bd5c43bf6 100644
>> --- a/arch/x86/include/asm/cacheflush.h
>> +++ b/arch/x86/include/asm/cacheflush.h
>> @@ -4,6 +4,7 @@
>>  /* Caches aren't brain-dead on the intel. */
>>  #include <asm-generic/cacheflush.h>
>>  #include <asm/special_insns.h>
>> +#include <asm/uaccess.h>
>>
>>  /*
>>   * The set_memory_* API can be used to change various attributes of a virtual
>> @@ -108,4 +109,27 @@ static inline int rodata_test(void)
>>  }
>>  #endif
>>
>> +static inline void arch_persistent_copy(void *dst, const void *src, size_t n)
>> +{
>> +     /*
>> +      * We are copying between two kernel buffers, if
>> +      * __copy_from_user_inatomic_nocache() returns an error (page
>> +      * fault) we would have already taken an unhandled fault before
>> +      * the BUG_ON.  The BUG_ON is simply here to satisfy
>> +      * __must_check and allow reuse of the common non-temporal store
>> +      * implementation for persistent_copy().
>> +      */
>> +     BUG_ON(__copy_from_user_inatomic_nocache(dst, src, n));
>> +}
>> +
>> +static inline void arch_persistent_sync(void)
>> +{
>> +     wmb();
>> +     pcommit_sfence();
>> +}
>> +
>> +static inline bool __arch_has_persistent_sync(void)
>> +{
>> +     return boot_cpu_has(X86_FEATURE_PCOMMIT);
>> +}
>>  #endif /* _ASM_X86_CACHEFLUSH_H */
>> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
>> index 956f2768bdc1..f3c32bb207cf 100644
>> --- a/arch/x86/include/asm/io.h
>> +++ b/arch/x86/include/asm/io.h
>> @@ -250,6 +250,12 @@ static inline void flush_write_buffers(void)
>>  #endif
>>  }
>>
>> +static inline void *arch_persistent_remap(resource_size_t offset,
>> +     unsigned long size)
>> +{
>> +     return (void __force *) ioremap_cache(offset, size);
>> +}
>> +
>>  #endif /* __KERNEL__ */
>>
>>  extern void native_io_delay(void);
>> diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
>> index 799acff6bd7c..10cbe557165c 100644
>> --- a/drivers/block/pmem.c
>> +++ b/drivers/block/pmem.c
>> @@ -23,9 +23,16 @@
>>  #include <linux/module.h>
>>  #include <linux/moduleparam.h>
>>  #include <linux/slab.h>
>> +#include <linux/pmem.h>
>>
>>  #define PMEM_MINORS          16
>>
>> +struct pmem_ops {
>> +     void *(*remap)(resource_size_t offset, unsigned long size);
>> +     void (*copy)(void *dst, const void *src, size_t size);
>> +     void (*sync)(void);
>
> What? why the ops at all see below ...
>
>> +};
>> +
>>  struct pmem_device {
>>       struct request_queue    *pmem_queue;
>>       struct gendisk          *pmem_disk;
>> @@ -34,11 +41,54 @@ struct pmem_device {
>>       phys_addr_t             phys_addr;
>>       void                    *virt_addr;
>>       size_t                  size;
>> +     struct pmem_ops         ops;
>>  };
>>
>>  static int pmem_major;
>>  static atomic_t pmem_index;
>>
>> +static void default_pmem_sync(void)
>> +{
>> +     wmb();
>> +}
>> +
>> +static void default_pmem_copy(void *dst, const void *src, size_t size)
>> +{
>> +     memcpy(dst, src, size);
>> +}
>> +
>> +static void pmem_ops_default_init(struct pmem_device *pmem)
>> +{
>> +     /*
>> +      * These defaults seek to offer decent performance and minimize
>> +      * the window between i/o completion and writes being durable on
>> +      * media.  However, it is undefined / architecture specific
>> +      * whether acknowledged data may be lost in transit if a power
>> +      * fail occurs after bio_endio().
>> +      */
>> +     pmem->ops.remap = memremap_wt;
>> +     pmem->ops.copy = default_pmem_copy;
>> +     pmem->ops.sync = default_pmem_sync;
>> +}
>> +
>> +static bool pmem_ops_init(struct pmem_device *pmem)
>> +{
>> +     if (IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API) &&
>> +                     arch_has_persistent_sync()) {
>
> I must be slow and stupid but it looks to me like:
>
> if arch_has_persistent_sync == false then persistent_sync
> can then just be the default above wmb, and
>         if (something_always_off())
>                 do
> Will be always faster then a function pointer. This
> if can be in the generic implementation of persistent_sync
> and be done with.

A few things... that "something_always_off()" check is a cpuid call on
x86.  There's no need to keep asking we can resolve the answer once at
init.  If you can get this indirect branch to show up in a meaningful
way on a profile I'd reconsider, but branch-target-buffers are fairly
good these days.  The wmb() is neither necessary nor sufficient on x86
and it's simply a guess that it helps on other archs().

> Then persistent_copy() can just have an inline generic
> implementation of your memcpy above, and the WARN_ON_ONCE
> or what ever you want.

No, persistent_copy() does not have the proper context to tell you
which device is encountering the problem.  And again, we'd be taking a
conditional branch every i/o for this determination that could be made
once at init.

> And no need for any opt vector and function pointers call out.

There's a third case to consider, driver local persistence guarantees.
ADR platforms need not call pcommit_sfence() to guarantee persistence.
In that case I would expect ADR platform enabling developers to extend
pmem_ops_init() to turn off the warning with ops that are specific to
their platform.  We also have directed flush support through registers
that could be turned into another op option.

> And also for me the all arch_has_persistent_sync() is mute,
> the arches that have members of its family not support some
> fixture can do the if (always_false_or_true) thing and do
> not pollute the global name space. All we need is a single
> switch as above
> #ifdef CONFIG_ARCH_HAS_PMEM_API
>         => arch_persistent_sync
> #else
>         => wmb

wmb() is not a substitute for pcommit, I think it is dangerous to
imply that you can silently fall back to wmb().

> #endif
>
>> +             /*
>> +              * This arch + cpu guarantees that bio_endio() == data
>> +              * durable on media.
>> +              */
>> +             pmem->ops.remap = persistent_remap;
>> +             pmem->ops.copy = persistent_copy;
>> +             pmem->ops.sync = persistent_sync;
>> +             return true;
>> +     }
>> +
>> +     pmem_ops_default_init(pmem);
>> +     return false;
>> +}
>> +
>>  static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
>>                       unsigned int len, unsigned int off, int rw,
>>                       sector_t sector)
>> @@ -51,7 +101,7 @@ static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
>>               flush_dcache_page(page);
>>       } else {
>>               flush_dcache_page(page);
>> -             memcpy(pmem->virt_addr + pmem_off, mem + off, len);
>> +             pmem->ops.copy(pmem->virt_addr + pmem_off, mem + off, len);
>>       }
>>
>>       kunmap_atomic(mem);
>> @@ -82,6 +132,8 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
>>               sector += bvec.bv_len >> 9;
>>       }
>>
>> +     if (rw)
>> +             pmem->ops.sync();
>>  out:
>>       bio_endio(bio, err);
>>  }
>> @@ -131,6 +183,8 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
>>
>>       pmem->phys_addr = res->start;
>>       pmem->size = resource_size(res);
>> +     if (!pmem_ops_init(pmem))
>
> fine just #ifndef CONFIG_ARCH_HAS_PMEM_API

No because the presence of the API is not sufficient to determine
whether persistence durability can be guaranteed.

>> +             dev_warn(dev, "unable to guarantee persistence of writes\n");
>
> But I wouldn't even bother I'd just put a WARN_ON_ONCE inside
> persistent_copy() on any real use pmem or not and be done with it.

Again, we can make this determination once, and not forever for every
future usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
