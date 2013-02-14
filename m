Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id F32166B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 22:19:12 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so840106dak.25
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:19:12 -0800 (PST)
Date: Wed, 13 Feb 2013 19:19:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
In-Reply-To: <20130212195929.7cd2e597.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <liuj97@gmail.com>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, 12 Feb 2013, Andrew Morton wrote:

> > > > The installed memory on my system is 16 GiB. /proc/meminfo is showing me
> > > > "MemTotal:       16435048 kB" but /sys/devices/system/node/node0/meminfo is
> > > > showing me "Node 0 MemTotal:       16776380 kB".
> > > > 
> > > > My suggestion: MemTotal in /proc/meminfo should be 16776380 kB too. The old
> > > > value of 16435048 kB could have its own key "MemAvailable".
> > > 
> > > hm, mine does that too.  A discrepancy between `totalram_pages' and
> > > NODE_DATA(0)->node_present_pages.
> > > 
> > > I don't know what the reasons are for that but yes, one would expect
> > > the per-node MemTotals to sum up to the global one.
> > > 
> > 
> > I'd suspect it has something to do with 9feedc9d831e ("mm: introduce new 
> > field "managed_pages" to struct zone") and 3.8 would be the first kernel 
> > release with this change.  Is it possible to try 3.7 or, better yet, with 
> > this patch reverted?
> 
> My desktop machine at google in inconsistent, as is the 2.6.32-based
> machine, so it obviously predates 9feedc9d831e.
> 

Hmm, ok.  The question is which one is right: the per-node MemTotal is the 
amount of present RAM, the spanned range minus holes, and the system 
MemTotal is the amount of pages released to the buddy allocator by 
bootmem and discounts not only the memory holes but also reserved pages.  
Should they both be the amount of RAM present or the amount of unreserved 
RAM present?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
