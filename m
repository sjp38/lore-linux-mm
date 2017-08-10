Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA7196B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:23:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a186so3347928wmh.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:23:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w13si5481060wra.504.2017.08.10.08.23.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 08:23:54 -0700 (PDT)
Date: Thu, 10 Aug 2017 17:23:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Message-ID: <20170810152352.GZ23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170806140425.20937-3-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170806140425.20937-3-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Sun 06-08-17 10:04:25, Rik van Riel wrote:
[...]
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 17921b0390b4..db1fb2802ecc 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -659,6 +659,13 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
>  		tmp->vm_next = tmp->vm_prev = NULL;
>  		file = tmp->vm_file;
> +
> +		/* With VM_WIPEONFORK, the child gets an empty VMA. */
> +		if (tmp->vm_flags & VM_WIPEONFORK) {
> +			tmp->vm_file = file = NULL;
> +			tmp->vm_ops = NULL;
> +		}

What about VM_SHARED/|VM)MAYSHARE flags. Is it OK to keep the around? At
least do_anonymous_page SIGBUS on !vm_ops && VM_SHARED. Or do I miss
where those flags are cleared?

> +
>  		if (file) {
>  			struct inode *inode = file_inode(file);
>  			struct address_space *mapping = file->f_mapping;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
