Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C17A4C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:29:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 737C920673
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F7ZExr/g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 737C920673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 215B86B0006; Tue, 13 Aug 2019 05:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6496B0007; Tue, 13 Aug 2019 05:29:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08EB36B0008; Tue, 13 Aug 2019 05:29:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id DD87D6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:29:35 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 86641AC08
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:29:35 +0000 (UTC)
X-FDA: 75816881910.10.kite24_53abe553f9b49
X-HE-Tag: kite24_53abe553f9b49
X-Filterd-Recvd-Size: 9461
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com [209.85.167.68])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:29:34 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id h28so76218115lfj.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:29:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fAGysT7hqZ7fpkKuFt14uGWUhbRaQKW6bEkju/DQztU=;
        b=F7ZExr/gKphkOMbwzFNWLmCTRAdBlrNKlQyD7+WmTsRhHi+YC6OsQlm/kv9McDMwFJ
         R20dugVH22xMQS1tATtQnipVcUq5+nBQw4VKYvqVVy0lO9RLXadlOBVtdkC+07Hec/kC
         DaAxgaUQr+XJFc1x48p5QOiOp7ImUQcDuXmckL3kz0gh3pOD6TO1exI8vCRFYeNYfwwY
         GuWqop4SZxgOPqPLslr9Tweb22sqb99wojlKzdUtMX+YxWcdjrTcQZNHET4LJMrsBGvV
         Se3PKx/Jb49JIgI0HVFL7j86xEU7J1qzFvi9BsTcEnZwiht5JPWGfREGMG5RwN2l2MFR
         ZNVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=fAGysT7hqZ7fpkKuFt14uGWUhbRaQKW6bEkju/DQztU=;
        b=hYV1ZcSaRorc8K0d4uU8cbSFEdq3X7uFE1pYjW0lkueZ8sOocFdWHhBzgCi56Urvbh
         WtQzOen+6aByQwQv3aHQJPH2EdZkaAgLsA8OHXqoGq5E3xPUftCL5RK22ecDtCWHAXKd
         6NgH3V4NrsS6YLcCkK4xWeuHdNV6q2xzVyICdQ2NAhv8e0S4SH5mahrJIkp7fck43DU3
         VelyPJAM03May71qYCKGJorliaC5rGGzSCZczGomLko9mjGY3/xTK5dfTHr9IzeZVDkk
         vdH7b02S694KzYtRiZvU96P0Wv8U1uUJJ9OBlMOOgMu7F0B6TfnXCAYGpXZB+tw9ikxS
         bQKg==
X-Gm-Message-State: APjAAAW5YvBXkiNL6/EyiI602KeiCrjWnXkskHvwBTvcERg9z4Yeq7SY
	+sND0NPPPMJ1lxV4L+rIyJM=
X-Google-Smtp-Source: APXvYqxYBQM5SCNw2q/2hCRd2Jc3+NStRRPko0hooVWmdJu4/GZCA6opIqvaZS1fQLxMejlgwxnMBw==
X-Received: by 2002:ac2:4a6e:: with SMTP id q14mr21147287lfp.80.1565688573302;
        Tue, 13 Aug 2019 02:29:33 -0700 (PDT)
Received: from pc636 ([37.212.214.187])
        by smtp.gmail.com with ESMTPSA id m25sm19522310lfc.83.2019.08.13.02.29.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Aug 2019 02:29:32 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 13 Aug 2019 11:29:22 +0200
To: Michel Lespinasse <walken@google.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <guro@fb.com>,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] some cleanups related to RB_DECLARE_CALLBACKS_MAX
Message-ID: <20190813092922.udzdjgfj4w6e362c@pc636>
References: <20190811184613.20463-1-urezki@gmail.com>
 <CANN689H0bzp_wPXugvStJu=ozWE2zcHaKiQ60bCdyGhcdpy8tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689H0bzp_wPXugvStJu=ozWE2zcHaKiQ60bCdyGhcdpy8tg@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> I think it would be sufficient to call RBCOMPUTE(node, true) on every
> node and check the return value ?
>
Yes, that is enough for sure. The only way i was thinking about to make it
public, because checking the tree for MAX is generic for every users which
use RB_DECLARE_CALLBACKS_MAX template. Something like:

validate_rb_max_tree() {
    for (nd = rb_first(root); nd; nd = rb_next(nd)) {
	    fooo = rb_entry(nd, struct sometinhf, rb_field);
	    WARN_ON(!*_compute_max(foo, true);	
    }
}

and call this public function under debug code. But i do not have strong
opinion here and it is probably odd. Anyway i am fine with your change.

There is small comment below:

> 
> Something like the following (probably applicable in other files too):
> 
> ---------------------------------- 8< ------------------------------------
> 
> augmented rbtree: use generated compute_max function for debug checks
> 
> In debug code, use the generated compute_max function instead of
> reimplementing similar functionality in multiple places.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  lib/rbtree_test.c | 15 +-------------
>  mm/mmap.c         | 26 +++--------------------
>  mm/vmalloc.c      | 53 +++++++----------------------------------------
>  3 files changed, 12 insertions(+), 82 deletions(-)
> 
> diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
> index 41ae3c7570d3..a5a04e820f77 100644
> --- a/lib/rbtree_test.c
> +++ b/lib/rbtree_test.c
> @@ -222,20 +222,7 @@ static void check_augmented(int nr_nodes)
>  	check(nr_nodes);
>  	for (rb = rb_first(&root.rb_root); rb; rb = rb_next(rb)) {
>  		struct test_node *node = rb_entry(rb, struct test_node, rb);
> -		u32 subtree, max = node->val;
> -		if (node->rb.rb_left) {
> -			subtree = rb_entry(node->rb.rb_left, struct test_node,
> -					   rb)->augmented;
> -			if (max < subtree)
> -				max = subtree;
> -		}
> -		if (node->rb.rb_right) {
> -			subtree = rb_entry(node->rb.rb_right, struct test_node,
> -					   rb)->augmented;
> -			if (max < subtree)
> -				max = subtree;
> -		}
> -		WARN_ON_ONCE(node->augmented != max);
> +		WARN_ON_ONCE(!augment_callbacks_compute_max(node, true));
>  	}
>  }
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 24f0772d6afd..d6d23e6c2d10 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -311,24 +311,6 @@ static inline unsigned long vma_compute_gap(struct vm_area_struct *vma)
>  }
>  
>  #ifdef CONFIG_DEBUG_VM_RB
> -static unsigned long vma_compute_subtree_gap(struct vm_area_struct *vma)
> -{
> -	unsigned long max = vma_compute_gap(vma), subtree_gap;
> -	if (vma->vm_rb.rb_left) {
> -		subtree_gap = rb_entry(vma->vm_rb.rb_left,
> -				struct vm_area_struct, vm_rb)->rb_subtree_gap;
> -		if (subtree_gap > max)
> -			max = subtree_gap;
> -	}
> -	if (vma->vm_rb.rb_right) {
> -		subtree_gap = rb_entry(vma->vm_rb.rb_right,
> -				struct vm_area_struct, vm_rb)->rb_subtree_gap;
> -		if (subtree_gap > max)
> -			max = subtree_gap;
> -	}
> -	return max;
> -}
> -
>  static int browse_rb(struct mm_struct *mm)
>  {
>  	struct rb_root *root = &mm->mm_rb;
> @@ -355,10 +337,8 @@ static int browse_rb(struct mm_struct *mm)
>  			bug = 1;
>  		}
>  		spin_lock(&mm->page_table_lock);
> -		if (vma->rb_subtree_gap != vma_compute_subtree_gap(vma)) {
> -			pr_emerg("free gap %lx, correct %lx\n",
> -			       vma->rb_subtree_gap,
> -			       vma_compute_subtree_gap(vma));
> +		if (!vma_gap_callbacks_compute_max(vma, true)) {
> +			pr_emerg("wrong subtree gap in vma %p\n", vma);
>  			bug = 1;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> @@ -385,7 +365,7 @@ static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
>  		struct vm_area_struct *vma;
>  		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
>  		VM_BUG_ON_VMA(vma != ignore &&
> -			vma->rb_subtree_gap != vma_compute_subtree_gap(vma),
> +			!vma_gap_callbacks_compute_max(vma, true),
>  			vma);
>  	}
>  }
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f7c61accb0e2..ea23ccaf70fc 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -553,48 +553,6 @@ unlink_va(struct vmap_area *va, struct rb_root *root)
>  	RB_CLEAR_NODE(&va->rb_node);
>  }
>  
> -#if DEBUG_AUGMENT_PROPAGATE_CHECK
> -static void
> -augment_tree_propagate_check(struct rb_node *n)
> -{
> -	struct vmap_area *va;
> -	struct rb_node *node;
> -	unsigned long size;
> -	bool found = false;
> -
> -	if (n == NULL)
> -		return;
> -
> -	va = rb_entry(n, struct vmap_area, rb_node);
> -	size = va->subtree_max_size;
> -	node = n;
> -
> -	while (node) {
> -		va = rb_entry(node, struct vmap_area, rb_node);
> -
> -		if (get_subtree_max_size(node->rb_left) == size) {
> -			node = node->rb_left;
> -		} else {
> -			if (va_size(va) == size) {
> -				found = true;
> -				break;
> -			}
> -
> -			node = node->rb_right;
> -		}
> -	}
> -
> -	if (!found) {
> -		va = rb_entry(n, struct vmap_area, rb_node);
> -		pr_emerg("tree is corrupted: %lu, %lu\n",
> -			va_size(va), va->subtree_max_size);
> -	}
> -
> -	augment_tree_propagate_check(n->rb_left);
> -	augment_tree_propagate_check(n->rb_right);
> -}
> -#endif
> -
>  /*
>   * This function populates subtree_max_size from bottom to upper
>   * levels starting from VA point. The propagation must be done
> @@ -645,9 +603,14 @@ augment_tree_propagate_from(struct vmap_area *va)
>  		node = rb_parent(&va->rb_node);
>  	}
>  
> -#if DEBUG_AUGMENT_PROPAGATE_CHECK
> -	augment_tree_propagate_check(free_vmap_area_root.rb_node);
> -#endif
> +	if (DEBUG_AUGMENT_PROPAGATE_CHECK) {
> +		struct vmap_area *va;
> +
> +		list_for_each_entry(va, &free_vmap_area_list, list) {
> +			WARN_ON(!free_vmap_area_rb_augment_cb_compute_max(
> +					va, true));
> +		}
> +	}
>  }
>
The object of validating is the tree, therefore it makes sense to go with it,
instead of iterating over the list.

Thank you!

--
Vlad Rezki

