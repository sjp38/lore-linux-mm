Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B9E646B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:13:43 -0400 (EDT)
Date: Fri, 7 Sep 2012 15:13:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/7] mm: interval tree updates
Message-Id: <20120907151341.79cb5638.akpm@linux-foundation.org>
In-Reply-To: <1346750457-12385-2-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
	<1346750457-12385-2-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org

On Tue,  4 Sep 2012 02:20:51 -0700
Michel Lespinasse <walken@google.com> wrote:

> This commit updates the generic interval tree code that was
> introduced in "mm: replace vma prio_tree with an interval tree".
> 
> Changes:
> 
> - fixed 'endpoing' typo noticed by Andrew Morton
> 
> - replaced include/linux/interval_tree_tmpl.h, which was used as a
>   template (including it automatically defined the interval tree
>   functions) with include/linux/interval_tree_generic.h, which only
>   defines a preprocessor macro INTERVAL_TREE_DEFINE(), which itself
>   defines the interval tree functions when invoked. Now that is a very
>   long macro which is unfortunate, but it does make the usage sites
>   (lib/interval_tree.c and mm/interval_tree.c) a bit nicer than previously.
> 
> - make use of RB_DECLARE_CALLBACKS() in the INTERVAL_TREE_DEFINE() macro,
>   instead of duplicating that code in the interval tree template.
> 
> - replaced vma_interval_tree_add(), which was actually handling the
>   nonlinear and interval tree cases, with vma_interval_tree_insert_after()
>   which handles only the interval tree case and has an API that is more
>   consistent with the other interval tree handling functions.
>   The nonlinear case is now handled explicitly in kernel/fork.c dup_mmap().
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  include/linux/interval_tree_generic.h |  191 ++++++++++++++++++++++++++++
>  include/linux/interval_tree_tmpl.h    |  219 ---------------------------------

Well that's a mess.  We create interval_tree_generic.h then four
commits later it vanishes, never to return.  And I can't fold
mm-interval-tree-updates.patch into
mm-replace-vma-prio_tree-with-an-interval-tree.patch because
rbtree-move-augmented-rbtree-functionality-to-rbtree_augmentedh.patch
mucks with interval_tree_generic.h within those four commits.

Ho hum.  I don't think I can be bothered untangling all this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
