Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l4AIXFLJ005225
	for <linux-mm@kvack.org>; Thu, 10 May 2007 11:33:18 -0700
Received: from an-out-0708.google.com (andd11.prod.google.com [10.100.30.11])
	by zps77.corp.google.com with ESMTP id l4AIWesS001218
	for <linux-mm@kvack.org>; Thu, 10 May 2007 11:32:53 -0700
Received: by an-out-0708.google.com with SMTP id d11so210393and
        for <linux-mm@kvack.org>; Thu, 10 May 2007 11:32:53 -0700 (PDT)
Message-ID: <b040c32a0705101132m5baacb9cx59f15fe9dccfff05@mail.gmail.com>
Date: Thu, 10 May 2007 11:32:52 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
	 <20070509164859.15dd347b.pj@sgi.com>
	 <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
	 <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> > However, mbind shouldn't create discrepancy between what is allowed
> > and what is promised, especially with MPOL_BIND policy.  Since a
> > numa-aware app has already gone such a detail to request memory
> > placement on a specific nodemask, they fully expect memory to be
> > placed there for performance reason.  If kernel lies about it, we get
> > very unpleasant performance issue.
>
> How does the kernel lie? The memory is placed given the current cpuset and
> memory policy restrictions.

I wish Christoph whack me a little bit harder ;-)  He already fixed
the darn thing 4 month ago.  And I should've set more rigorous habit
of cross check/test somewhat non-ancient kernel tree.  We are indeed
already restrict nodemask to current mems_allowed.

- Ken


commit 30150f8d7b76f25b1127a5079528b7a17307f995
Author: Christoph Lameter <clameter@sgi.com>
Date:   Mon Jan 22 20:40:45 2007 -0800

    [PATCH] mbind: restrict nodes to the currently allowed cpuset

    Currently one can specify an arbitrary node mask to mbind that includes
    nodes not allowed.  If that is done with an interleave policy then we will
    go around all the nodes.  Those outside of the currently allowed cpuset
    will be redirected to the border nodes.  Interleave will then create
    imbalances at the borders of the cpuset.

    This patch restricts the nodes to the currently allowed cpuset.

    The RFC for this patch was discussed at
    http://marc.theaimsgroup.com/?t=116793842100004&r=1&w=2

    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Cc: Paul Jackson <pj@sgi.com>
    Cc: Andi Kleen <ak@suse.de>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index da94639..c2aec0e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -884,6 +884,10 @@ asmlinkage long sys_mbind(unsigned long
        err = get_nodes(&nodes, nmask, maxnode);
        if (err)
                return err;
+#ifdef CONFIG_CPUSETS
+       /* Restrict the nodes to the allowed nodes in the cpuset */
+       nodes_and(nodes, nodes, current->mems_allowed);
+#endif
        return do_mbind(start, len, mode, &nodes, flags);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
