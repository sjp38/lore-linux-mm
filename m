Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 88975828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:37:19 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id dx2so20087489lbd.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:37:19 -0800 (PST)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id tj2si5325580lbb.98.2016.02.03.13.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 13:37:18 -0800 (PST)
Received: by mail-lf0-x22b.google.com with SMTP id l143so23502998lfe.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:37:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
	<1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
Date: Thu, 4 Feb 2016 00:37:17 +0300
Message-ID: <CALYGNiOksSkSzJWz3JPPozfeAaHPWOQZFgDzSr-MnR9zVBTncw@mail.gmail.com>
Subject: Re: [PATCH 1/5] radix-tree: Fix race in gang lookup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stable <stable@vger.kernel.org>

On Thu, Jan 28, 2016 at 12:17 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> If the indirect_ptr bit is set on a slot, that indicates we need to
> redo the lookup.  Introduce a new function radix_tree_iter_retry()
> which forces the loop to retry the lookup by setting 'slot' to NULL and
> turning the iterator back to point at the problematic entry.
>
> This is a pretty rare problem to hit at the moment; the lookup has to
> race with a grow of the radix tree from a height of 0.  The consequences
> of hitting this race are that gang lookup could return a pointer to a
> radix_tree_node instead of a pointer to whatever the user had inserted
> in the tree.
>
> Fixes: cebbd29e1c2f ("radix-tree: rewrite gang lookup using iterator")
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Cc: stable@vger.kernel.org
> ---
>  include/linux/radix-tree.h | 16 ++++++++++++++++
>  lib/radix-tree.c           | 12 ++++++++++--
>  2 files changed, 26 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index f9a3da5bf892..db0ed595749b 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -387,6 +387,22 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
>                              struct radix_tree_iter *iter, unsigned flags);
>
>  /**
> + * radix_tree_iter_retry - retry this chunk of the iteration
> + * @iter:      iterator state
> + *
> + * If we iterate over a tree protected only by the RCU lock, a race
> + * against deletion or creation may result in seeing a slot for which
> + * radix_tree_deref_retry() returns true.  If so, call this function
> + * and continue the iteration.
> + */
> +static inline __must_check
> +void **radix_tree_iter_retry(struct radix_tree_iter *iter)
> +{
> +       iter->next_index = iter->index;
> +       return NULL;
> +}
> +
> +/**
>   * radix_tree_chunk_size - get current chunk size
>   *
>   * @iter:      pointer to radix tree iterator
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index a25f635dcc56..65422ac17114 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -1105,9 +1105,13 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
>                 return 0;
>
>         radix_tree_for_each_slot(slot, root, &iter, first_index) {
> -               results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> +               results[ret] = rcu_dereference_raw(*slot);
>                 if (!results[ret])
>                         continue;
> +               if (radix_tree_is_indirect_ptr(results[ret])) {
> +                       slot = radix_tree_iter_retry(&iter);
> +                       continue;
> +               }
>                 if (++ret == max_items)
>                         break;
>         }

Looks like your fix doesn't work.

After radix_tree_iter_retry: radix_tree_for_each_slot will call
radix_tree_next_slot which isn't safe to call for NULL slot.

#define radix_tree_for_each_slot(slot, root, iter, start) \
for (slot = radix_tree_iter_init(iter, start) ; \
    slot || (slot = radix_tree_next_chunk(root, iter, 0)) ; \
    slot = radix_tree_next_slot(slot, iter, 0))

tagged iterator works becase restart happens only at root - tags
filled with single bit.

quick (untested) fix for that

--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -457,9 +457,9 @@ radix_tree_next_slot(void **slot, struct
radix_tree_iter *iter, unsigned flags)
                        return slot + offset + 1;
                }
        } else {
-               unsigned size = radix_tree_chunk_size(iter) - 1;
+               int size = radix_tree_chunk_size(iter) - 1;

-               while (size--) {
+               while (size-- > 0) {
                        slot++;
                        iter->index++;
                        if (likely(*slot))


> @@ -1184,9 +1188,13 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
>                 return 0;
>
>         radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
> -               results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> +               results[ret] = rcu_dereference_raw(*slot);
>                 if (!results[ret])
>                         continue;
> +               if (radix_tree_is_indirect_ptr(results[ret])) {
> +                       slot = radix_tree_iter_retry(&iter);
> +                       continue;
> +               }
>                 if (++ret == max_items)
>                         break;
>         }
> --
> 2.7.0.rc3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
