Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A47476B00FF
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:06:31 -0400 (EDT)
Message-ID: <1340312765.18025.40.camel@twins>
Subject: Re: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 21 Jun 2012 23:06:05 +0200
In-Reply-To: <1340057126-31143-3-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
	 <1340057126-31143-3-git-send-email-riel@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, 2012-06-18 at 18:05 -0400, Rik van Riel wrote:
> +       /* Find the left-most free area of sufficient size. */


Just because there's nothing better than writing it yourself.. I tried
writing something that does the above. The below is the result, it
doesn't use your uncle functions and is clearly limited to two
traversals and thus trivially still O(log n). [ although I think with a
bit of effort you can prove the same for your version ].

---

static inline struct vm_area_struct *vma_of(struct rb_node *node)
{
        return container_of(node, struct vm_area_struct, vm_rb);
}

static inline unsigned long max_gap_of(struct rb_node *node)
{
        return vma_of(node)->free_gap;
}

static unsigned long gap_of(struct rb_node *node)
{
        struct vm_area_struct *vma =3D vma_of(node);

        if (!vma->vm_prev)
                return vma->vm_start;

        return vma->vm_start - vma->vm_prev->vm_end;
}

static bool node_better(struct rb_node *node, struct rb_node *best)
{
        if (!best)
                return true;

        return vma_of(node)->vm_start < vma_of(best)->vm_start;
}

unsigned long find_leftmost_gap(struct mm_struct *mm, unsigned long len)
{
        struct rb_node *node =3D mm->mm_rb.rb_node, *best =3D NULL, *tree =
=3D NULL;

        /*
         * Do a search for TASK_UNMAPPED_BASE + len, all nodes right of thi=
s
         * boundary should be considered. Path nodes are immediate candidat=
es,
         * their right sub-tree is stored for later consideration in case
         * the immediate path doesn't yield a suitable node.
         */
        while (node) {
                if (vma_of(node)->vm_start - len >=3D TASK_UNMAPPED_BASE) {
                        /*
                         * If our node has a big enough hole, track it.
                         */
                        if (gap_of(node) > len && node_better(node, best))
                                best =3D node;

                        /*
                         * In case we flunk out on the path nodes, keep tra=
ck=20
                         * of the right sub-trees which have big enough hol=
es.
                         */
                        if (node->rb_right && max_gap_of(node-rb_right) >=
=3D len &&
                            node_better(node->rb_right, tree))
                                tree =3D node->rb_right;

                        node =3D node->rb_left;
                        continue;
                }
                node =3D node->rb_right;
        }

        if (best)
                return vma_of(best)->vm_start - len;

        /*
         * Our stored subtree must be entirely right of TASK_UNMAPPED_BASE =
+ len
         * so do a simple search for leftmost hole of appropriate size.
         */
        while (tree) {
                if (gap_of(tree) >=3D len && node_better(tree, best))
                        best =3D tree;

                if (tree->rb_left && max_gap_of(tree->rb_left) >=3D len) {
                        tree =3D tree->rb_left;
                        continue;
                }

                tree =3D tree->rb_right;
        }

        if (best)
                return vma_of(best)->vm_start - len;

        /*
         * Ok, so no path node, nor right sub-tree had a properly sized hol=
e
         * we could use, use the rightmost address in the tree.
         */
        node =3D mm->mm_rb.rb_node;
        while (node && node->rb_right)
                node =3D node->rb_right;

        return max(vma_of(node)->vm_end, TASK_UNMAPPED_BASE);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
