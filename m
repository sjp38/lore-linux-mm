Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12189C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24E420868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:06:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IXRXXYLj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24E420868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459A06B0270; Fri,  7 Jun 2019 18:06:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 430B46B0271; Fri,  7 Jun 2019 18:06:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36D5F6B0272; Fri,  7 Jun 2019 18:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB0056B0270
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:06:24 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 9so379458ljv.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:06:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7UWYaKzZEtXuaxJwJzSC3OWehwEB/n9ql+PmX3iEbFc=;
        b=kzRiIn8aFeLTum5spLIQWYHKa291fvu4OOLeHZFordXyQLJjBR1lZFPnsJmXHsicNv
         2zB3aG6MFnp7mWc36lS3nxGfZisp4Nc9YDeT64M+DntajT2VsJfHGfhv3OanlorrI4tq
         /jHxfNPOEH4AkGgo4oJvqLpJVXSY5ZE73NdKIylPte2feWXoNW8vKzX8e9+3JnzTNqRg
         AigismHwatb61XI5u8WnQPTOEZHiC3IB6+QTmo6tGBpwLwGpW8TP3PYsxlNcD4I5syBi
         ialQUpqwQd5SITZhSFVVj3EuUk63ZXd4SQomJBEVh1Yls2+aHKHKMI8p8vfqBX9MGUTJ
         L66g==
X-Gm-Message-State: APjAAAUkIFKx6PdMbhRt4Cl7i7SBDIkNLFudLX+P7jV5lUrxVnzkvpvY
	a1iOiwemmspavmVNl7ihZd6sUcvLZXpexbYym0uG/ZmKJSpqirSYjq3vK1oCTu+0wTZZ77LG2V0
	XREGvLa8wj/PGEtd6y5MlOSXnwLd/nsSKo0CNawKe7VoKxk8ihmrvjniOjiX9390D3g==
X-Received: by 2002:ac2:4286:: with SMTP id m6mr29021908lfh.150.1559945184306;
        Fri, 07 Jun 2019 15:06:24 -0700 (PDT)
X-Received: by 2002:ac2:4286:: with SMTP id m6mr29021882lfh.150.1559945183338;
        Fri, 07 Jun 2019 15:06:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559945183; cv=none;
        d=google.com; s=arc-20160816;
        b=hs3I5sDh3no8SLHDxwsxccB/H3NUWNRsAfrtivVGGKXDA8cWbP6ekTmQ1hnSCaHbNt
         wGrZkQGROPXCNYv2yVXvmVrZfCI3HF3I1uz6g3SiXx3JRqRY38Pu+yiFEMCqYBwiAH6u
         Gs9awaBYHuxz62+nw7Hz/bwdGrX+aEPNFUn3Y3dnEAm4ivc3jQW3hG1Gi2V/E22VQhWt
         Ntu7pQRT2Ga8iNpzyeSssGYy5GYr/0cuQ4DYJspkgVU57ZDZDGWAZVRBKZictaKr7AeU
         Torx6eHjHKsQJ4Au4kROpzEuR4xbDqGXLjI9EUE/Akjg/v3s0KlsdR5XOZHTajYCGRg7
         8sDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7UWYaKzZEtXuaxJwJzSC3OWehwEB/n9ql+PmX3iEbFc=;
        b=MgC31E+HBAaykVoz8S9UiMlCqOmJ0UVwlcW7ggy8epdPgN7t5HTgE5kRxD0IX91JZB
         +GnyQwBdfOlBizNAECV7EG8YpLdgYpQCz/mACZtNo6MSf56O29Qtk1rUnJ6wxn3jDO4s
         DjNM740JB2JWZ9eVBAK8poE7jNmvPCcQ6nljvu/TS+Luy3HXkeCTgFyxnhP3M57Na3AT
         kGYBiAvsKxtZf2I893pEY++detHU+VPa/KzE23SM7pdzQgdWr0sVjQ9k4aDupwtcRcSu
         /HlY5nopUXiw8E9b+3uzB8O1qkCjFAcPPupEGpHCOA6cC1/AvS4Wss1uoUf70O5M4e+Q
         /dZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IXRXXYLj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7sor2050170ljj.40.2019.06.07.15.06.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 15:06:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IXRXXYLj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7UWYaKzZEtXuaxJwJzSC3OWehwEB/n9ql+PmX3iEbFc=;
        b=IXRXXYLjlXhkS7yvhzoYrp+YIYuNj8w+FKvrC2tbRiW0c/0o8dRW8aDCyUkwFWzE/z
         /YJtG4/7E6x8p7aeeTjHwUD+oOzcin26LtKwS/wxd0ElDf+AxtFBCcpbr3rFGlqL2QkO
         annY8RhMfQ/yEquJ2BJvQFemzB095m8iLIKkDZUB0xq71t8R9eVEu667+JgcYBTdImY+
         ubTPhYaxG8U+XvWiy1VeaxHA/JGMBDnE7er/xvmG9dGaM3hCKLub403mntSllA90kI0K
         yE/wisp+efrCTrhv8ade8ujVMfWOTLSWJqv6ftXcXNCZyqKsNqtBiWB4mj7QGdKBqH3H
         yZTQ==
X-Google-Smtp-Source: APXvYqwBeEPN7kLgMnERE0EV7XcHl9B9PjKXKhgkNCm9ydhdQJSENk3Qi8H9gBVf130eoY4SU8M3FQfw0DAJrGoOB1o=
X-Received: by 2002:a2e:a311:: with SMTP id l17mr8533284lje.214.1559945182726;
 Fri, 07 Jun 2019 15:06:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190606184438.31646-1-jgg@ziepe.ca> <20190606184438.31646-11-jgg@ziepe.ca>
In-Reply-To: <20190606184438.31646-11-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 03:41:27 +0530
Message-ID: <CAFqt6zafAR3fqvKCTCLmGNVfbSP80KqqR8cT0bUj4CW4scgxpQ@mail.gmail.com>
Subject: Re: [PATCH v2 hmm 10/11] mm/hmm: Do not use list*_rcu() for hmm->ranges
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, 
	Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 12:15 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> This list is always read and written while holding hmm->lock so there is
> no need for the confusing _rcu annotations.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c2fecb3ecb11e1..709d138dd49027 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -911,7 +911,7 @@ int hmm_range_register(struct hmm_range *range,
>         mutex_lock(&hmm->lock);
>
>         range->hmm =3D hmm;
> -       list_add_rcu(&range->list, &hmm->ranges);
> +       list_add(&range->list, &hmm->ranges);
>
>         /*
>          * If there are any concurrent notifiers we have to wait for them=
 for
> @@ -941,7 +941,7 @@ void hmm_range_unregister(struct hmm_range *range)
>                 return;
>
>         mutex_lock(&hmm->lock);
> -       list_del_rcu(&range->list);
> +       list_del(&range->list);
>         mutex_unlock(&hmm->lock);
>
>         /* Drop reference taken by hmm_range_register() */
> --
> 2.21.0
>

