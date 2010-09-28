Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BDF096B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 19:12:40 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o8SNCa0C020978
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 16:12:36 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz17.hot.corp.google.com with ESMTP id o8SNCY9T024725
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 16:12:35 -0700
Received: by pzk36 with SMTP id 36so48190pzk.12
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 16:12:34 -0700 (PDT)
Date: Tue, 28 Sep 2010 16:12:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] arch: remove __GFP_REPEAT for order-0 allocations
In-Reply-To: <20100928155326.9ded5a92.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1009281605180.24817@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com> <20100928143655.4282a001.akpm@linux-foundation.org> <alpine.DEB.2.00.1009281536390.24817@chino.kir.corp.google.com> <20100928155326.9ded5a92.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Andrew Morton wrote:

> > So we can definitely remove __GFP_REPEAT for any order-0 allocation and 
> > it's based on its implementation -- poorly defined as it may be -- and the 
> > inherit design of any sane page allocator that retries such an allocation 
> > if it's going to use reclaim in the first place.
> 
> Why was __GFP_REPEAT used in those callsites?  What were people trying
> to achieve?
> 

I can't predict what they were trying to achieve since the documentation 
varies on the semantics of __GFP_REPEAT, but the actual implementation 
would suggest that we want to ensure that reclaim actually frees memory 
before we fail the allocation, and that was probably done before it was 
decided to implicitly loop already for order-3 and smaller allocations and 
prehaps even predates the oom killer.

With the oom killer, which would be used iff direct reclaim failed for the 
allocs touched in this patch, we can't report how much memory may be freed 
when that killed task exits, so we implicitly loop forever regardless of 
__GFP_REPEAT (and for a reason other than PAGE_ALLOC_COSTLY_ORDER: if the 
oom killer kills or finds a task that has already been killed but yet to 
exit, it automatically retries the allocation waiting for that free memory 
without even looking at should_alloc_retry()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
