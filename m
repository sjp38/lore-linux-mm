Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B93A76B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:27:39 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so81288942pfb.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:27:39 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id y11si36333277pfi.175.2016.02.14.21.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:27:39 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id e127so7039152pfe.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:27:39 -0800 (PST)
Date: Mon, 15 Feb 2016 14:28:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160215052855.GA2010@swordfish>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160215050858.GA556@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160215050858.GA556@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On (02/15/16 14:08), Sergey Senozhatsky wrote:
> 
> will this compile with !CONFIG_TRACEPOINTS config?
> 

uh.. sorry, was composed in email client. seems the correct way to do it is

+#if defined CONFIG_DEBUG_PAGE_REF && defined CONFIG_TRACEPOINTS

 #include <linux/tracepoint-defs.h>

 #define page_ref_tracepoint_active(t) static_key_false(&(t).key)

 extern struct tracepoint __tracepoint_page_ref_set;
 ...

 extern void __page_ref_set(struct page *page, int v);
 ...

#else

 #define page_ref_tracepoint_active(t) false

 static inline void __page_ref_set(struct page *page, int v)
 {
 }
 ...

#endif



or add a dependency of PAGE_REF on CONFIG_TRACEPOINTS in Kconfig.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
