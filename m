From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 4/4] mm/vmalloc: don't assume vmap_area w/o VM_VM_AREA
 flag is vm_map_ram allocation
Date: Tue, 3 Sep 2013 15:51:39 +0800
Message-ID: <7609.04283165491$1378194759@news.gmane.org>
References: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378191706-29696-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130903074221.GA30920@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VGlPc-0001iM-2y
	for glkm-linux-mm-2@m.gmane.org; Tue, 03 Sep 2013 09:52:32 +0200
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 253CC6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:52:18 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 17:37:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A024D2BB005A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 17:51:48 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r837pVJt5308834
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 17:51:37 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r837pfA8014028
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 17:51:41 +1000
Content-Disposition: inline
In-Reply-To: <20130903074221.GA30920@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 03, 2013 at 04:42:21PM +0900, Joonsoo Kim wrote:
>On Tue, Sep 03, 2013 at 03:01:46PM +0800, Wanpeng Li wrote:
>> There is a race window between vmap_area free and show vmap_area information.
>> 
>> 	A                                                B
>> 
>> remove_vm_area
>> spin_lock(&vmap_area_lock);
>> va->flags &= ~VM_VM_AREA;
>> spin_unlock(&vmap_area_lock);
>> 						spin_lock(&vmap_area_lock);
>> 						if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEZING))
>> 							return 0;
>> 						if (!(va->flags & VM_VM_AREA)) {
>> 							seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>> 								(void *)va->va_start, (void *)va->va_end,
>> 								va->va_end - va->va_start);
>> 							return 0;
>> 						}
>> free_unmap_vmap_area(va);
>> 	flush_cache_vunmap
>> 	free_unmap_vmap_area_noflush
>> 		unmap_vmap_area
>> 		free_vmap_area_noflush
>> 			va->flags |= VM_LAZY_FREE 
>> 
>> The assumption is introduced by commit: d4033afd(mm, vmalloc: iterate vmap_area_list, 
>> instead of vmlist, in vmallocinfo()). This patch fix it by drop the assumption and 
>> keep not dump vm_map_ram allocation information as the logic before that commit.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/vmalloc.c | 7 -------
>>  1 file changed, 7 deletions(-)
>> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 5368b17..62b7932 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -2586,13 +2586,6 @@ static int s_show(struct seq_file *m, void *p)
>>  	if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
>>  		return 0;
>>  
>> -	if (!(va->flags & VM_VM_AREA)) {
>> -		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>> -			(void *)va->va_start, (void *)va->va_end,
>> -					va->va_end - va->va_start);
>> -		return 0;
>> -	}
>> -
>>  	v = va->vm;
>>  
>>  	seq_printf(m, "0x%pK-0x%pK %7ld",
>
>Hello, Wanpeng.
>

Hi Joonsoo and Yanfei,

>Did you test this patch?
>
>I guess that, With this patch, if there are some vm_map areas,
>null pointer deference would occurs, since va->vm may be null for it.
>
>And with this patch, if this race really occur, null pointer deference
>would occurs too, since va->vm is set to null in remove_vm_area().
>
>I think that this is not a right fix for this possible race.
>

How about append below to this patch?

if (va->vm)
	v = va->vm;
else 
	return 0;

Regards,
Wanpeng Li 

>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
