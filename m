Date: Wed, 9 May 2007 16:48:59 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
Message-Id: <20070509164859.15dd347b.pj@sgi.com>
In-Reply-To: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Ken wrote:
> I wonder why we don't check cpuset's mems_allowed node mask in the
> sys_mbind() path?

Looking back through the version history of mm/mempolicy.c, I see that
we used to check the cpuset (by calling contextualize_policy), but then
with the following patch (Christoph added to CC list above), this was
changed.

=========================== begin ===========================
Subject: - remove-policy-contextualization-from-mbind.patch removed from -mm tree
To: clameter@engr.sgi.com, ak@muc.de, clameter@sgi.com,
   mm-commits@vger.kernel.org
From: akpm@osdl.org
Date:   Sun, 30 Oct 2005 00:27:40 -0700


The patch titled

     Remove policy contextualization from mbind

has been removed from the -mm tree.  Its filename is

     remove-policy-contextualization-from-mbind.patch

This patch was probably dropped from -mm because
it has already been merged into a subsystem tree
or into Linus's tree


From: Christoph Lameter <clameter@engr.sgi.com>

Policy contextualization is only useful for task based policies and not for
vma based policies.  It may be useful to define allowed nodes that are not
accessible from this thread because other threads may have access to these
nodes.  Without this patch strange memory policy situations may cause an
application to fail with out of memory.

Example:

Let's say we have two threads A and B that share the same address space and
a huge array computational array X.

Thread A is restricted by its cpuset to nodes 0 and 1 and thread B is
restricted by its cpuset to nodes 2 and 3.

Thread A now wants to restrict allocations to the first node and thus
applies a BIND policy on X to node 0 and 2.  The cpuset limits this to node
0.  Thus pages for X must be allocated on node 0 now.

Thread B now touches a page that has never been used in X and faults in a
page.  According to the BIND policy of the vma for X the page must be
allocated on page 0.  However, the cpuset of B does not allow allocation on
0 and 1.  Now the application fails in alloc_pages with out of memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/mempolicy.c~remove-policy-contextualization-from-mbind mm/mempolicy.c
--- devel/mm/mempolicy.c~remove-policy-contextualization-from-mbind     2005-10-29 17:43:43.000000000 -0700
+++ devel-akpm/mm/mempolicy.c   2005-10-29 17:43:43.000000000 -0700
@@ -370,7 +370,7 @@ long do_mbind(unsigned long start, unsig
                return -EINVAL;
        if (end == start)
                return 0;
-       if (contextualize_policy(mode, nmask))
+       if (mpol_check_policy(mode, nmask))
                return -EINVAL;
        new = mpol_new(mode, nmask);
        if (IS_ERR(new))
_

Patches currently in -mm which might be from clameter@engr.sgi.com are

increase-maximum-kmalloc-size-to-256k.patch
use-alloc_percpu-to-allocate-workqueues-locally.patch
============================ end ============================

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
