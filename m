Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D201C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BC0C2075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:12:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BC0C2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92E976B000A; Tue,  6 Aug 2019 14:12:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E75F6B000C; Tue,  6 Aug 2019 14:12:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A5936B000D; Tue,  6 Aug 2019 14:12:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 283916B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:12:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so54469432edr.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:12:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=QL9sIbM3j+q3pn60KqHLo9/QQpDb5U4L4P7zT6waYnw=;
        b=o2skL288p/m/+ZSHbvCoACWSY0KrZwPFOeCB75sx0fK1fcH9RWvWavsB5Cjc6PKbsU
         30b5ZXpcC2U2JqJfbLp6XW0vrGRCV93A+xLr2nAEutd6DCt8XBFp7kJsdtvTwHa9Rcde
         GEfFNkgNxdUWY3XPFhR43GrTxNDbM6ljBYHya4qCWllVlPpTUiUkJ3V5rh8NE8Iwwer0
         mD01l6EfKXGdeKMoFFpdVa09pzN2XQQ/iltNdV311+CZpfk2e5W+sY2q4kskcWiQljuD
         qTk1cQiYz4jgnQY3jlFh51hkMckfdxUMRuex4Y/WcSCf5/OFwmU1CTRij1dPi7m175p2
         pgJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAXqbXF1BAy0NAHO9pi41Qqh++9CAH2pcDOxRzli/60WVBvt/OpN
	3cbSFmgtT61K2DDpEKuLGl7NQ2dhw2gK09JY9q3xueXi7t0UkyAC4GFHgpBkm2Lv77lfjoMzvA6
	WsFh2gGUM4DYWDGYuHBmk6uf43Hcxv37REGG72vzET1BQ8a4hnIGCo8vEgfQWwiL2KQ==
X-Received: by 2002:a50:c94b:: with SMTP id p11mr5298900edh.301.1565115139639;
        Tue, 06 Aug 2019 11:12:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd1gwa/TQArx3hPYZS0UmO3zePGKO6MRGvH8CfdRQUNUkHBHSZIaWN9mo61WwloULSmRvQ
X-Received: by 2002:a50:c94b:: with SMTP id p11mr5298805edh.301.1565115138691;
        Tue, 06 Aug 2019 11:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565115138; cv=none;
        d=google.com; s=arc-20160816;
        b=0SpjMBgF81PWINgEt2crrKT2KADVbc1Tk2s7055wZWwrj0H13Qxt6XnzZDqA/qlvoj
         oTxQrtdmw6zCNOPdK0D2kWpckgHOC7zKH2zw7SbzK663fq283ZVBLGFdiurkKFhiVa7y
         EO1MbhwmrkJA/qgiXuwxJtb0/RKTK1H+2RAhtcnq9EHSKI5qM36GxGxBrjZu5ObyBDRR
         6ucgsNDbgM2ubnpAtfCHnFP5i3PJL+FXyMuLSYgceekydFAjr/mx5Utkr8udX36o6IPi
         s0z4QzB7ZEqxKjqa6WxFYlkpLRdiiZH5bivvn/4czcF37i6NTUtrFO/okH4IxfnsXqxU
         Ejog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=QL9sIbM3j+q3pn60KqHLo9/QQpDb5U4L4P7zT6waYnw=;
        b=Bj45+N+EJe3URwSELOgVYQ0pLjQ77Ron78oHvM/KzKcRQNZIRk6++bcjavUKstmU9G
         2jFciBCGGGuDzCMuunAIdgzJvo+ILMoBDE52tf8I2mCSfYHlThqc749t7GdESx7RXS8g
         FVpwWi4zH0k0OixOJ3PIbPUz3dXnYTSn9YV4iJ5cE+tJGs1w2J26N3a1mNTT+D1Gl8Ry
         6xC51S8l/WTGa3xk7eG6fp4REfLlWBVpZa2GVbFqc/1yxCXdCXU4b5Lh/p2UPGkTwBCi
         K/UqbwqNmB6NGQSC9k9tv83bKXaxBM4KUfPRhM1IqUeH2NuH7lxXd9A0n+k0QIZtOtnB
         zjwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sa28si28461226ejb.308.2019.08.06.11.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 11:12:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6E40AEF6;
	Tue,  6 Aug 2019 18:12:17 +0000 (UTC)
Message-ID: <12eb3aba207c552e5eb727535e7c4f08673c4c80.camel@suse.de>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Rob Herring <robh+dt@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will@kernel.org>,  Christoph Hellwig <hch@lst.de>, wahrenst@gmx.net, Marc
 Zyngier <marc.zyngier@arm.com>, Robin Murphy <robin.murphy@arm.com>,
 "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE"
 <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, Linux
 IOMMU <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, Frank Rowand
 <frowand.list@gmail.com>, phill@raspberryi.org, Florian Fainelli
 <f.fainelli@gmail.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>, Matthias
 Brugger <mbrugger@suse.com>, Andrew Morton <akpm@linux-foundation.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>, "moderated list:BROADCOM
 BCM2835 ARM ARCHITECTURE" <linux-rpi-kernel@lists.infradead.org>
Date: Tue, 06 Aug 2019 20:12:10 +0200
In-Reply-To: <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-4-nsaenzjulienne@suse.de>
	 <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
	 <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de>
	 <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-BWDWLSX5DbZPpBq0FAfV"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-BWDWLSX5DbZPpBq0FAfV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Rob,

On Mon, 2019-08-05 at 13:23 -0600, Rob Herring wrote:
> On Mon, Aug 5, 2019 at 10:03 AM Nicolas Saenz Julienne
> <nsaenzjulienne@suse.de> wrote:
> > Hi Rob,
> > Thanks for the review!
> >=20
> > On Fri, 2019-08-02 at 11:17 -0600, Rob Herring wrote:
> > > On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
> > > <nsaenzjulienne@suse.de> wrote:
> > > > Some SoCs might have multiple interconnects each with their own DMA
> > > > addressing limitations. This function parses the 'dma-ranges' on ea=
ch of
> > > > them and tries to guess the maximum SoC wide DMA addressable memory
> > > > size.
> > > >=20
> > > > This is specially useful for arch code in order to properly setup C=
MA
> > > > and memory zones.
> > >=20
> > > We already have a way to setup CMA in reserved-memory, so why is this
> > > needed for that?
> >=20
> > Correct me if I'm wrong but I got the feeling you got the point of the =
patch
> > later on.
>=20
> No, for CMA I don't. Can't we already pass a size and location for CMA
> region under /reserved-memory. The only advantage here is perhaps the
> CMA range could be anywhere in the DMA zone vs. a fixed location.

Now I get it, sorry I wasn't aware of that interface.

Still, I'm not convinced it matches RPi's use case as this would hard-code
CMA's size. Most people won't care, but for the ones that do, it's nicer to
change the value from the kernel command line than editing the dtb. I get t=
hat
if you need to, for example, reserve some memory for the video to work, it'=
s
silly not to hard-code it. Yet due to the board's nature and users base I s=
ay
it's important to favor flexibility. It would also break compatibility with
earlier versions of the board and diverge from the downstream kernel behavi=
our.
Which is a bigger issue than it seems as most users don't always understand
which kernel they are running and unknowingly copy configuration options fr=
om
forums.

As I also need to know the DMA addressing limitations to properly configure
memory zones and dma-direct. Setting up the proper CMA constraints during t=
he
arch's init will be trivial anyway.

> > > IMO, I'd just do:
> > >=20
> > > if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
> > >     dma_zone_size =3D XX;
> > >=20
> > > 2 lines of code is much easier to maintain than 10s of incomplete cod=
e
> > > and is clearer who needs this. Maybe if we have dozens of SoCs with
> > > this problem we should start parsing dma-ranges.
> >=20
> > FYI that's what arm32 is doing at the moment and was my first instinct.=
 But
> > it
> > seems that arm64 has been able to survive so far without any machine
> > specific
> > code and I have the feeling Catalin and Will will not be happy about th=
is
> > solution. Am I wrong?
>=20
> No doubt. I'm fine if the 2 lines live in drivers/of/.
>=20
> Note that I'm trying to reduce the number of early_init_dt_scan_*
> calls from arch code into the DT code so there's more commonality
> across architectures in the early DT scans. So ideally, this can all
> be handled under early_init_dt_scan() call.

How does this look? (I'll split it in two patches and add a comment explain=
ing
why dt_dma_zone_size is needed)

diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index f2444c61a136..1395be40b722 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -30,6 +30,8 @@
=20
 #include "of_private.h"
=20
+u64 dt_dma_zone_size __ro_after_init;
+
 /*
  * of_fdt_limit_memory - limit the number of regions in the /memory node
  * @limit: maximum entries
@@ -802,6 +805,11 @@ const char * __init of_flat_dt_get_machine_name(void)
        return name;
 }
=20
+static const int __init of_fdt_machine_is_compatible(char *name)
+{
+       return of_compat_cmp(of_flat_dt_get_machine_name(), name, strlen(na=
me));
+}
+
 /**
  * of_flat_dt_match_machine - Iterate match tables to find matching machin=
e.
  *
@@ -1260,6 +1268,14 @@ void __init early_init_dt_scan_nodes(void)
        of_scan_flat_dt(early_init_dt_scan_memory, NULL);
 }
=20
+void __init early_init_dt_get_dma_zone_size(void)
+{
+       dt_dma_zone_size =3D 0;
+
+       if (of_fdt_machine_is_compatible("brcm,bcm2711"))
+               dt_dma_zone_size =3D 0x3c000000;
+}
+
 bool __init early_init_dt_scan(void *params)
 {
        bool status;
@@ -1269,6 +1285,7 @@ bool __init early_init_dt_scan(void *params)
                return false;
=20
        early_init_dt_scan_nodes();
+       early_init_dt_get_dma_zone_size();
        return true;
 }
diff --git a/include/linux/of_fdt.h b/include/linux/of_fdt.h
index 2ad36b7bd4fa..b5a9f685de14 100644
--- a/include/linux/of_fdt.h
+++ b/include/linux/of_fdt.h
@@ -27,6 +27,8 @@ extern void *of_fdt_unflatten_tree(const unsigned long *b=
lob,
                                   struct device_node *dad,
                                   struct device_node **mynodes);
=20
+extern u64 dt_dma_zone_size __ro_after_init;
+
 /* TBD: Temporary export of fdt globals - remove when code fully merged */
 extern int __initdata dt_root_addr_cells;
 extern int __initdata dt_root_size_cells;

=20
Regards,
Nicolas



--=-BWDWLSX5DbZPpBq0FAfV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1JwvoACgkQlfZmHno8
x/5f/QgAsruOFQ8PvpoSHvG6DlzmdqSfRJK2v/9MyF59tpuvGoJUQggc4SObGIz8
/Nk2Md0j7gXdLjr+t1elpo6xBmJxLWhZPw7HfIx1ejSHv2QK+gJopm/BJ54gV8cl
oUh+Ed8eD1FBlYszwI3YRaKY/HXcQaZn97el4/AaCbztxkkAg1xEH/1L6XPwf2FC
j9/TMxpFyE6aWdQ5GtOzxL1RVmzOEYgpvsr+mKxOFHX9V5+8UXNnLDRDjR36Ms78
NVgFECrTr4rxiU2UJalTgyyPtch73aj8xMNKwHkOyiagITz9PhesPdVYy9sLWTM+
KTFFdX5XzhKpZAHyjtBWPWEKO34aqg==
=JTdS
-----END PGP SIGNATURE-----

--=-BWDWLSX5DbZPpBq0FAfV--

