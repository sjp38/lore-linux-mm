Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5735E6B2925
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 22:15:16 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so12674239ply.4
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 19:15:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s22-v6si49740852plp.201.2018.11.21.19.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 19:15:15 -0800 (PST)
Date: Wed, 21 Nov 2018 19:15:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 RESEND update 1/2] mm/page_alloc: free order-0 pages
 through PCP in page_frag_free()
Message-Id: <20181121191511.658e0d41504e146edd88af53@linux-foundation.org>
In-Reply-To: <20181120014544.GB10657@intel.com>
References: <20181119134834.17765-1-aaron.lu@intel.com>
	<20181119134834.17765-2-aaron.lu@intel.com>
	<20181120014544.GB10657@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Ian Kumlien <ian.kumlien@gmail.com>

On Tue, 20 Nov 2018 09:45:44 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> page_frag_free() calls __free_pages_ok() to free the page back to
> Buddy. This is OK for high order page, but for order-0 pages, it
> misses the optimization opportunity of using Per-Cpu-Pages and can
> cause zone lock contention when called frequently.
> 

Looks nice to me.  Let's tell our readers why we're doing this.

--- a/mm/page_alloc.c~mm-page_alloc-free-order-0-pages-through-pcp-in-page_frag_free-fix
+++ a/mm/page_alloc.c
@@ -4684,7 +4684,7 @@ void page_frag_free(void *addr)
 	if (unlikely(put_page_testzero(page))) {
 		unsigned int order = compound_order(page);
 
-		if (order == 0)
+		if (order == 0)		/* Via pcp? */
 			free_unref_page(page);
 		else
 			__free_pages_ok(page, order);
_
