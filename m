Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC0AC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:29:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C1582084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:29:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="lJ88QZFs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C1582084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 266086B000D; Wed,  3 Apr 2019 15:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215876B000E; Wed,  3 Apr 2019 15:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 103DD6B0010; Wed,  3 Apr 2019 15:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C10EF6B000D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:29:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n23so133546plp.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:29:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=EMEywSF90TvdoPb/6692zRyCulUcB2GENRR829mmn4Q=;
        b=YQuGlvI6ot6mGdO9xhuojX95ZNo2eXWyWdBVx83wbWxGgaogb9cYyDJvYgysFE9Dr1
         NIWLw+IJn0fEfz0dbpfVPXysqEbHSQmtKuyWDJ45u1PF26TF5cP3fYqNiEnFdLvdMxF5
         SRbfCycuLINFiSvPrEQaTuWgFXlHdyhNaKmvY5jMhbmPmNBWFmJf4D+/kPLMB6As6/Wv
         eB1CPYyA7nDMe9zdhcqJbxWwEISq+vB3rGPiTcdbneJYEfBcfv0LG7RCnPtPPpyXy0l4
         S68feVg9wrsN1CF/DH78JiIphk80x6VN6a8x5fPdCAibJzQh5G9c0bhPyvR22UjRnY71
         3/8Q==
X-Gm-Message-State: APjAAAXoPRl9MmBvZD4ZPaOa05IKNhIpahu53Vz5aviqgqs61/pXMK7E
	tyHPpqVDUN2waDbzAj9Hce/HWnJ5Bd0Qm87aJ/4zWMOaQmKAdY5bebQsgie/4DzQbwArOINkc7J
	zg4w83j0sqJR3WG9IJvSDL7Jg0F1ggEtRZIBvXQfRonYbGWAatjh9iBXefLWVvjNKKg==
X-Received: by 2002:aa7:884b:: with SMTP id k11mr1238492pfo.49.1554319765911;
        Wed, 03 Apr 2019 12:29:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1kbR42Q5BlgjuS59qF9kWLieW05zrfJOuFxcGFVAUo7SprT8IojAD0J3vXqiicvWyJ7ee
X-Received: by 2002:aa7:884b:: with SMTP id k11mr1238426pfo.49.1554319764990;
        Wed, 03 Apr 2019 12:29:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554319764; cv=none;
        d=google.com; s=arc-20160816;
        b=LKAZ1Np+sub8/latOdRa+JvHlBhPqAjXrW3lTt7FuUIaT8wUkl6BmjKZ4gE0oDhIfS
         lExJ5MSuIGthMW2OZD/gdvwcObZAQC8nkoUbyAKqDYti2Ohabcr3I6u6EQ0UgepzB69Q
         xczQ8LByviRslUJiOou6h1GO+hwI5jVeqHwIDYjHIOpe/5JinI4gyrVsaSB11tTaKf6l
         S5vIvYZxT+yCYy++DINTokTCIBvI7F/ZJR+swWpDdVfsQe0d2qAijCCe4vORR6cLc3nP
         +jM3Irahcb+hljDzY/+2ZCjl+wbbDjvFhChziPRkTvjBk6xjPud8At0+DfWnflYtfvrf
         cS6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=EMEywSF90TvdoPb/6692zRyCulUcB2GENRR829mmn4Q=;
        b=V52iw3UFhsL4WVPekc08NFaVnduVVhdmr9Yuj1QKsAO9DlNdog973UpFlzzZm9CBTL
         I0shJfnRDtiwNQVgPsNzM024Y7zTb5qQ+XptxK1o0oXyDAn/qQ6R4e5r+VFgEMoHLagY
         dY5yao7l3sesD0Kg3HoPUtLy037R9lkXR7tlxgctO9JAenhqa0qZZFQWNzOWdUBZ1GkA
         FcvCuMdoxnI/5TdMyXNGXOd2ZVbO5byadjt9LAHqPbUe/K05D+kQF1t3H+Ca7CMAI7Mf
         ms/5cY2adqsL1UbIGPdKDug8XR6EAN+WI+luStXKPjQjRxCAiRcajd1hyq6fiolwxfI0
         684w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=lJ88QZFs;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id d2si14267967pgh.499.2019.04.03.12.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:29:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=lJ88QZFs;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (badc-mailhost1.synopsys.com [10.192.0.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 4672210C21CA;
	Wed,  3 Apr 2019 12:29:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1554319764; bh=VwOw8NKGjDhuWj/ytpnB+wbo+Pg/Hr9sYniIX46bAAE=;
	h=From:To:CC:Subject:Date:References:From;
	b=lJ88QZFsPvzhZnEom6BdxRIx91rJVGr7y+WMAJF5AN75ZOgx6u8NnVokfMrGNszRT
	 ols0uPuvcSMznzWv27J5HkCYU7Q9rK2tGimfL8NDuf50VFIxaYbp1qsQgHLWP0v74J
	 1pP6mdW3Vd7o103K1V49JW66TIUgtXkvHxwAFvGvREvEOIyNyP27VKBdg+N8eA64vJ
	 aVAB6pUeQ87FtI0TNToTDdgfyD21oWVMMnmV8w/QcwfToUQAQ8FK1+H41RtCflLruS
	 8msEMueD3zvafekfsuPNjZABN3NHfrf9B//ngYiZe2yoGCTT2E2NyixA/bdu5ME+E9
	 Q3z7aEe/QaZ8A==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id 9C398A005A;
	Wed,  3 Apr 2019 19:29:23 +0000 (UTC)
Received: from US01WEMBX2.internal.synopsys.com ([fe80::e4b6:5520:9c0d:250b])
 by US01WEHTC3.internal.synopsys.com ([::1]) with mapi id 14.03.0415.000; Wed,
 3 Apr 2019 12:29:23 -0700
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>,
	"linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Alexey  Brodkin" <alexey.brodkin@synopsys.com>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH] ARC: fix memory nodes topology in case of highmem
 enabled
Thread-Topic: [PATCH] ARC: fix memory nodes topology in case of highmem
 enabled
Thread-Index: AQHU6LrOWOMbCHYyAEyuYCAzMbnAdg==
Date: Wed, 3 Apr 2019 19:29:22 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA230750146440183@US01WEMBX2.internal.synopsys.com>
References: <20190401184242.7636-1-Eugeniy.Paltsev@synopsys.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.13.184.20]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/1/19 11:43 AM, Eugeniy Paltsev wrote:=0A=
> Tweak generic node topology in case of CONFIG_HIGHMEM enabled to=0A=
> prioritize allocations from ZONE_HIGHMEM to avoid ZONE_NORMAL=0A=
> pressure.=0A=
=0A=
Can you explain the "pressure" part a bit more concretely - as in when did =
you saw=0A=
crashes, oom, yadi yada ....=0A=
=0A=
> Signed-off-by: Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>=0A=
> ---=0A=
> Tested on both NSIM and HSDK (require memory apertures remmaping and=0A=
> device tree patching)=0A=
=0A=
How can one test this patch w/o those - are they secret which rest of world=
 should=0A=
not know about :-)=0A=
Jokes apart, at the very least, please include them as part of changelog "a=
s=0A=
indicative code" which people can use in testing if needed.=0A=
Preferably they need to be part of platform code under the right config (HI=
GHMEM +=0A=
PAE etc)=0A=
=0A=
FWIW as mentioned on other thread, for my setup of PAE + 2GB  HIGHMEM (so 2=
 nodes)=0A=
1. I didn't need any AXI aperture remapping=0A=
2. Didn't see any extra mem pressure / failures when running glibc testsuit=
e=0A=
=0A=
>=0A=
>  arch/arc/include/asm/Kbuild     |  1 -=0A=
>  arch/arc/include/asm/topology.h | 30 ++++++++++++++++++++++++++++++=0A=
>  2 files changed, 30 insertions(+), 1 deletion(-)=0A=
>  create mode 100644 arch/arc/include/asm/topology.h=0A=
>=0A=
> diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild=0A=
> index caa270261521..e64e0439baff 100644=0A=
> --- a/arch/arc/include/asm/Kbuild=0A=
> +++ b/arch/arc/include/asm/Kbuild=0A=
> @@ -18,7 +18,6 @@ generic-y +=3D msi.h=0A=
>  generic-y +=3D parport.h=0A=
>  generic-y +=3D percpu.h=0A=
>  generic-y +=3D preempt.h=0A=
> -generic-y +=3D topology.h=0A=
>  generic-y +=3D trace_clock.h=0A=
>  generic-y +=3D user.h=0A=
>  generic-y +=3D vga.h=0A=
> diff --git a/arch/arc/include/asm/topology.h b/arch/arc/include/asm/topol=
ogy.h=0A=
> new file mode 100644=0A=
> index 000000000000..c273506931c9=0A=
> --- /dev/null=0A=
> +++ b/arch/arc/include/asm/topology.h=0A=
> @@ -0,0 +1,30 @@=0A=
> +#ifndef _ASM_ARC_TOPOLOGY_H=0A=
> +#define _ASM_ARC_TOPOLOGY_H=0A=
> +=0A=
> +/*=0A=
> + * On ARC (w/o PAE) HIGHMEM addresses are smaller (0x0 based) than addre=
sses in=0A=
> + * NORMAL aka low memory (0x8000_0000 based).=0A=
> + * Thus HIGHMEM on ARC is imlemented with DISCONTIGMEM which requires mu=
ltiple=0A=
=0A=
s/imlemented/implemented=0A=
> + * nodes. So here is memory node map depending on the CONFIG_HIGHMEM=0A=
> + * enabled/disabled:=0A=
> + *=0A=
> + * CONFIG_HIGHMEM disabled:=0A=
> + *  - node 0: ZONE_NORMAL memory only.=0A=
> + *=0A=
> + * CONFIG_HIGHMEM enabled:=0A=
> + *  - node 0: ZONE_NORMAL memory only.=0A=
> + *  - node 1: ZONE_HIGHMEM memory only.=0A=
=0A=
Perhaps we could reduce the text above by having 2 lines and adding a "()" =
comment=0A=
for node 1=0A=
=0A=
+ *  - node 0: ZONE_NORMAL memory  (always)=0A=
+ *  - node 1: ZONE_HIGHMEM memory (HIGHMEM only)=0A=
=0A=
=0A=
=0A=
> + *=0A=
> + * In case of CONFIG_HIGHMEM enabled we tweak generic node topology and =
mark=0A=
> + * node 1 as the closest to all CPUs to prioritize allocations from ZONE=
_HIGHMEM=0A=
> + * where it is possible to avoid ZONE_NORMAL pressure.=0A=
> + */=0A=
> +#ifdef CONFIG_HIGHMEM=0A=
> +#define cpu_to_node(cpu)	((void)(cpu), 1)=0A=
> +#define cpu_to_mem(cpu)		((void)(cpu), 1)=0A=
> +#define cpumask_of_node(node)	((node) =3D=3D 1 ? cpu_online_mask : cpu_n=
one_mask)=0A=
> +#endif /* CONFIG_HIGHMEM */=0A=
> +=0A=
> +#include <asm-generic/topology.h>=0A=
> +=0A=
> +#endif /* _ASM_ARC_TOPOLOGY_H */=0A=
=0A=
Otherwise LGTM. I would like to give this a spin myself, but first need to =
know=0A=
what tests cause the increased failures which this patch mitigates.=0A=
=0A=
Thx,=0A=
-Vineet=0A=

