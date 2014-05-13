Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 971D66B0039
	for <linux-mm@kvack.org>; Tue, 13 May 2014 02:21:25 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so9366282vcb.11
        for <linux-mm@kvack.org>; Mon, 12 May 2014 23:21:25 -0700 (PDT)
Received: from mail-vc0-x231.google.com (mail-vc0-x231.google.com [2607:f8b0:400c:c03::231])
        by mx.google.com with ESMTPS id sq9si2471594vdc.89.2014.05.12.23.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 23:21:25 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id if17so5628464vcb.22
        for <linux-mm@kvack.org>; Mon, 12 May 2014 23:21:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL_JsqK=BiZx31xUC=_8s7+QeAGjrWePOzeDLEt=YfpdLbS_KA@mail.gmail.com>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
	<1399861195-21087-2-git-send-email-superlibj8301@gmail.com>
	<CAL_JsqK=BiZx31xUC=_8s7+QeAGjrWePOzeDLEt=YfpdLbS_KA@mail.gmail.com>
Date: Tue, 13 May 2014 14:21:24 +0800
Message-ID: <CAHPCO9G8nqVfBXw3ej_Ot8CUkKgVB5QiZtkd9y+JBOBAaeJ7GQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/2] mm/vmalloc: Add IO mapping space reused interface.
From: Richard Lee <superlibj8301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robherring2@gmail.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Lee <superlibj@gmail.com>

On Tue, May 13, 2014 at 11:13 AM, Rob Herring <robherring2@gmail.com> wrote:
> On Sun, May 11, 2014 at 9:19 PM, Richard Lee <superlibj8301@gmail.com> wrote:
>> For the IO mapping, for the same physical address space maybe
>> mapped more than one time, for example, in some SoCs:
>> 0x20000000 ~ 0x20001000: are global control IO physical map,
>> and this range space will be used by many drivers.
>
> What address or who the user is isn't really relevant.
>
>> And then if each driver will do the same ioremap operation, we
>> will waste to much malloc virtual spaces.
>
> s/malloc/vmalloc/
>
>>
>> This patch add the IO mapping space reusing interface:
>> - find_vm_area_paddr: used to find the exsit vmalloc area using
>
> s/exsit/exist/
>

Yes, see the next version.

[...]
>> +{
>> +       struct vmap_area *va;
>> +
>> +       va = find_vmap_area((unsigned long)addr);
>> +       if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
>> +               return 1;
>> +
>> +       if (va->vm->used <= 1)
>> +               return 1;
>> +
>> +       --va->vm->used;
>
> What lock protects this? You should use atomic ops here.
>

Yes, it is.


[...]
>> +       if (!(flags & VM_IOREMAP))
>> +               return NULL;
>> +
>> +       rcu_read_lock();
>> +       list_for_each_entry_rcu(va, &vmap_area_list, list) {
>> +               phys_addr_t phys_addr;
>> +
>> +               if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
>> +                       continue;
>> +
>> +               phys_addr = va->vm->phys_addr;
>> +
>> +               if (paddr < phys_addr || paddr + size > phys_addr + va->vm->size)
>> +                       continue;
>> +
>> +               *offset = paddr - phys_addr;
>> +
>> +               if (va->vm->flags & VM_IOREMAP && va->vm->size >= size) {
>> +                       va->vm->used++;
>
> What lock protects this? It looks like you are modifying this with
> only a rcu reader lock.

I'll try to use the proper lock ops for this later.



Thanks very much,

Richard


>
>> +                       rcu_read_unlock();
>> +                       return va->vm;
>> +               }
>> +       }
>> +       rcu_read_unlock();
>> +
>> +       return NULL;
>> +}
>> +
>>  /**
>>   *     find_vm_area  -  find a continuous kernel virtual area
>>   *     @addr:          base address
>> --
>> 1.8.4
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
