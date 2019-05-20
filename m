Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57B85C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 10:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0152206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 10:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0152206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B24F6B0005; Mon, 20 May 2019 06:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462056B0006; Mon, 20 May 2019 06:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3502E6B0007; Mon, 20 May 2019 06:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F32D76B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 06:21:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s8so9545398pgk.0
        for <linux-mm@kvack.org>; Mon, 20 May 2019 03:21:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=nU39mFUwgC58YfNuujcUIkv+iQuhqwICROQ1KRWDSa0=;
        b=H0WJ4Z/cWUoVsJvrjmfaPzKnCYTuTOXAR+0tP0dMZ+OE0a3wSl6BuHWPDM1Blm26Xp
         q5+BfcQyMEgRHPuUa4xYqVKYqGFxgYCd8obI5Jhg5RNgswSeN+r1lJgoAhSwxO4ALuSC
         SC+E0aew4H+F6o8reud0wD1LzENNFPLVp8XyVLsLNfLq6Wl5EOiOlTGQ+T+7fxTG1O4d
         GCKEWxKJmICYZqav5UpTnC2LTJSTiS1Z5gh3GMEJx7LX1ns42Kij4OhbdFPTtN/t+Sgq
         TWAUyxn+A1PhEaccgnJkqFcFaG/7mMX7rgbL3466EEGtItvyMR1lwgGxuodzyWr2dSIv
         v3MQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAVRrMlQtFaZsj2s82788TLa3wcdL4ORwMuWYbr4GPGAgJsmDpeP
	KeOmpJDXfJsGDwJ93D11szKThe+dH8CkDxZE55bLrbKXKooBCc9ZXV+tH3+b40Jg6OdpW6maW/K
	0unsSc/go4XPg8WIX9q5ISHP+1LpOvc/8JeaEMEMgCG7kFbuEFaLROmZpNY4b7lcmeQ==
X-Received: by 2002:a63:7c54:: with SMTP id l20mr72009784pgn.167.1558347710592;
        Mon, 20 May 2019 03:21:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFhzFyVJ1U7usBnLvJrZbHsltv4AXvm/F/WgiHVyNnb0q4EaH2kN41BR7314cGrN3o9YAX
X-Received: by 2002:a63:7c54:: with SMTP id l20mr72009732pgn.167.1558347709874;
        Mon, 20 May 2019 03:21:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558347709; cv=none;
        d=google.com; s=arc-20160816;
        b=ViuzZmdY31S3ddeEgfmCt3Ciwxv7UpsBEm7YQOmPZz/iKvt0VHYeELtWW6OkmiWuhB
         4QRbmumPHn9R2GK+07BrqBBOAweHHn4mrXWr1F61jmMES9y/mIr0Z8gBCt2ujLL6iqmA
         OC1SY42OAoj1/WAsn/P69+2U15kZ/7kCs1tpOamjEEeYgnMsM3I6NbtxR9jutlO7cIMb
         VcD5q0aiTQ9pzapaxCiG4CTf5pg04E7GHMUGfG7ra06ZvJ5TQcpADWFRviXHJbkNciiL
         BWhhn2yeVysJUwXmHjMbfvvL/mgSkkxt0GXRgY3unBkjaCOrlhYoynoDUDo/zQ0hjVHC
         2b0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=nU39mFUwgC58YfNuujcUIkv+iQuhqwICROQ1KRWDSa0=;
        b=cKAUUoxmeXyaR5LiKIwvy3YyJF+F+p35fXDqxQW31TMiEb+zaUFqxSFU4YkWCe1N/4
         nBTV9gECXwr/ZRTfM+fGhoHIy3IUjTkiyV0J4Ve6wYlhvjes+oFgqDI0Gq6ef/eXh+bM
         Vrkn1UkaHDCO7NnP8MdVmLyvQNwzZXbvr50C5WxcHexXjF2FdE/CEgdjaCk4E8vi9jZn
         JX2FgM+JDYS23V0waIaV15mOP6mvELjQe6E12Bafok2bRUWYp/tNl1+zSKt/AJC38miq
         DNy7fxDWDJ0XMMyDgtMreBMGOd1rAtn4mk0gIPHsHM0JZ8OX0WBmq1xglosvh+XkeMTA
         LkPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id f2si18229462pgb.543.2019.05.20.03.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 03:21:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x4KALhFs013250
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 20 May 2019 19:21:43 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4KALhLU009626;
	Mon, 20 May 2019 19:21:43 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4KAJuFw020474;
	Mon, 20 May 2019 19:21:43 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-5209311; Mon, 20 May 2019 19:21:06 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Mon,
 20 May 2019 19:21:06 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: Jane Chu <jane.chu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH] mm, memory-failure: clarify error message
Thread-Topic: [PATCH] mm, memory-failure: clarify error message
Thread-Index: AQHVDGYtMbmPk2oO9EWAkFfiZXN9haZuJ74AgAUUDQA=
Date: Mon, 20 May 2019 10:21:05 +0000
Message-ID: <20190520102106.GA12721@hori.linux.bs1.fc.nec.co.jp>
References: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
 <512532de-4c09-626d-380f-58cef519166b@arm.com>
In-Reply-To: <512532de-4c09-626d-380f-58cef519166b@arm.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CEE34CE09A73174D91E6FF4DEC23B445@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 10:18:02AM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 05/17/2019 09:38 AM, Jane Chu wrote:
> > Some user who install SIGBUS handler that does longjmp out
>=20
> What the longjmp about ? Are you referring to the mechanism of catching t=
he
> signal which was registered ?

AFAIK, longjmp() might be useful for signal-based retrying, so highly
optimized applications like Oracle DB might want to utilize it to handle
memory errors in application level, I guess.

>=20
> > therefore keeping the process alive is confused by the error
> > message
> >   "[188988.765862] Memory failure: 0x1840200: Killing
> >    cellsrv:33395 due to hardware memory corruption"
>=20
> Its a valid point because those are two distinct actions.
>=20
> > Slightly modify the error message to improve clarity.
> >=20
> > Signed-off-by: Jane Chu <jane.chu@oracle.com>
> > ---
> >  mm/memory-failure.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index fc8b517..14de5e2 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -216,10 +216,9 @@ static int kill_proc(struct to_kill *tk, unsigned =
long pfn, int flags)
> >  	short addr_lsb =3D tk->size_shift;
> >  	int ret;
> > =20
> > -	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory co=
rruption\n",
> > -		pfn, t->comm, t->pid);
> > -
> >  	if ((flags & MF_ACTION_REQUIRED) && t->mm =3D=3D current->mm) {
> > +		pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory "
> > +			"corruption\n", pfn, t->comm, t->pid);
> >  		ret =3D force_sig_mceerr(BUS_MCEERR_AR, (void __user *)tk->addr,
> >  				       addr_lsb, current);
> >  	} else {
> > @@ -229,6 +228,8 @@ static int kill_proc(struct to_kill *tk, unsigned l=
ong pfn, int flags)
> >  		 * This could cause a loop when the user sets SIGBUS
> >  		 * to SIG_IGN, but hopefully no one will do that?
> >  		 */
> > +		pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardwar=
e "
> > +			"memory corruption\n", pfn, t->comm, t->pid);
> >  		ret =3D send_sig_mceerr(BUS_MCEERR_AO, (void __user *)tk->addr,
> >  				      addr_lsb, t);  /* synchronous? */
>=20
> As both the pr_err() messages are very similar, could not we just switch =
between "Killing"
> and "Sending SIGBUS to" based on a variable e.g action_[kill|sigbus] eval=
uated previously
> with ((flags & MF_ACTION_REQUIRED) && t->mm =3D=3D current->mm).

That might need additional if sentence, which I'm not sure worth doing.
I think that the simplest fix for the reported problem (a confusing message=
)
is like below:

	-	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corru=
ption\n",
	+	pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware me=
mory corruption\n",
			pfn, t->comm, t->pid);

Or, if we have a good reason to separate the message for MF_ACTION_REQUIRED=
 and
MF_ACTION_OPTIONAL, that might be OK.

Thanks,
Naoya Horiguchi=

