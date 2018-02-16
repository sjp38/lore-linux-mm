Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B02F96B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:44:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l7so1438735wmh.4
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:44:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2si1588892wrg.537.2018.02.16.12.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 12:43:59 -0800 (PST)
Date: Fri, 16 Feb 2018 12:43:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND v2] mm: don't defer struct page initialization for Xen
 pv guests
Message-Id: <20180216124357.de2cb8fe96c07dea51556adb@linux-foundation.org>
In-Reply-To: <20180216154101.22865-1-jgross@suse.com>
References: <20180216154101.22865-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, mhocko@suse.com, stable@vger.kernel.org

On Fri, 16 Feb 2018 16:41:01 +0100 Juergen Gross <jgross@suse.com> wrote:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -347,6 +347,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  	/* Always populate low zones for address-constrained allocations */
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
> +	/* Xen PV domains need page structures early */
> +	if (xen_pv_domain())
> +		return true;

I'll do this:

--- a/mm/page_alloc.c~mm-dont-defer-struct-page-initialization-for-xen-pv-guests-fix
+++ a/mm/page_alloc.c
@@ -46,6 +46,7 @@
 #include <linux/stop_machine.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
+#include <xen/xen.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>

So we're not relying on dumb luck ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
