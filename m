From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Wed, 27 Jun 2007 00:42:26 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706270042.27365.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wednesday 27 June 2007 00:21, Christoph Lameter wrote:
> On Mon, 25 Jun 2007, Lee Schermerhorn wrote:
> > Also note that because we can remove a shared policy from a "live"
> > inode, we need to handle potential races with another task performing
> > a get_file_policy() on the same file via a file descriptor access
> > [read()/write()/...].  Patch #9 handles this by defining an RCU reader
> > critical region in get_file_policy() and by synchronizing with this
> > in mpol_free_shared_policy().
>
> You are sure that this works? Just by looking at the description: It
> cannot work. Any allocator use of a memory policy must use rcu locks
> otherwise the memory policy can vanish from under us while allocating a
> page. This means you need to add this to alloc_pages_current
> and alloc_pages_node.  Possible all of __alloc_pages must be handled
> under RCU. This is a significant increase of RCU use.

I've been actually looking at using RCUs for the shared policies 
too to plug the recent reference count issue.  I don't think it's a problem 
because the RCU use can be limited to when policies are actually
used. Besides rcu_read_lock() is a nop on non preemptible kernels
anyways and users of preemptible kernels will probably not notice
it among all the other overhead they have anyways.

> If we can make this work then RCU should be used for all policies so that
> we can get rid of the requirement that policies can only be modified from
> the task context that created it.

Huh? RCU doesn't give you locking against multiple writers. Just existence
guarantees. And you can have those already by just holding the reference 
count.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
