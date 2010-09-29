Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 786CB6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 21:10:58 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o8T1Ate4008031
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 18:10:55 -0700
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by hpaq7.eem.corp.google.com with ESMTP id o8T1AkVQ010718
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 18:10:53 -0700
Received: by pxi4 with SMTP id 4so74653pxi.36
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 18:10:53 -0700 (PDT)
Date: Tue, 28 Sep 2010 18:10:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] arch: remove __GFP_REPEAT for order-0 allocations
In-Reply-To: <20100928174147.41e48aef.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1009281751170.15357@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com> <20100928143655.4282a001.akpm@linux-foundation.org> <alpine.DEB.2.00.1009281536390.24817@chino.kir.corp.google.com> <20100928155326.9ded5a92.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1009281605180.24817@chino.kir.corp.google.com> <20100928164006.55c442b1.akpm@linux-foundation.org> <alpine.DEB.2.00.1009281644110.21757@chino.kir.corp.google.com> <20100928174147.41e48aef.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Andrew Morton wrote:

> What I care about is that very smart, experienced and hard-working
> Linux developers decided, a long time ago, that page-table allocations
> are special, and need special treatment.  This is information!
> 

Then they implemented it incorrectly since __GFP_REPEAT has never given 
any order-0 allocation special treatment.

> What I also care about is lazy MM developers who just rip stuff out
> without understanding it and without even bothering to make an
> *attempt* to understand it.
> 

I understand that __GFP_REPEAT does absolutely nothing in all the places 
that I removed it in this patch, but if you want to use a gfp flag as 
documentation instead of adding a comment to the PAGE_ALLOC_COSTLY_ORDER 
retry logic, then that's your call, but I would certainly suggest cleaning 
up the erroneous documentation in the tree that specifies its semantics.

> > So, given the fact that the PAGE_ALLOC_COSTLY_ORDER logic has existed 
> > since the same time, the semantics of __GFP_REPEAT have changed and are 
> > often misrepresented, and we don't even invoke the __GFP_REPEAT logic for 
> > any of the allocations in my patch since they are oom killable,
> 
> Probably this is because lazy ignorant MM developers broke earlier
> intentions without even knowing that they were doing so.
> 

The intention was that they loop forever, but since that's implicit for 
these order-0 allocations, I guess you allowed its semantics to change in 
a41f24ea without the same objections?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
