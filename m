Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C65A6B028D
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 05:20:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w102so9515073wrb.17
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 02:20:26 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id b45si21796297wrd.125.2017.04.23.02.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 02:20:24 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id z129so11995131wmb.1
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 02:20:24 -0700 (PDT)
Date: Sun, 23 Apr 2017 11:20:21 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: gup: fix access_ok() argument type
Message-ID: <20170423092021.xpfyapinlxmxpi5l@gmail.com>
References: <20170421162659.3314521-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421162659.3314521-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Arnd Bergmann <arnd@arndb.de> wrote:

> MIPS just got changed to only accept a pointer argument for access_ok(),
> causing one warning in drivers/scsi/pmcraid.c. I tried changing x86
> the same way and found the same warning in __get_user_pages_fast()
> and nowhere else in the kernel during randconfig testing:

Doing that for x86 access_ok() would definitely be a good idea.

> mm/gup.c: In function '__get_user_pages_fast':
> mm/gup.c:1578:6: error: passing argument 1 of '__chk_range_not_ok' makes pointer from integer without a cast [-Werror=int-conversion]
> 
> It would probably be a good idea to enforce type-safety in general,
> so let's change this file to not cause a warning if we do that.
> 
> I don't know why the warning did not appear on MIPS.
> 
> Fixes: 2667f50e8b81 ("mm: introduce a general RCU get_user_pages_fast()")
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/gup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 2559a3987de7..7f5bc26d9229 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1575,7 +1575,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	end = start + len;
>  
>  	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
> -					start, len)))
> +					(void __user *)start, len)))
>  		return 0;

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
