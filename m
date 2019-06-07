Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B672C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFBD320868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="jmx3ZNaL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFBD320868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7141E6B000E; Fri,  7 Jun 2019 15:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C5A16B0266; Fri,  7 Jun 2019 15:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B46B6B0269; Fri,  7 Jun 2019 15:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 405A66B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:37:26 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so2501240qke.0
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:37:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/AFA6heE9oFOy80aylD9Y4/+SplGswIERTbj+0KxLSo=;
        b=rLIIib218vZv/mu6JULRRVEhsco6WHauhMUMfEUMt5FX7dndx/twBxKa9mVZ4hD9H5
         9sbzyCeZeVyEmMUO9NG6HjAWCmaf3zWF5FaiCV69TmNhhNszEV3++GR4yclBUxEspHjg
         ICctLl2ds5v+qR8eLhGftHbUopSdqSSfXaQkGaq1gaAxHf9tST0jJH9JAtssNiNyDWW8
         yguzvum3myi1BoYQi5nqQj4uOPfbBtPbo9JfnvuUmgx8sNzSwM4NsQhBgkYyX2ao/YDF
         UmNDUvIqzC9IUMh/3k4c/uf9ooYLPObGzYi3WfE0ABRRCLZo+fKOc0y9RaLYwpi9b8X2
         9OLw==
X-Gm-Message-State: APjAAAVO7yh1lJnFWVD6mHVnI17Ou+ZxjtDUj97IxfBAALCk+SYwPDi5
	BHQUTYpcwp1B95rsANMhNq2rjRucDmxMZzy1N1hrBvFHj/7kUOWj+BLGThpvXz88qTcHJ1PecKB
	v46IG/WOwp9k5pSZeKZ0pPWaFwXRMPGgD8z46pDh0tmfb5ghN7m+VGGXO6QkpnP+bMQ==
X-Received: by 2002:a0c:b04d:: with SMTP id l13mr45642020qvc.104.1559936245774;
        Fri, 07 Jun 2019 12:37:25 -0700 (PDT)
X-Received: by 2002:a0c:b04d:: with SMTP id l13mr45641893qvc.104.1559936243769;
        Fri, 07 Jun 2019 12:37:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559936243; cv=none;
        d=google.com; s=arc-20160816;
        b=0vgnraubXQgxky2RkR07N1IzvFWcnUsZUMChqUG4GIs5E4sWpRDh+jOUc8zuAUYpk9
         UEwE3oQ+edsG3eG5i52dXZLffJHgMcTV57av4hEqVYxvnrq1qbBRG/MGpTB2OKAL6zOq
         OOIBMP/bcqSOQK2lyAJG9TCFzevKA3n4fIiRlXITCx64acG3WvZ/UAze/CGs92xAUU5e
         BRcswJTgK1ZzO77xhiC/46j9FGf7k5hj0+WS40iwYgFCkGLbdOoojV3sMTLCnxtAWWZP
         +ZJjkbot9ALZmWNoI+XkljkbKnPd3LqGe8hBg7xXVx9zgdKHFkE7Bf0CB38+C1gHH40n
         o+kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/AFA6heE9oFOy80aylD9Y4/+SplGswIERTbj+0KxLSo=;
        b=Nhtj8rJZNgEvonincByE9hBsAps2MAhBiCi3lEJsE8cYMMAY+Sn742s6wR/WcV81qq
         VjC46k3HmFDLzFKNPi+4X6ovr+f1S1kB02gvPYhQm4/sQZSqLXcgIezkHizidypuccvL
         c2McZmNSx7U1aFwPfeFG0L9dUlRPJK94GM4T6uapmStoxO0Osz5ezWdUDRKRf/mCoLWW
         wtIBakhbpY65vj6X1ZRwzMrZqSZDiLU3q6VIt/XSZsp25b8J9BQfsR+J+cdzarKQOUKN
         PKEKsGyjycOhbHx7xiGO8oSoJBq4QlygiG9T4BlGhATIwLtmeEzIuSYvLfnYY3SrHTOD
         lWqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jmx3ZNaL;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12sor1646454qkg.98.2019.06.07.12.37.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:37:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jmx3ZNaL;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/AFA6heE9oFOy80aylD9Y4/+SplGswIERTbj+0KxLSo=;
        b=jmx3ZNaL4sTz0pObXjA8wn8B94r/2MxW32fl93q51ucrdsggzUWgYGMKy+rK+/TuHU
         onsC9PN5EZJYqnLqbzsuy8YZR2LTvgoeL5XaJwPCEmirLz17sndc+hOh1bK1TQoIK7Xv
         qWvbXAV28Rx1ao2Yc0LuzPh97lipLEwcAkw8yXFyw183vKjxvZc+deJejPWAq6nqUNx1
         dsX4G/oG/WHycBeqCDwT0/NTaNV1vSzfHyakQ42g7ll6ouuINgrPCon1MPGqnLp9Vego
         DgqSGQeyMXEz9V0kswHrDy+xjyywbmrAbyJZ7548+kTN4QKWxBLRUwAImUDLZ4ZTjywa
         SO9w==
X-Google-Smtp-Source: APXvYqwPBxzMDVQqMS+XyYznJjqX3ILiIujEhALA//AylcqUHfJMUDx4Sfjwubmu2WrPV+xXb08mFg==
X-Received: by 2002:a37:b501:: with SMTP id e1mr26098442qkf.271.1559936243374;
        Fri, 07 Jun 2019 12:37:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r40sm2076805qtr.57.2019.06.07.12.37.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 12:37:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZKfy-0005KN-CF; Fri, 07 Jun 2019 16:37:22 -0300
Date: Fri, 7 Jun 2019 16:37:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 09/11] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190607193722.GS14802@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-10-jgg@ziepe.ca>
 <CAFqt6zarGTZeA+Dw_RT2WXwgoYhnKP28LGfc+CDZqNFRexEXoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zarGTZeA+Dw_RT2WXwgoYhnKP28LGfc+CDZqNFRexEXoQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 01:08:37AM +0530, Souptick Joarder wrote:
> On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >
> > No other register/unregister kernel API attempts to provide this kind of
> > protection as it is inherently racy, so just drop it.
> >
> > Callers should provide their own protection, it appears nouveau already
> > does, but just in case drop a debugging POISON.
> >
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> >  mm/hmm.c | 9 ++-------
> >  1 file changed, 2 insertions(+), 7 deletions(-)
> >
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 46872306f922bb..6c3b7398672c29 100644
> > +++ b/mm/hmm.c
> > @@ -286,18 +286,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
> >   */
> >  void hmm_mirror_unregister(struct hmm_mirror *mirror)
> >  {
> > -       struct hmm *hmm = READ_ONCE(mirror->hmm);
> > -
> > -       if (hmm == NULL)
> > -               return;
> > +       struct hmm *hmm = mirror->hmm;
> 
> How about remove struct hmm *hmm and replace the code like below -
> 
> down_write(&mirror->hmm->mirrors_sem);
> list_del_init(&mirror->list);
> up_write(&mirror->hmm->mirrors_sem);
> hmm_put(hmm);
> memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
> 
> Similar to hmm_mirror_register().

I think we get there in patch 10, right?

When the series is all done the function looks like this:

void hmm_mirror_unregister(struct hmm_mirror *mirror)
{
        struct hmm *hmm = mirror->hmm;

        down_write(&hmm->mirrors_sem);
        list_del(&mirror->list);
        up_write(&hmm->mirrors_sem);
        hmm_put(hmm);
        memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
}

I think this mostly matches what you wrote above, or do you think we
should s/hmm/mirror->hmm/ anyhow? I think Ralph just added that :)

Regards,
Jason

