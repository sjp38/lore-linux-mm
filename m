Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AF5FC31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 00:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42907208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 00:05:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iDBd+Nyh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42907208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E2E6B000D; Tue, 11 Jun 2019 20:05:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFF826B000E; Tue, 11 Jun 2019 20:05:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEE476B0010; Tue, 11 Jun 2019 20:05:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9E26B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 20:05:20 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id 77so666636ljf.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:05:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=twnhTVYd7tn35O7vvlIa3XEgKYk2/zieh7kgQ5Ms1VY=;
        b=g0d/qL+B1sNYjBjEFWOu/z13Ofd7SN25SBWIq0ZkQZMJJ35xtFJcM14yhiqVub2tXR
         ej/0t+XiDx9dQyae1cETV2gc3MotPxeGp7UqSAWl3lHGK2pMYA/HzYLdXzlkRlSGI/Zi
         PhyAlmQ3X3K5+1RgQtsiUdpFvPZNCWTS8NdIVJhCgfGWG2NTonftPG71ylUpwUTkifHt
         Bi/EC/0GEtwR9Mx04Z5+F8OL4DRQIhthG6sMSwd1sWEYQmqTavvhY8dxoAOtMp3JXL+L
         fxDSh5JF+u+4/VHCIEOKjrIlfZGRRPLZu6tT3IYugju5OyzfdwF3thT0XDI2hViL+GMK
         fK0A==
X-Gm-Message-State: APjAAAX0IcebOLRTSB6iIF+cXZuz/FMe3zU3dJxmfKXSqrCzXqtCzdTo
	WyQUxjPHeicCi2uivTkrVm3r2twdD8BjT20AFz7AcBZWOdi/GWgKRB7+nky02qTdci6BclQSR2P
	tjiKrD4WRmyjXdU0Qf0aLF9a9lYw3irNFenTyKQgz6olsGkYJy7d82/VfmtePb/0tPA==
X-Received: by 2002:ac2:46f9:: with SMTP id q25mr42339038lfo.181.1560297919438;
        Tue, 11 Jun 2019 17:05:19 -0700 (PDT)
X-Received: by 2002:ac2:46f9:: with SMTP id q25mr42339017lfo.181.1560297918652;
        Tue, 11 Jun 2019 17:05:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560297918; cv=none;
        d=google.com; s=arc-20160816;
        b=LQ1EUzEz1qKXk6qrRllX+/Bl50zfreTTCfRP3bkJElMXA+JGxYwolUAMrVqJRP7/w7
         Jw7kyy4ILovqlbR0VnTf9Jz4nYtwZBlZaLwxVtvF/gAlzwvnYdgkQHLQwWm2+7QluhEC
         FWYUPgscxi9psQmxvSyQg0Pjd2YLaKz2X1DfOhieKSfL32sHcqJWPUGH5P4LtNJoD5sK
         HpdAzW6Isg7RXOIf/Ls8z6ZiFvtHzQ5RVGhj77AP9V+cKA8gTN8UZTSarIClKxJqiThW
         ykx5syefH8fU8KHih80SnEdcAZd5j9KtIiocPKapJTDfyJ5zimHbsQ5szIcgh46BhWX9
         kO/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=twnhTVYd7tn35O7vvlIa3XEgKYk2/zieh7kgQ5Ms1VY=;
        b=Nb6YTlxDtK7/M2foyMWd8ctLkBIlLCVM92HsS4WJDo8tUDweGEqlz8VRIBBztmNhTp
         AnQ6lzimap9R7DJnSsE0SASd5MbzXEBRXnLhdDhl3T0IHjbNgG8IHTK0C6WE6yCiXtZj
         Q5HvceW3hmHDvQVmbu9mvUyq6ONrn9WQRfpWK4qnMW5b+wlXfOSVRuEoqdk82rFU+d5D
         TBKkqIEh2VhqX7wo7xlQpWJyFWCjIuQASDFzKQNTcwAFbLcNtGhCHA/upJMVyar1vOzc
         FVmxwNu5uPXx106FbH4Em6bmgvOhgl0hFYjmxbA1RDshJVEv2w+LnWAegdms8AszTNCm
         rUrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iDBd+Nyh;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b20sor4733666ljj.6.2019.06.11.17.05.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 17:05:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iDBd+Nyh;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=twnhTVYd7tn35O7vvlIa3XEgKYk2/zieh7kgQ5Ms1VY=;
        b=iDBd+Nyh60vWHvSGtVHWVETugM2fnnm+FqmmiJZ56NZHl6V9Aty9AmjFW8CRdEnVVB
         aGKuXc3BMI1WRmMN59ZmT1r6kVO7qzb4q1bDpYmpS/ZUrVuenxbQGoF2Qv4WS5P5xTYu
         MgUGL2vvXlsZ04GvxKv4oWOnyz8mNGE24H+bdBFJTo0aHTJ0k0u+7bh9tcE9VNAMwAtH
         iKtxqCy1DSmKDdJUUU93WbsyygyX8RtwvZ5Owd5cCDJ9ZU6yAlx8+gKU6PDNIGy1Yrds
         5FOvUqOWwAWAd5bt0eEYz6DGK7Ot7sHrl6lNbuwYOmPXTEQ7T1WTuP7Qnyr0A/A07xpx
         QkCw==
X-Google-Smtp-Source: APXvYqyO/Oi3PmoK5iJ0YzdPrMw5xZcqUF1R75rhMCOs6SLJy8NUkUXX4LUB1wFJr6ZxPQT0SJAlgxYZrwxAPMCixo8=
X-Received: by 2002:a2e:298a:: with SMTP id p10mr12710225ljp.74.1560297918252;
 Tue, 11 Jun 2019 17:05:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
In-Reply-To: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 11 Jun 2019 17:05:06 -0700
Message-ID: <CAADnVQKwvfuoyDEu+rB8=btOi33LdrUvk4EkQM86sDpDG61kew@mail.gmail.com>
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF macro
To: Shyam Saini <shyam.saini@amarulasolutions.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Kees Cook <keescook@chromium.org>, linux-arm-kernel@lists.infradead.org, 
	linux-mips@vger.kernel.org, intel-gvt-dev@lists.freedesktop.org, 
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	Network Development <netdev@vger.kernel.org>, linux-ext4@vger.kernel.org, 
	devel@lists.orangefs.org, linux-mm <linux-mm@kvack.org>, linux-sctp@vger.kernel.org, 
	bpf <bpf@vger.kernel.org>, kvm@vger.kernel.org, mayhs11saini@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 5:00 PM Shyam Saini
<shyam.saini@amarulasolutions.com> wrote:
>
> Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
> and FIELD_SIZEOF which are used to calculate the size of a member of
> structure, so to bring uniformity in entire kernel source tree lets use
> FIELD_SIZEOF and replace all occurrences of other two macros with this.
>
> For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
> tools/testing/selftests/bpf/bpf_util.h and remove its defination from
> include/linux/kernel.h

please dont. bpf_util.h is a user space header.
Please leave it as-is.

