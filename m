Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3254C6B0160
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 06:03:07 -0400 (EDT)
Message-ID: <1340359379.18025.60.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 12:02:59 +0200
In-Reply-To: <1340315835-28571-2-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	 <1340315835-28571-2-git-send-email-riel@surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, 2012-06-21 at 17:57 -0400, Rik van Riel wrote:
> +static unsigned long largest_free_gap(struct rb_node *node)
> +{
> +       struct vm_area_struct *vma, *prev, *left =3D NULL, *right =3D NUL=
L;
> +       unsigned long largest =3D 0;
> +
> +       if (node->rb_left)
> +               left =3D rb_to_vma(node->rb_left);
> +       if (node->rb_right)
> +               right =3D rb_to_vma(node->rb_right);
> +
> +       /* Calculate the free gap size between us and the VMA to our left=
. */
> +       vma =3D rb_to_vma(node);
> +       prev =3D vma->vm_prev;
> +
> +       if (prev)
> +               largest =3D vma->vm_start - prev->vm_end;
> +       else
> +               largest =3D vma->vm_start;
> +
> +       /* We propagate the largest of our own, or our children's free ga=
ps. */
> +       if (left)
> +               largest =3D max(largest, left->free_gap);
> +       if (right)
> +               largest =3D max(largest, right->free_gap);
> +
> +       return largest;
> +}=20

If you introduce helpers like:

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

You can write your largest free gap as:

unsigned long largest_gap(struct rb_node *node)
{
	unsigned long gap =3D gap_of(node);

	if (node->rb_left)
		gap =3D max(gap, max_gap_of(node->rb_left));
	if (node->rb_right)
		gap =3D max(gap, max_gap_of(node->rb_right));

	return gap;
}

And as shown, you can re-used those {max_,}gap_of() function in the
lookup function in the next patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
