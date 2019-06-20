Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A36B7C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 12:18:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6B82080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 12:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="So/APhDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6B82080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40CA6B0003; Thu, 20 Jun 2019 08:18:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF2E38E0002; Thu, 20 Jun 2019 08:18:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE11E8E0001; Thu, 20 Jun 2019 08:18:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9872B6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:18:55 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t2so1491933plo.10
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:18:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=YoTiXuUhP7MILD5fnaoAlkgFg2nR8TYJrJEF6s4RZXw=;
        b=sCHS7aB4+TNI1LvzDRIUp0KYi4E+8LFfsp4+eSeSQcFkisPT4ySC3TR7Gww2oG7+CL
         pqpLpqS5SnQnyZ2xkO/6SKmKroT5j/+cwoJ/tTlw62E6zzRquIW6G1Yr0KTF0xbSNtqC
         fv18uUcRvQxLKI/bIFaEsQ2jy9og5/YdfssXoMveHdhOeLoP9cxW+m9fVvRO+ViW5dC0
         34LBAFTqtdbb/YR0aiCxXM8qClG2jPPywtOtkpfY9f3cM5M3uwMpVJwJASPpF52lRu9R
         d4IeA8z2EdTkEydhaXahbw9dmQf778I7fX5rUAJp8Ux/DwHv3Fp0kFERK/KPCvvbuWK+
         D6TA==
X-Gm-Message-State: APjAAAVH0OYeNJQZT6R1xGwJBaCNAhh3flTz9bgWNjU/FnDqfBDqAh0d
	S84ugYzRyWgZqlgG6jP9ygBpFQIfOHJHayc9cQQV06/7jLULaZaNYL6zGEOLk3+7LSXnIux5rHu
	JDJUuAJc9amGTNmrk3GwIjSodBCTmsPMd9n9Zxs6dPWULK9gmuOxumATxUV0HSK8hvQ==
X-Received: by 2002:a17:90a:3225:: with SMTP id k34mr2783030pjb.31.1561033135212;
        Thu, 20 Jun 2019 05:18:55 -0700 (PDT)
X-Received: by 2002:a17:90a:3225:: with SMTP id k34mr2782963pjb.31.1561033134253;
        Thu, 20 Jun 2019 05:18:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561033134; cv=none;
        d=google.com; s=arc-20160816;
        b=Rctg5EdkXpUfKGqMkUyI0MtIS5CeBJslAM+swxifAaxY5jGBgFcdqtwSiRyAyrh5cU
         KMzGzTuxRkbooHE+rKP8zkHXzJyMlWzVWk3RmIZdE2z9W5JDAS8FJ6og57HP7RjRdtbK
         VsXp3twJxXZJRQXUTcA9oV4iKAJtoG0iKqF3lurv3jdgfVplfJEhWH6zJgwbkJ56ZvtU
         ISXjxCjRoWZhxH98ViWf/+jySYp/JxsRV1BG9y0KiOMvZw/nS5ggjNsUvKZq9X5O46JV
         8Uq69Y2w0LBbaAMRwFeLfC4foImoqm9xG/nXEIOr5dFUL2TpVinTbvvlqFYDTezXP6lT
         7m2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=YoTiXuUhP7MILD5fnaoAlkgFg2nR8TYJrJEF6s4RZXw=;
        b=Sq96uW1IvFFlWrM5iEs4SluurMnB/va47SNj8j66BfSQScyo2+RauReb3MyZH/hhG+
         4ZhF2PHIIPievCoXcrDI2QZnqJNbw0sHbj1v/1oeELJpb6+/jfoUMN+nKUylH5ypeuR0
         USB5XT64ZFMdR5vhXsQM/d2M44c+Tex2TfcdhjRnDgelATTjX3o68Cp30QBmMz7XW0K3
         vX9E4BjAdvsTHvRwLhdlPEjwNyUMhloq4Y+xZPU4OepeXPsoKg7d3f67UBM0tUr1YCTy
         pDp/niZt9rn01CQfpSg+tAv1ZtL/5EC+wiK+6VdqHaANC+FG8DtVKBL3hJHwXj6nmi59
         z27w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="So/APhDB";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor21215109pfi.47.2019.06.20.05.18.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 05:18:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="So/APhDB";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=YoTiXuUhP7MILD5fnaoAlkgFg2nR8TYJrJEF6s4RZXw=;
        b=So/APhDByNH5ZTnsyLPXFkassmIa6Ov5z4dUXPiq3BcI+/tBJroH1OYfD+D/LPx2Kz
         Z2iebLBARMIonYTJViKAMNqX6T9DWFpGX4f7lEU40XE6jdwOBAKSb7px2/VVG1NdMZUV
         DGEi2tUgpJk8ahufrxePUMdf1fVMSMqTEhNaXDKRGi+y/W5OIH7OvaZjkf2vDypfXqxI
         TD2ewroIsXlnf4E6gOQtkllshj947AFSuqcZtKArd6jeI++QOwML2r0B7G5wvAqJD4UD
         xWsias8CY08OAi7pp0ZZm2YUI8zBDfNLVjsK8N1PIHm6HWAHq05Ev5F7HsEKLa/T1vLU
         uiFg==
X-Google-Smtp-Source: APXvYqx1eSkhbrnX9j+XXPf1ijevNCfi95aQ4yuFnnSZCNNzh3FuAkFtzgkNfUYJBeEqzMwN6uhd9g==
X-Received: by 2002:a62:e815:: with SMTP id c21mr90025668pfi.244.1561033133807;
        Thu, 20 Jun 2019 05:18:53 -0700 (PDT)
Received: from localhost ([203.220.63.126])
        by smtp.gmail.com with ESMTPSA id i133sm24389358pfe.75.2019.06.20.05.18.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 05:18:52 -0700 (PDT)
Date: Thu, 20 Jun 2019 22:18:51 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Rich Felker <dalias@libc.org>, "David S. Miller"
	<davem@davemloft.net>, Christoph Hellwig <hch@lst.de>, James Hogan
	<jhogan@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>,
	Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
	the arch/x86 maintainers <x86@kernel.org>, Yoshinori Sato
	<ysato@users.sourceforge.jp>
References: <20190611144102.8848-1-hch@lst.de>
	<20190611144102.8848-17-hch@lst.de>
	<1560300464.nijubslu3h.astroid@bobo.none>
	<CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
In-Reply-To:
	<CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1561032202.0qfct43s2c.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds's on June 12, 2019 11:09 am:
> On Tue, Jun 11, 2019 at 2:55 PM Nicholas Piggin <npiggin@gmail.com> wrote=
:
>>
>> What does this do for performance? I've found this pattern can be
>> bad for store aliasing detection.
>=20
> I wouldn't expect it to be noticeable, and the lack of argument
> reloading etc should make up for it. Plus inlining makes it a
> non-issue when that happens.

Maybe in isolation. Just seems like a strange pattern to sprinkle
around randomly, I wouldn't like it to proliferate.

I understand in some cases where a big set of parameters or
basically state gets sent around through a lot of interfaces.
Within one file to make lines a bit shorter or save a few bytes
isn't such a strong case.

>=20
> But I guess we could also at least look at using "restrict", if that
> ends up helping. Unlike the completely bogus type-based aliasing rules
> (that we disable because I think the C people were on some bad bad
> drugs when they came up with them), restricted pointers are a real
> thing that makes sense.
>=20
> That said, we haven't traditionally used it, and I don't know how much
> it helps gcc. Maybe gcc ignores it entirely? S

Ahh, it's not compiler store alias analysis I'm talking about, but
processor (but you raise an interesting point about compiler too,
would be nice if we could improve that in general).

The processor aliasing problem happens because the struct will
be initialised with stores using one base register (e.g., stack
register), and then same memory is loaded using a different
register (e.g., parameter register). Processor's static heuristics
for determining a load doesn't alias with an earlier store doesn't
do so well in that case.

Just about everywhere I've seen those kind of misspeculation and
flushes in the kernel has been this pattern, so I'm wary of it in
performance critical code.

Thanks,
Nick
=

