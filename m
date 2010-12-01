Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 65D7C6B008C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:10:19 -0500 (EST)
Received: by yxl31 with SMTP id 31so3999731yxl.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 09:10:17 -0800 (PST)
Message-ID: <4CF68174.10301@petalogix.com>
Date: Wed, 01 Dec 2010 18:10:12 +0100
From: Michal Simek <michal.simek@petalogix.com>
Reply-To: michal.simek@petalogix.com
MIME-Version: 1.0
Subject: Re: Flushing whole page instead of work for ptrace
References: <4CEFA8AE.2090804@petalogix.com> <20101130233250.35603401C8@magilla.sf.frob.com>
In-Reply-To: <20101130233250.35603401C8@magilla.sf.frob.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, John Williams <john.williams@petalogix.com>, "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
List-ID: <linux-mm.kvack.org>

Roland McGrath wrote:
> This is a VM question more than a ptrace question.  
> I can't give you any authoritative answers about the VM issues.
> 
> Documentation/cachetlb.txt says:
> 
> 	Any time the kernel writes to a page cache page, _OR_
> 	the kernel is about to read from a page cache page and
> 	user space shared/writable mappings of this page potentially
> 	exist, this routine is called.
> 
> In your case, the kernel is only reading (write=0 passed to
> access_process_vm and get_user_pages).  In normal situations,
> the page in question will have only a private and read-only
> mapping in user space.  So the call should not be required in
> these cases--if the code can tell that's so.
> 
> Perhaps something like the following would be safe.
> But you really need some VM folks to tell you for sure.
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 02e48aa..2864ee7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1484,7 +1484,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  				pages[i] = page;
>  
>  				flush_anon_page(vma, page, start);
> -				flush_dcache_page(page);
> +				if ((vm_flags & VM_WRITE) || (vma->vm_flags & VM_SHARED)
> +					flush_dcache_page(page);
>  			}
>  			if (vmas)
>  				vmas[i] = vma;
> 
> 
> Thanks,
> Roland

Andrew any comment?

Thanks,
Michal



-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
