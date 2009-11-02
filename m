Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 021696B009F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:54:01 -0500 (EST)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id nA2Krr1Z007128
	for <linux-mm@kvack.org>; Mon, 2 Nov 2009 12:53:54 -0800
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by spaceape12.eur.corp.google.com with ESMTP id nA2KroAs022549
	for <linux-mm@kvack.org>; Mon, 2 Nov 2009 12:53:51 -0800
Received: by pwi12 with SMTP id 12so2291462pwi.5
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 12:53:50 -0800 (PST)
Date: Mon, 2 Nov 2009 12:53:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <alpine.DEB.1.10.0911021139100.24535@V090114053VZO-1>
Message-ID: <alpine.DEB.2.00.0911021249470.22525@chino.kir.corp.google.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz>
 <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz> <4AECCF6A.4020206@redhat.com> <alpine.DEB.1.10.0911021139100.24535@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, Christoph Lameter wrote:

> What is realtime in this scenario? There are no guarantees that reclaim
> wont have to occur. There are no guarantees anymore and therefore you
> cannot really call this realtime.
> 

Realtime in this scenario is anything with a priority of MAX_RT_PRIO or 
lower.

> Is realtime anything more than: "I want to have my patches merged"?
> 

These allocations are not using ~__GFP_WAIT for a reason, they can block 
on direct reclaim.

But we're convoluting this issue _way_ more than it needs to be.  We have 
used ALLOC_HARDER for these tasks as a convenience for over four years.  
The fix here is to address an omittion in the page allocator refactoring 
code that went into 2.6.31 that dropped the check for !in_interrupt().

If you'd like to raise the concern about the rt exemption being given 
ALLOC_HARDER, then it is seperate from this fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
