Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 776826B467D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:31:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g63-v6so13425922pfc.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:31:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor3754875pgl.1.2018.11.26.23.31.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:31:15 -0800 (PST)
Date: Tue, 27 Nov 2018 10:31:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/10] mm/khugepaged: collapse_shmem() stop if punched or
 truncated
Message-ID: <20181127073110.gs7t4euouf2fvuce@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261522040.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261522040.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:23:37PM -0800, Hugh Dickins wrote:
> Huge tmpfs testing showed that although collapse_shmem() recognizes a
> concurrently truncated or hole-punched page correctly, its handling of
> holes was liable to refill an emptied extent.  Add check to stop that.
> 
> Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+

I'm not yet comfortable with XArray API. Matthew, what is your take on the patch?

> ---
>  mm/khugepaged.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index c13625c1ad5e..2070c316f06e 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1359,6 +1359,17 @@ static void collapse_shmem(struct mm_struct *mm,
>  
>  		VM_BUG_ON(index != xas.xa_index);
>  		if (!page) {
> +			/*
> +			 * Stop if extent has been truncated or hole-punched,
> +			 * and is now completely empty.
> +			 */
> +			if (index == start) {
> +				if (!xas_next_entry(&xas, end - 1)) {
> +					result = SCAN_TRUNCATED;
> +					break;
> +				}
> +				xas_set(&xas, index);
> +			}
>  			if (!shmem_charge(mapping->host, 1)) {
>  				result = SCAN_FAIL;
>  				break;
> -- 
> 2.20.0.rc0.387.gc7a69e6b6c-goog
> 

-- 
 Kirill A. Shutemov
