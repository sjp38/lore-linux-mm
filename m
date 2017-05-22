Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C934831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:03:20 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o5so91507442ith.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 07:03:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c5si17995453pga.119.2017.05.22.07.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 07:03:17 -0700 (PDT)
Date: Mon, 22 May 2017 07:03:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] LSM: Make security_hook_heads a local variable.
Message-ID: <20170522140306.GA3907@infradead.org>
References: <20170520085147.GA4619@kroah.com>
 <1495365245-3185-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495365245-3185-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, Greg KH <gregkh@linuxfoundation.org>, Igor Stoppa <igor.stoppa@huawei.com>, James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>

On Sun, May 21, 2017 at 08:14:05PM +0900, Tetsuo Handa wrote:
> A sealable memory allocator patch was proposed at
> http://lkml.kernel.org/r/20170519103811.2183-1-igor.stoppa@huawei.com ,
> and is waiting for a follow-on patch showing how any of the kernel
> can be changed to use this new subsystem. So, here it is for LSM hooks.
> 
> The LSM hooks ("struct security_hook_heads security_hook_heads" and
> "struct security_hook_list ...[]") will benefit from this allocator via
> protection using set_memory_ro()/set_memory_rw(), and it will remove
> CONFIG_SECURITY_WRITABLE_HOOKS config option.
> 
> This means that these structures will be allocated at run time using
> smalloc(), and therefore the address of these structures will be
> determined at run time rather than compile time.
> 
> But currently, LSM_HOOK_INIT() macro depends on the address of
> security_hook_heads being known at compile time. But we already
> initialize security_hook_heads as an array of "struct list_head".
> 
> Therefore, let's use index number (or relative offset from the head
> of security_hook_heads) instead of absolute address of
> security_hook_heads so that LSM_HOOK_INIT() macro does not need to
> know absolute address of security_hook_heads. Then, security_add_hooks()
> will be able to allocate and copy "struct security_hook_list ...[]" using
> smalloc().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Paul Moore <paul@paul-moore.com>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: Casey Schaufler <casey@schaufler-ca.com>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Igor Stoppa <igor.stoppa@huawei.com>
> Cc: Greg KH <gregkh@linuxfoundation.org>
> ---
>  include/linux/lsm_hooks.h |  6 +++---
>  security/security.c       | 10 ++++++++--
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index 080f34e..865c11d 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -1884,8 +1884,8 @@ struct security_hook_heads {
>   */
>  struct security_hook_list {
>  	struct list_head		list;
> -	struct list_head		*head;
>  	union security_list_options	hook;
> +	const unsigned int		idx;
>  	char				*lsm;
>  };
>  
> @@ -1896,9 +1896,9 @@ struct security_hook_list {
>   * text involved.
>   */
>  #define LSM_HOOK_INIT(HEAD, HOOK) \
> -	{ .head = &security_hook_heads.HEAD, .hook = { .HEAD = HOOK } }
> +	{ .idx = offsetof(struct security_hook_heads, HEAD) / \
> +		sizeof(struct list_head), .hook = { .HEAD = HOOK } }
>  
> -extern struct security_hook_heads security_hook_heads;
>  extern char *lsm_names;
>  
>  extern void security_add_hooks(struct security_hook_list *hooks, int count,
> diff --git a/security/security.c b/security/security.c
> index 54b1e39..d6883ce 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -33,7 +33,7 @@
>  /* Maximum number of letters for an LSM name string */
>  #define SECURITY_NAME_MAX	10
>  
> -struct security_hook_heads security_hook_heads __lsm_ro_after_init;
> +static struct security_hook_heads security_hook_heads __lsm_ro_after_init;
>  char *lsm_names;
>  /* Boot-time LSM user choice */
>  static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
> @@ -152,10 +152,16 @@ void __init security_add_hooks(struct security_hook_list *hooks, int count,
>  				char *lsm)
>  {
>  	int i;
> +	struct list_head *list = (struct list_head *) &security_hook_heads;

Eww, struct casts.  This whole security_hook_heads scheme stink,
even with the slight improvements from Tetsuo.  It has everything we
shouldn't do - function pointers in structures that are not hard
read-only, structure casts, etc.

What's the reason why can't just have good old const function tables?
Yeah, stackable LSM make that a little harder, but they should not be
enable by default anyway.  But even with those we can still chain
them together with a list with external linkage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
