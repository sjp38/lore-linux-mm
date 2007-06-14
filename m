Date: Thu, 14 Jun 2007 10:16:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181840872.5410.159.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706141012200.30147@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost>  <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
 <1181836247.5410.85.camel@localhost> <20070614160913.GF7469@us.ibm.com>
 <Pine.LNX.4.64.0706140913530.29612@schroedinger.engr.sgi.com>
 <1181840872.5410.159.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Lee Schermerhorn wrote:

> If it (slab allocators etc) wants and/or can use memory from a different
> node from what it requested, then, it shouldn't be calling with
> GFP_THISNODE, right?  I mean what's the point?  If GFP_THISNODE never

The code wanted memory from a certain node because a certain structure is 
performance sensitive and it did get something else. Both slab and slub 
will fail at some point when trying to touch the structure that was not 
allocated.

> returned off-node memory, then one couldn't use it without checking for
> and dealing with failure.  And, 'THISNODE allocations CAN fail, when the

GFP_THISNODE *never* should return off node memory. That it happened is 
due to people not reviewing the VM as I told them to when we starting 
allowing memoryless nodes in the core VM.

> first zone in the selected zonelist is empty and subsequent zones are
> off-node.  __alloc_pages() et al WILL fail this case and return NULL, so
> callers must be prepared to deal with it--even [especially?] early boot
> code, IMO, anyway.

Bootstrap is a special case. It is a reasonable expectation to find memory 
on nodes that have memory (i.e. formerly online nodes were guaranteed to 
have memory now we guarantee that for "memory nodes").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
