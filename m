Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0F8D6B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:51:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q2so5393130pgf.22
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 01:51:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a61-v6si6452606pla.689.2018.02.26.01.51.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 01:51:02 -0800 (PST)
Date: Mon, 26 Feb 2018 10:51:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 1/6] dax: fix vma_is_fsdax() helper
Message-ID: <20180226095100.j7dpeeto6wh6hncw@quack2.suse.cz>
References: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151943299140.29249.1858877799010776925.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151943299140.29249.1858877799010776925.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jane Chu <jane.chu@oracle.com>, Haozhong Zhang <haozhong.zhang@intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Gerd Rausch <gerd.rausch@oracle.com>, linux-fsdevel@vger.kernel.org

On Fri 23-02-18 16:43:11, Dan Williams wrote:
> Gerd reports that ->i_mode may contain other bits besides S_IFCHR. Use
> S_ISCHR() instead. Otherwise, get_user_pages_longterm() may fail on
> device-dax instances when those are meant to be explicitly allowed.
> 
> Fixes: 2bb6d2837083 ("mm: introduce get_user_pages_longterm")
> Cc: <stable@vger.kernel.org>
> Reported-by: Gerd Rausch <gerd.rausch@oracle.com>
> Acked-by: Jane Chu <jane.chu@oracle.com>
> Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I wonder how I didn't notice this when reading the original patch. Anyway
the fix looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 2a815560fda0..79c413985305 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -3198,7 +3198,7 @@ static inline bool vma_is_fsdax(struct vm_area_struct *vma)
>  	if (!vma_is_dax(vma))
>  		return false;
>  	inode = file_inode(vma->vm_file);
> -	if (inode->i_mode == S_IFCHR)
> +	if (S_ISCHR(inode->i_mode))
>  		return false; /* device-dax */
>  	return true;
>  }
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
