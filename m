Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38BD6C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F6E22BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V8onZfDZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F6E22BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD276B0005; Thu, 25 Jul 2019 14:33:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78CBE6B0008; Thu, 25 Jul 2019 14:33:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 656156B000A; Thu, 25 Jul 2019 14:33:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2F86B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:33:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so32604709edd.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:33:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AuU4nyrEtuT3w9Jo5wyp3Jkj2G36pS00KDYO2VYJxyQ=;
        b=VyAbOeG3nyeq5bSY0+UsQgu0XA4XPXG0DhFdVwUPpuDLvejccc0q0E17iM1aqgDzxv
         MgiZaSCDnC+Zm7EblJKjxYUgNAZfKjUoM9ZAs99Szm/8noIxVx3B31pSg4xlHo2kFy+z
         47BXC3jQURXQpdS9RqvN7obc7zVPy3NhmvuTOeZxxgo1nkYzo8Mo9iwoZzFd1k6mdcLR
         CbRP4/tZVHJIlxLrFQ92mKdlAw03cwcimuwcem2BzIZJ+8B5qf6AkFzDgqvHil722uYB
         /xWUERSK2Keaa9BvQjQ6cn6LNnOoS7La6l/Zr3mEsYJEULFoXd6RZqbpPM0ucbjp8E5g
         gzCg==
X-Gm-Message-State: APjAAAWkR6cUOywdNyHJWt0cmJFDp9Z2dp04X1evml2HRJ7uAOByLLiW
	ehPJxCygkq/N9+GSa3K6tQuJJjO7ZJ0m8Fk8RBKH0UwKQ9MrGtq7zYgQn9n2A9krsD/O9g2+SVB
	t6Q1KZpsjmQV/PV5hi+UOjH5kLp9DbrwCrh/uRerp2Cjs1KRIP2CucwPW414mXcY6+g==
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr79575280edv.68.1564079617599;
        Thu, 25 Jul 2019 11:33:37 -0700 (PDT)
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr79575207edv.68.1564079616651;
        Thu, 25 Jul 2019 11:33:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564079616; cv=none;
        d=google.com; s=arc-20160816;
        b=wCOGi119xWFFSuPO6cr0+Bd+ve3GQCsB/D2OvIyj9leTFPpPcCq1MM2S7okYXI4qrp
         hq9+P7VF1x4hIGGK9xvPjaiPIqCr9zvqF/Xuw8SkldpjzPV4sJAM6PIxYKOyxfn93PJj
         sN4KtYInW8T3qJHiGWvd/PKW/2bK685vtlsJ+R1nmmPW/htbs66pi+2xzmRyF5hF2MIB
         vVvAbLtI9itAM8QUJg+7RAp9GHXtW1BzS79jvJqNbfTQBzgpW1jKg0WDveMPXc/8deEs
         RGSV00kAxIet/6MT5FMW2XQwAhRn0QURuosBdx7TJz0Rn2d0jm16inaBh+ITrIdpQL+U
         61Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AuU4nyrEtuT3w9Jo5wyp3Jkj2G36pS00KDYO2VYJxyQ=;
        b=L9ANjtth8nJCS0H9V1BV/8LK1rxN51BGl3dhVYwj+Yeg+bEHpWlAF2MWGqG4eFlnmp
         JHYBvNEwGsVGj7Lx7GldWU6Pj5//d7PkHbWYA+ia9nOrlpX7Sya4iCrgdZdwEkiHdPKA
         DnrS+LWc+jDGK/iI/n1JQuMeZr/YBpMUV9ScfPRb0p0pVTXF5jWGSKcq4OWpNdINgQQl
         breIPRz4rGBvr94n2Jh6cRyNJQx/iRfjP50phBOh6dBFURvcMfZMjtyjGhSnERkm8ptu
         7gLpKkhQj9/OAtMp45r+3/OK4uDfSudsBEZGZrBAv74hkhvDWZcJtbz76VGW/R5ownFN
         FiEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=V8onZfDZ;
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor38821875eda.1.2019.07.25.11.33.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:33:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=V8onZfDZ;
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AuU4nyrEtuT3w9Jo5wyp3Jkj2G36pS00KDYO2VYJxyQ=;
        b=V8onZfDZKgE1lCY1sJyvGaCLF6wKkftziOVch1g1x7yGvEJx8cQ4qQPLlYVp5WeRwG
         wuwNzvyBsCghliDlAPtHciGL+inTAtGwkR2FNHtZR7PQJalcCO5AJgEZBpr8l+e3Ro9Q
         mq8R2UFa5rXD5zFBnsDKGPWpMGskEsNfOCeFaDa3DEReI579ufl0sPtTtrmXnOdPNtq6
         ZzBwY4lmd+uULWigAkZnORDpRnZX3+mJ1JOsDmNGsSND4xSuVNLTfFZ31DJaYsPI9MX+
         iGO7KZLGipzMomMi1m+KKgSBwAifGOukD+I0Cj67NYopeSi/nJ2TNV04LPOPsff9eIMN
         pfIg==
X-Google-Smtp-Source: APXvYqw6N86vVfRIvU7fAQubRb8w6XpUTYh/1QgHCfg6AtGs50OjwIiv0MuuIZJdRWpqC1GXgwzbAcukhf1vb9fnmIE=
X-Received: by 2002:a05:6402:1446:: with SMTP id d6mr79749937edx.37.1564079616259;
 Thu, 25 Jul 2019 11:33:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190717215956.GA30369@altlinux.org> <20190718.141405.1070121094691581998.davem@davemloft.net>
 <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com> <20190724.131324.1545677795217357026.davem@davemloft.net>
In-Reply-To: <20190724.131324.1545677795217357026.davem@davemloft.net>
From: Anatoly Pugachev <matorola@gmail.com>
Date: Thu, 25 Jul 2019 21:33:24 +0300
Message-ID: <CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: David Miller <davem@davemloft.net>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>, Christoph Hellwig <hch@lst.de>, khalid.aziz@oracle.com, 
	torvalds@linux-foundation.org, akpm@linux-foundation.org, 
	Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 11:13 PM David Miller <davem@davemloft.net> wrote:
>
> From: Anatoly Pugachev <matorola@gmail.com>
> Date: Wed, 24 Jul 2019 22:32:17 +0300
>
> > the first test where it was discovered was done on my test LDOM named
> > ttip, hardware (hypervisor) is T5-2 server, running under Solaris 11.4
> > OS.
> > ttip LDOM is debian sparc64 unstable , so with almost all the latest
> > software (gcc 8.3.0, binutils 2.32.51.20190707-1, debian GLIBC
> > 2.28-10, etc..)
> >
> > For another test, i also installed LDOM with oracle sparc linux
> > https://oss.oracle.com/projects/linux-sparc/ , but I've to install a
> > more fresh version of gcc on it first, since system installed gcc 4.4
> > is too old for a git kernel (linux-2.6/Documentation/Changes lists gcc
> > 4.6 as a minimal version), so I choose to install gcc-7.4.0 to /opt/
> > (leaving system installed gcc 4.4 under /usr/bin). Compiled and
> > installed git kernel version, i.e. last tag 5.3.0-rc1 and ran the
> > test. Kernel still produced oops.
>
> I suspect, therefore, that we have a miscompile.
>
> Please put your unstripped vmlinux image somewhere so I can take a closer
> look.

David,

http://u164.east.ru/kernel/

there's vmlinuz-5.3.0-rc1 kernel and archive 5.3.0-rc1-modules.tar.gz
of /lib/modules/5.3.0-rc1/
this is from oracle sparclinux LDOM , compiled with 7.4.0 gcc

Thank you.

