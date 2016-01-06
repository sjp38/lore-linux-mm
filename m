Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 966EC800C7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 19:15:36 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id to18so22654900igc.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:15:36 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id y79si41582186ioi.7.2016.01.05.16.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 16:15:36 -0800 (PST)
Received: by mail-io0-x236.google.com with SMTP id 1so156678932ion.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:15:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450755641-7856-8-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
	<1450755641-7856-8-git-send-email-laura@labbott.name>
Date: Tue, 5 Jan 2016 16:15:35 -0800
Message-ID: <CAGXu5jKZTg9jfg9CtXxjDOO_DDBW=c5iyLtkfJr7zAqzxWgQ4Q@mail.gmail.com>
Subject: Re: [RFC][PATCH 7/7] lkdtm: Add READ_AFTER_FREE test
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <laura@labbott.name>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Dec 21, 2015 at 7:40 PM, Laura Abbott <laura@labbott.name> wrote:
>
> In a similar manner to WRITE_AFTER_FREE, add a READ_AFTER_FREE
> test to test free poisoning features. Sample output when
> no poison is present:
>
> [   20.222501] lkdtm: Performing direct entry READ_AFTER_FREE
> [   20.226163] lkdtm: Freed val: 12345678
>
> with poison:
>
> [   24.203748] lkdtm: Performing direct entry READ_AFTER_FREE
> [   24.207261] general protection fault: 0000 [#1] SMP
> [   24.208193] Modules linked in:
> [   24.208193] CPU: 0 PID: 866 Comm: sh Not tainted 4.4.0-rc5-work+ #108
>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Laura Abbott <laura@labbott.name>
> ---
>  drivers/misc/lkdtm.c | 29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
>
> diff --git a/drivers/misc/lkdtm.c b/drivers/misc/lkdtm.c
> index 11fdadc..c641fb7 100644
> --- a/drivers/misc/lkdtm.c
> +++ b/drivers/misc/lkdtm.c
> @@ -92,6 +92,7 @@ enum ctype {
>         CT_UNALIGNED_LOAD_STORE_WRITE,
>         CT_OVERWRITE_ALLOCATION,
>         CT_WRITE_AFTER_FREE,
> +       CT_READ_AFTER_FREE,
>         CT_SOFTLOCKUP,
>         CT_HARDLOCKUP,
>         CT_SPINLOCKUP,
> @@ -129,6 +130,7 @@ static char* cp_type[] = {
>         "UNALIGNED_LOAD_STORE_WRITE",
>         "OVERWRITE_ALLOCATION",
>         "WRITE_AFTER_FREE",
> +       "READ_AFTER_FREE",
>         "SOFTLOCKUP",
>         "HARDLOCKUP",
>         "SPINLOCKUP",
> @@ -417,6 +419,33 @@ static void lkdtm_do_action(enum ctype which)
>                 memset(data, 0x78, len);
>                 break;
>         }
> +       case CT_READ_AFTER_FREE: {
> +               int **base;
> +               int *val, *tmp;
> +
> +               base = kmalloc(1024, GFP_KERNEL);
> +               if (!base)
> +                       return;
> +
> +               val = kmalloc(1024, GFP_KERNEL);
> +               if (!val)
> +                       return;

For both of these test failure return, I think there should be a
pr_warn too (see CT_EXEC_USERSPACE).

> +
> +               *val = 0x12345678;
> +
> +               /*
> +                * Don't just use the first entry since that's where the
> +                * freelist goes for the slab allocator
> +                */
> +               base[1] = val;

Maybe just aim at the middle, in case allocator freelist tracking ever
grows? base[1024/sizeof(int)/2] or something?

> +               kfree(base);
> +
> +               tmp = base[1];
> +               pr_info("Freed val: %x\n", *tmp);

Instead of depending on the deref to fail, maybe just use a simple
BUG_ON to test that the value did actually change? Or, change the
pr_info to "Failed to Oops when reading freed value: ..." just to be
slightly more verbose about what failed?

> +
> +               kfree(val);
> +               break;
> +       }
>         case CT_SOFTLOCKUP:
>                 preempt_disable();
>                 for (;;)
> --
> 2.5.0
>

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
