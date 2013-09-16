Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6AA716B0036
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 19:25:13 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 09:25:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 08FAF2BB0056
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:25:09 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GN8dfK459104
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:08:39 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8GNP86l012457
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:25:08 +1000
Date: Tue, 17 Sep 2013 07:25:06 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 4/4] mm/vmalloc: fix show vmap_area information
 race with vmap_area tear down
Message-ID: <20130916232506.GB3241@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <523777D8.2000304@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <523777D8.2000304@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 16, 2013 at 05:27:52PM -0400, KOSAKI Motohiro wrote:
>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>> Changelog:
>>  *v4 -> v5: return directly for !VM_VM_AREA case and remove (VM_LAZY_FREE | VM_LAZY_FREEING) check 
>> 
>> There is a race window between vmap_area tear down and show vmap_area information.
>> 
>> 	A                                                B
>> 
>> remove_vm_area
>> spin_lock(&vmap_area_lock);
>> va->vm = NULL;
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
>> The assumption !VM_VM_AREA represents vm_map_ram allocation is introduced by 
>> commit: d4033afd(mm, vmalloc: iterate vmap_area_list, instead of vmlist, in 
>> vmallocinfo()). However, !VM_VM_AREA also represents vmap_area is being tear 
>> down in race window mentioned above. This patch fix it by don't dump any 
>> information for !VM_VM_AREA case and also remove (VM_LAZY_FREE | VM_LAZY_FREEING)
>> check since they are not possible for !VM_VM_AREA case.
>> 
>> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>

Thanks for your review. ;-)

Regards,
Wanpeng Li 

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
