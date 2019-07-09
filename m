Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B564C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF0A216C4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:51:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SagoGHLw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF0A216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7200C8E003E; Tue,  9 Jul 2019 00:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AA248E0032; Tue,  9 Jul 2019 00:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54B0C8E003E; Tue,  9 Jul 2019 00:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD088E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 00:51:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u21so11693728pfn.15
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 21:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=NHGXxZKoUC+etV5J4TA2pzGAE32N1lUMWS0xtU10i5g=;
        b=gl6GEKo8UnJq6wxz1Q9hD2MYstueEgdRdz7e2oU6aeODHNFhTSD/eesldefMClAju8
         lzkkwT4kI6xKMvGF6oha2FkSoPIiq3vcvr6NIiKurQgM0IJw1UJp8PLpnwBxU3/vhwJT
         ilf9bRD3QLNjnmAktsEFhBYxnwfCTLZ/qsZ2u9+0rcikt4R0Gv3PJPu5g9zvjcE/JZ0r
         ciOwDJWgKWGpobItjVRruXTSe3n1rZDHIoJYK/qEKEaypryIFh1swzCCOR96Yk/oRbkv
         U7hWJFK8oIhFbZ1in+icPMsOSaMCgZYcimEP61++JQeaZQxT/L1Peig8HewUeyDKJxhl
         DMZQ==
X-Gm-Message-State: APjAAAUCsbCbg8AeXwHJ9lfx4UET3uBFcoDPoA7EPi+tD4gGKCsGlKUJ
	hYuP2Y1ULG/i56qkYqWTNrghYTkdAYNPoNgbbzTHrNk5RY7iYSmcM9sEQxom+vHhd34sBg+ht6H
	BGf4P85NRXmKT/6ycaf22fw0hF4FJme5Lh3exnC8vlb4zJEuHPV0OljsYNJct+EvG/Q==
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr30665941pjb.53.1562647874779;
        Mon, 08 Jul 2019 21:51:14 -0700 (PDT)
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr30665868pjb.53.1562647873971;
        Mon, 08 Jul 2019 21:51:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562647873; cv=none;
        d=google.com; s=arc-20160816;
        b=RKX2Ha0W0/vnTFbrpPZKL1rVHXvOPFB1c9ei3+lcTYFQ9B5q+Z3ipYiScm/qvNF6AG
         +LT5FLoJyDZkTDG3x65KqpFpjHZCYNeLizNlD1/dvmTKSSyN0EXcEesH6e5zv+waI3C/
         h7mhYritBNEMVOJCr0PBPwMukuZvMytX0h9MUMdXzQyClDtqOTWjgYdZ3CpIFFX6uVT9
         Azi7ycmXeunqFIlujseISElr1dg115GbyxVJ+Hp2Urv5c+ZwgD86McxefbivTSa5clk6
         5V7e89Ga/HUvXCaaG23zP6X+BqSeVMzUbV9cwTXVBaISU1Kg3+ZMuOHh+gFRux4+9h1X
         xe3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=NHGXxZKoUC+etV5J4TA2pzGAE32N1lUMWS0xtU10i5g=;
        b=Z2uCxb1m8x8u7IwIHGRLAkkyu3xxsUsiF8tw7OM4kejai32cHJS2HDOIQ+PT82Fg6p
         gHfn8ydbYHAPGZxQ3gZUlxXaiTLRch5OoY5b3r3np2tk+DRh33hop35dua5BXQ0wNFJs
         PiJaN1wWssk4reqBVXI/QfT9ukgSToVwzWvau1vhULY0eYD3Op2lfrzZSTLBUdII2gzF
         1Ih0SiB20Nt6Cv4LlcFg4TfKTJew2O9pMG6e6L71Advp+pUJalmZetKrNeprzCI6YMqr
         5WKEPKZnvEcK93vq+AKFLebFaoRylH5LdgzHvQ12LUD567kQLDePxAjAT9rJvGEGHGlN
         QIXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SagoGHLw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor3997030pfq.72.2019.07.08.21.51.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 21:51:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SagoGHLw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=NHGXxZKoUC+etV5J4TA2pzGAE32N1lUMWS0xtU10i5g=;
        b=SagoGHLwdhyzez71wGl/CWUd7JfpmwBlosfeoAMty1PvK2lxm4NEetTyojTrzhwaud
         Ts1+0xOhHRFwpsMA3AASevOpJhCQpHPI498ZcCp2Qj9585GB+tRmt389Z+LWTJKx/y7s
         mH1FVgB0X1hwFpGEC/wHgqIXjB8rWZKfMla1I=
X-Google-Smtp-Source: APXvYqyra4dBr6pwAJEejOYr3AfqsfOhUfKQCLpljKcJwOvohsdTUY/A0C/0JPVAWBLwSN9mXPaIsg==
X-Received: by 2002:a63:7a5b:: with SMTP id j27mr28067294pgn.242.1562647873177;
        Mon, 08 Jul 2019 21:51:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id n7sm23797582pff.59.2019.07.08.21.51.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Jul 2019 21:51:12 -0700 (PDT)
Date: Mon, 8 Jul 2019 21:51:11 -0700
From: Kees Cook <keescook@chromium.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	Brad Spengler <spender@grsecurity.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christoph Hellwig <hch@infradead.org>, Jann Horn <jannh@google.com>,
	PaX Team <pageexec@freemail.hu>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	James Morris <jmorris@namei.org>
Subject: Re: [PATCH v5 06/12] S.A.R.A.: WX protection
Message-ID: <201907082140.51E0B9E2@keescook>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com>
 <20190706192852.GO17978@ZenIV.linux.org.uk>
 <CAJHCu1+JYWN7mEHprmCc+osP=K4qGA9xB3Jxg53_K4kwo4J6dA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJHCu1+JYWN7mEHprmCc+osP=K4qGA9xB3Jxg53_K4kwo4J6dA@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 07, 2019 at 05:49:35PM +0200, Salvatore Mesoraca wrote:
> Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > On Sat, Jul 06, 2019 at 12:54:47PM +0200, Salvatore Mesoraca wrote:
> >
> > > +#define sara_warn_or_return(err, msg) do {           \
> > > +     if ((sara_wxp_flags & SARA_WXP_VERBOSE))        \
> > > +             pr_wxp(msg);                            \
> > > +     if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))      \
> > > +             return -err;                            \
> > > +} while (0)
> > > +
> > > +#define sara_warn_or_goto(label, msg) do {           \
> > > +     if ((sara_wxp_flags & SARA_WXP_VERBOSE))        \
> > > +             pr_wxp(msg);                            \
> > > +     if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))      \
> > > +             goto label;                             \
> > > +} while (0)
> >
> > No.  This kind of "style" has no place in the kernel.
> >
> > Don't hide control flow.  It's nasty enough to reviewers,
> > but it's pure hell on anyone who strays into your code while
> > chasing a bug or doing general code audit.  In effect, you
> > are creating your oh-so-private C dialect and assuming that
> > everyone who ever looks at your code will start with learning
> > that *AND* incorporating it into their mental C parser.
> > I'm sorry, but you are not that important.
> >
> > If it looks like a function call, a casual reader will assume
> > that this is exactly what it is.  And when one is scanning
> > through a function (e.g. to tell if handling of some kind
> > of refcounts is correct, with twentieth grep through the
> > tree having brought something in your code into the view),
> > the last thing one wants is to switch between the area-specific
> > C dialects.  Simply because looking at yours is sandwiched
> > between digging through some crap in drivers/target/ and that
> > weird thing in kernel/tracing/, hopefully staying limited
> > to 20 seconds of glancing through several functions in your
> > code.
> >
> > Don't Do That.  Really.
> 
> I understand your concerns.
> The first version of SARA didn't use these macros,
> they were added because I was asked[1] to do so.
> 
> I have absolutely no problems in reverting this change.
> I just want to make sure that there is agreement on this matter.
> Maybe Kees can clarify his stance.
> 
> Thank you for your suggestions.
> 
> [1] https://lkml.kernel.org/r/CAGXu5jJuQx2qOt_aDqDQDcqGOZ5kmr5rQ9Zjv=MRRCJ65ERfGw@mail.gmail.com

I just didn't like how difficult it was to review the repeated checking.
I thought then (and still think now) it's worth the unusual style to
improve the immediate readability. Obviously Al disagrees. I'm not
against dropping my suggestion; it's just a pain to review it and it
seems like an area that would be highly prone to subtle typos. Perhaps
some middle ground:

#define sara_warn(msg)	({				\
		if ((sara_wxp_flags & SARA_WXP_VERBOSE))	\
			pr_wxp(msg);				\
		!(sara_wxp_flags & SARA_WXP_COMPLAIN);		\
	})

...

	if (unlikely(sara_wxp_flags & SARA_WXP_WXORX &&
		     vm_flags & VM_WRITE &&
		     vm_flags & VM_EXEC &&
		     sara_warn("W^X")))
		return -EPERM;

that way the copy/pasting isn't present but the control flow is visible?

-- 
Kees Cook

