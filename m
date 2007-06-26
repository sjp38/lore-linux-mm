Date: Tue, 26 Jun 2007 15:21:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jun 2007, Lee Schermerhorn wrote:

> Also note that because we can remove a shared policy from a "live"
> inode, we need to handle potential races with another task performing
> a get_file_policy() on the same file via a file descriptor access
> [read()/write()/...].  Patch #9 handles this by defining an RCU reader
> critical region in get_file_policy() and by synchronizing with this
> in mpol_free_shared_policy().

You are sure that this works? Just by looking at the description: It 
cannot work. Any allocator use of a memory policy must use rcu locks 
otherwise the memory policy can vanish from under us while allocating a 
page. This means you need to add this to alloc_pages_current 
and alloc_pages_node.  Possible all of __alloc_pages must be handled 
under RCU. This is a significant increase of RCU use.

If we can make this work then RCU should be used for all policies so that 
we can get rid of the requirement that policies can only be modified from 
the task context that created it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
