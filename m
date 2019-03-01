Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5119EC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:50:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B1382083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:50:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sirena.org.uk header.i=@sirena.org.uk header.b="f4ltOCsT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B1382083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B253C8E0005; Fri,  1 Mar 2019 06:50:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AADED8E0001; Fri,  1 Mar 2019 06:50:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9788D8E0005; Fri,  1 Mar 2019 06:50:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 407EB8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:50:19 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id g19so4696545wmh.1
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:50:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8UVC6OHIwdcazfIJj3sm5OshMYauX1dxmV71jZvkR+g=;
        b=sMb2SeFuYbIRkvaAvlWdbRQNp6sRaV9fyOcKpDERexy1dVKn5Y3oMMWBI9WGcFrchq
         JAj1FOAYDxT/Z4RzmpYWqJGmiMePPtDyDAW0j5+ZHUAlj/84afN7T82g+DyZaNPISIFp
         OmGFwN/dSPKcqMmotTmLV6aKKMMlnTwcIwFFtuuRrDhDY9OzEKxkmhwo94CvqmhyEXoo
         F3tAlRHxBvzRAWOxqUYZ2E/cuq9DIF+5gJstp1I2E2drWmeEziwyUtd7Km0+HeiwvpIc
         e6XBLzjysOy+OiiYnh/UuO3Q3hTAoccuRVBZodw9hgYAWbl72W/xHmnd2Q1E9/tDBVW7
         0U2Q==
X-Gm-Message-State: APjAAAXkbv4PM4DHzOdV38YoEojMyYhiU61MTqPSfu0HfzKLd9zDZ72s
	2oUWkfEdjR0KF7v7mzi/fjnsgYxPv5MZb8MSTL6/q09m4LJw/8H+OnhDugOjeQ9dG9VWvtIHfe8
	y9M5WSl9guvlLutteJVZf1fVcsZRjSNKPWDJhglkLxIE265eziw4M5Xw5D5NqY2s=
X-Received: by 2002:adf:f690:: with SMTP id v16mr3190900wrp.139.1551441018862;
        Fri, 01 Mar 2019 03:50:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqzV6bcGAdhwLlLmprYDyjuXClulq9D7Sft/f65/FAOiv8NDK/3xuIRnNNrlZiQi1rtjODB9
X-Received: by 2002:adf:f690:: with SMTP id v16mr3190866wrp.139.1551441018096;
        Fri, 01 Mar 2019 03:50:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551441018; cv=none;
        d=google.com; s=arc-20160816;
        b=zIZQdOhnxphf79n9Q4v4ish8yDbe6ERy7rKq6FbvY83fZT23aYvp5cgBKQF2FRmdk3
         23Bewg14s9uLdGtz7XnDVPmUVZnSGKOcZVAUiip6eJed9kvNOgV+qGB+J7+QEb7tkl6i
         N7jJBrN8QEQcqo6pzLA2bT1bYmVIRk59ivjGxEUaitsnCFKGufXjiRK2awPzymLCex6m
         pbUIt/9w2JxqPC2r4JYFLI0ggM8W1kFF1RA65EtYkYy5cj78L4jbo3ZOPeP4zLPc8QdU
         8nWh4MwcaNx9LAOdxwQYLAxDzKgkU79DpsFj1NpPqSAqSuwrK/n13ZrCodzAb/4H0wQH
         IYaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8UVC6OHIwdcazfIJj3sm5OshMYauX1dxmV71jZvkR+g=;
        b=R92GlGGKMoDbWraG0BFEMn1AU3p/QtaH9iSsE0vD0InW1iScdI0/Fd74nYelIoNcG3
         9hottbTcOqQwWQGcGE6/mV+yE1BduK2JGBWl7vA8k6Qr/aNMDKrEAmZc/HSEkxZnu4ye
         jZzwWUe4cLOdoKFlN+l8xE3ONUJn9SwjGInldKOO35S8A5awC2aajTDE62VadAyDUm2E
         QfoPu+91leIluD6Q1Yj6ItvGbwwwJDsglTAUbOG+QXoGb6mzhxfsOCRw7ExU5Szaea6i
         0GBUrrk9MLtFGOREg9cHOTxLdvhBkL4iLMWTpr8aCPXkXh2iEkEBJYfj0+xSLh/xOcV7
         7XmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=f4ltOCsT;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from heliosphere.sirena.org.uk (heliosphere.sirena.org.uk. [2a01:7e01::f03c:91ff:fed4:a3b6])
        by mx.google.com with ESMTPS id c2si13564090wrx.309.2019.03.01.03.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 03:50:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) client-ip=2a01:7e01::f03c:91ff:fed4:a3b6;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=f4ltOCsT;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=sirena.org.uk; s=20170815-heliosphere; h=In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8UVC6OHIwdcazfIJj3sm5OshMYauX1dxmV71jZvkR+g=; b=f4ltOCsTRazPqxmyv16YF27/3
	GWWiKWZtrOV8+B2TtA+qOlmThBixRr4SqcH+DoHnR9+1Lq55/LVzUWtS3Y69yRZBkvABiiXVAv3Uv
	/3dApNah9ALDa1iGfwSg60s7Wi2zOhXd/TTVWe4ZZCrH4XiXerJG349ChIZXlOmlpgPoQ=;
Received: from cpc102320-sgyl38-2-0-cust46.18-2.cable.virginm.net ([82.37.168.47] helo=debutante.sirena.org.uk)
	by heliosphere.sirena.org.uk with esmtpa (Exim 4.89)
	(envelope-from <broonie@sirena.org.uk>)
	id 1gzgfu-00028G-V8; Fri, 01 Mar 2019 11:49:59 +0000
Received: by debutante.sirena.org.uk (Postfix, from userid 1000)
	id 87CCF1126E96; Fri,  1 Mar 2019 11:49:58 +0000 (GMT)
Date: Fri, 1 Mar 2019 11:49:58 +0000
From: Mark Brown <broonie@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Guillaume Tucker <guillaume.tucker@collabora.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Tomeu Vizoso <tomeu.vizoso@collabora.com>,
	Matt Hart <matthew.hart@linaro.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
	enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Richard Guy Briggs <rgb@redhat.com>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-ID: <20190301114958.GB7429@sirena.org.uk>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk>
 <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
 <20190301104011.GB5156@rapoport-lnx>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="vGgW1X5XWziG23Ko"
Content-Disposition: inline
In-Reply-To: <20190301104011.GB5156@rapoport-lnx>
X-Cookie: Yow!
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 01, 2019 at 12:40:11PM +0200, Mike Rapoport wrote:

> Another thing to consider is adding "earlyprintk debug" to the kernel
> command line for the boot tests.

We probably don't want to do that on all the tests since it does
occasionally change timing enough to "fix" things but doing a final boot
with the failing commit and earlyprintk turned on is definitely a good
idea.

--vGgW1X5XWziG23Ko
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlx5HGUACgkQJNaLcl1U
h9BTkQf/VrjYWVkvN4y2fMqvKBsYfN7JSwOOYZywThA3uYBAEhgyQgEQU9gfCFZG
GCArUfZPSoLF+QKmaRiH/otILLye8aZDOLfrye3mxgyjtGkOGGQ/MKg1ez+2tKJ5
l/hD+wsMILytbH95oBmXw4GeCKc/7xnBNSAKMBf17X57IIgP5G8qdVxqEFxJc7N/
W9cKcQInyoqMCv4zgu+A6H3cvtYPkArOyoXfaobPn08evl9nj2foLmaJ59jBB3fR
Qsaf10R/O4Wj1lZQx6hLZGGHNIkBNmx1eNdKhCthLbsFs/isfEQo4IFkZ2t2B7ZT
FhMt4KB/mtFOrf0uwjZXISDKJ8dGGQ==
=owaE
-----END PGP SIGNATURE-----

--vGgW1X5XWziG23Ko--

