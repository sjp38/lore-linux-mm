Date: Thu, 16 Oct 2008 15:48:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [garloff@suse.de: [PATCH 1/1] default mlock limit 32k->64k]
Message-Id: <20081016154816.c53a6f8e.akpm@linux-foundation.org>
In-Reply-To: <20081016074319.GD5286@tpkurt2.garloff.de>
References: <20081016074319.GD5286@tpkurt2.garloff.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kurt Garloff <garloff@suse.de>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, NPiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008 09:43:19 +0200
Kurt Garloff <garloff@suse.de> wrote:

> By default, non-privileged tasks can only mlock() a small amount of
> memory to avoid a DoS attack by ordinary users. The Linux kernel
> defaulted to 32k (on a 4k page size system) to accommodate the
> needs of gpg.
> However, newer gpg2 needs 64k in various circumstances and otherwise
> fails miserably, see bnc#329675.
> 
> Change the default to 64k, and make it more agnostic to PAGE_SIZE.
> 
> Signed-off-by: Kurt Garloff <garloff@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6.27/include/linux/resource.h
> ===================================================================
> --- linux-2.6.27.orig/include/linux/resource.h
> +++ linux-2.6.27/include/linux/resource.h
> @@ -59,10 +59,10 @@ struct rlimit {
>  #define _STK_LIM	(8*1024*1024)
>  
>  /*
> - * GPG wants 32kB of mlocked memory, to make sure pass phrases
> + * GPG2 wants 64kB of mlocked memory, to make sure pass phrases
>   * and other sensitive information are never written to disk.
>   */
> -#define MLOCK_LIMIT	(8 * PAGE_SIZE)
> +#define MLOCK_LIMIT	((PAGE_SIZE > 64*1024) ? PAGE_SIZE : 64*1024)

I dunno.  Is there really much point in chasing userspace changes like
this?

Worst case, we end up releasing distributions which work properly on
newer kernels and which fail to work properly on older kernels.

I suspect that it would be better to set the default to zero and
*force* userspace to correctly tune whatever-kernel-they're-running-on
to match their requirements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
