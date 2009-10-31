Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 085136B004D
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 17:20:02 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n9VLJuKB031817
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 14:19:57 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz13.hot.corp.google.com with ESMTP id n9VLJrVB012859
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 14:19:53 -0700
Received: by pzk32 with SMTP id 32so2613553pzk.21
        for <linux-mm@kvack.org>; Sat, 31 Oct 2009 14:19:53 -0700 (PDT)
Date: Sat, 31 Oct 2009 14:19:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <20091031201158.GB29536@elf.ucw.cz>
Message-ID: <alpine.DEB.2.00.0910311413160.25524@chino.kir.corp.google.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz>
 <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 31 Oct 2009, Pavel Machek wrote:

> > Um, no, it's a matter of the kernel implementation.  We allow such tasks 
> > to allocate deeper into reserves to avoid the page allocator from 
> > incurring a significant penalty when direct reclaim is required.  
> > Background reclaim has already commenced at this point in the
> > slowpath.
> 
> But we can't guarantee that enough memory will be ready in the
> reserves. So if realtime task relies on it, it is broken, and will
> fail to meet its deadlines from time to time.

This is truly a bizarre tangent to take, I don't quite understand the 
point you're trying to make.  Memory reserves exist to prevent blocking 
when we need memory the most (oom killed task or direct reclaim) and to 
allocate from when we can't (GFP_ATOMIC) or shouldn't (rt tasks) utilize 
direct reclaim.  The idea is to kick background reclaim first in the 
slowpath so we're only below the low watermark for a short period and 
allow the allocation to succeed.  If direct reclaim actually can't free 
any memory, the oom killer will free it for us.

So the realtime[*] tasks aren't relying on it at all, the ALLOC_HARDER 
exemption for them in the page allocator are a convenience to return 
memory faster than otherwise when the fastpath fails.  I don't see much 
point in arguing against that.

 [*] This is the current mainline definition of "realtime," which actually
     includes a large range of different priorities.  For strict realtime,
     you'd need to check out the -rt tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
