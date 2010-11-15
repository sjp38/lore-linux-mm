Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D19A8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:55:39 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oAFNtXBL000752
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 15:55:33 -0800
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by kpbe11.cbf.corp.google.com with ESMTP id oAFNsbkY001710
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 15:55:20 -0800
Received: by gxk1 with SMTP id 1so30474gxk.32
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 15:55:07 -0800 (PST)
Date: Mon, 15 Nov 2010 15:55:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <1289863857.13446.199.camel@oralap>
Message-ID: <alpine.DEB.2.00.1011151552440.29081@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap> <20101111120643.22dcda5b.akpm@linux-foundation.org> <1289512924.428.112.camel@oralap> <20101111142511.c98c3808.akpm@linux-foundation.org> <1289840500.13446.65.camel@oralap> <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
 <1289859596.13446.151.camel@oralap> <alpine.DEB.2.00.1011151426360.20468@chino.kir.corp.google.com> <1289863857.13446.199.camel@oralap>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010, Ricardo M. Correia wrote:

> > __GFP_REPEAT will retry the allocation indefinitely until the needed 
> > amount of memory is reclaimed without considering the order of the 
> > allocation; all orders of interest in your case are order-0, so it will 
> > loop indefinitely until a single page is reclaimed which won't happen with 
> > GFP_NOFS.  Thus, passing the flag is the equivalent of asking the 
> > allocator to loop forever until memory is available rather than failing 
> > and returning to your error handling.
> 
> When you say loop forever, you don't mean in a busy loop, right?
> Assuming we sleep in this loop (which AFAICS it does), then it's OK for
> us because memory will be freed asynchronously.
> 

Yes, __GFP_REPEAT will only be effected if it's blockable, so the 
allocator will reschedule during the loop but not return until the 
allocation suceeds in this case since it's GFP_NOFS which significantly 
impacts the ability to reclaim memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
