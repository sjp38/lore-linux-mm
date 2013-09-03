Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3EA866B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 05:08:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 18:54:39 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 389832BB0051
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 19:08:31 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8398EFr10093054
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 19:08:20 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8398OAg031718
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 19:08:25 +1000
Date: Tue, 3 Sep 2013 17:08:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 4/4] mm/vmalloc: don't assume vmap_area w/o VM_VM_AREA
 flag is vm_map_ram allocation
Message-ID: <20130903090822.GA14944@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378191706-29696-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130903074221.GA30920@lge.com>
 <52259541.86a02b0a.2e56.ffffde93SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130903085959.GB30920@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130903085959.GB30920@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 03, 2013 at 05:59:59PM +0900, Joonsoo Kim wrote:
>On Tue, Sep 03, 2013 at 03:51:39PM +0800, Wanpeng Li wrote:
>> On Tue, Sep 03, 2013 at 04:42:21PM +0900, Joonsoo Kim wrote:
>> >On Tue, Sep 03, 2013 at 03:01:46PM +0800, Wanpeng Li wrote:
>> >> There is a race window between vmap_area free and show vmap_area information.
>> >> 
>> >> 	A                                                B
>> >> 
>> >> remove_vm_area
>> >> spin_lock(&vmap_area_lock);
>> >> va->flags &= ~VM_VM_AREA;
>> >> spin_unlock(&vmap_area_lock);
>> >> 						spin_lock(&vmap_area_lock);
>> >> 						if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEZING))
>> >> 							return 0;
>> >> 						if (!(va->flags & VM_VM_AREA)) {
>> >> 							seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>> >> 								(void *)va->va_start, (void *)va->va_end,
>> >> 								va->va_end - va->va_start);
>> >> 							return 0;
>> >> 						}
>> >> free_unmap_vmap_area(va);
>> >> 	flush_cache_vunmap
>> >> 	free_unmap_vmap_area_noflush
>> >> 		unmap_vmap_area
>> >> 		free_vmap_area_noflush
>> >> 			va->flags |= VM_LAZY_FREE 
>> >> 
>> >> The assumption is introduced by commit: d4033afd(mm, vmalloc: iterate vmap_area_list, 
>> >> instead of vmlist, in vmallocinfo()). This patch fix it by drop the assumption and 
>> >> keep not dump vm_map_ram allocation information as the logic before that commit.
>> >> 
>> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> >> ---
>> >>  mm/vmalloc.c | 7 -------
>> >>  1 file changed, 7 deletions(-)
>> >> 
>> >> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> >> index 5368b17..62b7932 100644
>> >> --- a/mm/vmalloc.c
>> >> +++ b/mm/vmalloc.c
>> >> @@ -2586,13 +2586,6 @@ static int s_show(struct seq_file *m, void *p)
>> >>  	if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
>> >>  		return 0;
>> >>  
>> >> -	if (!(va->flags & VM_VM_AREA)) {
>> >> -		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>> >> -			(void *)va->va_start, (void *)va->va_end,
>> >> -					va->va_end - va->va_start);
>> >> -		return 0;
>> >> -	}
>> >> -
>> >>  	v = va->vm;
>> >>  
>> >>  	seq_printf(m, "0x%pK-0x%pK %7ld",
>> >
>> >Hello, Wanpeng.
>> >
>> 
>> Hi Joonsoo and Yanfei,
>> 
>> >Did you test this patch?
>> >
>> >I guess that, With this patch, if there are some vm_map areas,
>> >null pointer deference would occurs, since va->vm may be null for it.
>> >
>> >And with this patch, if this race really occur, null pointer deference
>> >would occurs too, since va->vm is set to null in remove_vm_area().
>> >
>> >I think that this is not a right fix for this possible race.
>> >
>> 
>> How about append below to this patch?
>> 
>> if (va->vm)
>> 	v = va->vm;
>> else 
>> 	return 0;
>
>Hello,
>
>I think that appending below code is better to represent it's purpose.
>Maybe some comment is needed.
>
>	/* blablabla */
>	if (!(va->flags & VM_VM_AREA))
>		return 0;
>

Looks reasonable to me. ;-)

>And maybe we can remove below code snippet, since
>either VM_LAZY_FREE or VM_LAZY_FREEING is not possible for !VM_VM_AREA case.
>
>	if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
>		return 0;
>

Agreed.

I will fold these in my patch and add your suggested-by. Thanks.

Regards,
Wanpeng Li 

>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
