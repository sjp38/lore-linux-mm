Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 765D06B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 05:01:28 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so20296622wiw.9
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 02:01:28 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id m10si49332061wie.93.2014.12.02.02.01.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 02:01:27 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id a1so16511228wgh.25
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 02:01:26 -0800 (PST)
Date: Tue, 2 Dec 2014 11:01:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141202100125.GD27014@dhcp22.suse.cz>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141130235652.GA10333@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 01-12-14 08:56:52, Minchan Kim wrote:
[...]
> From 2edd6890f92fa4943ce3c452194479458582d88c Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 1 Dec 2014 08:53:55 +0900
> Subject: [PATCH] madvise.2: Document MADV_FREE
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  man2/madvise.2 | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index 032ead7..33aa936 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -265,6 +265,19 @@ file (see
>  .BR MADV_DODUMP " (since Linux 3.4)"
>  Undo the effect of an earlier
>  .BR MADV_DONTDUMP .
> +.TP
> +.BR MADV_FREE " (since Linux 3.19)"
> +Gives the VM system the freedom to free pages, and tells the system that
> +information in the specified page range is no longer important.
> +This is an efficient way of allowing
> +.BR malloc (3)

This might be rather misleading. Only some malloc implementations are
using this feature (jemalloc, right?). So either be specific about which
implementation or do not add it at all.

> +to free pages anywhere in the address space, while keeping the address space
> +valid. The next time that the page is referenced, the page might be demand
> +zeroed, or might contain the data that was there before the MADV_FREE call.
> +References made to that address space range will not make the VM system page the
> +information back in from backing store until the page is modified again.

I am not sure I understand the last sentence. So say I did MADV_FREE and
the reclaim has dropped that page. I know that the file backed mappings
are not supported yet but assume they were for a second... Now, I do
read from that location again what is the result?
If we consider anon mappings then the backing store is misleading as
well because memory was dropped and so always newly allocated.
I would rather drop the whole sentence and rather see an explanation
what is the difference between to MADV_DONT_NEED.
"
Unlike MADV_DONT_NEED the memory is freed lazily e.g. when the VM system
is under memory pressure.
"

> +It works only with private anonymous pages (see
> +.BR mmap (2)).
>  .SH RETURN VALUE
>  On success
>  .BR madvise ()
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
