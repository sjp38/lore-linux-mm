Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DA9B46B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:16:32 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so224984pab.29
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:16:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yj9si3353769pac.146.2014.05.14.16.16.31
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 16:16:32 -0700 (PDT)
Date: Wed, 14 May 2014 16:16:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3.15] x86,vdso: Fix an OOPS accessing the hpet mapping
 w/o an hpet
Message-Id: <20140514161630.d604884474d13a4432360b0f@linux-foundation.org>
In-Reply-To: <e1640272803e7711d9a43d9454dbdae57ba22eed.1400108299.git.luto@amacapital.net>
References: <e1640272803e7711d9a43d9454dbdae57ba22eed.1400108299.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, 14 May 2014 16:01:22 -0700 Andy Lutomirski <luto@amacapital.net> wrote:

> The access should fail, but it shouldn't oops.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
> 
> The oops can be triggered in qemu using -no-hpet (but not nohpet) by
> running a 32-bit program and reading a couple of pages before the vdso.

This sentence is the best part of the changelog!  People often do this
- they put all the good stuff after the ^---.  I always move it into
the changelog.

So how old is this bug?

> --- a/arch/x86/vdso/vdso32-setup.c
> +++ b/arch/x86/vdso/vdso32-setup.c
> @@ -147,6 +147,8 @@ int __init sysenter_setup(void)
>  	return 0;
>  }
>  
> +static struct page *no_pages[] = {NULL};

nit: this could be local to arch_setup_additional_pages().

>  /* Setup a VMA at program startup for the vsyscall page */
>  int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>  {
> @@ -192,7 +194,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>  			addr -  VDSO_OFFSET(VDSO_PREV_PAGES),
>  			VDSO_OFFSET(VDSO_PREV_PAGES),
>  			VM_READ,
> -			NULL);
> +			no_pages);
>  
>  	if (IS_ERR(vma)) {
>  		ret = PTR_ERR(vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
