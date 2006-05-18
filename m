Subject: Re: Query re:  mempolicy for page cache pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060518111416.51de0127.akpm@osdl.org>
References: <1147974599.5195.96.camel@localhost.localdomain>
	 <20060518111416.51de0127.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 18 May 2006 15:10:18 -0400
Message-Id: <1147979418.5195.157.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, clameter@sgi.com, ak@suse.de, stevel@mvista.com
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-18 at 11:14 -0700, Andrew Morton wrote:
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> >
> > 1) What ever happened to Steve's patch set?
> 
> They were based on Andi's 4-level-pagetable work.  Then we merged Nick's
> 4-level-pagetable work instead, so
> numa-policies-for-file-mappings-mpol_mf_move.patch broke horridly and I
> dropped it.  Steve said he'd redo the patch based on the new pagetable code
> and would work with SGI on getting it benchmarked, but that obviously
> didn't happen.

Thanks for the info Andrew.

> 
> I was a bit concerned about the expansion in sizeof(address_space), but we
> ended up agreeing that it's numa-only and NUMA machines tend to have lots
> of memory anyway.  That being said, it would still be better to have a
> pointer to a refcounted shared_policy in the address_space if poss, rather
> than aggregating the whole thing.

Yes, I was concerned about that, too.  I do use a pointer to the shared
policy struct in the address space, allocating it only if one actually
applies a policy.  A null pointer results in current behavior:  fall
back
to process then global default policy.  Even so, the pointer member
would
only be included under CONFIG_NUMA.

As far as reference counting:  I didn't think it would be necessary,
because
it appears to me that the address space structs are one to one with the
inodes and persists as long as the inode does.  Is this correct?  If
so, 
then the shared policy struct would only be deleted when the inode goes
away.  I may have a race, but I didn't think one could be doing an
insert
or lookup w/o holding locks/references on structs that would prevent the
inode from being destroyed.

But, may turn out to be moot, heh?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
