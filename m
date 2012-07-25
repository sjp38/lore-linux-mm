Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 17D516B0044
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 00:39:13 -0400 (EDT)
Received: by yenr5 with SMTP id r5so353890yen.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2012 21:39:12 -0700 (PDT)
Date: Tue, 24 Jul 2012 21:38:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
 /dev/shmem
In-Reply-To: <500DA581.1020602@sgi.com>
Message-ID: <alpine.LSU.2.00.1207242048580.9334@eggly.anvils>
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com> <1341845199-25677-2-git-send-email-nzimmer@sgi.com> <1341845199-25677-3-git-send-email-nzimmer@sgi.com> <20120723105819.GA4455@mwanda> <500DA581.1020602@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Nathan, Kosaki-san,

I have, at long last, reached the point of looking at this patchset.
And I'm puzzled as to why it has grown more complicated than what you
first sent out.

I've read through the various threads, and some of the changes I like.

I'm glad Andrew took out the stable Cc: obviously the interleave policy
was never intended for a filesystem of many small files, and it could
be that some usages with larger files have actually optimized to the
current node layout, and will regress with this change.  Let's keep it
simple and assume not; but if there are complaints, then we shall have
to make the new behaviour dependent on a mount option.

And I'm glad you switched from random number to rotor: I'm probably
missing the mark by orders of magnitude, but I always think of random
numbers as a precious resource, and was unsure if this deserved them.

But other changes just seem unnecessary to me.  And I don't see how
we can accuse you of being hackish, so long as we have that horrid
business of pseudo-vma on the shmem stack.  I believe the mempolicy
work was designed around vmas, then at the last moment had shmem
grafted on, and the quick way to shoehorn it in was the pseudo-vma.
It's just a way of massaging the info into a format that mempolicy.c
expects, and the arguments about addresses and offsets mystified me.

I did set out to replace the pseudo-vma by adding an alloc_page_mpol()
three years ago; but, no surprise, I got stuck when it came to
understanding the mpol reference counting, and had to move away.
Maybe we can revisit that once Kosaki-san has the refcounting fixed.

Please, what's wrong with the patch below, to replace the current
two or three?  I don't have real NUMA myself: does it work?
If it doesn't work, can you see why not?

Nathan, I've presumptuously put in your signoff, because
you generally seemed happy to incorporate suggestions made.
Kosaki-san, I'm sorry if this version annoys you, but I've not
seen an actual explanation as to why anything more is needed.

Hugh

From: Nathan Zimmer <nzimmer@sgi.com>
Subject: tmpfs: distribute interleave better across nodes

When tmpfs has the interleave memory policy, it always starts allocating
for each file from node 0 at offset 0.  When there are many small files,
the lower nodes fill up disproportionately.

This patch spreads out node usage by starting files at nodes other than
0, by using the inode number to bias the starting node for interleave.

Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---

 mm/shmem.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- v3.5/mm/shmem.c	2012-07-21 13:58:29.000000000 -0700
+++ linux/mm/shmem.c	2012-07-24 20:13:58.468797969 -0700
@@ -929,7 +929,8 @@ static struct page *shmem_swapin(swp_ent
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
-	pvma.vm_pgoff = index;
+	/* Bias interleave by inode number to distribute better across nodes */
+	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
 	return swapin_readahead(swap, gfp, &pvma, 0);
@@ -942,7 +943,8 @@ static struct page *shmem_alloc_page(gfp
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
-	pvma.vm_pgoff = index;
+	/* Bias interleave by inode number to distribute better across nodes */
+	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
