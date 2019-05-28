Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D34C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74182075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:54:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74182075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B63C6B026E; Tue, 28 May 2019 07:54:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2664E6B026F; Tue, 28 May 2019 07:54:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C3E6B0272; Tue, 28 May 2019 07:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD06A6B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:54:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e14so10411828wrx.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m06acolN1j8vOdMrN03K65G8SlY2hmv7dm/Qi7OArks=;
        b=P1sLaO8c8yITxCJ43cvwzi8wp8/3NgoGXk37+ATKAdGVBruVfxgaPBcFxSzL3yb1if
         Cgm7KDIG9/YPIFGa2/lIdWS7jGq+gTIZHFwn3LE9wph8/dywhb3E64o41Kn57tJcUwNg
         tP1i3CcFy2BanoEVMhqOa/9Ce8vRQ05yJvmujOlf4y0yBRBF4QbxLC49k2acqMHIGiCb
         S32wrkhDhwO1vfrYWhWfRmSjOpEWqYoDoZm1m7YTyfPZAw12g9LNY3iRKJo+bblhNbnq
         fH6Xor6Sv/mVjrmEw6NM2dovUK/BYgywkdA/WfpS4PJv/z2A6It37ofQgpDeDIg5TTPP
         gyYw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAUaw0MIbSJ0tlspMDcEBUzmzYfCtFnnvbco6XbrR5qmNHsk1XBi
	p/o5U2tfGAWYDl7W7GYgpqUQkHmFxtxHHnRm5Fvv6FDtZMBGyDWOXjTs4XHMXR6bjWw031iMldf
	BHZYUCIdgK6eDbTlJqJGAHlEXGZapC2nunsIZq96QHA39hl1Npy8hFsIi87kjuQA=
X-Received: by 2002:a1c:9e08:: with SMTP id h8mr2810983wme.168.1559044486154;
        Tue, 28 May 2019 04:54:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyTdFbCk1WCRgq4QlK/caCg6gRdz8KqM0CfKMTNiaW9dCmbHXUlymbRsTo2s+RA53OiCIO
X-Received: by 2002:a1c:9e08:: with SMTP id h8mr2810925wme.168.1559044485128;
        Tue, 28 May 2019 04:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559044485; cv=none;
        d=google.com; s=arc-20160816;
        b=CriHf6coal6trfTmDidjal1QJ/FAk70huDv9YID57XvGFj4FlWMSOutzcKDMOh9zEe
         3EdnCuslN1EoVb/V40lemkV+7RdQo1ezcsWNip3jLDLGiwjXr7VLHfrqzn+Hucv4g1HY
         J0Y8Elf5ihgR8VuMdmwjkFS/5KmQhbR8Um0yUS6PVbADk5Xu2mYrrm52Yo+6puyfLtOO
         vMzOeqGjMZeZxif/oVwKYXFlOlHxCCXfWaFYwGOVytODUAARvcYJ+KsQJjbE+hPn0LPa
         4SJANPWxvOHzAKQlYhmXPsrIxqUfgvl8Zojo8yrYur5NksMqsSddlzcWBnx+8dBRzv5B
         tjXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m06acolN1j8vOdMrN03K65G8SlY2hmv7dm/Qi7OArks=;
        b=CaFNG3OW4tMRzbN9k4so1n2qw1eeKKGYnbOEeInvJKrTOQnLxOgDd8t6cQG6xPfEmU
         iZrV2/2AaN4NsiqHJOAgETSO5e5i7xf8+oVfRHfcUIHC1aIErbOsNYKgyzuWEkU4WOXD
         G1q+YI9i1MF6NbmCx+nlb/z2+267aNwBpKwCaUAcH9BzGtzqgWzwmdHnchYiItJXX1nu
         znGzausyIucRQrU1YcBGZ3QqSyj/P8mQlvps40awvdjK+3QG8vV6e4cYNi7WPFjFgNaZ
         uKE8/jMs9x4SVu3nzHwgd8sHed2hye9f08Z/zDDkr7SwdClPHPs9NS8R8rPEwXIo92zG
         /sLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id w17si3454651wrv.115.2019.05.28.04.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:54:45 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 7B43E80324; Tue, 28 May 2019 13:54:34 +0200 (CEST)
Date: Tue, 28 May 2019 13:54:44 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Hugh Dickins <hughd@google.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: My emacs problem -- was Re: [PATCH] x86/fpu: Use
 fault_in_pages_writeable() for pre-faulting
Message-ID: <20190528115443.GA27627@amd>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
 <20190526173501.6pdufup45rc2omeo@linutronix.de>
 <alpine.LSU.2.11.1905261211400.2004@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1905261211400.2004@eggly.anvils>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

On Sun 2019-05-26 12:25:27, Hugh Dickins wrote:
> On Sun, 26 May 2019, Sebastian Andrzej Siewior wrote:
> > On 2019-05-26 19:33:25 [+0200], To Hugh Dickins wrote:
> > From: Hugh Dickins <hughd@google.com>
> > =E2=80=A6
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> >=20
> > Hugh, I took your patch, slapped a signed-off-by line. Please say that
> > you are fine with it (or object otherwise).
>=20
> I'm fine with it, thanks Sebastian. Sorry if I wasted your time by not
> giving it my sign-off in the first place, but I was not comfortable to
> dabble there without your sign-off too - which it now has. (And thought
> you might already have your own version anyway: just provided mine as
> illustration, so that we could be sure of exactly what I'd been testing.)

I applied Hugh's patch on top of -rc2, but still get emacs problems:

But this time I'm not sure if it is same emacs problem or different
emacs problem....

X protocol error: BadValue (integer parameter out of range for
operation) on protocol request 139
When compiled with GTK, Emacs cannot recover from X disconnects.
This is a GTK bug: https://bugzilla.gnome.org/show_bug.cgi?id=3D85715
For details, see etc/PROBLEMS.

(emacs:8175): GLib-WARNING **: g_main_context_prepare() called
recursively from within a source's check() or prepare() member.

(emacs:8175): GLib-WARNING **: g_main_context_check() called
recursively from within a source's check() or prepare() member.
Fatal error 6: Aborted
Backtrace:
emacs[0x8138719]
emacs[0x8120446]
emacs[0x813875c]
emacs[0x80f54c0]
emacs[0x80f6f3f]
emacs[0x80f6fab]
/usr/lib/i386-linux-gnu/libX11.so.6(_XError+0x11a)[0xf6ea1b3a]
/usr/lib/i386-linux-gnu/libX11.so.6(+0x39b5b)[0xf6e9eb5b]
/usr/lib/i386-linux-gnu/libX11.so.6(+0x39c26)[0xf6e9ec26]
/usr/lib/i386-linux-gnu/libX11.so.6(_XEventsQueued+0x6e)[0xf6e9f4be]
/usr/lib/i386-linux-gnu/libX11.so.6(XPending+0x62)[0xf6e90752]
/usr/lib/i386-linux-gnu/libgdk-3.so.0(+0x48073)[0xf7566073]
/lib/i386-linux-gnu/libglib-2.0.so.0(g_main_context_prepare+0x17b)[0xf70244=
fb]
/lib/i386-linux-gnu/libglib-2.0.so.0(+0x46f74)[0xf7024f74]
/lib/i386-linux-gnu/libglib-2.0.so.0(g_main_context_pending+0x34)[0xf702514=
4]
/usr/lib/i386-linux-gnu/libgtk-3.so.0(gtk_events_pending+0x1f)[0xf77c9a8f]
emacs[0x80f55a9]
emacs[0x812714f]
emacs[0x8126a95]
emacs[0x8172db9]
emacs[0x8192bd7]
emacs[0x819312d]
emacs[0x8125634]
emacs[0x8125c6d]
emacs[0x812725b]
emacs[0x8129eaa]
emacs[0x81c7c90]
emacs[0x8127815]
emacs[0x812ada3]
emacs[0x812bdad]
emacs[0x812d838]
emacs[0x818b76c]
emacs[0x8120890]
emacs[0x818b66b]
emacs[0x8124b84]
emacs[0x8124e3f]
emacs[0x8059cb0]
/lib/i386-linux-gnu/i686/cmov/libc.so.6(__libc_start_main+0xf3)[0xf61a7a63]
emacs[0x805a76f]
Aborted (core dumped)

Best regards,
									Pavel


commit 018c9da72adf920efd0ba250fcf433b836d3cfbc
Author: Hugh Dickins <hughd@google.com>
Date:   Sun May 26 19:33:25 2019 +0200

    x86/fpu: Use fault_in_pages_writeable() for pre-faulting
   =20
    Since commit
   =20
       d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigf=
rame() fails")
   =20
    we use get_user_pages_unlocked() to pre-faulting user's memory if a
    write generates a page fault while the handler is disabled.
    This works in general and uncovered a bug as reported by Mike Rapoport.
   =20
    It has been pointed out that this function may be fragile and a
    simple pre-fault as in fault_in_pages_writeable() would be a better
    solution. Better as in taste and simplicity: That write (as performed by
    the alternative function) performs exactly the same faulting of memory
    that we had before. This was suggested by Hugh Dickins and Andrew
    Morton.
   =20
    Use fault_in_pages_writeable() for pre-faulting of user's stack.
   =20
    Suggested-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Hugh Dickins <hughd@google.com>
    Link: https://lkml.kernel.org/r/alpine.LSU.2.11.1905251033230.1112@eggl=
y.anvils
    [bigeasy: patch description]
    Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 5a8d118..060d618 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -5,6 +5,7 @@
=20
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/pagemap.h>
=20
 #include <asm/fpu/internal.h>
 #include <asm/fpu/signal.h>
@@ -189,15 +190,7 @@ int copy_fpstate_to_sigframe(void __user *buf, void __=
user *buf_fx, int size)
 	fpregs_unlock();
=20
 	if (ret) {
-		int aligned_size;
-		int nr_pages;
-
-		aligned_size =3D offset_in_page(buf_fx) + fpu_user_xstate_size;
-		nr_pages =3D DIV_ROUND_UP(aligned_size, PAGE_SIZE);
-
-		ret =3D get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
-					      NULL, FOLL_WRITE);
-		if (ret =3D=3D nr_pages)
+		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
 			goto retry;
 		return -EFAULT;
 	}



--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlztIYMACgkQMOfwapXb+vI75ACdHJt+UjplhowDy8ZXEkJhicP0
z70Anih1OGc59Aa8Dl3kUnN28Z4i83Dy
=94bm
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--

