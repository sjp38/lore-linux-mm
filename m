Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 918EA6B0074
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:12:53 -0400 (EDT)
Date: Thu, 9 Aug 2012 12:12:19 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v6 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120809151218.GB2719@t510.redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
 <efb9756c5d6de8952a793bfc99a9db9cdd66b12f.1344463786.git.aquini@redhat.com>
 <20120809090019.GB10288@csn.ul.ie>
 <20120809144835.GA2719@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120809144835.GA2719@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 09, 2012 at 11:48:36AM -0300, Rafael Aquini wrote:
> Sure! 
> what do you think of:
> 
> +/* putback_lru_page() counterpart for a ballooned page */
> +void putback_balloon_page(struct page *page)
> +{
> +   lock_page(page);
> +   if (!WARN_ON(!movable_balloon_page(page))) {
> +           __putback_balloon_page(page);
> +           put_page(page);
> +   }
> +   unlock_page(page);
> +}
>
Or perhaps
 
+/* putback_lru_page() counterpart for a ballooned page */
+void putback_balloon_page(struct page *page)
+{
+   if (!WARN_ON(!movable_balloon_page(page))) {
+           lock_page(page);
+           __putback_balloon_page(page);
+           put_page(page);
+           unlock_page(page);
+   }
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
