Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5D92C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:59:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43B702080A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:59:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43B702080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92C366B0003; Wed, 12 Jun 2019 06:59:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DCF06B0005; Wed, 12 Jun 2019 06:59:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A51F6B0006; Wed, 12 Jun 2019 06:59:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCCC6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:59:48 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g2so727372wrq.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:59:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=upe1KY25v3hgXKp8rEn9QptXzfb5Mmzs2by7mfJ5TOA=;
        b=jpzd60WzhMGM7zBvZPdOxxMZncMUCBpxbrpKJy4YtM2Uyq+Ua0LsInzRzv9Hj8S/td
         PYvqQSVQmoI5RA49BIDzZuMga3aa2e81r79Ew/dAtlhrGOC2USFtH4IwRFAzmOT4K+fX
         WycjFCZGQ/AxpaIA8X9/ONmkMSceljd1/4lPhM6rwwMyj5ZMumEkoerys8XKi2ko265N
         oYuXhkX7ruFXimY676Zi/w3otjuhMFMnOFRN2X8q6x2dk04J3VsijRYLFOW6Oe9j6/qC
         p4fm0ZKQOZZZ1Kb4gNCG8gFp2Y9yYigMaA1S+AwjSgwporEcBIaMB2Zx6Gz7pOosGgcW
         KFpg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAVxpn4IVhZthQudiXZfMNR1HY4GEKKHKjrPdKIx6BEd/uEnPOro
	MT1ckuZjgCAdK22vCRR7M61wzCHN2kSK8J7FsBTy2KPqQ/bxBmRa1L7fuKG11RCrNbbNmBAr/4j
	JPioSyrWC5l1E+FaTqd41YEolrntyzSy++teiCjKeHYUkFCXlUYcKrvJs4EIIrvQ=
X-Received: by 2002:a5d:4904:: with SMTP id x4mr27693440wrq.337.1560337187727;
        Wed, 12 Jun 2019 03:59:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1ZRy6cOrqbFXEk9fI9vOHkavaRJYrjzuhSR/s5ORDS+aE1+ia0BsSIGrqnS982zKnMuW7
X-Received: by 2002:a5d:4904:: with SMTP id x4mr27693387wrq.337.1560337186944;
        Wed, 12 Jun 2019 03:59:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560337186; cv=none;
        d=google.com; s=arc-20160816;
        b=tZP+XwGawvFOwZU07r5/EwlBDzeTRVNCtunsy2+HC/2cDjQ/EKL1Lt2v2DswwyQ0/V
         q0vOCAGDSLx3lBobtLKq4K7FKADuh8c36sbzEYtzCITMrVIsMs3utE2zP2VpFNsoPhHH
         Lx9NWU4s/G0nVEWDLOgWkXji8TZCDsFig+3UI4VM5A3Zdk8+4KJBFBnNxiQP6HAa1VDN
         F6v9rNLMOntmZxhOnIYWGLea3rucKynCIeVoVmpaVHbBK6xTNV8e1GFSrnYEb6rs06Dq
         aDWTvzQVrO5WhAClT0qSl3XRfU8aKd0ferIlJFlSxKLr7YnEYdgH8wdr27WR5V0p2PZ4
         WTng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=upe1KY25v3hgXKp8rEn9QptXzfb5Mmzs2by7mfJ5TOA=;
        b=rYBkowVmIT0/AAaacB9AInl3OtNOeXFYvFabCBSUMLlSwygi9RDYg8GqHVg0rOwl/9
         N+k6l3OZG9umj9lKtvADaXrrPHXTrhfh8l8r8HYI6SEzyezGqQJKGFB9CCw3c8lZlkVM
         Ch6Ve8vBZESyz5WqQXfbYdUk9HowpZcoTV11hnilT+/Pn0JCXeK4AEeNXCLtuFiKFq8N
         LNE5uQI3JHeAGXzg73g/gbISq6whKFh5XcOdLw9Y/t9Fd3D3cqtPArbaf+AOd/Dtw8Or
         11EqszJZ3KkkduMsXoR+p+6y3JKqmfJAnF9P98slz88ymYGfDeRv0hyI/ttJjMkXS3TT
         rCmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 36si15910277wrg.173.2019.06.12.03.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 03:59:46 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id F2751802E0; Wed, 12 Jun 2019 12:59:35 +0200 (CEST)
Date: Wed, 12 Jun 2019 12:59:45 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190612105945.GA16442@amd>
References: <20190610111252.239156-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> - Problem
>=20
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cach=
ed
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.

Is it still faster to swap-in the application than to restart it?


> This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> information required to make the reclaim decision is not known to the app.
> Instead, it is known to a centralized userspace daemon, and that daemon
> must be able to initiate reclaim on its own without any app involvement.
> To solve the concern, this patch introduces new syscall -
>=20
>     struct pr_madvise_param {
>             int size;               /* the size of this structure */
>             int cookie;             /* reserved to support atomicity */
>             int nr_elem;            /* count of below arrary fields */
>             int __user *hints;      /* hints for each range */
>             /* to store result of each operation */
>             const struct iovec __user *results;
>             /* input address ranges */
>             const struct iovec __user *ranges;
>     };
>    =20
>     int process_madvise(int pidfd, struct pr_madvise_param *u_param,
>                             unsigned long flags);

That's quite a complex interface.

Could we simply have feel_free_to_swap_out(int pid) syscall? :-).

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAl0A2yEACgkQMOfwapXb+vK7ngCdHTHlKgNthsiwMrKqz+jDGcDZ
sfAAn1C5KLFMD7cpycS9Ep2CWeYprU8B
=j4LI
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--

