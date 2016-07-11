Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7A706B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 08:28:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u1so252405921qkc.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 05:28:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b80si1646335qkh.9.2016.07.11.05.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 05:28:05 -0700 (PDT)
Date: Mon, 11 Jul 2016 14:28:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Message-ID: <20160711122826.GA969@redhat.com>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org> <1468014494-25291-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468014494-25291-3-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I think both patches are fine, just a question.

On 07/08, Kees Cook wrote:
>
> -static int do_brk(unsigned long addr, unsigned long len)
> +static int do_brk(unsigned long addr, unsigned long request)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> -	unsigned long flags;
> +	unsigned long flags, len;
>  	struct rb_node **rb_link, *rb_parent;
>  	pgoff_t pgoff = addr >> PAGE_SHIFT;
>  	int error;
>  
> -	len = PAGE_ALIGN(len);
> +	len = PAGE_ALIGN(request);
> +	if (len < request)
> +		return -ENOMEM;

So iiuc "len < request" is only possible if len == 0, right?

>  	if (!len)
>  		return 0;

and thus this patch fixes the error code returned by do_brk() in case
of overflow, now it returns -ENOMEM rather than zero. Perhaps

	if (!len)
		return 0;
	len = PAGE_ALIGN(len);
	if (!len)
		return -ENOMEM;

would be more clear but this is subjective.

I am wondering if we should shift this overflow check to the caller(s).
Say, sys_brk() does find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE)
before do_brk(), and in case of overflow find_vma_intersection() can
wrongly return NULL.

Then do_brk() will be called with len = -oldbrk, this can overflow or
not but in any case this doesn't look right too.

Or I am totally confused?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
