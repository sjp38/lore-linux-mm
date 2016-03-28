Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AEAB26B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 14:42:16 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id 4so143850427pfd.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 11:42:16 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id d27si16877641pfj.14.2016.03.28.11.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 11:42:16 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id zm5so18569073pac.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 11:42:16 -0700 (PDT)
Date: Mon, 28 Mar 2016 11:42:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
In-Reply-To: <20160328180029.GB25200@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1603281140010.1086@eggly.anvils>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1603231305560.4946@eggly.anvils> <20160324091727.GA26796@node.shutemov.name> <alpine.LSU.2.11.1603241153120.1593@eggly.anvils> <20160325150417.GA1851@node.shutemov.name>
 <alpine.LSU.2.11.1603251635490.1115@eggly.anvils> <20160328180029.GB25200@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 28 Mar 2016, Kirill A. Shutemov wrote:
> 
> I think I found it. I have refcounting screwed up in faultaround.
> 
> This should fix the problem:

Yes, this fixes it for me - thanks.

Hugh

> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 94c097ec08e7..1325bb4568d1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2292,19 +2292,18 @@ repeat:
>  		if (fe->pte)
>  			fe->pte += iter.index - last_pgoff;
>  		last_pgoff = iter.index;
> -		alloc_set_pte(fe, NULL, page);
> +		if (alloc_set_pte(fe, NULL, page))
> +			goto unlock;
>  		unlock_page(page);
> -		/* Huge page is mapped? No need to proceed. */
> -		if (pmd_trans_huge(*fe->pmd))
> -			break;
> -		/* Failed to setup page table? */
> -		VM_BUG_ON(!fe->pte);
>  		goto next;
>  unlock:
>  		unlock_page(page);
>  skip:
>  		page_cache_release(page);
>  next:
> +		/* Huge page is mapped? No need to proceed. */
> +		if (pmd_trans_huge(*fe->pmd))
> +			break;
>  		if (iter.index == end_pgoff)
>  			break;
>  	}
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
