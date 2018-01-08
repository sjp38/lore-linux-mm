Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 562C06B0261
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 14:35:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r85so13749034iod.11
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 11:35:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j193sor2007157itc.123.2018.01.08.11.35.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 11:35:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180102100320.24801-3-joeypabalinas@gmail.com>
References: <20180102100320.24801-1-joeypabalinas@gmail.com> <20180102100320.24801-3-joeypabalinas@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 8 Jan 2018 14:34:32 -0500
Message-ID: <CALZtOND_qRY1ctLRNVGP=xu01h+FieUTnKQ3xgf7c+r+tsAxPA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/zswap: move `zswap_has_pool` to front of `if ()`
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joey Pabalinas <joeypabalinas@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 2, 2018 at 5:03 AM, Joey Pabalinas <joeypabalinas@gmail.com> wrote:
> `zwap_has_pool` is a simple boolean, so it should be tested first
> to avoid unnecessarily calling `strcmp()`. Test `zswap_has_pool`
> first to take advantage of the short-circuiting behavior of && in
> `__zswap_param_set()`.
>
> Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>
>
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index a4f2dfaf9131694265..dbf35139471f692798 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -672,7 +672,7 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
>         }
>
>         /* no change required */
> -       if (!strcmp(s, *(char **)kp->arg) && zswap_has_pool)
> +       if (zswap_has_pool && !strcmp(s, *(char **)kp->arg))

Nak.

This function is only called when actually changing one of the zswap
module params, which is extremely rare (typically once per boot, per
parameter, if at all).  Changing the ordering will have virtually no
noticeable impact on anything.

Additionally, !zswap_has_pool is strictly an initialization-failed
temporary situation (until the compressor/zpool params are be set to
working implementation values), and in all "normal" conditions it will
be true, meaning this reordering will actually
*add* time - the normal path is for this check to *not* be true, so
keeping the strcmp first bypasses bothering with checking
zswap_has_pool.

>                 return 0;
>
>         /* if this is load-time (pre-init) param setting,
> --
> 2.15.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
