Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id kAU8dEAN025112
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 08:39:14 GMT
Received: from nf-out-0910.google.com (nfcn28.prod.google.com [10.48.115.28])
	by spaceape14.eur.corp.google.com with ESMTP id kAU8cp1n022980
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 08:39:10 GMT
Received: by nf-out-0910.google.com with SMTP id n28so2794155nfc
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 00:39:10 -0800 (PST)
Message-ID: <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>
Date: Thu, 30 Nov 2006 00:39:09 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456E95C4.5020809@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
	 <456E8A74.5080905@yahoo.com.au>
	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
	 <456E95C4.5020809@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >
> > - we're trying to move a job to a different real numa node because,
> > say, a new job has started that needs the whole of a node to itself,
> > and we need to clear space for it.
>
> So migrate at this point.

That's what I want to do. But currently you can only do this on a
process-by-process basis and it doesn't affect file pages in the
pagecache that aren't mapped by anyone.

Being able to say "try to move all memory from this node to this other
set of nodes" seems like a generically useful thing even for other
uses (e.g. hot unplug, general HPC numa systems, etc).

>
> > - we're trying to compact the memory usage of a job, when it has
> > plenty of free space in each of its nodes, and we can fit all the
> > memory into a smaller set of nodes.
>
> Or reclaim at this point.
>

This would be happening after reclaim has successfully shrunk the
in-use memory in a bunch of nodes, and we want to consolidate to a
smaller set of nodes.

>
> The ultimate would be to devise an API which is usable by your patch,
> as well as the other resource control mechanisms going around. If
> userspace has to know that you've implemented memory control with
> "fake nodes", then IMO something has gone wrong.

I disagree. Memory control via fake numa (or even via real numa if you
have enough real nodes) is sufficiently fundamentally different from
memory control via, say, per-page owner pointers (due to granularity,
etc) that userspace really needs to know about it in order to make
sensible decisions.

It also has the nice property that the kernel already exposes most of
the mechanism required for this via the cpusets code.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
