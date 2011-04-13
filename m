Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4E4900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:23:37 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3DN1ca4004212
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:01:38 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3B81D6E8036
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:23:33 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3DNNWOk463660
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:23:32 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3DNNV1O024444
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:23:32 -0600
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vtt1clbd3l0zgt@mnazarewicz-glaptop>
References: <20110411220345.9B95067C@kernel>
	 <20110411220346.2FED5787@kernel>
	 <20110411152223.3fb91a62.akpm@linux-foundation.org>
	 <op.vttl1ho83l0zgt@mnazarewicz-glaptop> <1302620653.8321.1725.camel@nimitz>
	 <op.vtt1clbd3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 13 Apr 2011 16:23:29 -0700
Message-ID: <1302737009.14658.3848.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

On Tue, 2011-04-12 at 17:58 +0200, Michal Nazarewicz wrote:
> > Actually, the various mem_map[]s _are_ arrays, at least up to
> > MAX_ORDER_NR_PAGES at a time.  We can use that property here.
> 
> In that case, waiting eagerly for the new patch. :) 

I misunderstood earlier.  release_pages() takes an array of 'struct page
*', not an array of 'struct page'.  To use it here, we'd need to
construct temporary arrays.  If we're going to do that, we should
probably just use pagevecs, and if we're going to do _that_, we don't
need release_pages().

Nobody calls free_pages_exact() in any kind of hot path these days.
Most of the users are like kernel profiling where they *never* free the
memory.  I'm not sure it's worth the complexity to optimize this.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
