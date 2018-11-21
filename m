Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF9A46B26CC
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:42:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so9718981ply.4
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:42:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f18si18044960pgl.457.2018.11.21.09.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 09:42:45 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wALHdLnR015980
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:42:45 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nwbscrkvm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:42:44 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 21 Nov 2018 17:42:42 -0000
Date: Wed, 21 Nov 2018 18:42:36 +0100
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] userfaultfd: convert userfaultfd_ctx::refcount to
 refcount_t
References: <20181115003916.63381-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115003916.63381-1-ebiggers@kernel.org>
Message-Id: <20181121174236.GA5704@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Wed, Nov 14, 2018 at 04:39:16PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Reference counters should use refcount_t rather than atomic_t, since the
> refcount_t implementation can prevent overflows, reducing the
> exploitability of reference leak bugs.  userfaultfd_ctx::refcount is a
> reference counter with the usual semantics, so convert it to refcount_t.
> 
> Note: I replaced the BUG() on incrementing a 0 refcount with just
> refcount_inc(), since part of the semantics of refcount_t is that that
> incrementing a 0 refcount is not allowed; with CONFIG_REFCOUNT_FULL,
> refcount_inc() already checks for it and warns.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  fs/userfaultfd.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 356d2b8568c14..8375faac2790d 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -53,7 +53,7 @@ struct userfaultfd_ctx {
>  	/* a refile sequence protected by fault_pending_wqh lock */
>  	struct seqcount refile_seq;
>  	/* pseudo fd refcounting */
> -	atomic_t refcount;
> +	refcount_t refcount;
>  	/* userfaultfd syscall flags */
>  	unsigned int flags;
>  	/* features requested from the userspace */
> @@ -140,8 +140,7 @@ static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
>   */
>  static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
>  {
> -	if (!atomic_inc_not_zero(&ctx->refcount))
> -		BUG();
> +	refcount_inc(&ctx->refcount);
>  }
> 
>  /**
> @@ -154,7 +153,7 @@ static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
>   */
>  static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
>  {
> -	if (atomic_dec_and_test(&ctx->refcount)) {
> +	if (refcount_dec_and_test(&ctx->refcount)) {
>  		VM_BUG_ON(spin_is_locked(&ctx->fault_pending_wqh.lock));
>  		VM_BUG_ON(waitqueue_active(&ctx->fault_pending_wqh));
>  		VM_BUG_ON(spin_is_locked(&ctx->fault_wqh.lock));
> @@ -686,7 +685,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
>  			return -ENOMEM;
>  		}
> 
> -		atomic_set(&ctx->refcount, 1);
> +		refcount_set(&ctx->refcount, 1);
>  		ctx->flags = octx->flags;
>  		ctx->state = UFFD_STATE_RUNNING;
>  		ctx->features = octx->features;
> @@ -1911,7 +1910,7 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
>  	if (!ctx)
>  		return -ENOMEM;
> 
> -	atomic_set(&ctx->refcount, 1);
> +	refcount_set(&ctx->refcount, 1);
>  	ctx->flags = flags;
>  	ctx->features = 0;
>  	ctx->state = UFFD_STATE_WAIT_API;
> -- 
> 2.19.1.930.g4563a0d9d0-goog
> 

-- 
Sincerely yours,
Mike.
