Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C89FC606AF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C4FD21655
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:42:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C4FD21655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B09E68E0011; Mon,  8 Jul 2019 08:42:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A92438E0002; Mon,  8 Jul 2019 08:42:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90B388E0011; Mon,  8 Jul 2019 08:42:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 556278E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 08:42:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so4349814pfd.3
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 05:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:mime-version
         :content-transfer-encoding;
        bh=SQ85GfuYXyAcQHM/d1IFhPMx5jZOxnGx2l6M3JbrWtU=;
        b=ceu2wRfKddHgCC0cFmqhQkKf1ttxOXhtZhNNX5O5Tk0WmS7s/axKHrSpJTdkq2a+2E
         oTBEcrBrad0ND/WEj05HnCkAqpCQGptwnvn2zFXqvCdi3FUQcGDMXSTAWUWjUcsdWwht
         KcVb3zfRCLFddoy97Rtmdu4siQeRBqMEX9D9rU8ne4PFD+w+lZYdg1alyBb2M8xw9SsK
         eB8YcQ+0lZ8D7/qZfNxbf5LyWa0jc7yBe260WDPJYEQ+mIJ12WMu4pHPz5sCqfEf9RE/
         B/YgCZp7bLE7/4z8V2J+ud2oAgsYL5jo6w+Im71VDVEfSn1Il62jKlg0z0EjFtAUw4gn
         NZDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
X-Gm-Message-State: APjAAAXU8GTCjuTGGnRgvw8xuxHRur0kPuEAfJmNJ5W0GmP9karWUpBP
	8pQt/fFh8r9CEXWu4l7bBKC2PoChRmeAyPBpbzlI60TsIA5os8tOEiwT2OQuB/DgkWaP15Rwz6H
	wM/zQNh8cAnGlpKTaP6lxpF1/PZvp5qsHTH/7TJp3bxJbLiFOPyzorM+ENW49EiyRsA==
X-Received: by 2002:a65:640d:: with SMTP id a13mr23403791pgv.256.1562589741889;
        Mon, 08 Jul 2019 05:42:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXkDbGzBttL6ukYX37rFXD/Bu08VpIWmwP+92X8bry1Po2JxZtLmwStxjXZYkRQVbWWAgs
X-Received: by 2002:a65:640d:: with SMTP id a13mr23403647pgv.256.1562589740656;
        Mon, 08 Jul 2019 05:42:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562589740; cv=none;
        d=google.com; s=arc-20160816;
        b=nGggq7flTAyGVjRM+WvZj3XtI8QHYLjB9RZDFDJ6REN6kGY0da1XkzuubwD1lKvtkZ
         D2U76bHLiA9ufYNN4wRat9fN2aql1KZwIbmxoOkh2aHUk4gJj0PGl5YYqbXoqIQkRGSU
         Ab+l6AdsbAbjGaPdP0VTDmsE2M2Qq2fv2MUmMsywFzbBHUwS6vGUxP2aoyvQcddXez+T
         SCVzTkQ1a1AfY94dq4HFYQAMKH8UIx2uxsApuw/rRQRB1ZmQhCO0uhHszVwZ0smk68Bv
         GrhskB5rNF2oBbA871djr85iZZvFd4LIQTB2gE2owW4Tz3opH7h7qVlD0zJ1RkYpPQdB
         PusQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=SQ85GfuYXyAcQHM/d1IFhPMx5jZOxnGx2l6M3JbrWtU=;
        b=Q1ngSGDz+1Sr3D4hYoOb4ump4yMMJmKKyoiSZ7p7B8WMixl/6GNwdcLXrSM/ou+YGv
         yAwtsZlhnmUTStoUXmlpSO/BPkPlvitCzRk2c0W9RFb5rLBr4DaxJNpW2ewl6K9A9Ji6
         jd53H9/MB1BHhTbnCVpssJouPWxvxnGxO553zyqY68ZOg/p+bbYYsLN8kOwsRwc6EPDl
         BsyR/pjN7KGQ5GThdpVf65TkU0xS02EMV/X7mTrQ2sfNHm0WMY7lSwcu0IjAHAI+zlEv
         jWvXfiQjkwRlJSi+dLqV9LfU2e0+dmrzhUoerTik+FXrRG+Hl1oZN8M3d+Fap5ijC8l/
         0lvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id a17si20141494pfa.45.2019.07.08.05.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 05:42:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) client-ip=207.82.80.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-230-dcsia1rtNYyT8xw3SipVDQ-1; Mon, 08 Jul 2019 13:42:16 +0100
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Mon, 8 Jul 2019 13:42:15 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000;
 Mon, 8 Jul 2019 13:42:15 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Salvatore Mesoraca' <s.mesoraca16@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, "Casey
 Schaufler" <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, "Kees
 Cook" <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, "Serge E.
 Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v5 06/12] S.A.R.A.: WX protection
Thread-Topic: [PATCH v5 06/12] S.A.R.A.: WX protection
Thread-Index: AQHVM+lhx/3G+gwH+UeGA1TJk0kwgabAq9yQ
Date: Mon, 8 Jul 2019 12:42:15 +0000
Message-ID: <b946dd861874401a910740a9adea8e8e@AcuMS.aculab.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
X-MC-Unique: dcsia1rtNYyT8xw3SipVDQ-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Salvatore Mesoraca
> Sent: 06 July 2019 11:55
...
> Executable MMAP prevention works by preventing any new executable
> allocation after the dynamic libraries have been loaded. It works under t=
he
> assumption that, when the dynamic libraries have been finished loading, t=
he
> RELRO section will be marked read only.

What about writing to the file of a dynamic library after it is loaded
but before it is faulted it (or after evicting it from the I$).

...
> +#define find_relro_section(ELFH, ELFP, FILE, RELRO, FOUND) do {=09=09\
> +=09unsigned long i;=09=09=09=09=09=09\
> +=09int _tmp;=09=09=09=09=09=09=09\
> +=09loff_t _pos =3D 0;=09=09=09=09=09=09\
> +=09if (ELFH.e_type =3D=3D ET_DYN || ELFH.e_type =3D=3D ET_EXEC) {=09=09\
> +=09=09for (i =3D 0; i < ELFH.e_phnum; ++i) {=09=09=09\
> +=09=09=09_pos =3D ELFH.e_phoff + i*sizeof(ELFP);=09=09\
> +=09=09=09_tmp =3D kernel_read(FILE, &ELFP, sizeof(ELFP),=09\
> +=09=09=09=09=09   &_pos);=09=09=09\
> +=09=09=09if (_tmp !=3D sizeof(ELFP))=09=09=09\
> +=09=09=09=09break;=09=09=09=09=09\
> +=09=09=09if (ELFP.p_type =3D=3D PT_GNU_RELRO) {=09=09\
> +=09=09=09=09RELRO =3D ELFP.p_offset >> PAGE_SHIFT;=09\
> +=09=09=09=09FOUND =3D true;=09=09=09=09\
> +=09=09=09=09break;=09=09=09=09=09\
> +=09=09=09}=09=09=09=09=09=09\
> +=09=09}=09=09=09=09=09=09=09\
> +=09}=09=09=09=09=09=09=09=09\
> +} while (0)

This is big for a #define.
Since it contains kernel_read() it can't really matter if it is
a real function.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)

