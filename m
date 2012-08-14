Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 1CF406B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:56:15 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so333432vcb.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 04:56:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1208131900260.29738@eggly.anvils>
References: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com>
	<alpine.LSU.2.00.1208091816240.9631@eggly.anvils>
	<CAJd=RBDu5ebAAOuie5yNc8x7vkn7LPfDZZyGzRsCUFNRojWmwQ@mail.gmail.com>
	<alpine.LSU.2.00.1208131900260.29738@eggly.anvils>
Date: Tue, 14 Aug 2012 19:56:13 +0800
Message-ID: <CAJd=RBD53oRWx7d7=tynzzHVe=pLV_5Y4ryi695VSq_T-YLx9Q@mail.gmail.com>
Subject: Re: [patch] mmap: feed back correct prev vma when finding vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benny Halevy <bhalevy@tonian.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Aug 14, 2012 at 10:17 AM, Hugh Dickins <hughd@google.com> wrote:
> [PATCH] mm: replace find_vma_prepare by clearer find_vma_links
>
> People get confused by find_vma_prepare(), because it doesn't care about
> what it returns in its output args, when its callers won't be interested.
>
> Clarify by passing in end-of-range address too, and returning failure if
> any existing vma overlaps the new range: instead of returning an ambiguous
> vma which most callers then must check.  find_vma_links() is a clearer name.
>
> This does revert 2.6.27's dfe195fb79e88 ("mm: fix uninitialized variables
> for find_vma_prepare callers"), but it looks like gcc 4.3.0 was one of
> those releases too eager to shout about uninitialized variables: only
> copy_vma() warns with 4.5.1 and 4.7.1, which a BUG on error silences.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Benny Halevy <bhalevy@tonian.com>


Acked-by: Hillf Danton <dhillf@gmail.com>

>  mm/mmap.c |   45 +++++++++++++++++++++------------------------
>  1 file changed, 21 insertions(+), 24 deletions(-)
>
> --- 3.6-rc1/mm/mmap.c   2012-08-03 08:31:27.064842271 -0700
> +++ linux/mm/mmap.c     2012-08-13 12:23:35.862895633 -0700
> @@ -356,17 +356,14 @@ void validate_mm(struct mm_struct *mm)
>  #define validate_mm(mm) do { } while (0)
>  #endif
>
> -static struct vm_area_struct *
> -find_vma_prepare(struct mm_struct *mm, unsigned long addr,
> -               struct vm_area_struct **pprev, struct rb_node ***rb_link,
> -               struct rb_node ** rb_parent)
> +static int find_vma_links(struct mm_struct *mm, unsigned long addr,
> +               unsigned long end, struct vm_area_struct **pprev,
> +               struct rb_node ***rb_link, struct rb_node **rb_parent)
>  {
> -       struct vm_area_struct * vma;
> -       struct rb_node ** __rb_link, * __rb_parent, * rb_prev;
> +       struct rb_node **__rb_link, *__rb_parent, *rb_prev;
>

Just a nitpick, we could further cut a couple of lines if
rb_prev is replaced by vma.

>         __rb_link = &mm->mm_rb.rb_node;
>         rb_prev = __rb_parent = NULL;
> -       vma = NULL;
>
>         while (*__rb_link) {
>                 struct vm_area_struct *vma_tmp;
> @@ -375,9 +372,9 @@ find_vma_prepare(struct mm_struct *mm, u
>                 vma_tmp = rb_entry(__rb_parent, struct vm_area_struct, vm_rb);
>
>                 if (vma_tmp->vm_end > addr) {
> -                       vma = vma_tmp;
> -                       if (vma_tmp->vm_start <= addr)
> -                               break;
> +                       /* Fail if an existing vma overlaps the area */
> +                       if (vma_tmp->vm_start < end)
> +                               return -ENOMEM;
>                         __rb_link = &__rb_parent->rb_left;
>                 } else {
>                         rb_prev = __rb_parent;
> @@ -390,7 +387,7 @@ find_vma_prepare(struct mm_struct *mm, u
>                 *pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
>         *rb_link = __rb_link;
>         *rb_parent = __rb_parent;
> -       return vma;
> +       return 0;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
