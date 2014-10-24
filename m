Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 80B926B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:30:34 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so1231409pdj.19
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:30:34 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id fo9si3830155pdb.175.2014.10.24.03.30.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 24 Oct 2014 03:30:33 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDY00IAK2IUKTE0@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Oct 2014 19:30:31 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
 <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
 <xa1tegtylnzl.fsf@mina86.com>
In-reply-to: <xa1tegtylnzl.fsf@mina86.com>
Subject: RE: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
Date: Fri, 24 Oct 2014 16:00:27 +0530
Message-id: <019601cfef75$8fbf8860$af3e9920$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Nazarewicz' <mina86@mina86.com>, akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com



----- Original Message -----
> From: Michal Nazarewicz <mina86@mina86.com>
> To: Pintu Kumar <pintu.k@samsung.com>; akpm@linux-foundation.org; =
riel@redhat.com; pintu.k@samsung.com; aquini@redhat.com; =
paul.gortmaker@windriver.com; jmarchan@redhat.com; =
lcapitulino@redhat.com; kirill.shutemov@linux.intel.com; =
m.szyprowski@samsung.com; aneesh.kumar@linux.vnet.ibm.com; =
iamjoonsoo.kim@lge.com; lauraa@codeaurora.org; gioh.kim@lge.com; =
mgorman@suse.de; rientjes@google.com; hannes@cmpxchg.org; =
vbabka@suse.cz; sasha.levin@oracle.com; linux-kernel@vger.kernel.org; =
linux-mm@kvack.org
> Cc: pintu_agarwal@yahoo.com; cpgs@samsung.com; vishnu.ps@samsung.com; =
rohit.kr@samsung.com; ed.savinay@samsung.com
> Sent: Thursday, 23 October 2014 10:31 PM
> Subject: Re: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
>=20
> On Wed, Oct 22 2014, Pintu Kumar wrote:
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
>> This patch corrects the problem by properly subtracting the CMA =
reserved
>> memory from the total reserved memory in dmesg logs.
>>=20
>> Below is the dmesg snapshot from an arm based device with 512MB RAM =
and
>> 12MB single CMA region.
>>=20
>> Before this change:
>> Memory: 458840k/458840k available, 65448k reserved, 0K highmem
>>=20
>> After this change:
>> Memory: 458840k/458840k available, 53160k reserved, 12288k =
cma-reserved, 0K=20
> highmem
>>=20
>> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
>> Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
>=20
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>=20
>=20
> I'm not sure how Andrew would think about it, and I don't have strong
> feelings, but I would consider a few changes:
>=20
>> ---
>> v2: Moved totalcma_pages extern declaration to linux/cma.h
>>     Removed CONFIG_CMA while show cma-reserved, from page_alloc.c
>>     Moved totalcma_pages declaration to page_alloc.c, so that if will =
be=20
> visible=20
>>     in non-CMA cases.
>>   include/linux/cma.h |    1 +
>>   mm/cma.c            |    1 +
>>   mm/page_alloc.c    |    6 ++++--
>>   3 files changed, 6 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/include/linux/cma.h b/include/linux/cma.h
>> index 0430ed0..0b75896 100644
>> --- a/include/linux/cma.h
>> +++ b/include/linux/cma.h
>> @@ -15,6 +15,7 @@
>>  =20
>>   struct cma;
>>  =20
>> +extern unsigned long totalcma_pages;
>=20
> +#ifdef CONFIG_CMA
> +extern unsigned long totalcma_pages;
> +#else
> +#  define totalcma_pages 0UL
> +#endif
>=20
>>   extern phys_addr_t cma_get_base(struct cma *cma);
>>   extern unsigned long cma_get_size(struct cma *cma);
>>  =20
>> diff --git a/mm/cma.c b/mm/cma.c
>> index 963bc4a..8435762 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -288,6 +288,7 @@ int __init cma_declare_contiguous(phys_addr_t =
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
>> index dd73f9a..ababbd8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -110,6 +110,7 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
>>  =20
>>   unsigned long totalram_pages __read_mostly;
>>   unsigned long totalreserve_pages __read_mostly;
>> +unsigned long totalcma_pages __read_mostly;
>=20
> Move this to cma.c.
>=20

In our earlier patch (first version), we added it in cmc.c itself.
But, Andrew wanted this variable to be visible in non-CMA case as well =
to avoid build error, when we use=20
this variable in mem_init_print_info, without CONFIG_CMA.
So, we moved it to page_alloc.c

>>   /*
>>   * When calculating the number of globally allowed dirty pages, =
there
>>   * is a certain number of per-zone reserves that should not be
>> @@ -5520,7 +5521,7 @@ void __init mem_init_print_info(const char =
*str)
>>  =20
>>       pr_info("Memory: %luK/%luK available "
>>             "(%luK kernel code, %luK rwdata, %luK rodata, "
>> -          "%luK init, %luK bss, %luK reserved"
>> +          "%luK init, %luK bss, %luK reserved, %luK=20
> cma-reserved"
>>   #ifdef    CONFIG_HIGHMEM
>>             ", %luK highmem"
>>   #endif
>> @@ -5528,7 +5529,8 @@ void __init mem_init_print_info(const char =
*str)
>>             nr_free_pages() << (PAGE_SHIFT-10), physpages <<=20
> (PAGE_SHIFT-10),
>>             codesize >> 10, datasize >> 10, rosize >> 10,
>>             (init_data_size + init_code_size) >> 10, bss_size=20
>>> 10,
>> -          (physpages - totalram_pages) << (PAGE_SHIFT-10),
>> +          (physpages - totalram_pages - totalcma_pages) <<=20
> (PAGE_SHIFT-10),
>> +          totalcma_pages << (PAGE_SHIFT-10),
>>   #ifdef    CONFIG_HIGHMEM
>>             totalhigh_pages << (PAGE_SHIFT-10),
>>   #endif
>> --=20
>> 1.7.9.5
>>=20
>=20
> --=20
> Best regards,                                        _    _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
> ..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D =
Nazarewicz    (o o)
> ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--
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
