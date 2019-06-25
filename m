Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8BBDC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:24:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79C8E20883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:24:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79C8E20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mina86.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25FF26B0003; Tue, 25 Jun 2019 05:24:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EA7D8E0003; Tue, 25 Jun 2019 05:24:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B0A08E0002; Tue, 25 Jun 2019 05:24:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADF676B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 05:24:19 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so7652137wrn.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 02:24:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=IcI+Qwi0PZqqxfOd1WI+zyMYeKSE1MMDp3b/xqI3lJ8=;
        b=c+O/87+TP3z1l64j49n5Fb5IUEZJtWKF4tYVmaw0AXN7YXOkN2N67ae1tDEzc3EcLs
         A46vsBBRmykUDNRMzYoKcfWtJGtPPD59udPKQV1xrN/nbqHzE3sE78pt0Ovj0pAXGtg8
         wi+7+lCaG7bXh+ELZ/mnl7w4XkvuQR2jSg0kFKi/C3CcK0jEJJtjI8uACeLibuwbwebP
         saIPzpRYOtB95Z2TQtqIAqPhP/rovWkYwugQbRL2+UtxuW3wkJ85VCxP41ZTcbJulgL7
         s/oA7dmNQMq7y3Oqps40dJEUUtHT3iiqFvV3dCrSPEV//nqXRB0MOER6XHqqut4JDi5N
         rC2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mnazarewicz@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mnazarewicz@gmail.com
X-Gm-Message-State: APjAAAVfKunxNtgaGuhLNm779Ha8cMukAUEPIVErZrcxIcNVNn2spnP1
	KfgifbO5+VL42Jy5zIrjr7/3gOugaEWtQ16jjmqATOnR4vt1fvNEwu7iGjt0ohRPv8ePSTr7tD8
	tWPQX2k5OzE5uwIbj5rIT7BFfpKVMx5z/3K8XWAMqfjA3IIbS3q/OdE7rRisGebc=
X-Received: by 2002:a05:600c:20c3:: with SMTP id y3mr19755837wmm.3.1561454659316;
        Tue, 25 Jun 2019 02:24:19 -0700 (PDT)
X-Received: by 2002:a05:600c:20c3:: with SMTP id y3mr19755782wmm.3.1561454658392;
        Tue, 25 Jun 2019 02:24:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561454658; cv=none;
        d=google.com; s=arc-20160816;
        b=G6Rsyqt+yHXgt6lqHxzLAUaGGgdwtNLXv7zoadc+hQMIBlKcdOdD5OUZiovzwkRxww
         XqMbo05XTJ7tr6TG38G7DPWOLWeYZyThth0TXpPugvnvp4wxHOTaF8SYHpnclD7kogjp
         fQOSpx8y0P0ph+c02/e4ExHJ3T4KFjtXDG80FsB+zF41xuxoraKLykTiOsKsdgrDoiLT
         iNLD10L9ZbuDgHP8BS7vY4rOMwzCBr3a2k+khyetZf+c54L7udiVJRCITBcmX6lLL1Pn
         zQ9w/aN3pz3rsVuHzRMK2q+vDpKf5wjPMwswZQ7ghHyUuU2JrjpZFQX2KnfGTaMpdTD4
         xgVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=IcI+Qwi0PZqqxfOd1WI+zyMYeKSE1MMDp3b/xqI3lJ8=;
        b=fsKKCuDy45L68CuOY5w67Y6OzUPXxwo/CUmi7t0ljfwwaSb0LZJ+Hr/xSuUD0N/0zd
         FSfYpdEs4vyhX4QtgBFhVWSueD/dDm1/h2FskVuiMTds7EMgAUu/05ddlSx6Zo+lgXIV
         PMIvtDMW8eg51VzCAt0BP97VnWllG2JzqPrDTVpV9Xt7S9gY5wJ4d2o3O3gLIXERMlEP
         BzgE2F9qCLfg5LRC/FV2ovg/1Lvjh6dk2/eg43Xvm6kHf8gLaGY+mGpeFXE6D5bsvH+M
         ES32m+s963EHmxwgpXmUqcLrC37oMS8/4PMsKMsd9NOlSc0O9ktq24fIqqcb/Ik4saeA
         nXgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mnazarewicz@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mnazarewicz@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c64sor1184188wma.17.2019.06.25.02.24.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 02:24:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mnazarewicz@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mnazarewicz@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mnazarewicz@gmail.com
X-Google-Smtp-Source: APXvYqw8sRDWBKAQxpNo946SC1g7h3dvf2OsGboL0kSuUIRbkMHctG2STAN7kYumNWKB/FbuAqOHRQKNf/f1To9ZSHY=
X-Received: by 2002:a05:600c:c6:: with SMTP id u6mr19586296wmm.153.1561454657781;
 Tue, 25 Jun 2019 02:24:17 -0700 (PDT)
MIME-Version: 1.0
References: <1561422051-16142-1-git-send-email-opendmb@gmail.com>
In-Reply-To: <1561422051-16142-1-git-send-email-opendmb@gmail.com>
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Date: Tue, 25 Jun 2019 10:24:06 +0100
Message-ID: <CA+pa1O1Y8T9c-gD6qBteiNM4FCf6A2M-7o3vvCxMdR3hL7-+SA@mail.gmail.com>
Subject: Re: [PATCH] cma: fail if fixed declaration can't be honored
To: Doug Berger <opendmb@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Yue Hu <huyue2@yulong.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Laura Abbott <labbott@redhat.com>, Peng Fan <peng.fan@nxp.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Marek Szyprowski <m.szyprowski@samsung.com>, 
	Andrey Konovalov <andreyknvl@google.com>, linux-kernel@vger.kernel.org
Content-Type: multipart/alternative; boundary="00000000000035c743058c227e52"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000035c743058c227e52
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Jun 2019 at 01:22, Doug Berger <opendmb@gmail.com> wrote:

> The description of the cma_declare_contiguous() function indicates
> that if the 'fixed' argument is true the reserved contiguous area
> must be exactly at the address of the 'base' argument.
>
> However, the function currently allows the 'base', 'size', and
> 'limit' arguments to be silently adjusted to meet alignment
> constraints. This commit enforces the documented behavior through
> explicit checks that return an error if the region does not fit
> within a specified region.
>
> Fixes: 5ea3b1b2f8ad ("cma: add placement specifier for "cma=3D" kernel
> parameter")
> Signed-off-by: Doug Berger <opendmb@gmail.com>
>

Acked-by: Michal Nazarewicz <mina86@mina86.com>


> ---
>  mm/cma.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 3340ef34c154..4973d253dc83 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -278,6 +278,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
>          */
>         alignment =3D max(alignment,  (phys_addr_t)PAGE_SIZE <<
>                           max_t(unsigned long, MAX_ORDER - 1,
> pageblock_order));
> +       if (fixed && base & (alignment - 1)) {
> +               ret =3D -EINVAL;
> +               pr_err("Region at %pa must be aligned to %pa bytes\n",
> +                       &base, &alignment);
> +               goto err;
> +       }
>
        base =3D ALIGN(base, alignment);
>         size =3D ALIGN(size, alignment);
>         limit &=3D ~(alignment - 1);
> @@ -308,6 +314,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
>         if (limit =3D=3D 0 || limit > memblock_end)
>                 limit =3D memblock_end;
>
> +       if (base + size > limit) {
> +               ret =3D -EINVAL;
> +               pr_err("Size (%pa) of region at %pa exceeds limit (%pa)\n=
",
> +                       &size, &base, &limit);
> +               goto err;
> +       }
> +
>         /* Reserve memory */
>         if (fixed) {
>                 if (memblock_is_region_reserved(base, size) ||
> --
> 2.7.4
>
>

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--00000000000035c743058c227e52
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"g=
mail_attr">On Tue, 25 Jun 2019 at 01:22, Doug Berger &lt;<a href=3D"mailto:=
opendmb@gmail.com">opendmb@gmail.com</a>&gt; wrote:<br></div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid=
 rgb(204,204,204);padding-left:1ex">The description of the cma_declare_cont=
iguous() function indicates<br>
that if the &#39;fixed&#39; argument is true the reserved contiguous area<b=
r>
must be exactly at the address of the &#39;base&#39; argument.<br>
<br>
However, the function currently allows the &#39;base&#39;, &#39;size&#39;, =
and<br>
&#39;limit&#39; arguments to be silently adjusted to meet alignment<br>
constraints. This commit enforces the documented behavior through<br>
explicit checks that return an error if the region does not fit<br>
within a specified region.<br>
<br>
Fixes: 5ea3b1b2f8ad (&quot;cma: add placement specifier for &quot;cma=3D&qu=
ot; kernel parameter&quot;)<br>
Signed-off-by: Doug Berger &lt;<a href=3D"mailto:opendmb@gmail.com" target=
=3D"_blank">opendmb@gmail.com</a>&gt;<br>
</blockquote><div><br></div><div>Acked-by: Michal Nazarewicz &lt;<a href=3D=
"mailto:mina86@mina86.com">mina86@mina86.com</a>&gt;<br></div><div>=C2=A0</=
div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bor=
der-left:1px solid rgb(204,204,204);padding-left:1ex">---<br>
=C2=A0mm/cma.c | 13 +++++++++++++<br>
=C2=A01 file changed, 13 insertions(+)<br>
<br>
diff --git a/mm/cma.c b/mm/cma.c<br>
index 3340ef34c154..4973d253dc83 100644<br>
--- a/mm/cma.c<br>
+++ b/mm/cma.c<br>
@@ -278,6 +278,12 @@ int __init cma_declare_contiguous(phys_addr_t base,<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 alignment =3D max(alignment,=C2=A0 (phys_addr_t=
)PAGE_SIZE &lt;&lt;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 max_t(unsigned long, MAX_ORDER - 1, pageblock_order));<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (fixed &amp;&amp; base &amp; (alignment - 1)=
) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -EINVAL;<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;Region=
 at %pa must be aligned to %pa bytes\n&quot;,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&amp;base, &amp;alignment);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0} <br></blockquote><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex">
=C2=A0 =C2=A0 =C2=A0 =C2=A0 base =3D ALIGN(base, alignment);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D ALIGN(size, alignment);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 limit &amp;=3D ~(alignment - 1);<br>
@@ -308,6 +314,13 @@ int __init cma_declare_contiguous(phys_addr_t base,<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (limit =3D=3D 0 || limit &gt; memblock_end)<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 limit =3D memblock_=
end;<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (base + size &gt; limit) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -EINVAL;<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;Size (=
%pa) of region at %pa exceeds limit (%pa)\n&quot;,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&amp;size, &amp;base, &amp;limit);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Reserve memory */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (fixed) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (memblock_is_reg=
ion_reserved(base, size) ||<br>
-- <br>
2.7.4<br>
<br>
</blockquote></div><br clear=3D"all"><br>-- <br><div dir=3D"ltr" class=3D"g=
mail_signature">Best regards<br>=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=
=93=B6=F0=9D=93=B2=F0=9D=93=B7=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=
=83=AC=E3=83=B4=E3=82=A4=E3=83=84<br>=C2=ABIf at first you don=E2=80=99t su=
cceed, give up skydiving=C2=BB<br></div></div>

--00000000000035c743058c227e52--

