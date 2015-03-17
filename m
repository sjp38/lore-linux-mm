Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DEA796B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 18:52:36 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so24040765iec.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:52:36 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id gs14si7719585icb.15.2015.03.17.15.52.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 15:52:36 -0700 (PDT)
Received: by igcau2 with SMTP id au2so48289588igc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:52:36 -0700 (PDT)
Date: Tue, 17 Mar 2015 15:52:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mremap should return -ENOMEM when __vm_enough_memory
 fail
In-Reply-To: <1426580713-21151-1-git-send-email-denc716@gmail.com>
Message-ID: <alpine.DEB.2.10.1503171551180.11185@chino.kir.corp.google.com>
References: <1426580713-21151-1-git-send-email-denc716@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: denc716@gmail.com
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Derek Che <crquan@ymail.com>

On Tue, 17 Mar 2015, denc716@gmail.com wrote:

> Recently I straced bash behavior in this dd zero pipe to read test,
> in part of testing under vm.overcommit_memory=2 (OVERCOMMIT_NEVER mode):
>     # dd if=/dev/zero | read x
> 
> The bash sub shell is calling mremap to reallocate more and more memory
> untill it finally failed -ENOMEM (I expect), or to be killed by system
> OOM killer (which should not happen under OVERCOMMIT_NEVER mode);
> But the mremap system call actually failed of -EFAULT, which is a
> surprise to me, I think it's supposed to be -ENOMEM? then I wrote this
> piece of C code testing confirmed it:
> https://gist.github.com/crquan/326bde37e1ddda8effe5
> 
>     $ ./remap
>     allocated one page @0x7f686bf71000, (PAGE_SIZE: 4096)
>     grabbed 7680512000 bytes of memory (1875125 pages) @ 00007f6690993000.
>     mremap failed Bad address (14).
> 
> The -EFAULT comes from the branch of security_vm_enough_memory_mm
> failure, underlyingly it calls __vm_enough_memory which returns only
> 0 for success or -ENOMEM; So why vma_to_resize needs to return
> -EFAULT in this case? this sounds like a mistake to me.
> 
> Some more digging into git history:
> 1) Before commit 119f657c7 in May 1 2005 (pre 2.6.12 days) it was
>    returning -ENOMEM for this failure;
> 2) but commit 119f657c7 changed it accidentally, to what ever is
>    preserved in local ret, which happened to be -EFAULT, in a previous assignment;
> 3) then in commit 54f5de709 code refactoring, it's explicitly returning
>    -EFAULT, should be wrong.
> 
> Signed-off-by: Derek Che <crquan@ymail.com>
> Acked-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Acked-by: David Rientjes <rientjes@google.com>

Did Kirill ack this patch?

> ---
>  mm/mremap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 57dadc0..5da81cb 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -375,7 +375,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>  	if (vma->vm_flags & VM_ACCOUNT) {
>  		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
>  		if (security_vm_enough_memory_mm(mm, charged))
> -			goto Efault;
> +			goto Enomem;
>  		*p = charged;
>  	}

The patch is corrupted and won't apply because there aren't three lines 
after the changed line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
