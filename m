Date: Mon, 4 Jun 2007 09:44:52 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: tmpfs and numa mempolicy
Message-Id: <20070604094452.6eae8828.randy.dunlap@oracle.com>
In-Reply-To: <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
References: <20070603203003.64fd91a8.randy.dunlap@oracle.com>
	<Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jun 2007 13:43:33 +0100 (BST) Hugh Dickins wrote:

> On Sun, 3 Jun 2007, Randy Dunlap wrote:
> > 
> > If someone mounts tmpfs as in
> > 
> > > mount -t tmpfs -o size=10g,nr_inodes=10k,mode=777,mpol=prefer:1 \
> > 	tmpfs /mytmpfs
> > 
> > but does not have a node 1, bad things happen when /mytmpfs is accessed.
> > (CONFIG_NUMA=y)
> > 
> > Is this just a case of shoot self in foot, DDT (don't do that)?
> 
> Thanks for finding that, Randy.
> 
> While it's true that you have to be privileged to mount in the first
> place (so this isn't too serious), I don't think we can dismiss it as
> just root shooting own foot: we are in the habit of validating mount
> arguments to avoid obvious crashes, so ought to do something about this.

I agree.  Thanks.

> I've appended a patch to check node_online_map below, and update
> tmpfs.txt accordingly.  I'm not entirely happy with it: you and I
> rather need to undo it when testing whether the mpol= parsing works,
> and it is more restrictive than Robin or I intended.
> 
> But it looks to me like mempolicy.c normally never lets a nonline
> node get into any of its policies, and it would be a bit tedious,
> error-prone and unnecessary overhead to relax that: so tmpfs mount
> is at present a dangerous exception in this regard.
> 
> Would you be happy with this change, Robin?  I'm not very NUMArate:
> do nodes in fact ever get onlined after early system startup?
> If not, then this change would hardly be any real limitation.
> 
> Hugh

> [PATCH] mount -t tmpfs -o mpol= check nodes online
> 
> Randy Dunlap reports that a tmpfs, mounted with NUMA mpol= specifying
> an offline node, crashes as soon as data is allocated upon it.  Now
> restrict it to online nodes, where before it restricted to MAX_NUMNODES.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com> // and tested-by:

> ---
>  Documentation/filesystems/tmpfs.txt |   10 +++++-----
>  mm/shmem.c                          |    2 ++
>  2 files changed, 7 insertions(+), 5 deletions(-)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
