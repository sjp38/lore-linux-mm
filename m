Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CFABC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF573206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:43:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a/bVu7m7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF573206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48CD86B0006; Mon, 15 Jul 2019 14:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 416856B0007; Mon, 15 Jul 2019 14:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DDB96B0008; Mon, 15 Jul 2019 14:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD3B66B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:43:29 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id w17so1391018lff.15
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:43:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=f6Dq0pTLLk6Oz2CYrqTE6G1SQRdL9xa13WkscrhabFI=;
        b=dvRfByHOJcu7nPImGKWjFsy3gz33SrBjXPMhsxmhgRs31mIRdk6TxR5iwbHNW8b/lg
         kPE5klFS4f4i5ANN4cRMwMDPDFuKP+2/fYuufJhquKnb+WC7IeyatU/Ilz6ABaW6HYPy
         ZC+6YyKEFwJavHn10bJlThh2Tm547uPFHGm1elXz4seLPOxgupKxkmcs1lHDO6ylUoSO
         o2COE6VQMvTiL24jjewE9OqA5sQ5BwMo3Z+JPX6+mA/WQvMfyFN9PiCEhBEk4ZntqjD/
         3NSpSb8Cj6Mv+qA/LFZor+lwyw7miFHvP6o6YJisWIkNX7KrsoPZmz0KLAQzzqC4DOor
         SYFw==
X-Gm-Message-State: APjAAAVio853pkGnpvnl/Yjegg0bBFIxuZ+PnBUhvhXcOKsxXuezhx7m
	Bvgmo27T9TuH4dPbnvy4G+U48+5aagQfPvqcr8rtpgIEUPbRUNkA6M+B1hnZFsnedLKejZCeia3
	MMz/oPzHIL4QdrGgLKbvobpCoWkuIg/4/lX/3mnb7L/RaXsBCGlzT9bmgVH0CaKFXXQ==
X-Received: by 2002:ac2:4d02:: with SMTP id r2mr11863390lfi.138.1563216208705;
        Mon, 15 Jul 2019 11:43:28 -0700 (PDT)
X-Received: by 2002:ac2:4d02:: with SMTP id r2mr11863366lfi.138.1563216207829;
        Mon, 15 Jul 2019 11:43:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563216207; cv=none;
        d=google.com; s=arc-20160816;
        b=bjOsE+4BEqvxV7sOVVPWnw91nrXVJbgR4OpV4iRE0c2CpMSg+2/wEPaE6hLtTdXjQw
         t4cx5xAK0Epx9bzjMyf0EHFtB5wrZgsb9gWE53+Bqwr5UU5EA6JMWEIAxUr8Hisk9R4e
         Olzvu3tQYJet7eqBmXtVNjod94Pwsd4aMMBcq2C5fKMY5lNq7qWQhQWUUa+vN/Sg8+Mm
         4PF4/49UMme/Q3KnTxlt0tsqmtPBU3dF+WQOc/Km3Y+umDfecgn5TDZZkyC5IouyWCIz
         qrpj9lpL1yVWa3Lrh2A5TNzV0EYr3uoAjlPNnQ4C0dkpyodd1Jz+rNVFi+IoaKE3Oz5P
         1Hlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=f6Dq0pTLLk6Oz2CYrqTE6G1SQRdL9xa13WkscrhabFI=;
        b=t3EwFz+tD+a2MlBKmHl7qDRITJT3aZqKxL5/bQO1/4EcINXxMgs9YnVAAStkwtXDWe
         xSRPSHJhUH7etU1o3KlykP6MCYOdjDNPFH9XAjQ04z7npv//kA3bTjfNDFpGPFewBfnl
         xqJWurr6BK4KR2YXKml+tXKlHoQnNwb41JtdkXYc8+KJ/MzV1i6f7V7BBMxLlkeiwyBv
         Py6NaEEkf8Zxb0lIMqmL6WqzQWCQX13Dt9vzRLCNUiTZ2q/IZEsOuxa0i3CczZPYTIV4
         e7RdB4CvZBtDtchiYA/MXBnJfWMaSf7s2owsFSmO65XoR2yn4ZEl1pg/qWl2D+qtQtMy
         YK2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="a/bVu7m7";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f28sor4450410lfh.62.2019.07.15.11.43.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 11:43:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="a/bVu7m7";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=f6Dq0pTLLk6Oz2CYrqTE6G1SQRdL9xa13WkscrhabFI=;
        b=a/bVu7m7UHAVj4cc+QtM3A6vTokk5U2CSBPJ33X6UhNJHf9vZZ5S4zAb5E87J8BMn8
         nePLNS6y7GZxZqXIc6JKOpKdMj3MYBcyyFyi5/D7QdwAdPG7RxLcYMz/hShGcPzODCxk
         ubX2Vpd8FNMjN9IR+cSLjJZaCN764URNo1NKTZTgOmo6qH6gSUiB6ISN97sj/Ne9fbKM
         4OjllP4ic41kllorCPwz3IK9VDWRnFmMfrJ/Jc8AnK12YwK9m8bAjuGAenqfl9wLvXK5
         IxhCKLzxe//wSkbdss/AhN8fqg8VBO9VU79P+MkeF3baGp+2/F8FU3/0SqG+xrV0fnd5
         KUng==
X-Google-Smtp-Source: APXvYqwnhUazbciJKuRQa/n8SKi2BPZXX12LT56mhDF4CJ4tLoMGtsgJIQ7+NrC/BFwBJiEcUrf+Tfr2+3DHbU8t8cg=
X-Received: by 2002:ac2:5a01:: with SMTP id q1mr12462761lfn.46.1563216207468;
 Mon, 15 Jul 2019 11:43:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190715164705.220693-1-henryburns@google.com>
In-Reply-To: <20190715164705.220693-1-henryburns@google.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 15 Jul 2019 20:43:15 +0200
Message-ID: <CAMJBoFMS2BiCdBFBEGE_p5fovDphGqjDjaBYnfGFWhNvCnAvdQ@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Reinitialize zhdr structs after migration
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: multipart/alternative; boundary="000000000000c0e091058dbca2f6"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000c0e091058dbca2f6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Den m=C3=A5n 15 juli 2019 6:47 emHenry Burns <henryburns@google.com> skrev:

> z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
> However, zhdr contains fields that can't be directly coppied over (ex:
> list_head, a circular linked list). We only need to initialize the
> linked lists in new_zhdr, as z3fold_isolate_page() already ensures
> that these lists are empty.
>
> Additionally it is possible that zhdr->work has been placed in a
> workqueue. In this case we shouldn't migrate the page, as zhdr->work
> references zhdr as opposed to new_zhdr.
>
> Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
> Signed-off-by: Henry Burns <henryburns@google.com>
> ---
>  mm/z3fold.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 42ef9955117c..9da471bcab93 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct
> address_space *mapping, struct page *newpa
>                 z3fold_page_unlock(zhdr);
>                 return -EBUSY;
>         }
> +       if (work_pending(&zhdr->work)) {
> +               z3fold_page_unlock(zhdr);
> +               return -EAGAIN;
> +       }
>         new_zhdr =3D page_address(newpage);
>         memcpy(new_zhdr, zhdr, PAGE_SIZE);
>         newpage->private =3D page->private;
>         page->private =3D 0;
>         z3fold_page_unlock(zhdr);
>         spin_lock_init(&new_zhdr->page_lock);
> +       INIT_WORK(&new_zhdr->work, compact_page_work);
> +       /*
> +        * z3fold_page_isolate() ensures that this list is empty, so we
> only
> +        * have to reinitialize it.
> +        */
>

On the nitpicking side, we seem to have ensured that directly in migrate :)
Looks OK to me otherwise.

~Vitaly

+       INIT_LIST_HEAD(&new_zhdr->buddy);
>         new_mapping =3D page_mapping(page);
>         __ClearPageMovable(page);
>         ClearPagePrivate(page);
> --
> 2.22.0.510.g264f2c817a-goog
>
>

--000000000000c0e091058dbca2f6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" =
class=3D"gmail_attr">Den m=C3=A5n 15 juli 2019 6:47 emHenry Burns &lt;<a hr=
ef=3D"mailto:henryburns@google.com">henryburns@google.com</a>&gt; skrev:<br=
></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex">z3fold_page_migration() calls memcpy(=
new_zhdr, zhdr, PAGE_SIZE).<br>
However, zhdr contains fields that can&#39;t be directly coppied over (ex:<=
br>
list_head, a circular linked list). We only need to initialize the<br>
linked lists in new_zhdr, as z3fold_isolate_page() already ensures<br>
that these lists are empty.<br>
<br>
Additionally it is possible that zhdr-&gt;work has been placed in a<br>
workqueue. In this case we shouldn&#39;t migrate the page, as zhdr-&gt;work=
<br>
references zhdr as opposed to new_zhdr.<br>
<br>
Fixes: bba4c5f96ce4 (&quot;mm/z3fold.c: support page migration&quot;)<br>
Signed-off-by: Henry Burns &lt;<a href=3D"mailto:henryburns@google.com" tar=
get=3D"_blank" rel=3D"noreferrer">henryburns@google.com</a>&gt;<br>
---<br>
=C2=A0mm/z3fold.c | 10 ++++++++++<br>
=C2=A01 file changed, 10 insertions(+)<br>
<br>
diff --git a/mm/z3fold.c b/mm/z3fold.c<br>
index 42ef9955117c..9da471bcab93 100644<br>
--- a/mm/z3fold.c<br>
+++ b/mm/z3fold.c<br>
@@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct address_space=
 *mapping, struct page *newpa<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 z3fold_page_unlock(=
zhdr);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBUSY;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (work_pending(&amp;zhdr-&gt;work)) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0z3fold_page_unlock(=
zhdr);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EAGAIN;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 new_zhdr =3D page_address(newpage);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(new_zhdr, zhdr, PAGE_SIZE);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 newpage-&gt;private =3D page-&gt;private;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 page-&gt;private =3D 0;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 z3fold_page_unlock(zhdr);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&amp;new_zhdr-&gt;page_lock);<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_WORK(&amp;new_zhdr-&gt;work, compact_page_=
work);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * z3fold_page_isolate() ensures that this list=
 is empty, so we only<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * have to reinitialize it.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br></blockquote></div></div><div dir=3D"aut=
o"><br></div><div dir=3D"auto">On the nitpicking side, we seem to have ensu=
red that directly in migrate :) Looks OK to me otherwise.=C2=A0</div><div d=
ir=3D"auto"><br></div><div dir=3D"auto">~Vitaly=C2=A0</div><div dir=3D"auto=
"><br></div><div dir=3D"auto"><div class=3D"gmail_quote"><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&amp;new_zhdr-&gt;buddy);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 new_mapping =3D page_mapping(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __ClearPageMovable(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ClearPagePrivate(page);<br>
-- <br>
2.22.0.510.g264f2c817a-goog<br>
<br>
</blockquote></div></div></div>

--000000000000c0e091058dbca2f6--

