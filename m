Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9FA6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 14:30:47 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so167857821wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:30:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f9si50860110wjs.71.2016.02.16.11.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 11:30:45 -0800 (PST)
Date: Tue, 16 Feb 2016 14:29:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160216192946.GA32543@cmpxchg.org>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
 <20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
 <20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Fri, Feb 12, 2016 at 08:35:53PM +0100, Andres Freund wrote:
> To make an actually usable patch out of this it seems we'd have to add a
> 'partial' argument to grab_cache_page_write_begin(), so writes to parts
> of a page still cause the pages to be marked active.  Is it preferrable
> to change all callers of grab_cache_page_write_begin and
> add_to_page_cache_lru or make them into wrapper functions, and call the
> real deal when it matters?

Personally, I'd prefer explicit arguments over another layer of
wrappers, especially in the add_to_page_cache family. But it's
possible others will disagree and only voice their opinion once you
went through the hassle and sent a patch.

> I do think that that's a reasonable algorithmic change, but nonetheless
> its obviously possible that such changes regress some workloads. What's
> the policy around testing such things?

How about a FGP_WRITE that only sets the page's referenced bit, but
doesn't activate or refault-activate the page?

That way, pages that are only ever written would never get activated,
but a single read mixed in would activate the page straightaway;
either in mark_page_accessed() or through refault-activation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
