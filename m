Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 136376B02A3
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 05:32:11 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o6L9W75Y013711
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:32:07 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by kpbe12.cbf.corp.google.com with ESMTP id o6L9W6hD021287
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:32:06 -0700
Received: by pzk9 with SMTP id 9so3135050pzk.40
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:32:06 -0700 (PDT)
Date: Wed, 21 Jul 2010 02:31:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/6] gfs2: remove dependency on __GFP_NOFAIL
In-Reply-To: <1279704285.2667.2.camel@localhost>
Message-ID: <alpine.DEB.2.00.1007210229490.19769@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201940300.8728@chino.kir.corp.google.com> <1279704285.2667.2.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010, Steven Whitehouse wrote:

> Hi,
> 
> Looks good to me, I've added it to the -nmw tree. There are a few more
> GFP_NOFAIL instances in the code that we can probably remove in the
> future, but these two are pretty easy. Thanks for the patch,
> 

Thanks!  I'm planning on replacing __GFP_NOFAIL with a different flag that 
will use all of the page allocator's capabilities (direct reclaim, 
compaction for order > 0, and oom killer) but not loop forever.  Existing 
__GFP_NOFAIL callers can then do

	do {
		page = alloc_page(GFP_KERNEL | __GFP_KILLABLE);
	} while (!page);

to duplicate the behavior of __GFP_NOFAIL until such time as 
__GFP_KILLABLE can be removed as well.  That's what I was planning for the 
remaining instances in gfs2 during the second phase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
