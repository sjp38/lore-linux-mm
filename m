Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75985C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 19:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D0B320863
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 19:37:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D0B320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEEFF6B000D; Sun, 26 May 2019 15:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9F246B000E; Sun, 26 May 2019 15:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A68696B0010; Sun, 26 May 2019 15:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59BE86B000D
	for <linux-mm@kvack.org>; Sun, 26 May 2019 15:37:00 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s4so7871329wrn.1
        for <linux-mm@kvack.org>; Sun, 26 May 2019 12:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Xhpv3rzZXCXdnhB3+ewBqAKXuOjOa/8zxNK7SCXnJwE=;
        b=Dfn3mFrsQxYEMgxXMy/0JbnEmL3WsYpBYALRed5oGNp+H/AtU0qJT54TlHCjBZ3y/W
         itcDum8T1EKIumJSPXInSVyNoMHUNEZG5onHtNH5zsKyTKMuqlRA2Wl1DdJk215GkXQU
         4feWToohcKS7D2r6GcXBeKwz8VdpXEMFsK4jt2KSB5KFSfJ6E7d1XY4+WE9SalDKUI1m
         PQGWmilypEmOR1XVY4Pye1Rqpqa+bHzd6OB/lU/Ggn7WvHGas+qA0Z80MndFgiu20RvD
         OgFqe/RSvyBY/tMB135zkyIQa8cfNr2OXen7Ve6NH+eLAVWF3fBYBsQIUFdAyRlFVLBX
         RMjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAVwYmUVfKRO7vO4rt57Sj/IodgxMKhLhJ9m4xuAe4vjpjTewxtM
	+O+Kpid97pTimVDplvcvCEIObxesa1ylfH8Z8Q+5CEaMicvKXUmAYBenxskvkdOD23lYYH0Wt3Z
	FcjN3sLz0bMqRjnccR/1Mm4AAYF0HEijd9cVJ26IRSw9QJJ+Az9PRIhKwdA9eVIWyOQ==
X-Received: by 2002:a1c:2c89:: with SMTP id s131mr23484178wms.142.1558899419421;
        Sun, 26 May 2019 12:36:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyG7PDpWjDiuoWtLTEhaSN6jEJYataPHRoq/SMwGrhosEmQvSjq156SBpo9Vk4NHmVDdYBp
X-Received: by 2002:a1c:2c89:: with SMTP id s131mr23484153wms.142.1558899418426;
        Sun, 26 May 2019 12:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558899418; cv=none;
        d=google.com; s=arc-20160816;
        b=nJABnQqEYcFFnABNpRbvzAEyziQ6JQP3unq4imckXHagw9oIIDCAjK0oYJ3C5NlDeZ
         0CajaxFLKy8EVrD5Gor5PJpAu7mD88lTE7Bh0C5lLWUDkEATCu4rIrGEoAatJNRVH3I8
         B4n108AkZzGDVQp5l7zBGs2rIZuu3wK+tEsKBlWTCvMcnQquF9wW2w0zp5fgfJEiUIYd
         U7pR4aZWcskDpCNbVcgLxW6fwDxtPnNE7oQIbeLk8ms/KqRLRbf7w2HvAqgfUVPIU7DB
         OO2z18vxZS2Fvo6sJ43FA/3CGY5HLCHvukUne6jLLEEbm/gcn2whhWGzcYorwp0Ik+yH
         xBDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Xhpv3rzZXCXdnhB3+ewBqAKXuOjOa/8zxNK7SCXnJwE=;
        b=bqxne43e7hsmISC7GD4h6LiK2PPjuM3vK8UfwWBDZRSTpgVrqAT4cxL3hVJLH0f9rv
         qgGb8YgpfWJJZQ/BywESINrp8W7D2RzX53I/3VFS5loc6wLnKAHm9hv9+rGH5Pd24l4+
         bAaGqhcaBEsSoBRlEIS9UmkduB5xPlVuLpuwqwjbNGxApiQ9QpKStBpFLGktJejvvYmZ
         BRUtTRAvAShdCqgrDwODlcA6mgms7/wFbRQULX80m6IZCcEpFyefyPWMGON/EcC60WAM
         BSBjSba7JENoo8EN56u1xQq76yoGUpfrxHPJNJ1yNifoX8OtDXxHY8KZwa+/LQ3eQ+N7
         SrIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y136si6568322wmd.196.2019.05.26.12.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 May 2019 12:36:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hUywt-00040n-BE; Sun, 26 May 2019 21:36:51 +0200
Date: Sun, 26 May 2019 21:36:51 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Pavel Machek <pavel@ucw.cz>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-ID: <20190526193651.spvm2vtrwxlhsjrv@linutronix.de>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
 <20190522194322.5k52docwgp5zkdcj@linutronix.de>
 <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
 <20190525084546.fap2wkefepeia22f@linutronix.de>
 <alpine.LSU.2.11.1905251033230.1112@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <alpine.LSU.2.11.1905251033230.1112@eggly.anvils>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-25 11:09:15 [-0700], Hugh Dickins wrote:
> On Sat, 25 May 2019, Sebastian Andrzej Siewior wrote:
> > On 2019-05-24 15:22:51 [-0700], Hugh Dickins wrote:
> > > I've now run a couple of hours of load successfully with Mike's patch
> > > to GUP, no problem; but whatever the merits of that patch in general,
> > > I agree with Andrew that fault_in_pages_writeable() seems altogether
> > > more appropriate for copy_fpstate_to_sigframe(), and have now run a
> > > couple of hours of load successfully with this instead (rewrite to ta=
ste):
> >=20
> > so this patch instead of Mike's GUP patch fixes the issue you observed?
>=20
> Yes.
>=20
> > Is this just a taste question or limitation of the function in general?
>=20
> I'd say it's just a taste question. Though the the fact that your
> usage showed up a bug in the get_user_pages_unlocked() implementation,
> demanding a fix, does indicate that it's a more fragile and complex
> route, better avoided if there's a good simple alternative. If it were
> not already on your slowpath, I'd also argue fault_in_pages_writeable()
> is a more efficient way to do it.

Okay. The GUP functions are not properly documented for my taste. There
is no indication whether or not the mm_sem has to be acquired prior
invoking it. Following the call chain of get_user_pages() I ended up in
__get_user_pages_locked() `locked =3D NULL' indicated that mm_sem is no
acquired and then I saw this:
|                 if (!locked)
|                         /* VM_FAULT_RETRY couldn't trigger, bypass */
|                         return ret;

kind of suggesting that it is okay to invoke it without holding the
mm_sem prefault. It passed a few tests and then
	https://lkml.kernel.org/r/1556657902.6132.13.camel@lca.pw

happened. After that, I switched to the locked variant and the problem
disappeared (also I noticed that MPX code is invoked within ->mmap()).

> > I'm asking because it has been suggested and is used in MPX code (in the
> > signal path but .mmap) and I'm not aware of any limitation. But as I
> > wrote earlier to akpm, if the MM folks suggest to use this instead I am
> > happy to switch.
>=20
> I know nothing of MPX, beyond that Dave Hansen has posted patches to
> remove that support entirely, so I'm surprised arch/x86/mm/mpx.c is
> still in the tree.
I need to poke at that. I has been removed but then KVM folks complained
that they kind of depend on that if it has been exposed to the guest. We
need to fade it out slowly=E2=80=A6

>                    But peering at it now, it looks as if it's using
> get_user_pages() while holding mmap_sem, whereas you (sensibly enough)
> used get_user_pages_unlocked() to handle the mmap_sem for you -
> the trouble with that is that since it knows it's in control of
> mmap_sem, it feels free to drop it internally, and that takes it
> down the path of the premature return when pages NULL that Mike is
> fixing. MPX's get_user_pages() is not free to go that way.
oki.

> > > --- 5.2-rc1/arch/x86/kernel/fpu/signal.c
> > > +++ linux/arch/x86/kernel/fpu/signal.c
> > > @@ -3,6 +3,7 @@
> > >   * FPU signal frame handling routines.
> > >   */
> > > =20
> > > +#include <linux/pagemap.h>
> > >  #include <linux/compat.h>
> > >  #include <linux/cpu.h>
> > > =20
> > > @@ -189,15 +190,7 @@ retry:
> > >  	fpregs_unlock();
> > > =20
> > >  	if (ret) {
> > > -		int aligned_size;
> > > -		int nr_pages;
> > > -
> > > -		aligned_size =3D offset_in_page(buf_fx) + fpu_user_xstate_size;
> > > -		nr_pages =3D DIV_ROUND_UP(aligned_size, PAGE_SIZE);
> > > -
> > > -		ret =3D get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
> > > -					      NULL, FOLL_WRITE);
> > > -		if (ret =3D=3D nr_pages)
> > > +		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
> > >  			goto retry;
> > >  		return -EFAULT;
> > >  	}
> > >=20
> > > (I did wonder whether there needs to be an access_ok() check on buf_f=
x;
> > > but if so, then I think it would already have been needed before the
> > > earlier copy_fpregs_to_sigframe(); but I didn't get deep enough into
> > > that to be sure, nor into whether access_ok() check on buf covers buf=
_fx.)
> >=20
> > There is an access_ok() at the begin of copy_fpregs_to_sigframe(). The
> > memory is allocated from user's stack and there is (later) an
> > access_ok() for the whole region (which can be more than the memory used
> > by the FPU code).
>=20
> Yes, but remember I know nothing of this FPU signal code, so I cannot
> tell whether an access_ok(buf, size) is good enough to cover the range
> of an access_ok(buf_fx, fpu_user_xstate_size).

yes, because size >=3D fpu_user_xstate_size

> Your "(later)" worries me a little - I hope you're not writing first
> and checking the limits later; but what you're doing may be perfectly
> correct, I'm just too far from understanding the details to say; but
> raised the matter because (I think) get_user_pages_unlocked() would
> entail an access_ok() check where fault_in_pages_writable() would not.

no, we first check the range and then write. It is later checked again
after the size has been extended.

> Hugh

Sebastian

