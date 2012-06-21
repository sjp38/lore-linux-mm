Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2CC6C6B00BD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 07:07:56 -0400 (EDT)
Message-ID: <1340276867.21745.172.camel@twins>
Subject: Re: [PATCH -mm 1/7] mm: track free size between VMAs in VMA rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 21 Jun 2012 13:07:47 +0200
In-Reply-To: <1340057126-31143-2-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
	 <1340057126-31143-2-git-send-email-riel@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, 2012-06-18 at 18:05 -0400, Rik van Riel wrote:
> @@ -473,11 +524,17 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_s=
truct *vma,
>                 struct vm_area_struct *prev)
>  {
>         struct vm_area_struct *next =3D vma->vm_next;
> +       struct rb_node *deepest;
> =20
>         prev->vm_next =3D next;
> -       if (next)
> +       if (next) {
>                 next->vm_prev =3D prev;
> +               adjust_free_gap(next);
> +       }
> +       deepest =3D rb_augment_erase_begin(&vma->vm_rb);
>         rb_erase(&vma->vm_rb, &mm->mm_rb);
> +       rb_augment_erase_end(deepest, vma_rb_augment_cb, NULL);
> +
>         if (mm->mmap_cache =3D=3D vma)
>                 mm->mmap_cache =3D prev;
>  }


> @@ -1933,7 +2002,10 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, s=
truct vm_area_struct *vma,
>         insertion_point =3D (prev ? &prev->vm_next : &mm->mmap);
>         vma->vm_prev =3D NULL;
>         do {
> +               struct rb_node *deepest;
> +               deepest =3D rb_augment_erase_begin(&vma->vm_rb);
>                 rb_erase(&vma->vm_rb, &mm->mm_rb);
> +               rb_augment_erase_end(deepest, vma_rb_augment_cb, NULL);=
=20


---
 include/linux/rbtree.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 033b507..07c5843 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -155,6 +155,14 @@ extern struct rb_node *rb_augment_erase_begin(struct r=
b_node *node);
 extern void rb_augment_erase_end(struct rb_node *node,
 				 rb_augment_f func, void *data);
=20
+static inline void rb_augment_erase(struct rb_node *node, struct rb_root *=
root,
+				    rb_augment_f func, void *data)
+{
+	struct rb_node *deepest =3D rb_augment_erase_begin(node);
+	rb_erase(node, root);
+	rb_augment_erase_end(deepest, func, data);
+}
+
 /* Find logical next and previous nodes in a tree */
 extern struct rb_node *rb_next(const struct rb_node *);
 extern struct rb_node *rb_prev(const struct rb_node *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
