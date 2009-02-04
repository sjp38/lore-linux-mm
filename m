Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 47E866B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 06:01:25 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so1193753fgg.4
        for <linux-mm@kvack.org>; Wed, 04 Feb 2009 03:01:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090204083524.GJ4456@balbir.in.ibm.com>
References: <20090204170944.c93772d2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090204083524.GJ4456@balbir.in.ibm.com>
Date: Wed, 4 Feb 2009 13:01:22 +0200
Message-ID: <84144f020902040301p138411fam2295c37843515f90@mail.gmail.com>
Subject: Re: [PATCH] use __GFP_NOWARN in page cgroup allocation
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, heiko.carstens@de.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 4, 2009 at 10:35 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-04 17:09:44]:
>
>> This was recommended in
>> "kmalloc-return-null-instead-of-link-failure.patch added to -mm tree" thread
>> in the last month.
>> Thanks,
>> -Kame
>> =
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> page_cgroup's page allocation at init/memory hotplug uses kmalloc() and
>> vmalloc(). If kmalloc() failes, vmalloc() is used.
>>
>> This is because vmalloc() is very limited resource on 32bit systems.
>> We want to use kmalloc() first.
>>
>> But in this kind of call, __GFP_NOWARN should be specified.
>>
>> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> Index: mmotm-2.6.29-Feb03/mm/page_cgroup.c
>> ===================================================================
>> --- mmotm-2.6.29-Feb03.orig/mm/page_cgroup.c
>> +++ mmotm-2.6.29-Feb03/mm/page_cgroup.c
>> @@ -114,7 +114,8 @@ static int __init_refok init_section_pag
>>               nid = page_to_nid(pfn_to_page(pfn));
>>               table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
>>               if (slab_is_available()) {
>> -                     base = kmalloc_node(table_size, GFP_KERNEL, nid);
>> +                     base = kmalloc_node(table_size,
>> +                                     GFP_KERNEL | __GFP_NOWARN, nid);
>
> Thanks for getting to this.
>
>>                       if (!base)
>>                               base = vmalloc_node(table_size, nid);
>>               } else {
>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Looks good to me as well.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
