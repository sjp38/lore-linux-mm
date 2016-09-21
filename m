Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBADA6B026B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 19:22:47 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i129so137812865ywb.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:22:47 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id t8si24710826qkt.172.2016.09.21.16.22.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 16:22:47 -0700 (PDT)
Subject: Re: [PATCH 2/5] mm/vmalloc.c: simplify /proc/vmallocinfo
 implementation
References: <57E20BE0.6040104@zoho.com>
 <alpine.DEB.2.10.1609211414200.20971@chino.kir.corp.google.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <7961c13d-639a-25d7-ac0d-3dac2ebd7524@zoho.com>
Date: Thu, 22 Sep 2016 07:22:33 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1609211414200.20971@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/22 5:16, David Rientjes wrote:
> On Wed, 21 Sep 2016, zijun_hu wrote:
> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index cc6ecd6..a125ae8 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -2576,32 +2576,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
>>  static void *s_start(struct seq_file *m, loff_t *pos)
>>  	__acquires(&vmap_area_lock)
>>  {
>> -	loff_t n = *pos;
>> -	struct vmap_area *va;
>> -
>>  	spin_lock(&vmap_area_lock);
>> -	va = list_first_entry(&vmap_area_list, typeof(*va), list);
>> -	while (n > 0 && &va->list != &vmap_area_list) {
>> -		n--;
>> -		va = list_next_entry(va, list);
>> -	}
>> -	if (!n && &va->list != &vmap_area_list)
>> -		return va;
>> -
>> -	return NULL;
>> -
>> +	return seq_list_start(&vmap_area_list, *pos);
>>  }
>>  
>>  static void *s_next(struct seq_file *m, void *p, loff_t *pos)
>>  {
>> -	struct vmap_area *va = p, *next;
>> -
>> -	++*pos;
>> -	next = list_next_entry(va, list);
>> -	if (&next->list != &vmap_area_list)
>> -		return next;
>> -
>> -	return NULL;
>> +	return seq_list_next(p, &vmap_area_list, pos);
>>  }
>>  
>>  static void s_stop(struct seq_file *m, void *p)
>> @@ -2636,9 +2617,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
>>  
>>  static int s_show(struct seq_file *m, void *p)
>>  {
>> -	struct vmap_area *va = p;
>> +	struct vmap_area *va;
>>  	struct vm_struct *v;
>>  
>> +	va = list_entry((struct list_head *)p, struct vmap_area, list);
> 
> Looks good other than no cast is neccessary above.
  you are right, it will correct it
  i refer to show_timer()@fs/proc/base.c plainly and ignore that redundant cast
> 
> The patches in this series seem to be unrelated to each other, they 
> shouldn't be numbered in order since there's no dependence.  Just 
> individual patches are fine.
> 
you are right, i will provide a individual patch finnally

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
