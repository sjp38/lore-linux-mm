Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 238836B006C
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 08:04:18 -0400 (EDT)
Received: by widdi4 with SMTP id di4so28638923wid.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 05:04:17 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id na9si7460965wic.65.2015.04.06.05.04.16
        for <linux-mm@kvack.org>;
        Mon, 06 Apr 2015 05:04:16 -0700 (PDT)
Date: Mon, 6 Apr 2015 15:04:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2 mmotm] mm/page-writeback: check-before-clear
 PageReclaim
Message-ID: <20150406120409.GB8375@node.dhcp.inet.fi>
References: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
 <20150406072551.GA7539@node.dhcp.inet.fi>
 <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
 <20150406081325.GB7373@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150406081325.GB7373@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Apr 06, 2015 at 08:13:25AM +0000, Naoya Horiguchi wrote:
> With page flag sanitization patchset, an invalid usage of ClearPageReclaim()
> is detected in set_page_dirty().
> This can be called from __unmap_hugepage_range(), so let's check PageReclaim
> flag before trying to clear it to avoid the misuse.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/page-writeback.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 22f3714d35e6..38aa0d8f19d3 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2225,7 +2225,8 @@ int set_page_dirty(struct page *page)
>  		 * it will confuse readahead and make it restart the size rampup
>  		 * process. But it's a trivial problem.
>  		 */
> -		ClearPageReclaim(page);
> +		if (PageReclaim(page))
> +			ClearPageReclaim(page);
>  #ifdef CONFIG_BLOCK
>  		if (!spd)
>  			spd = __set_page_dirty_buffers;
> -- 
> 2.1.0

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
