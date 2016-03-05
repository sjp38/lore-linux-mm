Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2C88F6B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 19:48:17 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id d205so49012410oia.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 16:48:17 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id p187si4199885oih.10.2016.03.04.16.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 16:48:16 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id r187so48884456oih.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 16:48:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160305004624.12825.93210.stgit@dwillia2-desk3.jf.intel.com>
References: <20160305004624.12825.93210.stgit@dwillia2-desk3.jf.intel.com>
Date: Fri, 4 Mar 2016 16:48:16 -0800
Message-ID: <CAPcyv4gjxk3XYd3=kHgAqHGnsE2yWU4K=YWxkHC7_ORpHfKUPw@mail.gmail.com>
Subject: Re: [PATCH] nfit: Continue init even if ARS commands are unimplemented
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Haozhong Zhang <haozhong.zhang@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vishal Verma <vishal.l.verma@intel.com>

Andrew, sorry, ignore this, I fumble fingered a ^R in bash and sent
this.  I'm going to include this in a pull request to Linus.

On Fri, Mar 4, 2016 at 4:46 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> From: Vishal Verma <vishal.l.verma@intel.com>
>
> If firmware doesn't implement any of the ARS commands, take that to
> mean that ARS is unsupported, and continue to initialize regions without
> bad block lists. We cannot make the assumption that ARS commands will be
> unconditionally supported on all NVDIMMs.
>
> Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
> Acked-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
> Tested-by: Haozhong Zhang <haozhong.zhang@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/acpi/nfit.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/acpi/nfit.c b/drivers/acpi/nfit.c
> index fb53db187854..35947ac87644 100644
> --- a/drivers/acpi/nfit.c
> +++ b/drivers/acpi/nfit.c
> @@ -1590,14 +1590,21 @@ static int acpi_nfit_find_poison(struct acpi_nfit_desc *acpi_desc,
>         start = ndr_desc->res->start;
>         len = ndr_desc->res->end - ndr_desc->res->start + 1;
>
> +       /*
> +        * If ARS is unimplemented, unsupported, or if the 'Persistent Memory
> +        * Scrub' flag in extended status is not set, skip this but continue
> +        * initialization
> +        */
>         rc = ars_get_cap(nd_desc, ars_cap, start, len);
> +       if (rc == -ENOTTY) {
> +               dev_dbg(acpi_desc->dev,
> +                       "Address Range Scrub is not implemented, won't create an error list\n");
> +               rc = 0;
> +               goto out;
> +       }
>         if (rc)
>                 goto out;
>
> -       /*
> -        * If ARS is unsupported, or if the 'Persistent Memory Scrub' flag in
> -        * extended status is not set, skip this but continue initialization
> -        */
>         if ((ars_cap->status & 0xffff) ||
>                 !(ars_cap->status >> 16 & ND_ARS_PERSISTENT)) {
>                 dev_warn(acpi_desc->dev,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
