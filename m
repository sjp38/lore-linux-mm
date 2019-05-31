Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2B4AC28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 962C425972
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:00:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="YtsLcn5D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 962C425972
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 321866B027F; Thu, 30 May 2019 20:00:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D3356B0280; Thu, 30 May 2019 20:00:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1986B0281; Thu, 30 May 2019 20:00:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D84DA6B027F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 20:00:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so3373701pgs.13
        for <linux-mm@kvack.org>; Thu, 30 May 2019 17:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=mQCPK+vZCIeYpKq0x+6b8ZtHTXL+f2Z6f07HEITCI4c=;
        b=IIPzFDizZCNkud9gd4S2rs7OT9ulEp6tyZtHxcMFvlzKB9Mgj6nYWk5g1TzohxZwVK
         j5l6RkNY+M69SV58fOYqOiCKFtIvBS3fQDagOUak2LkbjHpWfRAc3o6SlHRYtG3BI9UX
         kBS3LboONPEPhtOAvJSk+dEjsQcWg8veK/elXsDcsDLK6+XPkjkFO5QvfOsBVDwQQS+V
         Ka6tMdP9UXDHjycYp/0/r58IOgQDBXL06DvRpUHGWImuUzL1aZe1N4/dHIiYLHNTUvCu
         HmRdVQr7TFNqTlzH/l25T80gZ1ZTbOVLpCu0xJWTrKopJmLkQy2hyFYRH9GBnSAnl8nm
         AFYg==
X-Gm-Message-State: APjAAAVT9Ka7pAP3SgAz24FdsTqN9e734wmgk4sQGfSLwi3KbE4LRtf6
	9uncH/dEL96VikwwvMKDC6ppmO9gp7yxv9PpPyBYlhANKmIG4POcCHgPzZXVcb/sCnc482vY3HC
	ILD8VffdpzZUp7ULeOyLX4cW6/Sp0QVaPGlLN2Lxwk1wdd0QxoIWDrNRHfcx2ZNgZvQ==
X-Received: by 2002:a17:902:9a9:: with SMTP id 38mr6393855pln.10.1559260830361;
        Thu, 30 May 2019 17:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfl7f5BkTGGKFSoL3E1PhTthhiMUtX+vnO31wNlRovIzsoOP0tBhCYF0TP4IVqQ9+C8iCL
X-Received: by 2002:a17:902:9a9:: with SMTP id 38mr6393741pln.10.1559260829074;
        Thu, 30 May 2019 17:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559260829; cv=none;
        d=google.com; s=arc-20160816;
        b=UvomAyqm8vxmAqBiSP8h/DRJUQ9BTQbu6jdJer05b4BshPUPInopQNYeNfdWAcVbWZ
         MYCaEY15vH6qhUmAt93ePkLS1jqlR0ua1nA0HEDUS/jtSblB95yFyFUcfktgqj8+uXSc
         O72On9U/aWaRCNT14a0QP2VItiwFiap2us9bC3Z+vbjWlbm5YkVQ8R+llQqq02eyhDns
         NsdEWODeKt2LrmZWtjM8h6WCQE7Qd0p6+yKYma4p7FkDYZRlWcsM+q/amcuHg5dlVimL
         zgADyRMwvBWBB+4Ucoa50UGb2KIfIxFiiB75C+iHCkuFhZiIHXREQjFZdfgneJXrbEKG
         G8xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=mQCPK+vZCIeYpKq0x+6b8ZtHTXL+f2Z6f07HEITCI4c=;
        b=vk24+0bCVLATyVOOxeXvG7jWR2TBJMUzxZjoDJI4ofHSpOaHfZKKjfHthPN7bVwfFx
         qU9WyWeeNlr5iUexjMlOTcFlAOHMRYwBivb583Crl66+/PplzVc398kM8u1OHx3YpUwt
         /yWVvjFIc8jjd50dqpHdhzsUWhrFf8Nzicnor/4U3H6u+XkAF3aiIpcAoH7YvKjPchh2
         EA4kgZh+IFI+GMbqDTyynDXoTLnPEATZ+XhiF+qJVLjGFpl38chimSDoSCnnPVWNCKPQ
         E4c5VIILGr8006AI93kx1D860Ry/5UcT+hnevPszSyfQ8sl4224vkz1AIqqC3TB7S53N
         2+TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=YtsLcn5D;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id t25si4442349pfe.240.2019.05.30.17.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 17:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=YtsLcn5D;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45FPj46hxjz9s4V;
	Fri, 31 May 2019 10:00:24 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559260826;
	bh=+W/kPMCnPX3G040qq9SfOqrYhRy9N0s6PHAHIKwgkdc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=YtsLcn5DWIULUp2E0BKQF/9uB4UdOXhUp98ThYaRABDRVgE/lMxFhXMCqc62sIGWi
	 OmfpUUg0Dv711wmBfAnhpTiCnARVtksV3Z0ZGDsW7zS6fYHnt4pXf0TrlZz/XLLoXj
	 G/AYgGidtqrSxf0gKwlB2l8VJyHKIZx3SQ/CEoDADx2JWEhxsTiOXUjOXW2dfcGNB0
	 JQElH89Ud/SUCesWvBeVyUrjC53BgeGljm/B980H8VbAX3wQj5oGMeLlCYXDeW4Re2
	 9WrmcmTqJDlt9y4P6k7e1+ZVoMcfjsRhJPwVprvt80qyCm2Cfyy7iUCZ1CL/xl3PLT
	 Z6ukqM+zMdf+Q==
Date: Fri, 31 May 2019 10:00:04 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>, "Sasha Levin
 (Microsoft)" <sashal@kernel.org>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 linux-sh@vger.kernel.org
Subject: Re: [linux-stable-rc:linux-5.0.y 1434/2350]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
Message-ID: <20190531100004.0b1f4983@canb.auug.org.au>
In-Reply-To: <92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>
References: <201905301509.9Hu4aGF1%lkp@intel.com>
	<92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//Urd_40J.ripfqILoQhBQM6"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_//Urd_40J.ripfqILoQhBQM6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 30 May 2019 07:43:10 -0700 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> On 5/30/19 12:31 AM, kbuild test robot wrote:
> > Hi Randy,
> >=20
> > It's probably a bug fix that unveils the link errors.
> >=20
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-st=
able-rc.git linux-5.0.y
> > head:   8c963c3dcbdec7b2a1fd90044f23bc8124848381
> > commit: b174065805b55300d9d4e6ae6865c7b0838cc0f4 [1434/2350] sh: fix mu=
ltiple function definition build errors
> > config: sh-allmodconfig (attached as .config)
> > compiler: sh4-linux-gcc (GCC) 7.4.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/s=
bin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout b174065805b55300d9d4e6ae6865c7b0838cc0f4
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=3D7.4.0 make.cross ARCH=3Dsh=20
> >=20
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> >=20
> > All errors (new ones prefixed by >>):
> >  =20
> >>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined referen=
ce to `followparent_recalc' =20
> >=20
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology =
Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corpo=
ration =20
>=20
>=20
> The maintainer posted a patch for this but AFAIK it is not merged anywher=
e.
>=20
> https://marc.info/?l=3Dlinux-sh&m=3D155585522728632&w=3D2

Unfortunately, the sh tree (git://git.libc.org/linux-sh#for-next) has
been removed from linux-next due to lack of any updates in over a year,
but I will add that patch (see below) to linux-next today, but someone
will need to make sure it gets to Linus at some point (preferably
sooner rather than later).  (I can send it if someone associated with
the sh development wants/asks me to ...)

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Sun, 21 Apr 2019 14:00:16 +0000
Subject: [PATCH] sh: Fix allyesconfig output

Conflict JCore-SoC and SolutionEngine 7619.

Reported-by: kbuild test robot <lkp@intel.com>
Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested
Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 arch/sh/boards/Kconfig | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/arch/sh/boards/Kconfig b/arch/sh/boards/Kconfig
index b9a37057b77a..cee24c308337 100644
--- a/arch/sh/boards/Kconfig
+++ b/arch/sh/boards/Kconfig
@@ -8,27 +8,19 @@ config SH_ALPHA_BOARD
 	bool
=20
 config SH_DEVICE_TREE
-	bool "Board Described by Device Tree"
+	bool
 	select OF
 	select OF_EARLY_FLATTREE
 	select TIMER_OF
 	select COMMON_CLK
 	select GENERIC_CALIBRATE_DELAY
-	help
-	  Select Board Described by Device Tree to build a kernel that
-	  does not hard-code any board-specific knowledge but instead uses
-	  a device tree blob provided by the boot-loader. You must enable
-	  drivers for any hardware you want to use separately. At this
-	  time, only boards based on the open-hardware J-Core processors
-	  have sufficient driver coverage to use this option; do not
-	  select it if you are using original SuperH hardware.
=20
 config SH_JCORE_SOC
 	bool "J-Core SoC"
-	depends on SH_DEVICE_TREE && (CPU_SH2 || CPU_J2)
+	select SH_DEVICE_TREE
 	select CLKSRC_JCORE_PIT
 	select JCORE_AIC
-	default y if CPU_J2
+	depends on CPU_J2
 	help
 	  Select this option to include drivers core components of the
 	  J-Core SoC, including interrupt controllers and timers.
--=20
2.11.0

--=20
Cheers,
Stephen Rothwell

--Sig_//Urd_40J.ripfqILoQhBQM6
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlzwboQACgkQAVBC80lX
0GySOQf/T+Goi4No9tDwJYA952YXZzB0jB1/cwe3Z6PZ8UQWoeI7iEaA7kuj1+8L
z6Eo0aF9KAfzCxJYVByINBUxQ+LS2847bezjsm+c2/CTgW180H/lMRad3cjaD3JF
xsNO5+utt+YM54xXPAUOySND/XtRnjzn2LJe+zxh9087xVFmamWFrKyqRAPRhjg0
9SnSa2DEulCOfi4fv8lWXaRJg81HowDqczHZ7N2wtMGuW3ELxNchALFcwdWt+rOl
p5YYJO/HsCOmj5lspNcEl8sUMRzcL8qRwwRXo7rqzWfn2ifbj3RcAQJvFhIy/hCy
SWhbdV5NnLxFroLheN0colbcEWCCMQ==
=Zrm5
-----END PGP SIGNATURE-----

--Sig_//Urd_40J.ripfqILoQhBQM6--

