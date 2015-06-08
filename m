Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EE70B6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 04:17:57 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so77321380wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 01:17:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si11763563wiy.12.2015.06.08.01.17.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 01:17:56 -0700 (PDT)
Date: Mon, 8 Jun 2015 10:17:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/mmap.c: optimization of do_mmap_pgoff function
Message-ID: <20150608081751.GC1380@dhcp22.suse.cz>
References: <1433584472-19151-1-git-send-email-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433584472-19151-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, sasha.levin@oracle.com, dave@stgolabs.net, koct9i@gmail.com, pfeiner@google.com, dh.herrmann@gmail.com, vishnu.ps@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-06-15 11:54:32, Piotr Kwapulinski wrote:
> The simple check for zero length memory mapping may be performed
> earlier. It causes that in case of zero length memory mapping some
> unnecessary code is not executed at all. It does not make the code less
> readable and saves some CPU cycles.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/mmap.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index bb50cac..aa632ad 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1258,6 +1258,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  
>  	*populate = 0;
>  
> +	if (!len)
> +		return -EINVAL;
> +
>  	/*
>  	 * Does the application expect PROT_READ to imply PROT_EXEC?
>  	 *
> @@ -1268,9 +1271,6 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
>  			prot |= PROT_EXEC;
>  
> -	if (!len)
> -		return -EINVAL;
> -
>  	if (!(flags & MAP_FIXED))
>  		addr = round_hint_to_min(addr);
>  
> -- 
> 2.3.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
