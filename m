Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 03EB06B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 03:55:02 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id lh14so3844690vcb.19
        for <linux-mm@kvack.org>; Thu, 15 May 2014 00:55:02 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id aw3si40769vdd.201.2014.05.15.00.55.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 00:55:02 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so3853730vcb.41
        for <linux-mm@kvack.org>; Thu, 15 May 2014 00:55:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514155610.5a8c64fbff857a22cb8c6e91@linux-foundation.org>
References: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
	<1400055532-13134-2-git-send-email-superlibj8301@gmail.com>
	<20140514155610.5a8c64fbff857a22cb8c6e91@linux-foundation.org>
Date: Thu, 15 May 2014 15:55:01 +0800
Message-ID: <CAHPCO9HSe8GmgO9s0fQc+EY3EuyEC_Y3cuFuJ7gTe==qGmDy8w@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] mm/vmalloc: Add IO mapping space reused interface support.
From: Richard Lee <superlibj8301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, arnd@arndb.de, robherring2@gmail.com, lauraa@codeaurora.org, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Thu, May 15, 2014 at 6:56 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 May 2014 16:18:51 +0800 Richard Lee <superlibj8301@gmail.com> wrote:
>
>> For the IO mapping, the same physical address space maybe
>> mapped more than one time, for example, in some SoCs:
>>   - 0x20001000 ~ 0x20001400 --> 1KB for Dev1
>>   - 0x20001400 ~ 0x20001800 --> 1KB for Dev2
>>   and the page size is 4KB.
>>
>> Then both Dev1 and Dev2 will do ioremap operations, and the IO
>> vmalloc area's virtual address will be aligned down to 4KB, and
>> the size will be aligned up to 4KB. That's to say, only one
>> 4KB size's vmalloc area could contain Dev1 and Dev2 IO mapping area
>> at the same time.
>
> Unclear.  What happens when a caller does the two ioremaps at present?
> It fails?  Returns the current mapping's address?  Something else?
>

For this case, should the later one wait ?
Maybe this patch hasn't consider about this.


>> For this case, we can ioremap only one time, and the later ioremap
>> operation will just return the exist vmalloc area.
>
> I guess an alternative is to establish a new vmap pointing at the same
> physical address.  How does this approach compare to refcounting the
> existing vmap?
>

Yes, I'm also thinking to estabish one new vmap.


>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -1,6 +1,7 @@
>>  #ifndef _LINUX_VMALLOC_H
>>  #define _LINUX_VMALLOC_H
>>
>> +#include <linux/atomic.h>
>>  #include <linux/spinlock.h>
>>  #include <linux/init.h>
>>  #include <linux/list.h>
>> @@ -34,6 +35,7 @@ struct vm_struct {
>>       struct page             **pages;
>>       unsigned int            nr_pages;
>>       phys_addr_t             phys_addr;
>> +     atomic_t                used;
>>       const void              *caller;
>>  };
>>
>> @@ -100,6 +102,9 @@ static inline size_t get_vm_area_size(const struct vm_struct *area)
>>       return area->size - PAGE_SIZE;
>>  }
>>
>> +extern struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
>> +                                  unsigned long *offset,
>> +                                  unsigned long flags);
>>  extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
>>  extern struct vm_struct *get_vm_area_caller(unsigned long size,
>>                                       unsigned long flags, const void *caller);
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index bf233b2..cf0093c 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1293,6 +1293,7 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
>>       vm->addr = (void *)va->va_start;
>>       vm->size = va->va_end - va->va_start;
>>       vm->caller = caller;
>> +     atomic_set(&vm->used, 1);
>>       va->vm = vm;
>>       va->flags |= VM_VM_AREA;
>>       spin_unlock(&vmap_area_lock);
>> @@ -1383,6 +1384,84 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
>>                                 NUMA_NO_NODE, GFP_KERNEL, caller);
>>  }
>>
>> +static int vm_area_used_inc(struct vm_struct *area)
>> +{
>> +     if (!(area->flags & VM_IOREMAP))
>> +             return -EINVAL;
>
> afaict this can never happen?
>

Yes, it is for now.

>> +     atomic_add(1, &area->used);
>> +
>> +     return atomic_read(&va->vm->used);
>
> atomic_add_return() is neater.  But the return value is in fact never
> used so it could return void.
>

yes, that' fine.

>> +}
>> +
>> +static int vm_area_used_dec(const void *addr)
>> +{
>> +     struct vmap_area *va;
>> +
>> +     va = find_vmap_area((unsigned long)addr);
>> +     if (!va || !(va->flags & VM_VM_AREA))
>> +             return 0;
>> +
>> +     if (!(va->vm->flags & VM_IOREMAP))
>> +             return 0;
>> +
>> +     atomic_sub(1, &va->vm->used);
>> +
>> +     return atomic_read(&va->vm->used);
>
> atomic_sub_return()
>

yes,

>> +}
>> +
>> +/**
>> + *   find_vm_area_paddr  -  find a continuous kernel virtual area using the
>> + *                   physical addreess.
>> + *   @paddr:         base physical address
>> + *   @size:          size of the physical area range
>> + *   @offset:        the start offset of the vm area
>> + *   @flags:         %VM_IOREMAP for I/O mappings
>> + *
>> + *   Search for the kernel VM area, whoes physical address starting at
>> + *   @paddr, and if the exsit VM area's size is large enough, then return
>> + *   it with increasing the 'used' counter, or return NULL.
>> + */
>> +struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
>> +                                  unsigned long *offset,
>> +                                  unsigned long flags)
>> +{
>> +     struct vmap_area *va;
>> +     int off;
>> +
>> +     if (!(flags & VM_IOREMAP))
>> +             return NULL;
>> +
>> +     size = PAGE_ALIGN((paddr & ~PAGE_MASK) + size);
>> +
>> +     rcu_read_lock();
>> +     list_for_each_entry_rcu(va, &vmap_area_list, list) {
>> +             phys_addr_t phys_addr;
>> +
>> +             if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
>> +                     continue;
>> +
>> +             if (!(va->vm->flags & VM_IOREMAP))
>> +                     continue;
>> +
>> +             phys_addr = va->vm->phys_addr;
>> +
>> +             off = (paddr & PAGE_MASK) - (phys_addr & PAGE_MASK);
>> +             if (off < 0)
>> +                     continue;
>> +
>> +             if (off + size <= va->vm->size - PAGE_SIZE) {
>> +                     *offset = off + (paddr & ~PAGE_MASK);
>> +                     vm_area_used_inc(va->vm);
>> +                     rcu_read_unlock();
>> +                     return va->vm;
>> +             }
>> +     }
>> +     rcu_read_unlock();
>> +
>> +     return NULL;
>> +}
>> +
>>  /**
>>   *   find_vm_area  -  find a continuous kernel virtual area
>>   *   @addr:          base address
>> @@ -1443,6 +1522,9 @@ static void __vunmap(const void *addr, int deallocate_pages)
>>                       addr))
>>               return;
>>
>> +     if (vm_area_used_dec(addr))
>> +             return;
>
> This could do with a comment explaining why we return - ie, document
> the overall concept/design.
>
> Also, what prevents races here?  Some other thread comes in and grabs a
> new reference just after this thread has decided to nuke the vmap?
>
> If there's locking here which I failed to notice then some code
> commentary which explains the locking rules would also be nice.
>

I will try to revise this.

Actually, I'm thinking about adding a new rb tree for the ioremap vmalloc
area sorted by physical address ? Then this will be more efficient for
searching.



Thanks very much for you comments.

BRs
Richard Lee



>>       area = remove_vm_area(addr);
>>       if (unlikely(!area)) {
>>               WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
