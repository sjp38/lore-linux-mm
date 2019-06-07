Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8779C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC888208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WBAeb9Yr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC888208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B6D26B000A; Fri,  7 Jun 2019 15:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53FF06B000C; Fri,  7 Jun 2019 15:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42FA56B000E; Fri,  7 Jun 2019 15:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id D31EF6B000A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:33:34 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id u26so706112lfq.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:33:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gEQTt/69w62CAMJlx7lidr4JWqQ1JSVOKzZe9wzUYD0=;
        b=af/sH+CvPy7LgFp8JOALEe0jR3VY1/2wkw4N934FifnSdQfnCu6JojzrzkBCpb7PT6
         Hxq/vQ4rb2Fi/FDv4iZ/n8FSnSVY+NrlDNbEPm1F7JJqeBdMSl8qwimvpjIMdqxsUEkF
         mTpW27bWenioUFBVyub7riSHLowJ8Ugp6Rsicc+pIfOzX8404FjSF9renPfEhrtaZcvK
         2qprdnO5mbEwyBKxfXG7XWj6hLttEGSp6hsI752qMmc5Q+pwomxWRV/8o0vj0mRHwLP0
         Z/xvKcOdXv+f6S7OEpKwHOEccShgrmvVfdzn5KLHQrgDChBVYXmiDEQYXXBNHEoZiYDT
         tluA==
X-Gm-Message-State: APjAAAXNwIAHCrXVEC5mM8iv1ioyRxg/NdSMWuottBw8zy+b2BjawKvB
	TncXQXyY2oK7Sh5KR+ml3Bjv2sCAhg3xq9jcCI7cl2C6npU3kYVt0jyoJPTRJikYnyfPFxVt9Wm
	DENDaoM13NBmAyIw2lqUgtZVitDlknBJPLZ8J0jGEeZSAGlQlBJafMmnpsLZkws63gQ==
X-Received: by 2002:a2e:824c:: with SMTP id j12mr21080250ljh.53.1559936014274;
        Fri, 07 Jun 2019 12:33:34 -0700 (PDT)
X-Received: by 2002:a2e:824c:: with SMTP id j12mr21080234ljh.53.1559936013564;
        Fri, 07 Jun 2019 12:33:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559936013; cv=none;
        d=google.com; s=arc-20160816;
        b=f5I2otokGKv6XOxOglwQZCMljZAPL0WH7fzQDlRdH0sB7dKmSEIxET5mNGgcv2paHv
         RLWzc5BW3MXNls96slOPrSOhMCwQwsaZsfvqCO0lckPWveZqSQwhQK2uzLEavMXK65dU
         ZmMZZo6aRFPzabCX5oFdoKQW5w0VXY9JlmiqdFK+rSE5KmH05Pb1cChv5t8lToPLAnXO
         e3gjge0s32D2MEHz1NrnXgtexXZ24Zzjp9dU9/WbYGmKpKP9tzITD+Lxw/fpvwmGbYY2
         aMZNK5xVp6FFPEL7zP3PPKqJVJa14T87eUHo5yukEV0Slep9aMX8M9q15gbsNOaJkx7r
         XX1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gEQTt/69w62CAMJlx7lidr4JWqQ1JSVOKzZe9wzUYD0=;
        b=AvTJlabqiBKVix40FVMDmvRA/PfDwCKgjNqI3hC5OE5UtJD719S+q9EuZYgg/lAoV3
         vd4R49yui40yKZPHvqnM2ajtDsWkthGTSR7DutlgnBlSgsRkJ5GNrU70qOwouLrNef4U
         4ZAx47wnII2mzWdkg+yrrRyI1tDJtrsquDbWMN2GJyfYBB6l5ujXOxTWb+9K01D62Jg3
         6JV7EMijE0lKC0a5kIpec4u/X8C1qE05WUQZbRcdItklbe7a3MxPilsbxm/9ajiPAVC4
         1lmMCa5AKrig+pGQFOu3KWlumpcip+1B4gWKWiQniiKtsUx4VNpS74TfeRt0E8rQQdh4
         RZcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WBAeb9Yr;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor1857088ljw.32.2019.06.07.12.33.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:33:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WBAeb9Yr;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gEQTt/69w62CAMJlx7lidr4JWqQ1JSVOKzZe9wzUYD0=;
        b=WBAeb9YrKbAluVQu4nrMlV3okf6XsP120P+h1v7Rd4vr3vsnkTU4vgCpduY2YM5ezQ
         ZC8U/tNgH2EZA0xU6gYm6T8EHUBJFtOyB8pCUYpNHE0K2uu7cRS2HajdLzZVPGJNWmLP
         o5kn20ai9Nk6v1lhHpA15tdkXrTIPHbeu1KGol63jaJ85T1QmQKpgRq8dBfivro5TDq/
         0VVuFLvOpVZ30wfG4maqWRq7WEpWaiwNYozzr3KF2QYpm6e3SiLKwMCnouJNlEACXYDG
         /DhWUWfy9Gpre3kK/XzwNxujrgejdBj3ZDHJ4T5DTjCnGMOJBfhZFptCx2FUne4MeKwM
         KqOA==
X-Google-Smtp-Source: APXvYqyV5At9/bNoRANbxY42yFL3bcvziWxc6FqbPzzHMOEDWF48b73ld+sfmXEOlH6jYmy6qcg6bXlVtdgv8tNf/9Q=
X-Received: by 2002:a2e:8696:: with SMTP id l22mr5536229lji.201.1559936013206;
 Fri, 07 Jun 2019 12:33:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-10-jgg@ziepe.ca>
In-Reply-To: <20190523153436.19102-10-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 01:08:37 +0530
Message-ID: <CAFqt6zarGTZeA+Dw_RT2WXwgoYhnKP28LGfc+CDZqNFRexEXoQ@mail.gmail.com>
Subject: Re: [RFC PATCH 09/11] mm/hmm: Remove racy protection against double-unregistration
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> No other register/unregister kernel API attempts to provide this kind of
> protection as it is inherently racy, so just drop it.
>
> Callers should provide their own protection, it appears nouveau already
> does, but just in case drop a debugging POISON.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  mm/hmm.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 46872306f922bb..6c3b7398672c29 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -286,18 +286,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
>   */
>  void hmm_mirror_unregister(struct hmm_mirror *mirror)
>  {
> -       struct hmm *hmm = READ_ONCE(mirror->hmm);
> -
> -       if (hmm == NULL)
> -               return;
> +       struct hmm *hmm = mirror->hmm;

How about remove struct hmm *hmm and replace the code like below -

down_write(&mirror->hmm->mirrors_sem);
list_del_init(&mirror->list);
up_write(&mirror->hmm->mirrors_sem);
hmm_put(hmm);
memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));

Similar to hmm_mirror_register().


>         down_write(&hmm->mirrors_sem);
>         list_del_init(&mirror->list);
> -       /* To protect us against double unregister ... */
> -       mirror->hmm = NULL;
>         up_write(&hmm->mirrors_sem);
> -
>         hmm_put(hmm);
> +       memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
>  }
>  EXPORT_SYMBOL(hmm_mirror_unregister);
>
> --
> 2.21.0
>

