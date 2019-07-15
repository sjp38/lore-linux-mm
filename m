Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AF4DC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:28:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77CB12080A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:28:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="anOF09A9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77CB12080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C90F06B0005; Mon, 15 Jul 2019 19:28:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1AAB6B0006; Mon, 15 Jul 2019 19:28:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B09486B0007; Mon, 15 Jul 2019 19:28:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC556B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 19:28:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so14819443edr.13
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:28:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version;
        bh=T9V8nyAYacgOHu9qVaULQEjZGV1mejSM74PefvCkMvA=;
        b=HRxKNzUJXn/+/MppMzAQOEFpy6XS1h8SZjhFJkikDyoq6e7Dqo9YGcUG4OVUh75/sP
         eRXURcP+2VykHuLGORR5j9olWQrAOtAaJQwd6Y7Iogh0e7w8qrKzEdoTdO/R9ZswKYZ5
         D3GgZyTtKbNqhOUjzHKOyalHPyU4TQkTKA8Q19dOsVYnFl4pl99yeKa9YSpn3GdvYVj+
         LPUIVYBAz7RP87UusAuPL5dedWt1f4IKAE48mBsHVp+F6XvB5nnD3sHQRp5cha/8XfyA
         Ae7tLr5bRP3TwvBcNgj1CoOtkd9W5GgDQ4u5Qz4G6lgPlUTAr8kxmesoNUkdGyjApdJ9
         pc+w==
X-Gm-Message-State: APjAAAVG54rAN6c9u6YEEO7PfQUlHOi0bOkbttUQIO3RmBPcnL8gTTRc
	lb0Jgca2G0SdljN9oqSJ40Ip3WcA3obJbDqXMZK6armWKXxsMTOfmVWGWruW5yPTgtvJl6xewvF
	7EtrQsb/dQKc3g6xOoWBoi9KVhvrKX5lHO2AvvNyK/V2AYTysdQO9spoxItY/Mvhj2w==
X-Received: by 2002:a50:94f5:: with SMTP id t50mr25827192eda.150.1563233306819;
        Mon, 15 Jul 2019 16:28:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8I17XVGMG9yLdqg/m1xvj1lzGovIGeVb02QHv3JSNX2edwdYOhEvwYKHnkX2KBM8nRymE
X-Received: by 2002:a50:94f5:: with SMTP id t50mr25827153eda.150.1563233305844;
        Mon, 15 Jul 2019 16:28:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563233305; cv=none;
        d=google.com; s=arc-20160816;
        b=vAr+v9Egcbp9bDwA/dYWK6G59YNlpxDP0Tp8MJnHgRyY7Hznh5ahfIzgVtPy59yGa5
         bVGHRJilTigOkIycRbiNl6NpVByUdaPIUqAuZZv+RAXWt+PnDNLSwI60YLU5kTU8cKXg
         rXkTRigA3BWd+XfmzZ6msiDdx1eebhxYsnT8K6Yarkzk3gi2weCh0XFXmd2KgjKdlPhO
         IDE+SvbACbDRkUDfRi9XEBIU7H3cwH1t1t16emaE6J09kHgcLWe72y/6CoJltZPnCvhs
         6vdmJdPBITpnEqaPFcdG7OoKnLFJriot8iWLc6WvEhMetMPq3+wqiI4aEecx+HrY92Xr
         7/MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:feedback-id:references:in-reply-to:message-id:subject
         :reply-to:cc:from:to:dkim-signature:date;
        bh=T9V8nyAYacgOHu9qVaULQEjZGV1mejSM74PefvCkMvA=;
        b=YtEb9yKJkWpMsvavAn4bNHgahJfJIPdSJBBme+s7IRaAV6M6NESEUWPFnElLarAW7p
         Jq34EEyrYaDhPq/FSFj2oGrVFZ4XjVGGt8XOe43QF/nkspB4kZh3PmpiLAP8M6tJneWv
         Z/fP4wtGU1Cuo68287RvqoHE5RY0U+zZO9LFjkCAX5ZIiLTqQX3dQnQGOM+UsyQ49p7w
         5zPr2H3lVVWOQEvKfszFRHHKoJ8xIcL1NzSxty3mqpSO6MV/Wd2UO3CXYaIGO60ANUAC
         jXB0x3NTxDXM51ANV0J7oaN62Gifpx/QeWRee3QGEPE2EzxNJ5cLX33U3XxS6jhqhqko
         nhvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=anOF09A9;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40136.protonmail.ch (mail-40136.protonmail.ch. [185.70.40.136])
        by mx.google.com with ESMTPS id os26si5990216ejb.346.2019.07.15.16.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 16:28:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) client-ip=185.70.40.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=anOF09A9;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Mon, 15 Jul 2019 23:28:22 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563233305;
	bh=T9V8nyAYacgOHu9qVaULQEjZGV1mejSM74PefvCkMvA=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=anOF09A9Z55TfxNh8FPLRkvq9CkbfDC2fcEQTQ0WjPcyPvsFfvV2hKbN2UcDEHekX
	 JEpCYr8ILn9c1HHYph/sXprmMg6yb+lStsvKURaNBlnC0HoW8M+Jv/xX5fjz2Ezm5z
	 IzzbLvwMO1qJ1hF83d5KetgMbG9pIPkLqOy2wPCg=
To: Andrew Morton <akpm@linux-foundation.org>
From: howaboutsynergy@protonmail.com
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
In-Reply-To: <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha256; boundary="---------------------f9cf7709289c0253c27547d854b711d7"; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
-----------------------f9cf7709289c0253c27547d854b711d7
Content-Type: multipart/mixed;boundary=---------------------b2ee6b90a20cc8ef21998f5505683477

-----------------------b2ee6b90a20cc8ef21998f5505683477
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;charset=utf-8

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original M=
essage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Monday, July 15, 2019 11:25 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:

> (switched to email. Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
Roger that.

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

Regression: yes? =


I'm not sure... =


tl;dr: seen with kernel linux-stable 5.1.8.r0.g937cc0cc22a2-1
And really not sure if I've seen it before.

long read:
At least one previous kernel did because I've seen this before in https://=
bugzilla.kernel.org/show_bug.cgi?id=3D203833#c1 where I thought it was due=
 to 'teo' governor but it wasn't (I'm using 'menu' gov. now)

I didn't mention kernel version there, but according to irc logs where I s=
eek'd help at the time, the date was June 10th 2019 3am, checking which ke=
rnel I was running at the time (thanks to my q1q repo. git logs) it was 5.=
1.8 (stable)kernel to which I updated on Sun Jun 9 10:50:09 2019 +0200 and=
 have not changed until Tue Jun 11 05:16:59 2019 +0200
local/linux-stable 5.1.8.r0.g937cc0cc22a2-1 (builtbydaddy)

Side note:
I've encountered something similar here https://github.com/constantoverrid=
e/qubes-linux-kernel/issues/2
 where kworker would randomly start using 100% CPU and couldn't be killed.=
 The kernel there was 4.18.7, the VM had very little RAM in Qubes there. S=
ince it's probably a different bug due to that stacktrace being so differe=
nt/unrelated, please ignore.



-----------------------b2ee6b90a20cc8ef21998f5505683477
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
-----------------------b2ee6b90a20cc8ef21998f5505683477--

-----------------------f9cf7709289c0253c27547d854b711d7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: ProtonMail
Comment: https://protonmail.com

wsFcBAEBCAAGBQJdLQwSAAoJEBz9yWB4WvJMM/AP/2JHLLahw8i0MK148X/4
RYMN/ftwXi0yymqK0jHwKIbmdxuM1XO4pgKVTkjxhAeRmi2+O95iWDGMnXf5
Tm8MJFEcie6SLsHOWewNI2uTQkXHZCJGIExXIENDpikOUU6MnMOfDtvUOLid
Bt/Ic/arCf9Udam6bOaQYsECGleBH59lk8EHpQ0CNFgv/ZFmlgLJ8Tl6QCA1
EHYjGvTF0AZJK9sAaMpDyXfDD5dTBCNdbTxr/U1V8qebcJciZfShCkmq7I0X
K/8YlGN+IEOyvixY9UIazBL8zfNejKVBygCUPKa2e3J4DCe2NdW2homOmzJ3
MRHusC7Xc6zb4FG/q7MBhQDrUZ5KK5+Y6QtR8ahUka2kSA4CLmPXEXy+1ozb
97iGvgoTsKg2mPJYOE3cNd9a9kYjxJueapAo3t+TcTWLE1tM4lNqW529Bmg9
OcLqEUdNJQ+FPzEuYNv/2lGIiUsY+8fablirfKqMiAukO+r5pG76aYj0uRj1
5vpvOuuOYSJ3Yt0743UHfDg/YLPJXLHPPaIpRpWJNctt6vgk3sRIcYWb+ShS
sDRw696TY3/02VZWZ+drgCXDlEPgHkXTCczX2Z37l5VC8UVSpVyRxH2cTkIG
2DQiAPn3KmsJvidnIAPB72Xxg/DZVTaO8JsPDKyJnUCGPCHNSw3H0BuHNsJM
rCkv
=zFdX
-----END PGP SIGNATURE-----


-----------------------f9cf7709289c0253c27547d854b711d7--

