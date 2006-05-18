Date: Thu, 18 May 2006 11:15:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Query re:  mempolicy for page cache pages
In-Reply-To: <1147974599.5195.96.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605181105550.20557@schroedinger.engr.sgi.com>
References: <1147974599.5195.96.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 May 2006, Lee Schermerhorn wrote:

> Below I've included an overview of a patch set that I've been working
> on.  I submitted a previous version [then called Page Cache Policy] back
> ~20Apr.  I started working on this because Christoph seemed to consider
> this a prerequisite for considering migrate-on-fault/lazy-migration/...
> Since the previous post, I have addressed comments [from Christoph] and
> kept the series up to date with the -mm tree.  

The prequisite for automatic page migration schemes in the kernel is proof 
that these automatic migrations consistently improve performance. We are 
still waiting on data showing that this is the case.

The particular automatic migration scheme that you proposed relies on 
allocating pages according to the memory allocation policy. 

The basic problem is first of all that the memory policies do not
necessarily describe how the user wants memory to be allocated. The user
may temporarily switch task policies to get specific allocation patterns.
So moving memory may misplace memory. We got around that by 
saying that we need to separately enable migration if a user 
wants it.

But even then we have the issue that the memory policies cannot 
describe proper allocation at all since allocation policies are 
ignored for file backed vmas. And this is the issue you are trying to 
address.

I think this is all far to complicated to do in kernel space and still 
conceptually unclean. I would like to have all automatic migration schemes 
confined to user space. We will add an API that allows some process
to migrate pages at will.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
