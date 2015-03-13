Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9D36B00AC
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 06:39:53 -0400 (EDT)
Received: by wesx3 with SMTP id x3so22367850wes.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 03:39:52 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id r19si2438671wik.45.2015.03.13.03.39.51
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 03:39:51 -0700 (PDT)
Date: Fri, 13 Mar 2015 12:39:49 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mremap should return -ENOMEM when __vm_enough_memory fail
Message-ID: <20150313103949.GB7251@node.dhcp.inet.fi>
References: <1426238498-21127-1-git-send-email-crquan@ymail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426238498-21127-1-git-send-email-crquan@ymail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Derek <crquan@ymail.com>
Cc: linux-mm@kvack.org

On Fri, Mar 13, 2015 at 02:21:38AM -0700, Derek wrote:
> Recently I straced bash behavior in this dd zero pipe to read test,
> in part of testing under vm.overcommit_memory=2 (OVERCOMMIT_NEVER mode):
>     # dd if=/dev/zero | read x
> 
> The bash sub shell is calling mremap to reallocate more and more memory
> untill it finally failed -ENOMEM (I expect), or to be killed by system
> OOM killer (which should not happen under OVERCOMMIT_NEVER mode);
> But the mremap system call actually failed of -EFAULT, which is a surprise
> to me, I think it's supposed to be -ENOMEM? then I wrote this piece
> of C code testing confirmed it:
> https://gist.github.com/crquan/326bde37e1ddda8effe5
> 
> The -EFAULT comes from the branch of security_vm_enough_memory_mm failure,
> underlyingly it calls __vm_enough_memory which returns only 0 for success
> or -ENOMEM; So why vma_to_resize needs to return -EFAULT in this case?
> it sounds like a mistake to me.
> 
> Some more digging into git history:
> 1) Before commit 119f657c7 in May 1 2005 (pre 2.6.12 days) it was returning
>    -ENOMEM for this failure;
> 2) but commit 119f657c7 changed it accidentally, to what ever is preserved
>    in local ret, which happened to be -EFAULT, in a previous assignment;
> 3) then in commit 54f5de709 code refactoring, it's explicitly returning
>    -EFAULT, should be wrong.
> 
> Signed-off-by: Derek Che <crquan@ymail.com>
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

Looks good to me.
But that would be nice to get rid of these pointless gotos. Just plain
return would work too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
