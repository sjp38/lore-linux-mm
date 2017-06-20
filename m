Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78BA66B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:47:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u8so133199004pgo.11
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:47:24 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id e5si10224156pgf.449.2017.06.19.21.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 21:47:23 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id d5so20827050pfe.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:47:23 -0700 (PDT)
Date: Mon, 19 Jun 2017 21:47:21 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 22/23] usercopy: split user-controlled
 slabs to separate caches
Message-ID: <20170620044721.GE610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497915397-93805-23-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 19, 2017 at 04:36:36PM -0700, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> Some userspace APIs (e.g. ipc, seq_file) provide precise control over
> the size of kernel kmallocs, which provides a trivial way to perform
> heap overflow attacks where the attacker must control neighboring
> allocations of a specific size. Instead, move these APIs into their own
> cache so they cannot interfere with standard kmallocs. This is enabled
> with CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC.
> 
> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY_SLABS
> code in the last public patch of grsecurity/PaX based on my understanding
> of the code. Changes or omissions from the original code are mine and
> don't reflect the original grsecurity/PaX code.
> 
> Signed-off-by: David Windsor <dave@nullcore.net>
> [kees: added SLAB_NO_MERGE flag to allow split of future no-merge Kconfig]
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/seq_file.c        |  2 +-
>  include/linux/gfp.h  |  9 ++++++++-
>  include/linux/slab.h | 12 ++++++++++++
>  ipc/msgutil.c        |  5 +++--
>  mm/slab.h            |  3 ++-
>  mm/slab_common.c     | 29 ++++++++++++++++++++++++++++-
>  security/Kconfig     | 12 ++++++++++++
>  7 files changed, 66 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index dc7c2be963ed..5caa58a19bdc 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -25,7 +25,7 @@ static void seq_set_overflow(struct seq_file *m)
>  
>  static void *seq_buf_alloc(unsigned long size)
>  {
> -	return kvmalloc(size, GFP_KERNEL);
> +	return kvmalloc(size, GFP_KERNEL | GFP_USERCOPY);
>  }
>  

Also forgot to mention the obvious: there are way more places where GFP_USERCOPY
would need to be (or should be) used.  Helper functions like memdup_user() and
memdup_user_nul() would be the obvious ones.  And just a random example, some of
the keyrings syscalls (callable with no privileges) do a kmalloc() with
user-controlled contents and size.

So I think this by itself needs its own patch series.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
