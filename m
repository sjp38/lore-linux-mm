Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	FREEMAIL_REPLYTO_END_DIGIT,GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3532AC48BD3
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 14:33:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABB6420828
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 14:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.ch header.i=@protonmail.ch header.b="HQzIhk8P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABB6420828
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FBE96B0003; Sat,  6 Jul 2019 10:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D3358E0003; Sat,  6 Jul 2019 10:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2B5E8E0001; Sat,  6 Jul 2019 10:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4A716B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 10:33:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so7455496ede.0
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 07:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=haA5wvB0xh+dZtWZGeuep4dEUXcEIlBy0xdSwX483iI=;
        b=Etd6Z1ZxPg+WPnWz0bUGEPofcpZT/cNoXBaLVAg48P5EOGUQCP98QDUVbzhNw6eGaf
         vMa6eew0SVP2tdS9yP6EP0IQMkyhy7SilfzTsogTlEG68sSrNvIi0Wnw68F8KV1aXDal
         9zYPtTbNb8TjFXBfow+G96vyuSrF8QJ+za3gqxe8g44mvJG5Ap7vl0GEgO8vLaHFWAoK
         huBBJXZ9YrxzkHYfsoyVkEkCWqWUxvF9UvcRxRAH5DdD8/8D0p7zphMREWhENFmAUQ4C
         HE36FWHNvc26JJKkCA6wzJSu40bsAj9sp20iuzKuZfcbE8njhC+A9zlVsMePUSsWIRj7
         gVrA==
X-Gm-Message-State: APjAAAVM5UW6tyb6Dnj1HIBDSkNBorJni2aIuOrVTMCYwXlbXwuhNXrF
	OGBYXosQOoUBBX5bM1UJ26Z5LhfCWhKD2LrghHoSMYJhaCGQ3is0i2BhlpJtKlgHmsfUV0JY9Om
	tw6bGHDYbqChQVr7MRZ0SUku5LS5OWT7v3Zap+TBl1r9+rMUZbNNOt5CzRtAu9ZSeig==
X-Received: by 2002:a17:906:6888:: with SMTP id n8mr8200462ejr.134.1562423588099;
        Sat, 06 Jul 2019 07:33:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/tSkFN5KMHxi3SRlzd10bC0FqnpzWh2fuAFCngZebRE8yfRAEbtXi+2nCKGQiujLcI6N/
X-Received: by 2002:a17:906:6888:: with SMTP id n8mr8200379ejr.134.1562423586795;
        Sat, 06 Jul 2019 07:33:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562423586; cv=none;
        d=google.com; s=arc-20160816;
        b=urGg6cA0RUBZkke8kyne5xikfSRuZxCN0ubW0amgvvUGdBwWwnJRLGqash5jrvPjUH
         b9pAvExtWp8jFtRZdmY8YEBjb5Oh5XfJUncq95YywTl+qtdWS2BRlIo1DpHDDrd3pkGC
         xDmj4BB3o2NfHndVvXL+rjm+CrTpLC/ubCocoQ1aFLy5Za5hWjygcXmP4Gm2GeNPeQWc
         gqBvkM2+XbdXD44ldvKSQiPnRXBdzBXIc4B2e5N013NP6ZbKBO4hrKQg/y4OFlKN73Rg
         yZDjv1rURlMadystnaifRHBl3VptsKJT4KTs/OZZyDpAtC7MWyx1eMnNuYGXLHE9n4fB
         vJ6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=haA5wvB0xh+dZtWZGeuep4dEUXcEIlBy0xdSwX483iI=;
        b=i8FIpMG3BrhodGrokuhVXqKk0dP6ofdaxVhyS/34JA2+xX/0niBrvsUp7x/xQgZwEr
         y7xTXd78tPcYKTcb4gbub2cAIloCrnEpWRA71znOxqGPWsraNYTtFZ8QAwEpAdySVeDq
         yxc74yPoOKvKWdKTyR2EbKgXdyyecyVuTbTtoQ8JOVRpQxa2rzTF4Phn70uKHBsF0tH1
         yP2xPKfN3s4+lrZLQ9xjZ+CNqO0/IqOOgqzOYEH2mjkD+w08w7t+MNkE2PtWF9Z5FPpo
         8wVUwBxY935x2aaUB6/wg5q3AP83Kuc06alrJV9i1He23zDHkFhezybl++5HlH5TqIlZ
         U8Ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.ch header.s=default header.b=HQzIhk8P;
       spf=pass (google.com: domain of golden_miller83@protonmail.ch designates 185.70.40.135 as permitted sender) smtp.mailfrom=Golden_Miller83@protonmail.ch;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.ch
Received: from mail-40135.protonmail.ch (mail-40135.protonmail.ch. [185.70.40.135])
        by mx.google.com with ESMTPS id w5si9413178edb.196.2019.07.06.07.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jul 2019 07:33:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of golden_miller83@protonmail.ch designates 185.70.40.135 as permitted sender) client-ip=185.70.40.135;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.ch header.s=default header.b=HQzIhk8P;
       spf=pass (google.com: domain of golden_miller83@protonmail.ch designates 185.70.40.135 as permitted sender) smtp.mailfrom=Golden_Miller83@protonmail.ch;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.ch
Date: Sat, 06 Jul 2019 14:33:04 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.ch;
	s=default; t=1562423586;
	bh=haA5wvB0xh+dZtWZGeuep4dEUXcEIlBy0xdSwX483iI=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=HQzIhk8PxKYt36ErbKPrQMJqON9fHmTQ3PYtYZqeFvsD1zSHVwbkoGWN0bzw7aR8K
	 ARMyt0tMl0YH2vDYzZbyJiNYKRjCOTq+GXhhio/qQiJlEQqHfHCkqYGRG+bPNFvlhE
	 1q+18riMHNgpRcuVQ6PozQhMO2ct7zAiMwLG2T2M=
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
From: Jordan Glover <Golden_Miller83@protonmail.ch>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, "Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>
Reply-To: Jordan Glover <Golden_Miller83@protonmail.ch>
Subject: Re: [PATCH v5 00/12] S.A.R.A. a new stacked LSM
Message-ID: <HJktY5gtjje4zNNpxEQx_tBd_TRDsjz0-7kL29cMNXFvB_t6KSgOHHXFQef04GQFqCi1Ie3oZFh9DS9_m-70pJtnunZ2XS0UlGxXwK9UcYo=@protonmail.ch>
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
Feedback-ID: QEdvdaLhFJaqnofhWA-dldGwsuoeDdDw7vz0UPs8r8sanA3bIt8zJdf4aDqYKSy4gJuZ0WvFYJtvq21y6ge_uQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday, July 6, 2019 10:54 AM, Salvatore Mesoraca <s.mesoraca16@gmail.=
com> wrote:

> S.A.R.A. is meant to be stacked but it needs cred blobs and the procattr
> interface, so I temporarily implemented those parts in a way that won't
> be acceptable for upstream, but it works for now. I know that there
> is some ongoing work to make cred blobs and procattr stackable, as soon
> as the new interfaces will be available I'll reimplement the involved
> parts.

I thought all stacking pieces for minor LSM were merged in Linux 5.1.
Is there still something missing or is this comment out-fo-date?

Jordan

