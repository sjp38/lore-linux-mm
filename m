Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58635C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19A8222CE3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:52:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="sAoj9rah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19A8222CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5C206B038F; Fri, 23 Aug 2019 07:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0C786B0391; Fri, 23 Aug 2019 07:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A22476B0392; Fri, 23 Aug 2019 07:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 93A0F6B038F
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 07:52:17 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4DCD152DA
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:52:17 +0000 (UTC)
X-FDA: 75853529514.07.tramp94_13ed40db74a1a
X-HE-Tag: tramp94_13ed40db74a1a
X-Filterd-Recvd-Size: 3713
Received: from mail-qk1-f175.google.com (mail-qk1-f175.google.com [209.85.222.175])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:52:16 +0000 (UTC)
Received: by mail-qk1-f175.google.com with SMTP id m2so7876965qki.12
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:52:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=c78+wpE5NtAkckuxK2dQr7Uguc2X5h5Uf88Hnt+OH4o=;
        b=sAoj9rah6K5BokDfPT19/4uD3oY8HqR9/TMn9gYhRMeXpNNLKoLCVM6zXbB13cSEaX
         XRQLlaqhbZLBKZ6CHE8SNKmMVmNjHNyyEPKdRe3mMLJwCd4OLjdGDZFy7lea/5Z9IjHP
         KfNMH8gypu5960lc5DDjhe5dRH4E0kKlKm6WikNERGfuCyzz4wEqrvzx8Hf7DTqB/HOB
         7tYKsMI2MyOxl81jVL9VdRnjaHUckQER7RAIgXBI9Gx/jT0wKhiJDPBYyQrY6tdSqaq+
         rTr3IS/eeTyZwDqD/voJ2MBuMdF4q63nRkmlnszGQbLX6ch6gLzvN7r4jvYtzb2uhWMz
         Mcgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=c78+wpE5NtAkckuxK2dQr7Uguc2X5h5Uf88Hnt+OH4o=;
        b=V/L37qTh/Y3tXgdBpjqKr6EuUYQGENpwDNdb1wldIwzIzjXEbR3adUb52JHBR1Uydk
         KZm4Jel6pKvbiEKIHQbHD5AxJhRgkMAVpdVz7N+e1KdGwOkHSJsfYACy95L7Q7hP3NQ/
         71DOgVMie4SiIF1HpPTYh0sSjagiZ9PXjwMW4LRpweyoD2l5+2PIqDYeez6Dg4JHPQ8c
         tEVbtvyiF8KAspiqD5ANA53fM/TNM8HJyE4acxshkOIlWIjU0Um+7U6ETW0nuEoZwGRU
         fU4Z3uuwOWjEoJmymmlOQ29jTBASF9uGyWpxCaEeyYG2N79e4eznPceDtFODUYm/nPFR
         znxA==
X-Gm-Message-State: APjAAAUqtqQ5TI3BC4lQHCNuPWh2i/nC9ZWsoum0cgLB17pgnRE1V+Oy
	kQnKqSD4LsO5aWGvvKk+GBXKCQ==
X-Google-Smtp-Source: APXvYqwH3MawXbPD2LmUDGMAota0KHoYSVT973YOIwpmhk73kYGH2B14rNwBdq5MBNv/MYwDoZqbHg==
X-Received: by 2002:a37:b004:: with SMTP id z4mr3622368qke.103.1566561136162;
        Fri, 23 Aug 2019 04:52:16 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 136sm1313279qkg.96.2019.08.23.04.52.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Aug 2019 04:52:15 -0700 (PDT)
Message-ID: <1566561133.5576.12.camel@lca.pw>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
From: Qian Cai <cai@lca.pw>
To: Will Deacon <will@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Dan Williams
 <dan.j.williams@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  linux-arm-kernel@lists.infradead.org, Peter
 Zijlstra <peterz@infradead.org>
Date: Fri, 23 Aug 2019 07:52:13 -0400
In-Reply-To: <20190823113715.n3lc73vtc4ea2ln4@willie-the-truck>
References: <1566509603.5576.10.camel@lca.pw>
	 <20190823113715.n3lc73vtc4ea2ln4@willie-the-truck>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-23 at 12:37 +0100, Will Deacon wrote:
> On Thu, Aug 22, 2019 at 05:33:23PM -0400, Qian Cai wrote:
> > https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> >=20
> > Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
> > CONFIG_PROVE_LOCKING=3Dy=C2=A0results in hanging.
>=20
> Hmm, but the config you link to above has:
>=20
> # CONFIG_PROVE_LOCKING is not set
>=20
> so I'm confused. Also, which tree is this?

I manually turn on CONFIG_PROVE_LOCKING=3Dy on the top of that, and repro=
duce on
both the mainline and linux-next trees.

