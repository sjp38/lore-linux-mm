Date: Wed, 2 May 2007 20:02:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070503022107.GA13592@kryten>
Message-ID: <Pine.LNX.4.64.0705021959100.4259@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Anton Blanchard wrote:

> It didnt take long to realise that alloc_fresh_huge_page is allocating
> from node 7 without GFP_THISNODE set, so we fallback to its next
> preferred node (ie 1). This means we end up with a 1/3 2/3 imbalance.

Yup.
 
> After fixing this it still didnt work, and after some more poking I see
> why. When building our fallback zonelist in build_zonelists_node we
> skip empty zones. This means zone 7 never registers node 7's empty
> zonelists and instead registers node 1's. Therefore when we ask for a
> page from node 7, using the GFP_THISNODE flag we end up with node 1
> memory.
> 
> By removing the populated_zone() check in build_zonelists_node we fix
> the problem:

Looks good. I guess that is possible now that memory policy
zonelist building skips empty zonelists. Andi?

> Im guessing registering empty remote zones might make the SGI guys a bit
> unhappy, maybe we should just force the registration of empty local
> zones? Does anyone care?

Why would that make us unhappy?

Note that this is a direct result of allowing node without memorys. We 
only recently allowed such things while being aware that there will be 
some breakage. This is one. If the empty node would not have been marked 
online then we would not have attempted an allocation there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
