Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E4ADE6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 09:50:00 -0400 (EDT)
Received: by wizk4 with SMTP id k4so195688623wiz.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 06:50:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id az10si14054464wjb.39.2015.04.16.06.49.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 06:49:57 -0700 (PDT)
Message-ID: <552FBDEC.7070108@redhat.com>
Date: Thu, 16 Apr 2015 08:49:32 -0500
From: Dean Nelson <dnelson@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memory-failure: call shake_page() when error hits
 thp tail page
References: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Jin Dongming <jin.dongming@np.css.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/15/2015 02:25 AM, Naoya Horiguchi wrote:
> Currently memory_failure() calls shake_page() to sweep pages out from pcplists
> only when the victim page is 4kB LRU page or thp head page. But we should do
> this for a thp tail page too.
> Consider that a memory error hits a thp tail page whose head page is on a
> pcplist when memory_failure() runs. Then, the current kernel skips shake_pages()
> part, so hwpoison_user_mappings() returns without calling split_huge_page() nor
> try_to_unmap() because PageLRU of the thp head is still cleared due to the skip
> of shake_page().
> As a result, me_huge_page() runs for the thp, which is a broken behavior.
> 
> This patch fixes this problem by calling shake_page() for thp tail case.
> 
> Fixes: 385de35722c9 ("thp: allow a hwpoisoned head page to be put back to LRU")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This looks correct to me. Thanks!

Acked-by: Dean Nelson <dnelson@redhat.com>


> Cc: stable@vger.kernel.org  # v3.4+
> ---
>   mm/memory-failure.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git v4.0.orig/mm/memory-failure.c v4.0/mm/memory-failure.c
> index d487f8dc6d39..2cc1d578144b 100644
> --- v4.0.orig/mm/memory-failure.c
> +++ v4.0/mm/memory-failure.c
> @@ -1141,10 +1141,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>   	 * The check (unnecessarily) ignores LRU pages being isolated and
>   	 * walked by the page reclaim code, however that's not a big loss.
>   	 */
> -	if (!PageHuge(p) && !PageTransTail(p)) {
> -		if (!PageLRU(p))
> -			shake_page(p, 0);
> -		if (!PageLRU(p)) {
> +	if (!PageHuge(p)) {
> +		if (!PageLRU(hpage))
> +			shake_page(hpage, 0);
> +		if (!PageLRU(hpage)) {
>   			/*
>   			 * shake_page could have turned it free.
>   			 */
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
