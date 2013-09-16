Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 13BE46B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 17:28:02 -0400 (EDT)
Message-ID: <523777D8.2000304@jp.fujitsu.com>
Date: Mon, 16 Sep 2013 17:27:52 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 4/4] mm/vmalloc: fix show vmap_area information
 race with vmap_area tear down
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com> <1379202342-23140-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202342-23140-4-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liwanp@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/14/2013 7:45 PM, Wanpeng Li wrote:
> Changelog:
>  *v4 -> v5: return directly for !VM_VM_AREA case and remove (VM_LAZY_FREE | VM_LAZY_FREEING) check 
> 
> There is a race window between vmap_area tear down and show vmap_area information.
> 
> 	A                                                B
> 
> remove_vm_area
> spin_lock(&vmap_area_lock);
> va->vm = NULL;
> va->flags &= ~VM_VM_AREA;
> spin_unlock(&vmap_area_lock);
> 						spin_lock(&vmap_area_lock);
> 						if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEZING))
> 							return 0;
> 						if (!(va->flags & VM_VM_AREA)) {
> 							seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
> 								(void *)va->va_start, (void *)va->va_end,
> 								va->va_end - va->va_start);
> 							return 0;
> 						}
> free_unmap_vmap_area(va);
> 	flush_cache_vunmap
> 	free_unmap_vmap_area_noflush
> 		unmap_vmap_area
> 		free_vmap_area_noflush
> 			va->flags |= VM_LAZY_FREE 
> 
> The assumption !VM_VM_AREA represents vm_map_ram allocation is introduced by 
> commit: d4033afd(mm, vmalloc: iterate vmap_area_list, instead of vmlist, in 
> vmallocinfo()). However, !VM_VM_AREA also represents vmap_area is being tear 
> down in race window mentioned above. This patch fix it by don't dump any 
> information for !VM_VM_AREA case and also remove (VM_LAZY_FREE | VM_LAZY_FREEING)
> check since they are not possible for !VM_VM_AREA case.
> 
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
