Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC336B0254
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 03:20:38 -0500 (EST)
Received: by igvg19 with SMTP id g19so65135112igv.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:20:37 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0090.outbound.protection.outlook.com. [157.55.234.90])
        by mx.google.com with ESMTPS id gb4si700990igd.36.2015.11.30.00.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 00:20:37 -0800 (PST)
Subject: Re: [PATCH v5 01/12] mm: support madvise(MADV_FREE)
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
 <1448865583-2446-2-git-send-email-minchan@kernel.org>
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Message-ID: <565C06C9.7040906@nextfour.com>
Date: Mon, 30 Nov 2015 10:20:25 +0200
MIME-Version: 1.0
In-Reply-To: <1448865583-2446-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Michal
 Hocko <mhocko@suse.com>

> +		 * If pmd isn't transhuge but the page is THP and
> +		 * is owned by only this process, split it and
> +		 * deactivate all pages.
> +		 */
> +		if (PageTransCompound(page)) {
> +			if (page_mapcount(page) != 1)
> +				goto out;
> +			get_page(page);
> +			if (!trylock_page(page)) {
> +				put_page(page);
> +				goto out;
> +			}
> +			pte_unmap_unlock(orig_pte, ptl);
> +			if (split_huge_page(page)) {
> +				unlock_page(page);
> +				put_page(page);
> +				pte_offset_map_lock(mm, pmd, addr, &ptl);
> +				goto out;
> +			}
> +			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +			pte--;
> +			addr -= PAGE_SIZE;
> +			continue;
> +		}

looks like this leaks page count if split_huge_page() is succesfull
(returns zero).

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
