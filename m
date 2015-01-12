Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E6F946B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:11:12 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so32967043pdb.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:11:12 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com. [209.85.192.180])
        by mx.google.com with ESMTPS id ak2si25047064pad.85.2015.01.12.15.11.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 15:11:11 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id fl12so32912306pdb.11
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:11:10 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Mike Turquette <mturquette@linaro.org>
In-Reply-To: <1421054323-14430-4-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <1421054323-14430-4-git-send-email-a.hajda@samsung.com>
Message-ID: <20150112231104.20842.5239@quantum>
Subject: Re: [PATCH 3/5] clk: convert clock name allocations to kstrdup_const
Date: Mon, 12 Jan 2015 15:11:04 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>, linux-mm@kvack.org
Cc: "Andrzej Hajda <a.hajda@samsung.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org,
 andi@firstfloor.org, andi@lisas.de, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andrew Morton" <akpm@linux-foundation.org>, sboyd@codeaurora.org

Quoting Andrzej Hajda (2015-01-12 01:18:41)
> Clock subsystem frequently performs duplication of strings located
> in read-only memory section. Replacing kstrdup by kstrdup_const
> allows to avoid such operations.
> =

> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Looks OK to me. Is there an easy trick to measuring the number of string
duplications saved short of instrumenting your code with a counter?

Regards,
Mike

> ---
>  drivers/clk/clk.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> =

> diff --git a/drivers/clk/clk.c b/drivers/clk/clk.c
> index f4963b7..27e644a 100644
> --- a/drivers/clk/clk.c
> +++ b/drivers/clk/clk.c
> @@ -2048,7 +2048,7 @@ struct clk *clk_register(struct device *dev, struct=
 clk_hw *hw)
>                 goto fail_out;
>         }
>  =

> -       clk->name =3D kstrdup(hw->init->name, GFP_KERNEL);
> +       clk->name =3D kstrdup_const(hw->init->name, GFP_KERNEL);
>         if (!clk->name) {
>                 pr_err("%s: could not allocate clk->name\n", __func__);
>                 ret =3D -ENOMEM;
> @@ -2075,7 +2075,7 @@ struct clk *clk_register(struct device *dev, struct=
 clk_hw *hw)
>  =

>         /* copy each string name in case parent_names is __initdata */
>         for (i =3D 0; i < clk->num_parents; i++) {
> -               clk->parent_names[i] =3D kstrdup(hw->init->parent_names[i=
],
> +               clk->parent_names[i] =3D kstrdup_const(hw->init->parent_n=
ames[i],
>                                                 GFP_KERNEL);
>                 if (!clk->parent_names[i]) {
>                         pr_err("%s: could not copy parent_names\n", __fun=
c__);
> @@ -2090,10 +2090,10 @@ struct clk *clk_register(struct device *dev, stru=
ct clk_hw *hw)
>  =

>  fail_parent_names_copy:
>         while (--i >=3D 0)
> -               kfree(clk->parent_names[i]);
> +               kfree_const(clk->parent_names[i]);
>         kfree(clk->parent_names);
>  fail_parent_names:
> -       kfree(clk->name);
> +       kfree_const(clk->name);
>  fail_name:
>         kfree(clk);
>  fail_out:
> @@ -2112,10 +2112,10 @@ static void __clk_release(struct kref *ref)
>  =

>         kfree(clk->parents);
>         while (--i >=3D 0)
> -               kfree(clk->parent_names[i]);
> +               kfree_const(clk->parent_names[i]);
>  =

>         kfree(clk->parent_names);
> -       kfree(clk->name);
> +       kfree_const(clk->name);
>         kfree(clk);
>  }
>  =

> -- =

> 1.9.1
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
