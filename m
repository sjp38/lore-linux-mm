Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDEE2C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 16:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91FE420842
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 16:45:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1qTO0K1i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91FE420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF1758E0003; Tue,  5 Mar 2019 11:45:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E77E78E0001; Tue,  5 Mar 2019 11:45:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D414F8E0003; Tue,  5 Mar 2019 11:45:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7178E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 11:45:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 17so9126616pgw.12
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 08:45:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=duTE2UJ/YklElEUN90YdkA/2iv3o9LmEQJ1n5awUW/o=;
        b=m1LviZ46di0B+fEKmOnEh+X7+keb/3RhOStYITei1ftL/3eYLCJvj7XmFj5zTDferW
         YCl3RT2jp7wkqgJ6xJijkuHY0cRqy1WXtuuLLbpIZb07SO2JEuSOi/Tklz72v7GyyN8R
         OgV6PYqbRUUd7bLW+boQeDMqy2F47yfGzGSNQ+AJ4s0NRKVcFUQI2KMCKmEGZWoyqkjp
         Zsa1BYcdxXEgT6Iif+gwITZNgxsPGsMBhW/xq7LTfMFLh7A63ysyQL0z8T15NyUFA7wE
         2btB4IxQW2UZMOOycsCWt7RqB37CzBH/twYVwVpd8goX3cu52hg6kRj/HSpMZiLUZakO
         VWfA==
X-Gm-Message-State: APjAAAVbBfXrCq5kgqmIaCszY3jbMnfh3hZbALtEqlIq7gPqwxjxDjDt
	vWofprTVsXX6T2l2g+FAFlrqD9Ujqash+oB2zBEJ3c0dyeay24u93wmRTmdiP8vd3cAaowKrqnP
	6aJ4rdfZ/zJArfSv1rj9dOr2ztsL7N4u7lnaBWyUFnW2txjre1cOg9Pt7ZRXGch3tHQ==
X-Received: by 2002:a62:489d:: with SMTP id q29mr2685846pfi.119.1551804338035;
        Tue, 05 Mar 2019 08:45:38 -0800 (PST)
X-Google-Smtp-Source: APXvYqx7Wa+kCnF+nNx7AZ26znONKBPIob+EG9ZosEff2uxlbHE0d0eDx7m+QFrbgKnkKzubHLCA
X-Received: by 2002:a62:489d:: with SMTP id q29mr2685764pfi.119.1551804336995;
        Tue, 05 Mar 2019 08:45:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551804336; cv=none;
        d=google.com; s=arc-20160816;
        b=DiwgbybDMJMdVXpFugwIespi0uS/RzrE68Hc/qCo6ae2ZDpfjOc411dD3+9p0/+26w
         YxFUHBTfy3IKSFV22gFONff+IfJa3BLwO3K0JH7zhtwTBB88TKVjCZizJ8JVadPgU14C
         /n6/X9UtzOxO2isnz9GQzbug9qqnAWDBy5ogoxznFqJkMcw/R92A2i3nesJROHgVQgO0
         XjJLY+nXv+SZUGRpSgh4cnvnOKB+w3x0buDJfr4+8GxH1SzKKCEerIjadH94D/skr2XK
         1sQESGjFvLy117wC2xFL/0JgNgm4RFVYFI0sbP+DKkKeGZCu0LXzOVzwdA+T+ZPOUyqT
         BV1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=duTE2UJ/YklElEUN90YdkA/2iv3o9LmEQJ1n5awUW/o=;
        b=RtQHOtRqSjWec3CpgkpGZpDmCX0Ix9O0+ZKqXqH0qNosRSxY7x/NkpBo292MNX4mfV
         06mZZomMOnL+yvjvlCkpt5nJipnYT0UV0EJvWIC+SrAVVRENDUJCmM5eIzZH6nacfGrp
         qqZyU8Li7x43b4zohAlF/gsHi69sGUFFdxTsYkNntdozmB9havVH5hthKLeLwWTL7uRf
         Da6eavhAWbqP79bDVqz3j8htViyqG03NgqlEfDmRPD6JI67nV/mifNedtjCIaNBdWq24
         okIMDagx3+zvB8/v/8iiES5HgUGpuArWz5SoFom04jhhl8LodxhuSODwCyLWcnLjw3lf
         yP7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1qTO0K1i;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b79si3945148pfj.205.2019.03.05.08.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 08:45:36 -0800 (PST)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1qTO0K1i;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [77.138.135.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E984220661;
	Tue,  5 Mar 2019 16:45:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551804336;
	bh=G2mnA6MtdEgoJaaEDw5X3sG6WrPVPZUPF7LejKLxKSE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=1qTO0K1iMlnmWuM9Zp8xmUDg8XvzvsCD5xK/oFqPeKqcFoD+QPFU8nyIXWCJNo2Fp
	 XvM5kWcK4CNBa77A/7sfftOhjyZSVif3+VQUPmBOeV3xKdwz2FxHweUusfxhb7wAWn
	 a4ZICKZWqPJMcKyaT+UwjaLFqc88qM9YmlyNBkE4=
Date: Tue, 5 Mar 2019 18:45:30 +0200
From: Leon Romanovsky <leon@kernel.org>
To: Yuval Shaia <yuval.shaia@oracle.com>
Cc: Ira Weiny <ira.weiny@intel.com>, john.hubbard@gmail.com,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190305164530.GO15253@mtr-leonro.mtl.com>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
 <20190304194645.10422-2-jhubbard@nvidia.com>
 <20190304115814.GE30058@iweiny-DESK2.sc.intel.com>
 <20190305150406.GA12098@lap1>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="o5hfEDzsoqw8wJwC"
Content-Disposition: inline
In-Reply-To: <20190305150406.GA12098@lap1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--o5hfEDzsoqw8wJwC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 05, 2019 at 05:04:06PM +0200, Yuval Shaia wrote:
> On Mon, Mar 04, 2019 at 03:58:15AM -0800, Ira Weiny wrote:
> > On Mon, Mar 04, 2019 at 11:46:45AM -0800, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> > >
> > > 1. Bug fix: fix an off by one error in the code that
> > > cleans up if it fails to dma-map a page, after having
> > > done a get_user_pages_remote() on a range of pages.
> > >
> > > 2. Refinement: for that same cleanup code, release_pages()
> > > is better than put_page() in a loop.
> > >
> > > Cc: Leon Romanovsky <leon@kernel.org>
> > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Doug Ledford <dledford@redhat.com>
> > > Cc: linux-rdma@vger.kernel.org
> > > Cc: linux-mm@kvack.org
> > > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> >
> > I meant...
> >
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> >
> > <sigh>  just a bit too quick on the keyboard before lunch...  ;-)
> >
> > Ira
>
> I have this mapping in vimrc so i just have to do shift+!
>
> map ! o=0DReviewed-by: Yuval Shaia <yuval.shaia@oracle.com>=0D=1B

I have something similar, but limited to responses through mail client only
and mapped to "rt" key combination.

in my .vimrc:

augroup filetypedetect
	" Mail
	autocmd BufRead,BufNewFile *mutt-* setfiletype mail
	 " Add Reviewed-by tag and delete rest of the email
	function! RBtag()
		r~/.vim/mutt/rb-tag.txt
	endfunction
	nmap rt :call RBtag()<CR>2j<CR>dG<CR>
augroup END

Thanks

--o5hfEDzsoqw8wJwC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJcfqeqAAoJEORje4g2clinMKQP/1gRoq+qz5xGqSzz+mJjU+4C
PJBCXt4vZF7+Gu/HfveIlS7wAB0jNAAd71Sg7rrO8U2iCBAzBopL98o2UK45vBvX
d5FNoMi1WpbiiY3of2d2NbnWu+IhgjUNrixW257UjjBBCllXaxnnpgTsXtBspnFP
wztRSNdIIksIlJBZJEBI/PqvbIs81vdGyQrN3Iiz64uRRinb6GAx75Rspk5M/YFq
WDLMv1+ImDeG2GHOaaQHPK0n5Uaf6gU65vLOqGZp5haZK3lrG1RtcFIFhplqGNUh
xRy+Q5Alsy9RO1E4gfg43bQs8yFgESuhYUHeQwUgENIMLYMwel5sMca6DQEbq1qo
yupHSId4i4oLjujXjJoAsYJilxsjrMxTSAgc44EVhFzf5gYOYgVAccjBj6m7IZMQ
i0E6KROm+XxOPXWXYYXGzO1r9h6RFDA70dH06xCl3011WnC28T4QoMeFRPiRdIX+
sdQtVUEo1HG+x9hF3pmjj2eDCYQNh7olKJC+kIxA9bn9Luo8/Ipoxrohjuvhpmie
52Ekt8ks6TteBjM9E0+msNLpYLL0nF45nvKpUxGW2q6tXTgLnf4epuDGbxTNmZmo
ktbselHH74/nux7OYVG3pUd8w+4guXzmLky1w5aNfnbLsPNSv0shvQ1eJregy2JU
bMNmng/g87i+g5NnWge+
=lxM4
-----END PGP SIGNATURE-----

--o5hfEDzsoqw8wJwC--

