Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC459003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:42:32 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so95600235wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 03:42:31 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id gh2si24070675wib.11.2015.07.22.03.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 03:42:30 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so95599242wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 03:42:30 -0700 (PDT)
Date: Wed, 22 Jul 2015 13:42:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4 1/6] mm: mlock: Refactor mlock, munlock, and
 munlockall code
Message-ID: <20150722104226.GA8630@node.dhcp.inet.fi>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-2-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437508781-28655-2-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 03:59:36PM -0400, Eric B Munson wrote:
> @@ -648,20 +656,23 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  	start &= PAGE_MASK;
>  
>  	down_write(&current->mm->mmap_sem);
> -	ret = do_mlock(start, len, 0);
> +	ret = apply_vma_flags(start, len, flags, false);
>  	up_write(&current->mm->mmap_sem);
>  
>  	return ret;
>  }
>  
> +SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
> +{
> +	return do_munlock(start, len, VM_LOCKED);
> +}
> +
>  static int do_mlockall(int flags)
>  {
>  	struct vm_area_struct * vma, * prev = NULL;
>  
>  	if (flags & MCL_FUTURE)
>  		current->mm->def_flags |= VM_LOCKED;
> -	else
> -		current->mm->def_flags &= ~VM_LOCKED;

I think this is wrong.

With current code mlockall(MCL_CURRENT) after mlockall(MCL_FUTURE |
MCL_CURRENT) would undo future mlocking, without unlocking currently
mlocked memory.

The change will break the use-case.

>  	if (flags == MCL_FUTURE)
>  		goto out;
>  

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
