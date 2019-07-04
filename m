Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DB06C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E322E218A4
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:50:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E322E218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71E3E6B0003; Thu,  4 Jul 2019 15:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF438E0003; Thu,  4 Jul 2019 15:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BD328E0001; Thu,  4 Jul 2019 15:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDD16B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 15:50:28 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 17so1880084wmj.3
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 12:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=80i31qefcXSPw5bHW1WC20YEaJkGzwOklQ+9tm93DtM=;
        b=W8MxfdjRpMsK5KVhOs5SHqvjYNDyl97mI7g0+ru0hx2KGZKRSKlaN8ie2FpnD7/X4J
         efJ2rDuQu1BUrv+XKPMHdD+Zl28mTSjDRR+I+8UaVW7hN885F8uXKJP1mfkhDsD2f0TL
         ROPxgKW8dyW2/dkWtPa0qh6P8q8XlYjYuDWZzFmcYWESqj697jYZkfhujopVurfNqXIP
         U7f5nZQkatbmRSAa+c5s6GVfwTokNsloLIaAVwimJ/eKffpTIixhtf/BByIm4H2qv814
         jfy55jd5PpCPUw3Sk1t1zVSc3XAZ+M5N7i7svwLNiJ7uktJiT6obcQKJQzyIkmrnXNzN
         B/IA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAUHQVMAkguKTBr+9Dwa31ulq1zEU4AkMx7uzF1c548+BhIJ65FM
	OFf9wkV9jI+6l4NgZVTnKaiUDZW6jyueTZOTNM6+f+/E+DyQfxRMD4R9BXI1NZQwYdarOLO0zUD
	LjtZ3+IodYROoLvRS4dy7ECsHMzwQ8scbgcSEznOsky4E1V/pG8xgyVgAxZF70qg=
X-Received: by 2002:a1c:2dd2:: with SMTP id t201mr719587wmt.109.1562269827519;
        Thu, 04 Jul 2019 12:50:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAUNPE4dNBQ97775ETn/AfsirSI/EEklu7ulRHyOE6ANxTPn3ITw2w7e+S4Ey7WWtnMOsK
X-Received: by 2002:a1c:2dd2:: with SMTP id t201mr719563wmt.109.1562269826684;
        Thu, 04 Jul 2019 12:50:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562269826; cv=none;
        d=google.com; s=arc-20160816;
        b=fYHoYrwQL3kksYsaUZMLQe40JgmUUwKE8/uVz1Uk88exzJ4rGPuhn1h6Tt1nNqATtz
         ieetL+WwpTCrFb0erBIkIQcTOBzsHDA9ePBxEfml+KH686Ec3dzJg1qxnqq+iGEycK22
         E+AbnhfzANsueB7IZmjGFTneh+yH8Vl78dpbTM+NCDPMixAAvfC5xDS1AOq0GT8VGfoM
         ItFcwS7JnfORsAjgd+qY+EyAgBxJvXplD8zQgRpcDnkuCgCy54TPC3IPg/BX95mf8mtk
         39URWLs5OMP4pneuz48PJyXIDb6aml7mWpndlWhdZrl09cT9PGxiWXXQb/FREzTxcCJ5
         Lk1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=80i31qefcXSPw5bHW1WC20YEaJkGzwOklQ+9tm93DtM=;
        b=GmisCLz1tiUzwYqkiYN9KdODD5dCALrBoEYZTqbhK22ofZi9/Ew6dc9h7zdA3qYk3Y
         zxwP4zT9ry0MkZiXNitE+bvSF9FnzcqBo+Ml+CA4x4mdfNfrSXUFAomEwU8gGseMafeb
         k5Q6cka06o6qhWW06A8jezDp969WSz2qI8Ftn0I7CFsi7b+kmwPPjevck2CcRtNnWDVb
         hktvLX0RG1w6QhZcHkV5+YBr9UHG295yzDxZc5+60Osn9gwwD3LjcsBc6SmtKGh28vU/
         +6GhBtiHWGy+xDCXRON743rkpsoZAMDW/MvMOhPf+Cj8jyqLcxw4Ja4mZN6sGfEdUR3I
         HKoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id o21si173587wmh.11.2019.07.04.12.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 12:50:26 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 67D7A8067F; Thu,  4 Jul 2019 21:50:14 +0200 (CEST)
Date: Thu, 4 Jul 2019 21:50:25 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Jann Horn <jannh@google.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,
	the arch/x86 maintainers <x86@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [RFC PATCH] binfmt_elf: Extract .note.gnu.property from an ELF
 file
Message-ID: <20190704195024.GA4013@amd>
References: <20190628172203.797-1-yu-cheng.yu@intel.com>
 <CAG48ez0rHHfcRgiVZf5FP0YOzxsXigvpg6ci790cmiN6PBwkhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <CAG48ez0rHHfcRgiVZf5FP0YOzxsXigvpg6ci790cmiN6PBwkhQ@mail.gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!


> > +static int scan(u8 *buf, u32 buf_size, int item_size, test_item_fn tes=
t_item,
> > +               next_item_fn next_item, u32 *arg, u32 type, u32 *pos)
> > +{
> > +       int found =3D 0;
> > +       u8 *p, *max;
> > +
> > +       max =3D buf + buf_size;
> > +       if (max < buf)
> > +               return 0;
>=20
> How can this ever legitimately happen? If it can't, perhaps you meant
> to put a WARN_ON_ONCE() or something like that here?
> Also, computing out-of-bounds pointers is UB (section 6.5.6 of C99:
> "If both the pointer operand and the result point to elements of the
> same array object, or one past the last element of the array object,
> the evaluation shall not produce an overflow; otherwise, the behavior
> is undefined."), and if the addition makes the pointer wrap, that's
> certainly out of bounds; so I don't think this condition can trigger
> without UB.

Kernel assumes sane compiler. We pass flags to get it... C99 does not
quite apply here.
								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAl0eWIAACgkQMOfwapXb+vLSMgCcC98TTx9pMIkokJGKGUu3i6ME
o+AAn3TIA7Pjz5wBcK19BycwV2+shMN6
=83sj
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--

