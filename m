Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 371706B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 21:50:58 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so7671121pdj.11
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:50:57 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id fu1si22677262pbc.254.2014.02.03.18.50.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 18:50:57 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so7639732pdj.4
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:50:57 -0800 (PST)
Date: Mon, 3 Feb 2014 18:50:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages fix
In-Reply-To: <20140204021533.GA14924@lge.com>
Message-ID: <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com> <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com> <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com> <20140204021533.GA14924@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014, Joonsoo Kim wrote:

> > > Okay. It can't fix your situation. Anyway, *normal* anon pages may be mapped
> > > and have positive page_count(), so your code such as
> > > '!page_mapping(page) && page_count(page)' makes compaction skip these *normal*
> > > anon pages and this is incorrect behaviour.
> > > 
> > 
> > So how does that work with migrate_page_move_mapping() which demands 
> > page_count(page) == 1 and the get_page_unless_zero() in 
> > __isolate_lru_page()?
> 
> Before doing migrate_page_move_mapping(), try_to_unmap() is called so that all
> mapping is unmapped. Then, remained page_count() is 1 which is grabbed by
> __isolate_lru_page(). Am I missing something?
> 

Ah, good point.  I wonder if we can get away with 
page_count(page) - page_mapcount(page) > 1 to avoid the get_user_pages() 
pin?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
