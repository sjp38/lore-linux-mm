Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9927C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:57:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF09208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:57:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="I+46Zffw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF09208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0237E6B000C; Fri,  7 Jun 2019 09:57:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFC06B000E; Fri,  7 Jun 2019 09:57:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB7FF6B0266; Fri,  7 Jun 2019 09:57:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFA8F6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 09:57:55 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l16so1633602qkk.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 06:57:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=17gadSvJGp+uvcoNC+FfcmshKqVGv1ZUwiPdnI82lOI=;
        b=UubGNozTnr5CaQph2Eix6d6qoOgoDqTy1JRmRQURCWiJNIZuxR5COQkWIha/bKlvpb
         eQrRgENURLkpWXDoYDghffPiQIbj7x97DtlMoStkCRDREQlKw5T7WS83o4Of5z6ddvHH
         KZlbZ0thCRbaEto6ePLya097brt4rRXOuzGdpYxll0Gs2uASAyHWFUPMHTX+czwFsQDA
         dtia/re9o9VT/A14EeMWpdtF1HE6fLb/SfU+XomGnd58QZ+sg3UNdOb+fodvqLLJ8igi
         jIO8fX0XJFRyTtUtMXOZMHXXvdN8r+xbmky4gimXwYCfcMAfqRif51gYWmhV/CxUlyDh
         Qx/A==
X-Gm-Message-State: APjAAAXpibUeXhVxh4TTomVlTHl0yrLIbaoWPJ/qKZQkzbqq0hHqAwUt
	trhf8pQHKWQycfzYTJLak01ZpS6L0Kmm2ZubNpZ6HSSULXxS0EO+muRU7OTfCtMwTlK7gUfx4q+
	oEyrwr2gKLp0TZnvexmV3C7d/dfkaIp4yw8Us9gkCl1aFqzQg+Qo9FgMYOzmv3o/jAQ==
X-Received: by 2002:a0c:baa7:: with SMTP id x39mr25270116qvf.100.1559915875496;
        Fri, 07 Jun 2019 06:57:55 -0700 (PDT)
X-Received: by 2002:a0c:baa7:: with SMTP id x39mr25270079qvf.100.1559915874899;
        Fri, 07 Jun 2019 06:57:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559915874; cv=none;
        d=google.com; s=arc-20160816;
        b=XIH1Kksmc4pfDjNyRxx/D88BvllT8AGEHoY1JJCyNs//DXLBpbt8T5GfOlsVlPL1R1
         TN6gWGYzaV0jmpbcY+KHNC9/hq7WZZ9OVjBEQo3DK31ulYvXOAzE0dxmrdSSESNbRy0U
         8ECgPkcCxfWn0zGs35zgBx2h9T4BZcroQJEFLJnenyluLNNjPlU1kQFXTlUGL1+NLemq
         c/QeVtg74ex1VPGuQpCIPuXVJdOqjPhu/3+sEDfIpU3ZRgsOdolmxWUqpajtyR6TKyuN
         +sUNM+sCEO5Q5UeoqEy9DPqrcISLz1uQmT/t2KR/Jk4QmI0CwGM9e9NNWCOFVXCtvL0B
         aQjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=17gadSvJGp+uvcoNC+FfcmshKqVGv1ZUwiPdnI82lOI=;
        b=UXgxm9Z2kYrYD/lmhcWVOBv95NsaUkuCLUwtRQ8jeGLXt9UQGbTvDCK50dpJk6+SVM
         aoslfKz483OKrZsbFtCwrf8sbi4Rz1QWLgG9HWyS8IaImIHhlxwkF29Sukvh81IsXgkW
         3hg+Om4ksDmLJmfJYO+1QhiB/Bc13fBW4gf8LGjMp6+LBpYBvI7dZqLMbFY6e85XvObT
         IYpac9vDoY5i0h2oLSoLSjLvKSRtXg6JEwt1tY3pe/n52HZylJNOpkyAE7E5jEKz572M
         bhaVpk0sY8mLSQQFmek/QLb0DWP2bCpz1wm2bn/I+j6wFIi+pgJe7YEJjyKkVuqSCCUd
         Ki9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=I+46Zffw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor1154938qkk.144.2019.06.07.06.57.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 06:57:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=I+46Zffw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=17gadSvJGp+uvcoNC+FfcmshKqVGv1ZUwiPdnI82lOI=;
        b=I+46Zffwelv3FY2kYKGzdobJ6uMmX8zCgsnvKiDTSkfI3HJBa+htk88VkGWM7NSZpi
         /0JCHDpAA7Hsoa4omW1wx1J85SCrH7dgr6RV0StdZtsaWrex1ZOuSIm+Zka617XPTGpN
         X1fcgiH+n0lyWRW1QagWvryyhg9XGrmKSd/F4IVorle0OcarTMiFrJd0Z3r6ZGdD+cmy
         VAiy5ECKzDJ4NQLEc4bwJAM+qICcpqA6QdhJ28xs1+NDe0kplypSuDdQRy0yFtY9sLB3
         MnA8Gv2LBIO0rwR5UIbYCFViG3FrLuek4drM6k3G4h9h5StmR/AX6O3RMQT8pEjmMpLr
         Yz8Q==
X-Google-Smtp-Source: APXvYqyXb3YGPBh3lIclsi3PYfUGbJ2uvWrtfDWhG41E8l5j7j4vV139lmCRlFT78OmA7F3xtrX4pg==
X-Received: by 2002:a37:bc03:: with SMTP id m3mr24773704qkf.199.1559915874559;
        Fri, 07 Jun 2019 06:57:54 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id w30sm1247493qtb.28.2019.06.07.06.57.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 06:57:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZFNR-0001xU-JJ; Fri, 07 Jun 2019 10:57:53 -0300
Date: Fri, 7 Jun 2019 10:57:53 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 08/11] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190607135753.GH14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-9-jgg@ziepe.ca>
 <88400de9-e1ae-509b-718f-c6b0f726b14c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <88400de9-e1ae-509b-718f-c6b0f726b14c@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 08:29:10PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > No other register/unregister kernel API attempts to provide this kind of
> > protection as it is inherently racy, so just drop it.
> > 
> > Callers should provide their own protection, it appears nouveau already
> > does, but just in case drop a debugging POISON.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> >  mm/hmm.c | 9 ++-------
> >  1 file changed, 2 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index c702cd72651b53..6802de7080d172 100644
> > +++ b/mm/hmm.c
> > @@ -284,18 +284,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
> >   */
> >  void hmm_mirror_unregister(struct hmm_mirror *mirror)
> >  {
> > -	struct hmm *hmm = READ_ONCE(mirror->hmm);
> > -
> > -	if (hmm == NULL)
> > -		return;
> > +	struct hmm *hmm = mirror->hmm;
> >  
> >  	down_write(&hmm->mirrors_sem);
> >  	list_del_init(&mirror->list);
> > -	/* To protect us against double unregister ... */
> > -	mirror->hmm = NULL;
> >  	up_write(&hmm->mirrors_sem);
> > -
> >  	hmm_put(hmm);
> > +	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
> 
> I hadn't thought of POISON_* for these types of cases, it's a 
> good technique to remember.
> 
> I noticed that this is now done outside of the lock, but that
> follows directly from your commit description, so that all looks 
> correct.

Yes, the thing about POISON is that if you ever read it then you have
found a use after free bug - thus we should never need to write it
under a lock (just after a serializing lock)

Normally I wouldn't bother as kfree does poison as well, but since we
can't easily audit the patches yet to be submitted this seems safer
and will reliably cause those patches to explode with an oops in
testing.

Thanks,
Jason

