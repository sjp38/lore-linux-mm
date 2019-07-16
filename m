Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB241C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 01:08:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A41C020693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 01:08:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="bvDrKv47"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A41C020693
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3457E6B0003; Mon, 15 Jul 2019 21:08:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F5566B0005; Mon, 15 Jul 2019 21:08:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C1B6B0006; Mon, 15 Jul 2019 21:08:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C572E6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 21:08:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so15029091eda.2
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:08:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version;
        bh=m2NunaIvYtC+XkVPYHu6aIHoDoviFqiYjLDr6zS+ALA=;
        b=Q0phV6UIFmuhX0sqa/3YEbC495bUirXx+8GQB1ZydXVEdaQOKVPTXLQRQewv9g1BlV
         qx2anb7jpzEvXxd9lB1QOPRCd6Bd5uvH2K35MRACIDEl1wCR7BDZyFufscl179CY8fAk
         3wtLqd0Kfa/+IWXyqqzJo4txrzvN35dwc2ipt5PdrxyZAOkk/Uj2vXcgkWJOXyzE+trc
         ufoQLbQx1pWpm11bLVDKwOrAVG7ZLKcPOMrEm+05NX/wSFSXRVzTgVLMK7wPJY5t4YFY
         ir2Iuf8b8C/btYZEUl6L3GdwGoP7jyLPokn5bYA4lJrISRiRRgiTyEetNgox0qOijDjy
         Rkug==
X-Gm-Message-State: APjAAAWIeiaCKj+zYsf7zll4vZchAbry77mC65LFwfYR5K/d2MxDuloP
	6BXH3p22laDmJD+bmuZapi9/KnycXZy71lDMcMBEjp7XP989+SCoZC00z/OXQr9POxQUiXDm5yc
	cARMQyjGGOPTJOy05NOOMSlAWJ+c39rCd16d4lLuRzFwLklN3OVc7cAT3UwJ/yrCgVA==
X-Received: by 2002:a17:906:6dd4:: with SMTP id j20mr23346066ejt.173.1563239313263;
        Mon, 15 Jul 2019 18:08:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjXSr1Qeo6R6QD1NGefg/OsHqNK1hjTNMFtxjF6pws4AxMNLGIoV4qDabaarIBi1IKlzBX
X-Received: by 2002:a17:906:6dd4:: with SMTP id j20mr23345995ejt.173.1563239312118;
        Mon, 15 Jul 2019 18:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563239312; cv=none;
        d=google.com; s=arc-20160816;
        b=Ej8fZqDpb+AXYxLPVSY+tAeUpd+4FwKbpbdPs0SZgj/5oTHpD52QEhMBol2FmKdvWI
         nN6zJQcEJAxf0/ck5aSctDUWPmwjmhPn0vUhd7YXcL+d+F7VRl0vWPX45OWja+KxVsKy
         TkL+fJc3YANteJdql3bsu3Mz8BwDixDn50x0NWTAXZk7560yyzWhJyFZG5UDiF/91MAj
         Dll29UEH7ymZmIigEaR7klqjGs8X9eBKHQPpD0B/zTcbDf5FzRm6UWsvrTJTL/gcV3l/
         eMaO/GxEAk8it9IRUiZ9RjMh5hasVQ/2CLvkRicMDzMfuUlD6QU2+vdt+2CkuAtgiamp
         t/bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:feedback-id:references:in-reply-to:message-id:subject
         :reply-to:cc:from:to:dkim-signature:date;
        bh=m2NunaIvYtC+XkVPYHu6aIHoDoviFqiYjLDr6zS+ALA=;
        b=qrQHVoudaJ27xSv0o4N2va0vB83GdwyMb7VUdP5hMKO/iZIQm61Oqx3smL7lFyEmkS
         b488vPa3SqanauHqwpCMNFIxrFXltxuj+EK+kjO+XR2R4lnME59WASJVNm9UmE/XzdlS
         nu1vL5EU88o2PBcLW6LQeS/iv7uQjCYNOONMy1W1MD3m0rgwNUi0xBgCKB9/kczLycTD
         2XKmPaicGIjBwj8i78pVbky5ZoZr9/KasYKrI/UGZBDwap62JY152wEI+CGHuVjsmfXc
         XXlw+R2ZlsDMiTbswF/9XTNXnc/6lAr3OLdK8oZ5ObgnG7pO2FT3vI3Op6fFcIIRmKAP
         3iCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=bvDrKv47;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.133 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40133.protonmail.ch (mail-40133.protonmail.ch. [185.70.40.133])
        by mx.google.com with ESMTPS id a1si2358836ejn.200.2019.07.15.18.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 18:08:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.133 as permitted sender) client-ip=185.70.40.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=bvDrKv47;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.133 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Tue, 16 Jul 2019 01:08:25 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563239311;
	bh=m2NunaIvYtC+XkVPYHu6aIHoDoviFqiYjLDr6zS+ALA=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=bvDrKv470zHMjt2t83XO2QMA/O6K7eT7UAIp3easm9CGcPjfnHelWHImvV+etF0Ru
	 4uT4JE4SR689cK/J1KZcaxAYhRGLBiOtXHwGj+Vj3CObtUckNVGWFBd9ymizUjr+TT
	 eusauKFlI/yzxkQfr01I4zbUeFhhiRO3il0ruRmQ=
To: Andrew Morton <akpm@linux-foundation.org>
From: howaboutsynergy@protonmail.com
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <GpYhzvuVkDasrIKYTwAS5RLC5ooyxn4xFepgkPDSQx7bPotn0HzNue5n9YgatrtqoydkCs8bLshc-ulda3MoaDOoUFM57FTDatWTZ7uRXk0=@protonmail.com>
In-Reply-To: <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha256; boundary="---------------------1dff28ad013210c90ab019f8f883e242"; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
-----------------------1dff28ad013210c90ab019f8f883e242
Content-Type: multipart/mixed;boundary=---------------------83a22489a983be4ef54bf7d6027f9d83

-----------------------83a22489a983be4ef54bf7d6027f9d83
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;charset=utf-8


=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original M=
essage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Monday, July 15, 2019 11:25 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:

> (switched to email. Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> =


> On Sat, 13 Jul 2019 19:20:21 +0000 bugzilla-daemon@bugzilla.kernel.org w=
rote:
> =


> > https://bugzilla.kernel.org/show_bug.cgi?id=3D204165
> > =


> >             Bug ID: 204165
> >            Summary: 100% CPU usage in compact_zone_order
> >     =


> =


> Looks like we have a lockup in compact_zone()
> =


> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 5.2.0-g0ecfebd2b524
> >           Hardware: x86-64
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Page Allocator
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: howaboutsynergy@pm.me
> >         Regression: No
> >     =


> =


> I assume this should be "yes". Did previous kernels exhibit this
> behavior or is it new in 5.2?

Is the reason that you switched to email somehow related to bugzilla not e=
ven posting this very reply of yours(seen above) that you sent via email e=
ven though you included bugzilla in the CC ?! I noticed that only mine got=
 posted and mine was after yours in the emails. Yet there's no trace of yo=
urs when looking at the issue through the bugzilla interface.

Your (emailed)comment should be right after this https://bugzilla.kernel.o=
rg/show_bug.cgi?id=3D204165#c11
but it's not.

Anyway, I'm ready to test stuff, please let me know how I can help.
Meanwhile I'll try to find a better way to replicate the issue.

-----------------------83a22489a983be4ef54bf7d6027f9d83
Content-Type: application/pgp-keys; filename="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"; name="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"; name="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"

LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tDQpWZXJzaW9uOiBPcGVuUEdQLmpz
IHY0LjUuMQ0KQ29tbWVudDogaHR0cHM6Ly9vcGVucGdwanMub3JnDQoNCnhzRk5CRnlmMlFnQkVB
RGhNTmIvSnlDcXkyeXhQeUxBckNSK1dkZnVOc1ZqZ05LMGZhaktDSm9uVWllNw0KRldXYVJhQzhs
RTg0MGkzQ0I1dlpSSmNiQUtWZHlTT3VkRHNuWmd4cmsyeEVOL1BSVWVrNWI0ZkxJRHIwDQpOb3Rt
b0dndXoxd0xXNU9US00zd0g0TXNIM0svT0R6RXhMZ0VNM0ovK0dGUEROemhsL1laNEZJWUhTaGUN
CkRFVytZNXBQajFhMXpDU2JGajR5ZG1hRGRZVWtIUTV6b1RSNGx2ZXFpVk5XUW13dG44YmF3eGE4
MmVyeQ0KUzIrMXZ0NTdTZm42UXNPNWdzRHNlMWlYaGIyZTRPS3dZTUVaK0gvYVkraE13MVoxTmpT
WDdhZmZoZFBUDQptSnB2Vkp1ZnNGS1JhbTViSzk3SHBtbHZlSFYxdU1sdzFLQjQrS3NYZnhTSWlp
bzU3R0Vqbk1vT1N1NnINCjRDYmhyQXBqZGc5cjZVM2ZkU1Y0alRUM3JESFpWbllFSXNnZ1BpUGJN
Wjd4WEdVa2dkQzNtUnJucnNBTQ0KajBSZmlNRTM1dVpoT2hiSzN0bFBIN0dIalFHWHNGQzR2SFcz
b1Z3MksrWUdtbDlvT3gwcVpKTnI2Tkt2DQpkRVdYMU5WbXdQZzQrVmthcVhkV1dLTXJlZnh3Z0NE
bVpCY094R3VuaXE4VEkwenlxdXNQVFJ5QUVPWVgNCmZHdVVUcHJEWUdRVk5aNGN1WkJCU045WHBj
dHliTnJGaDliZmNyNTMrUzZ1WVk5RlZkWmp5a0xCVW1uNw0KcjYxYWM4cndnc3ZuVzBzWktJUGZ5
R2k0K0VpMG81ZUtXcG1WTHVHSUVFWW5vc1lnODdOV0lhVWNZbnk4DQpLemk3dFIyV1YzaVNuVUhP
UmxPMkoxMUlCeE15OTIwbnVMdk03d0FSQVFBQnpVRWlhRzkzWVdKdmRYUnoNCmVXNWxjbWQ1UUhC
eWIzUnZibTFoYVd3dVkyOXRJaUE4YUc5M1lXSnZkWFJ6ZVc1bGNtZDVRSEJ5YjNSdg0KYm0xaGFX
d3VZMjl0UHNMQmRRUVFBUWdBSHdVQ1hKL1pDQVlMQ1FjSUF3SUVGUWdLQWdNV0FnRUNHUUVDDQpH
d01DSGdFQUNna1FIUDNKWUhoYThremtFeEFBbnFwak5aL1NhelpoREVsa0daeHErOGZMamh1NGw1
cGgNCjJVU0dFSEdyZTIrY1k0V2dwZEliRGlVeTE0Tkg0Y1ZLL3FEd1RJazhIZ2x2SVhsOFZzdk1t
SXU1YW9xcg0KdHpiUVVTZi80YkYxRER5WVZmZ21JSnN2cXZRTFg4eldoejJydXJvQmpCbnRwNzVV
UVBZalYvbCtGZmxlDQpIVzJLWG5TUGVmY1B2cTF0SWFNbkkxTHJsK0FxSXN6K0xMZS9tMkpsU0tL
c3F0YTRlZkJORlB6L3ZidEgNCjloOFZ6NTZpUm5RS1dpSGFFa1pIcUtiUC9hc2x2ZmltTHptVFVI
Zk43NVNTMUZpMkJQeG14eFAycDE3MQ0KcmhkMDZoa2V1NjFHRWxPU0M4OG8wc3dVOHJoVWlqem4z
blFHM1dXUFMvQnBIa1RmRjlTNC9na3dMMStMDQp0YUpOdEQwR2J4a29iQU1iMjA2RTNIRzBZY0g4
dTlDdWhXSWlpQ3B0bHJlN2dPckdmTkk2cG5qQUhrSFoNCjFaUWFmSm5oVUN0TFkxQjZZQXZ6SUta
dHM1MG9vTG5tSU5vRmh3MjJRRG9JMnVKU1NzbjkvS1RjOStzNg0KQ2Mvek1TL1NiV0FJdzBGc3Aw
SDRmM1RkSjd6djhRWE03Vjl5M0FOaVVLNFU1NWRESnRjWmxDZzBkS050DQpqYlNzdWUrZCtNS0cv
NnBFUHU1UlloSjJDVDgwOWFtdlRqa0JCOTdQdU4zcnNmYWNWZy9yaWtFdmRKWmoNCmtoWjMyVDJX
bjI0VjJKR0VMT0xLSHE4ZGZoWFNnaDF4YWJ3SUR0QmtleEhlaHVsbmxVekRDM1BHbjl2cQ0Kb29D
K2tnY01MSE52WEpVWlFldTUva29wa0N4cTBVZmc2MEdCc3hITkxjSlFhZlE3UnVuT3dVMEVYSi9a
DQpDQUVRQUxyK241MVkvdTZxUEdvMW1hU3B6Y2RrdUQzQnNQU3VRdlZBbzZpc0VVVUdnY0dmbHA5
by9Id3cNCldFTVFEMWdTTlRaV1BzMjFwbExJbVdJbHFJbExGYWlHS1FnRDRMOHVPVURpVUh1YzRC
VnBHTzMrTERmYQ0KdjBCc0x1enBWRXo0TXcwUjZ3UnAxTWEvWkNZU3pyaENMSHM0RGp4cURRUUkz
T1d5TzBub3lISGl3bGJWDQovS1BvejlUaU9adU93dHNLV3hLSzdaMWZuWlQvREZ1MDMrOEhKWTNi
TlRLamNqT0FYN0QrSUFtd1FaY04NCi9KMElGTkFuL000V01Tc21QdlFDMEtKTVJiRzAxNmhJZHlj
ZDBVQ2M0MG43MUMwTnFTTWJRY0d1RzdoNg0KWEc4dG50VmJSNE5VTTZIV25MekRXN2RpRFpQRXl1
TU1DQWVRZmVabzZ0L3BJd0Q0dDk4dmQzQWg0ZnNzDQpSR0hyWUdzMWpoa2dWTjAxOVZUaDVtUnk3
V2lpUDY4eU43elBBN1Iwa0gydkRCWmxnamdVUlJUaWVLTSsNClV4bllHbE54ek5waWhRZWpVaVEw
MlhPa3VHU1VCYmxUNm1YdFl5UHd5SC9EYmNoa3ZVa3FXejlSS1RURw0KSEJrdERyOHZjcHY1ZG9D
eXY1bW1Pb2ZRYnA0YXBuc0R2SldGejkxbUtYdkdwZlQ1Q1MyaDJhUnRPMW9SDQpadWpIQUhDNGQ0
OXc0MTVSdXo2MlhTTGw0d3E4UHZDcXFWS0dTc1R4bSsvR3plN01yOWZpWjZSVXAvaHUNCndoVm5H
UHE1UzQyQW8wemxOTXpYRTEvajVBS2drOTV2ZEVWeDB5V1ZDbTV1Wnc0K0haeXUyUUdGM3NjWQ0K
NFhDUGRHL2l5d3NjZU1ZMVdXQlZiQS95dWdMSkFCRUJBQUhDd1Y4RUdBRUlBQWtGQWx5ZjJRZ0NH
d3dBDQpDZ2tRSFAzSllIaGE4a3o0eFEvOUhSTlJGRjY4OVVCaXNISXg5eVI3WG5iVTNKaGd3VFAv
bHpSS01rZGcNCjVUSENqN0M1bXpKREtzZmZVMURSWEFtVkM1eWIvc1JEUzQ5aGdOa0ZpZlRxNWF0
V20yTWR4aHAyUlZFWQ0KREl3L2p0Wm5rLy9IWDJ2MDJhd3pJTktUTXM1S0tYdFAyMTA5NG1IT2wr
MzNFRi92T2t3ajJOMHRtL2wzDQp6ZmNDdzVsVHZpbGFCcDd5ZUpJSjB5aU45QlF0Skl3MG9PRjFF
b3k4Z3RlRGFzN2tWVFI0T2pLM0JyQzMNCktMYXFlZEQ0RVRrYSszZHdVZXRETEYyQkZ6Q3JIeDBI
bWFPWXZFNzgwaGpFMk9QQytUNTlwdnU2RG1wYg0KRmczcnlJcVJwSTZxRm5UUlVjVmVSNTU4Ly9Q
K3E1cElGd3F4Y0dwNllTdytXb0Q5UEs2MEd0ZVlIL2FRDQptTW5Ba096RlJSOGpqYVJBa2JtTnFF
L1ZLK2FLeDBBYWlNdy8zTFNsbHNrcGdGNUcvcjBEUXRobVpnRVENCmRNUWdRQWRVbW1EMFp3VzUx
VVVTZzJmaHd3NkFzMHAxWlBYTWdOaWdsLzQ0b0ZQdDZBSVBhc25HejVqRg0KYVRzSjlqdnFFT3lm
dlRtNTNvYnJZeTNaRHJydy9reEZYc1Z6MkVaZzI3Y05yY2Z1ejRzYWtodzUzZFY5DQp4MkVMTkE2
NlVSSFNpRjR6TUYxaVBpL2JGVkVrMEhuVVpNTGJmblV5V0hKTTBNY0RLSCthSDFIOGZpOWcNClVa
TitxWnEveXJ3dzJuYWJMVDRtVXFCTnVQOVZrY2dPdXlwNVhIYlBRZkIwRDI4cW9IWDVjNE1GeEVa
Qw0KV3MrOVRzQkxCdmxBSno3VkF4dWNrY1huWVhUUnNTanBTZUd0czBUeE85TT0NCj1Land6DQot
LS0tLUVORCBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tDQo=
-----------------------83a22489a983be4ef54bf7d6027f9d83--

-----------------------1dff28ad013210c90ab019f8f883e242
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: ProtonMail
Comment: https://protonmail.com

wsFcBAEBCAAGBQJdLSOFAAoJEBz9yWB4WvJM5i8P/iC9ch7FnrYYidPLbt5a
x8d23jsenDh49az5oJRr9jBiYpFK5qXRCSJQfrTSRkk1eBTh/wj3tXVmDdBM
25jc/gJ9OG/cDOXLI1V2PUr5/bADud6egQ+xbxVBDT7Q6HyRKMxjMn40uWTg
hCTVa5m53VF9QLDyW+WndjQRDan+WRgw/5Kisp0sbX6JqfgIKhM+RGB54sME
OH8WGC1yyIv3WOj8aaVQdKfQFukOoeaqqy3sCbSYfwc+lOXqoO1WjW5HxVh7
3G2b8kAn58Mv2iNwQROpOaWs/+uitVgXoRwSX2YD9N5P/56uVX8p1Ol7NTp1
wLCNtNZRwYlbt70wxhMi4NZgdBgnYEdgSMFRbTqsOyE82NLMrAqpaIHfrtHh
RrSM6IFSExYwLej/SQGY989P0LKhP9B9/w9sSzAxGpaTToxtFX06c1rtt12j
CcOPlM6UkpGQYHMKfQt2HRj05vpVOVQL+CZqEDvceA82ZCE/oJDJ0eOcdcD+
SgzcOtJB4DKb2NqkZ+6oGfFrIFCUCUGHQJa93Pl4ZQl3sbapr65und5S8yZJ
OrEArnoXldK5BNeluM7oupUKpDKHvGM6kKRjVQBGRg1lFWMW0pvZ+4sL1AZb
kQn+aNXJJNG2mnp0HFtzaCFtmI1ZDbnCBHteOh9YdT1glBFR6J/Su6CX3mWY
C65W
=jAkb
-----END PGP SIGNATURE-----


-----------------------1dff28ad013210c90ab019f8f883e242--

