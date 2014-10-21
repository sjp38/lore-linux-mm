Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEE682BDD
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 09:22:36 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so1333486pdi.38
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:22:35 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id zz3si11203743pac.49.2014.10.21.06.22.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 21 Oct 2014 06:22:35 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDS00B3QQHK7A40@mailout1.samsung.com> for linux-mm@kvack.org;
 Tue, 21 Oct 2014 22:22:32 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
 <5445AD12.9080502@lge.com>
In-reply-to: <5445AD12.9080502@lge.com>
Subject: RE: [PATCH] mm: cma: split cma-reserved in dmesg log
Date: Tue, 21 Oct 2014 18:51:30 +0530
Message-id: <00cd01cfed32$1ebfd5b0$5c3f8110$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=ks_c_5601-1987
Content-transfer-encoding: quoted-printable
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Gioh Kim' <gioh.kim@lge.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, vdavydov@parallels.com, nasa4836@gmail.com, ddstreet@ieee.org, m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, lauraa@codeaurora.org, rientjes@google.com, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pintu.k@samsung.com
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com, =?ks_c_5601-1987?B?J8DMsMfIoyc=?= <gunho.lee@lge.com>


Hi,

----- Original Message -----
> From: Gioh Kim <gioh.kim@lge.com>
> To: Pintu Kumar <pintu.k@samsung.com>; akpm@linux-foundation.org;
hannes@cmpxchg.org; riel@redhat.com; mgorman@suse.de;
vdavydov@parallels.com; nasa4836@gmail.com; ddstreet@ieee.org;
m.szyprowski@samsung.com; mina86@mina86.com; iamjoonsoo.kim@lge.com; =
aneesh.
kumar@linux.vnet.ibm.com; lauraa@codeaurora.org; rientjes@google.com;
vbabka@suse.cz; sasha.levin@oracle.com; linux-kernel@vger.kernel.org; =
linux-
mm@kvack.org
> Cc: cpgs@samsung.com; pintu_agarwal@yahoo.com; vishnu.ps@samsung.com;
rohit.kr@samsung.com; ed.savinay@samsung.com; =C0=CC=B0=C7=C8=A3 =
<gunho.lee@lge.com>
> Sent: Tuesday, 21 October 2014 6:17 AM
> Subject: Re: [PATCH] mm: cma: split cma-reserved in dmesg log
>=20
>=20
>=20
> 2014-10-20 =BF=C0=C8=C4 4:33, Pintu Kumar =BE=B4 =B1=DB:
>> When the system boots up, in the dmesg logs we can see
>> the memory statistics along with total reserved as below.
>> Memory: 458840k/458840k available, 65448k reserved, 0K highmem
>>=20
>> When CMA is enabled, still the total reserved memory remains the =
same.
>> However, the CMA memory is not considered as reserved.
>> But, when we see /proc/meminfo, the CMA memory is part of free =
memory.
>> This creates confusion.
>> This patch corrects the problem by properly substracting the CMA =
reserved
>> memory from the total reserved memory in dmesg logs.
>>=20
>> Below is the dmesg snaphot from an arm based device with 512MB RAM =
and
>> 12MB single CMA region.
>>=20
>> Before this change:
>> Memory: 458840k/458840k available, 65448k reserved, 0K highmem
>>=20
>> After this change:
>> Memory: 458840k/458840k available, 53160k reserved, 12288k =
cma-reserved,
0K=20
> highmem
>>=20
>> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
>> Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
>> ---
>>   include/linux/swap.h | 3 +++
>>   mm/cma.c            | 2 ++
>>   mm/page_alloc.c      | 8 ++++++++
>>   3 files changed, 13 insertions(+)
>>=20
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 37a585b..beb84be 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -295,6 +295,9 @@ static inline void
workingset_node_shadows_dec(struct=20
> radix_tree_node *node)
>>   /* linux/mm/page_alloc.c */
>>   extern unsigned long totalram_pages;
>>   extern unsigned long totalreserve_pages;
>> +#ifdef CONFIG_CMA
>> +extern unsigned long totalcma_pages;
>> +#endif

Ok, as per Andrew Morton comment, will remove CONFIG_CMA,=20
But then I need to put it under: include/linux/mm.h
In that case, it will solve the problem for CMA and non-CMA case.
Because, mm.h is already included in cma.c

>>   extern unsigned long dirty_balance_reserve;
>>   extern unsigned long nr_free_buffer_pages(void);
>>   extern unsigned long nr_free_pagecache_pages(void);
>> diff --git a/mm/cma.c b/mm/cma.c
>> index 963bc4a..73fe7be 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -45,6 +45,7 @@ struct cma {
>>   static struct cma cma_areas[MAX_CMA_AREAS];
>>   static unsigned cma_area_count;
>>   static DEFINE_MUTEX(cma_mutex);
>> +unsigned long totalcma_pages __read_mostly;
>=20
> I think __read_mostly is not good here.
> Cma areas often are rare
> but we cannot expect how many cma areas exists.
>=20

Firstly, I want to move this to mm/page_alloc.c, so that it can be =
visible
for non-CMA cases.
Next, the purpose this variable is not only during init time.
Just like totalram_pages, I wanted to retain this variable to use it to
populate the CMA info, during /proc/meminfo.
Like:
CMATotal: (using totalcma_pages)
CMAFree:  (using NR_FREE_CMA_PAGES)
I will post these changes in the next patch series.
Please let me know your comments.

>>  =20
>>   phys_addr_t cma_get_base(struct cma *cma)
>>   {
>> @@ -288,6 +289,7 @@ int __init cma_declare_contiguous(phys_addr_t =
base,
>>       if (ret)
>>           goto err;
>>  =20
>> +    totalcma_pages +=3D (size / PAGE_SIZE);
>>       pr_info("Reserved %ld MiB at %08lx\n", (unsigned=20
> long)size / SZ_1M,
>>           (unsigned long)base);
>>       return 0;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index dd73f9a..c6165ac 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5521,6 +5521,9 @@ void __init mem_init_print_info(const char =
*str)
>>       pr_info("Memory: %luK/%luK available "
>>             "(%luK kernel code, %luK rwdata, %luK rodata, "
>>             "%luK init, %luK bss, %luK reserved"
>> +#ifdef CONFIG_CMA
>> +        ", %luK cma-reserved"
>> +#endif
>>   #ifdef    CONFIG_HIGHMEM
>>             ", %luK highmem"
>>   #endif
>> @@ -5528,7 +5531,12 @@ void __init mem_init_print_info(const char =
*str)
>>             nr_free_pages() << (PAGE_SHIFT-10), physpages <<=20
> (PAGE_SHIFT-10),
>>             codesize >> 10, datasize >> 10, rosize >>=20
> 10,
>>             (init_data_size + init_code_size) >> 10, bss_size=20
>>> 10,
>> +#ifdef CONFIG_CMA
>> +          (physpages - totalram_pages - totalcma_pages) <<=20
> (PAGE_SHIFT-10),
>> +          totalcma_pages << (PAGE_SHIFT-10),
>> +#else
>>             (physpages - totalram_pages) << (PAGE_SHIFT-10),
>> +#endif
>>   #ifdef    CONFIG_HIGHMEM
>>             totalhigh_pages << (PAGE_SHIFT-10),
>>   #endif
>>=20
>=20
> I basically agree with your point.
> But CMA feature is not popular yet, so memory develoers probably =
doesn't=20
> like this.
>=20

Ok agree. If we move totalcma_pages declaration to page_alloc.c and =
mm.h,
then we can get rid of CONFIG_CMA, to make it neat.


> I'm not sure but I think there is a debugfs file for cma.
> Can you use it?
>=20

As of now, I think there is no debugfs for cma.
However, we can make one if required.

> Or what do you think about making another proc file to show cma area =
size
and=20
> address?
> For instance,
>=20
> # cat /proc/cmainfo
> CMATotal:    400kB
> 0x10000000  300kB
> 0x20000000  100kB
>=20

I think this is not required.
For multiple CMA regions, this can be found under:
/sys/kernel/debug/memblock/reserved
However, as I said, we can populate this information under: =
/proc/meminfo
I think capturing it at one place will be better. For non-CMA cases, it
will be hidden.
Thus summary of CMA info can be seen in meminfo, and detailed =
information
can be seen in memblock/reserved.
Do, let me know if you have any other idea?

>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org">=20
> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
