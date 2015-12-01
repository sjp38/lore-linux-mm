Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA7A6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 15:53:27 -0500 (EST)
Received: by padhx2 with SMTP id hx2so16381435pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 12:53:27 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tw2si3322496pab.238.2015.12.01.12.53.26
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 12:53:26 -0800 (PST)
Subject: Re: [PATCH 3/9] mm: postpone page table allocation until do_set_pte()
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447889136-6928-4-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <565E08C5.8090607@intel.com>
Date: Tue, 1 Dec 2015 12:53:25 -0800
MIME-Version: 1.0
In-Reply-To: <1447889136-6928-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/18/2015 03:25 PM, Kirill A. Shutemov wrote:
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2068,11 +2068,6 @@ void filemap_map_pages(struct fault_env *fe,
...
>  		if (file->f_ra.mmap_miss > 0)
>  			file->f_ra.mmap_miss--;
> -		do_set_pte(fe, page);
> +
> +		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> +		if (fe->pte)
> +			fe->pte += iter.index - last_pgoff;
> +		last_pgoff = iter.index;
> +		if (do_set_pte(fe, NULL, page)) {
> +			/* failed to setup page table: giving up */
> +			if (!fe->pte)
> +				break;
> +			goto unlock;
> +		}
>  		unlock_page(page);
>  		goto next;

Hey Kirill,

Is there a case here where do_set_pte() returns an error and _still_
manages to populate fe->pte?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
