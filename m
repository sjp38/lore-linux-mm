Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D9D9A6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 20:20:49 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so7815299pab.15
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 17:20:49 -0800 (PST)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id ek3si22520650pbd.55.2014.02.03.17.20.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 17:20:48 -0800 (PST)
Received: by mail-pb0-f45.google.com with SMTP id un15so7784139pbc.32
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 17:20:48 -0800 (PST)
Date: Mon, 3 Feb 2014 17:20:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: avoid isolating pinned pages fix
In-Reply-To: <20140204000237.GA17331@lge.com>
Message-ID: <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014, Joonsoo Kim wrote:

> I think that you need more code to skip this type of page correctly.
> Without page_mapped() check, this code makes migratable pages be skipped,
> since if page_mapped() case, page_count() may be more than zero.
> 
> So I think that you need following change.
> 
> (!page_mapping(page) && !page_mapped(page) && page_count(page))
> 

These pages returned by get_user_pages() will have a mapcount of 1 so this 
wouldn't actually fix the massive lock contention.  page_mapping() is only 
going to be NULL for pages off the lru like these are for 
PAGE_MAPPING_ANON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
