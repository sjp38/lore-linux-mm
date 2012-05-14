Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6C44D6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:59:02 -0400 (EDT)
Date: Mon, 14 May 2012 13:58:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: Fix slab->page _count corruption.
In-Reply-To: <1337020900-20120-1-git-send-email-pshelar@nicira.com>
Message-ID: <alpine.DEB.2.00.1205141353310.26304@router.home>
References: <1337020900-20120-1-git-send-email-pshelar@nicira.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin B Shelar <pshelar@nicira.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Mon, 14 May 2012, Pravin B Shelar wrote:

> On arches that do not support this_cpu_cmpxchg_double slab_lock is used
> to do atomic cmpxchg() on double word which contains page->_count.
> page count can be changed from get_page() or put_page() without taking
> slab_lock. That corrupts page counter.
>
> Following patch fixes it by moving page->_count out of cmpxchg_double
> data. So that slub does no change it while updating slub meta-data in
> struct page.

Ugly. Maybe its best to not touch the count in the page lock case in slub?

You could accomplish that by changing the definition of counters in
mm_types.h. Make it unsigned instead of unsigned long so that it only
covers the first part of the struct (which excludes the refcounter)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
