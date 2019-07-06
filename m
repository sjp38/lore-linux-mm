Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 187E9C48BD3
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3B3120856
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:02:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rh/FqlVe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3B3120856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 689948E0003; Sat,  6 Jul 2019 11:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6134C8E0001; Sat,  6 Jul 2019 11:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B4828E0003; Sat,  6 Jul 2019 11:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27E498E0001
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 11:02:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id p12so13243437iog.19
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 08:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=boVbp9ZUpDsf//+FdnJqiUZCUcTK245wDcHd7jIjrpY=;
        b=Udgs8jUTYVmiG1GWy0BuS2WAYQ++QdVzpZGUFbHYODw5spy27CjpA/POJI1cTJd0qm
         U+YjqVk0fLd1hzL1Y03nYd22rNV8kYwq1lA8CnB9Xpb9jbOHQ/rORnm2VyfxIcBURJsX
         PbeWwdwn9qYPJ8qQ5PTzIaZlXzFNZFv9Ow7ea+4KKbQ5wtUeD7eEYB/6xFSwH/g7udhA
         8q8fL5HljJBHLmnmOTFlSy8ps6nLYkmuPe2V+FtFxFTFYBMyt3EkP58S3dhzDqMX5qzJ
         H9GG68shkezF2FhI6HLrSTVPUszoIjR/HrxUnC4PHv7ItW4EbdACXErKBygV9/EhccKX
         oCTQ==
X-Gm-Message-State: APjAAAW/4yy5QUnT3hMgKDIlF6ZcIJowxr7rSlJQ+ki8cVS3GKQvAInR
	ih2atYKP3TwRMQ1VP1iclglMsbaK+uYHAC75rNoYrzdRe26fwhkGlLsESonvym7CF8Gb0Zr7f08
	0ZVa/kukcUDl9ino9LpAkMxA/llsgNSmyaWSVpNL9EQ94qIEMVFG3uBPTfoKS6wZj0A==
X-Received: by 2002:a5d:8c97:: with SMTP id g23mr9763635ion.250.1562425378851;
        Sat, 06 Jul 2019 08:02:58 -0700 (PDT)
X-Received: by 2002:a5d:8c97:: with SMTP id g23mr9763589ion.250.1562425378239;
        Sat, 06 Jul 2019 08:02:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562425378; cv=none;
        d=google.com; s=arc-20160816;
        b=EL/HB96oRG1mPL4YUcd8N5xy98f6eP0eab0uFncr+z4Xd4dmJtEqmgQ1WCEVafqspI
         tdv3a9HtVVjdLEVRrMCe1Tow6kMOKyzL8ZQnBZKSgbrLXcVtc3e+llQt89ViPAREvNgP
         6pOTX7YdGin5RmF3OSVFKlatHnCha7FA7ur7j5DaneXmgMXbIJKWQHZF6EumY4xlSq53
         ZEZuJzQfXuc/26P2/8Lf5kxuX9pzzbHY7PUqKMx60tKeGAMo14b0Ni+AL3wXcLdl7bmw
         TNS/oxHI8ZCwJhsuLjxl76Er5dVFYu6GDZjG+YzpE5cU4AA2Yp5F7ItillbmsvhSmFao
         ClRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=boVbp9ZUpDsf//+FdnJqiUZCUcTK245wDcHd7jIjrpY=;
        b=yQNCjU2QDGqq2cGgNTcbQgK+OvIm0FKXk7xhZ1CsNoTg0XAPWx31jJ/7ViBADZdtVe
         HsCdWUVSGSlWBgW6ValajVAjyaETUefC2Hs0CkMWF1WIf/T/0117YkMCyyo8IGrLP226
         TMleKAss/kECTdm4cjiqjjf5Q4ntGuEYGng59L3HSTl13Lw0JzNhLFheRswezyhW6RaZ
         h48FidMaU6PXX15KYeMVsr9mrAbyXHNeZZYGXc6sfvHbV6MzLoshBClZLS9DpKauLCiq
         f+cepCINPfUE+aQqxwmswXDvmLfC38LteHEm6x2TOi7bnXDh7k9wRsQ+rWbeXW2w/+Yu
         nsow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="rh/FqlVe";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor8733191ioj.69.2019.07.06.08.02.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 08:02:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="rh/FqlVe";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=boVbp9ZUpDsf//+FdnJqiUZCUcTK245wDcHd7jIjrpY=;
        b=rh/FqlVekhxhsGpxulSZ7913KgIi6gqoFF4i/RNbOKBumEHd/qP8oFyX+UMcwSBJ/K
         eJbwXN4Ov/ueoIt4Oyi19u68UVz6gWVl32e1YjWfUsFB+HhwINCxXsiVdhbRDT3gbdiG
         5ibSk2q5E+W34FIfKzIclMIaC9eqyeGf8flkt1UTZCjuuU8xyABLpmZVy9kQW38Wcd47
         gAN4OKTn4B+qQpI+Fdb0r7ze2FAi8FFmV7f4mtLyNxY5j9rWNMTHzsbte1amZOAaiclM
         2DjSHrq+GVNYO2PJo+dpnRZ5GGJt2TrAWtORL250xGp3SE0C7nVC/Ze8vY2ybOEgpvg+
         BqLA==
X-Google-Smtp-Source: APXvYqy2UcPtMHw6LxYEegmwXcbc6qsKnlfXOceq6+ohw3DYNqy1gXgyu+nij430oPjMdmSFDPXMk206/IR43gK04QA=
X-Received: by 2002:a02:b710:: with SMTP id g16mr10876342jam.88.1562425378023;
 Sat, 06 Jul 2019 08:02:58 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <HJktY5gtjje4zNNpxEQx_tBd_TRDsjz0-7kL29cMNXFvB_t6KSgOHHXFQef04GQFqCi1Ie3oZFh9DS9_m-70pJtnunZ2XS0UlGxXwK9UcYo=@protonmail.ch>
In-Reply-To: <HJktY5gtjje4zNNpxEQx_tBd_TRDsjz0-7kL29cMNXFvB_t6KSgOHHXFQef04GQFqCi1Ie3oZFh9DS9_m-70pJtnunZ2XS0UlGxXwK9UcYo=@protonmail.ch>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sat, 6 Jul 2019 17:02:46 +0200
Message-ID: <CAJHCu1LVk-3XwZCF=iQzZfbJR0eDn-0VOaipOthYeqknT6VzKQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/12] S.A.R.A. a new stacked LSM
To: Jordan Glover <Golden_Miller83@protonmail.ch>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, 
	Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, 
	Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, 
	Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, 
	PaX Team <pageexec@freemail.hu>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

You are right. I just forgot to remove that paragraph from the cover letter.
My bad.
Thank you for noticing that :)

Il giorno sab 6 lug 2019 alle ore 16:33 Jordan Glover
<Golden_Miller83@protonmail.ch> ha scritto:
>
> On Saturday, July 6, 2019 10:54 AM, Salvatore Mesoraca <s.mesoraca16@gmail.com> wrote:
>
> > S.A.R.A. is meant to be stacked but it needs cred blobs and the procattr
> > interface, so I temporarily implemented those parts in a way that won't
> > be acceptable for upstream, but it works for now. I know that there
> > is some ongoing work to make cred blobs and procattr stackable, as soon
> > as the new interfaces will be available I'll reimplement the involved
> > parts.
>
> I thought all stacking pieces for minor LSM were merged in Linux 5.1.
> Is there still something missing or is this comment out-fo-date?
>
> Jordan

