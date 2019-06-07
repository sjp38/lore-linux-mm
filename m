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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FFDEC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C57B520868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:50:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YCUY4mO4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C57B520868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583406B000E; Fri,  7 Jun 2019 15:50:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50D246B0266; Fri,  7 Jun 2019 15:50:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FC686B0269; Fri,  7 Jun 2019 15:50:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC3EC6B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:50:32 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id c201so715192lfg.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:50:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L4/BQvJwRH8pzYfkzs4GJ1WfF93VEGjPp4jeBLqlphY=;
        b=lqk4Lermr/YA7MDr2e7JZBzJS3xhK665UJ78cIQ5GPmd7K2+ltDrdWlTe8hj1Zdc0W
         eJnX/VlBGMlrsxhVBloQoBZZBflotJVf6mZedqZ0S+vy50KRPTcIiBqr4Vnls3mKjAhs
         2myw5PbW648ArQ4wLiSp4owB9G3ESdbozZuBP3lteRR4/L8xb40DyEICgODZj6sMrlKD
         ISpsGQCZo1/XzSKKDcFg1hTkNgFM2NPabCcxUb21QlGJx24MJC3B5RbW7ehlQe13ZqU6
         EN8f60K8Vae9cpn2dmbjgofEwtuLxvoGnZo8JFoGbOyvlPRHZ+J0PPaRwwSVuTA2On6i
         94xQ==
X-Gm-Message-State: APjAAAU+Fh+8P9l1kcUhzsvfF6H4mqmQGq2QoHLzCWO205871UMcteMi
	Ygnk89pZUGyv8XRGVFiAlATkUF1f3Qd2fTmgpEXUaqh9bwr6aAOaqMzrd1HOAtAaUhg7Qs4NuG8
	LTb32lmXp97F/IJ/JdAN6NIlHwqYS+DWKoxu2Dc88rMJ0/ryvuK8cTiG54v/aRulC4Q==
X-Received: by 2002:ac2:597c:: with SMTP id h28mr3804004lfp.90.1559937032294;
        Fri, 07 Jun 2019 12:50:32 -0700 (PDT)
X-Received: by 2002:ac2:597c:: with SMTP id h28mr3803977lfp.90.1559937031488;
        Fri, 07 Jun 2019 12:50:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937031; cv=none;
        d=google.com; s=arc-20160816;
        b=x9heQfB/XAaiUqnXZfXjvSeVBoyo/PyVcliZwpk6mhbFueYwxXSusTJy+3LOYqjzGg
         Hb9IJhRHUJmwD3ZskItA3xLLX79K2C4TRhjghk6b/5KSUrbchW3UrlLWCdbTlNE9i97t
         AArbJNyFl7Kq+zzvzIRjTOy6OtFwM7G/Mjfk+xD5Qe3umLDccMY/50rVfx4vDij57H7q
         eBwnFuUy4lSQUqDkcITe1B812+ZBeQnTmpszBkJZG/G6d5iBL09gHyffKSE1l/QKXCoc
         MnMu5zYwQ5Ac1HRB9mIRhtTIKJxwiz3bR2pSt6yXSUXXvcyV2ybyrk6OI/Lv9m4QfzZx
         iz8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L4/BQvJwRH8pzYfkzs4GJ1WfF93VEGjPp4jeBLqlphY=;
        b=aSlQ2LLwDnq6SquKbuR+TbJCj7Lj/37jRif0KtaF6rW+0d7vxOqxgI5QvmWTnPAw9Y
         qDfYXjSGnxtqzq+22k1h45t3Tx3zCYwx3d6LgcxWd4mrv4Q6umTaItyeNgcBbnRJSd8x
         hNrKOwjsZpUN2ADGdlSI2kH1wVSPkOjjgt73ruF9ZCFXThXJ/96zn1QX78PjvRegTCeF
         G9/i4oPmiiIKUmir4h34bNUkE2+8O9tLPs4bM7sgydmmMrOgSLHrrUElx1g3FgzKBXxY
         elKL14aoKAHHFKo8ELLxQHKF4DdhTJVn7KY9zS8Vq39r0Bd2Enciyay4/uHsIpuLmFn2
         4KWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YCUY4mO4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e5sor1898106ljj.29.2019.06.07.12.50.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:50:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YCUY4mO4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L4/BQvJwRH8pzYfkzs4GJ1WfF93VEGjPp4jeBLqlphY=;
        b=YCUY4mO48TpdXn4RiwPHgCrMGugdvwDHB8vyFdr/XROShWBDsWdsngRPoLfJD9TPR6
         IslwjkUAlLZPxElG6sFIGiVn1uv3FRFGVyRaFXPMK5vmCt1W40kS47ohKbJ/jiKGG2gD
         8xIuMivNI+7pZ0OMS0ULxhKEDTfL4NJS7PagdqHIAfmkR8n1pXPYeMBFwpCpmIoVjfd8
         Df2lK+rDqvVayMAoPzfdoqP8M4+AH53wN1R8WDXlrurqH/S8CqYCCePsYhJEnE5bNzH7
         ztKCZIFRg4gjihqAxZ1NPDjn8QRL6/fHYc3lwedsD8Tc5vVDKVwvGnvWkc7kmFNHUG2y
         cYlQ==
X-Google-Smtp-Source: APXvYqz1LzcnbHycWMD3GBKCgKDEZGlCDEysdeWvZ+1mAaMPH6qe+E+wW/6XfWmxUHzeQMloiPf8k1Da89PWu7bXKPA=
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr13678555lja.207.1559937031060;
 Fri, 07 Jun 2019 12:50:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-10-jgg@ziepe.ca>
 <CAFqt6zarGTZeA+Dw_RT2WXwgoYhnKP28LGfc+CDZqNFRexEXoQ@mail.gmail.com> <20190607193722.GS14802@ziepe.ca>
In-Reply-To: <20190607193722.GS14802@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 01:25:35 +0530
Message-ID: <CAFqt6zbUjFLXWch5jEx5OaC8ag27nBoHKGF5VXtCbvGcPbJ=Aw@mail.gmail.com>
Subject: Re: [RFC PATCH 09/11] mm/hmm: Remove racy protection against double-unregistration
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 8, 2019 at 1:07 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Sat, Jun 08, 2019 at 01:08:37AM +0530, Souptick Joarder wrote:
> > On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > From: Jason Gunthorpe <jgg@mellanox.com>
> > >
> > > No other register/unregister kernel API attempts to provide this kind of
> > > protection as it is inherently racy, so just drop it.
> > >
> > > Callers should provide their own protection, it appears nouveau already
> > > does, but just in case drop a debugging POISON.
> > >
> > > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > >  mm/hmm.c | 9 ++-------
> > >  1 file changed, 2 insertions(+), 7 deletions(-)
> > >
> > > diff --git a/mm/hmm.c b/mm/hmm.c
> > > index 46872306f922bb..6c3b7398672c29 100644
> > > +++ b/mm/hmm.c
> > > @@ -286,18 +286,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
> > >   */
> > >  void hmm_mirror_unregister(struct hmm_mirror *mirror)
> > >  {
> > > -       struct hmm *hmm = READ_ONCE(mirror->hmm);
> > > -
> > > -       if (hmm == NULL)
> > > -               return;
> > > +       struct hmm *hmm = mirror->hmm;
> >
> > How about remove struct hmm *hmm and replace the code like below -
> >
> > down_write(&mirror->hmm->mirrors_sem);
> > list_del_init(&mirror->list);
> > up_write(&mirror->hmm->mirrors_sem);
> > hmm_put(hmm);
> > memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
> >
> > Similar to hmm_mirror_register().
>
> I think we get there in patch 10, right?

No, Patch 10 of this series has modified hmm_range_unregister().
>
> When the series is all done the function looks like this:
>
> void hmm_mirror_unregister(struct hmm_mirror *mirror)
> {
>         struct hmm *hmm = mirror->hmm;
>
>         down_write(&hmm->mirrors_sem);
>         list_del(&mirror->list);
>         up_write(&hmm->mirrors_sem);
>         hmm_put(hmm);
>         memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
> }
>
> I think this mostly matches what you wrote above, or do you think we
> should s/hmm/mirror->hmm/ anyhow? I think Ralph just added that :)

I prefer, s/hmm/mirror->hmm and remove struct hmm *hmm :)

