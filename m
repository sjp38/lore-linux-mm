Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C293C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A480208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:29:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fbj3ryUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A480208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CA866B0005; Fri, 21 Jun 2019 04:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97B498E0002; Fri, 21 Jun 2019 04:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 891D08E0001; Fri, 21 Jun 2019 04:29:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53C286B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 04:29:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so3960708pfc.2
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 01:29:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=yxfaAKL36iRBk7i3lJUt2q8lAl7GH2S2sjM2Bw2uPJs=;
        b=i8uEW3XN2YInBuZA9sYwop6EqqJLz1RF8sS2LHYz0KeVnrxCrhTKre2QNw9VgIMC94
         SsPF6u8VUaKs16sN2mg/lE5Tru/9KT9ISIPO24BO6sswixcWYsa/AsFLJynRRI3nmFAt
         wEZ+IcmKVY9olQNAvdCMszjjrmJQw/z0GhtmaXWDyI+OAccMdHMssP0JCE05MWHnQyCB
         JZbNO7owMmZC3EnLMh1+H+B40HvuH1rcXMJ9vZgzdBwsrEPj7E4tukNpflSdZhCY+MY/
         Z1iyAcSe2mo0HTzHLfMldtd34MxNWaan5SiqvrbSw2H93uVSiwJJ+2BFYqYiXC8SMufX
         n9vw==
X-Gm-Message-State: APjAAAXQm9crFaxO0JSPFzp7Xixjseju7kX1nSaKTKA5UoqDUZjhpfNi
	s0qmtj5nSiLm12VZSamYhc8QI979DCD69mY1xJIqB9z2/wTOwiI4JlSNpzc06TIbV+SvqwSc7RE
	8hqujS1j0zAHBDkR1mMDJL1yhJ5gWiKwH8ihVqKmIyxcqCYVmL3mjQBsSGkV7Y3/9dA==
X-Received: by 2002:a17:90a:a09:: with SMTP id o9mr4975454pjo.95.1561105778834;
        Fri, 21 Jun 2019 01:29:38 -0700 (PDT)
X-Received: by 2002:a17:90a:a09:: with SMTP id o9mr4975382pjo.95.1561105778064;
        Fri, 21 Jun 2019 01:29:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561105778; cv=none;
        d=google.com; s=arc-20160816;
        b=RxiqVsdsP4bI9T7RbaRZ54AEbRbkdIi5XsX0h4MkaAQ63C6FPUm1uktM/jE96BLNIC
         f5lb5jsLD5tcmg/+H2Mx/PqLycDDQuy5P7gk9vvCS4FPUcHfY1esblpqrXGS9eUcBDaI
         rENOyzlhoTNYO5FTqW2jmgvlYJ0oxG3wAbZVIbAzUngpmiEEA6RHSAhfDL7ru1mnAe/v
         sQZIiU5rJ+nmK/NLolPwTXpyo9xLJytFic4/50yDWTkYCjELvhK85+wATdyI2Xw0YQ+v
         NrXk5+gp8VeJxVdUs+GcrNspbQhzK1jSWNllyfAQoNA/NeJt2n6zgEgv2M9TpwOIYsGQ
         PdSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=yxfaAKL36iRBk7i3lJUt2q8lAl7GH2S2sjM2Bw2uPJs=;
        b=tmndsaq/m6ktsqZFZjkZGko1Hq5eR7ef56V6DK4/2yenEe1vR2bo3mgH91/r1evlW4
         UZ65z6oGm7tjRJtBfiLXa/9+GS6rA9qISDEFowyT6divI+RP711tSAOTK0OZt3713hKL
         Mgbv+gW3VgTD/d+0DrXUUgEkUSxZFHOU9wFKx9XdImES6At0eu6kF5yZKKBGc4yfoucg
         LASn3MuPemH1F76by1bwdsuzS/NINgb9DT73M3g+/r9tV2ihDpf8BpFRt3fmie1/I0Te
         pygJrhdAvb+uGeQUFYwz9/TbHBZU3xUFCZTWF6RZ/rfm09SEZTky+L5z30ywVYhhly/2
         BY5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fbj3ryUA;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor3105382pjo.14.2019.06.21.01.29.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 01:29:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fbj3ryUA;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=yxfaAKL36iRBk7i3lJUt2q8lAl7GH2S2sjM2Bw2uPJs=;
        b=fbj3ryUASSI5WTeqBy+Hc5OEHWiPYdV7sIZyNqgV+qzFiANsZYBHP3eTFrdbgDPMqz
         +NZAYlBR+Dfy7yY9SJaByfth0oz38I9M0oFx0/PjpOVh4PwNfZ6TM2OYoTtOR9SENi8J
         c4JwUKiwqGhPWDDJTo19f+iyU8hDWG4ED1a79bBPnMbmzbrs+wX6NcAW3qliBAqn2Cz9
         cNxxEV7yL4Cgwr2k23ZRaqddTXmW7jlpNEyLek6w+pt1gX1BPnCgoRUSFo9HYLeo65pM
         jcwVL8KYaA8GxmgazJGRjU9ifPR/K7V+tvyC4gxu12oOVP2g9/tx3yANOSmbk/9lW3n7
         hoKQ==
X-Google-Smtp-Source: APXvYqw0+FZM5x3iJhEGb07mnJPrmGs4w362V6gxLaKrkfdj/o0PM7u+3QQXzswzUEdHsggmQOj3Bw==
X-Received: by 2002:a17:90a:cb15:: with SMTP id z21mr5012050pjt.87.1561105777693;
        Fri, 21 Jun 2019 01:29:37 -0700 (PDT)
Received: from localhost ([1.144.138.41])
        by smtp.gmail.com with ESMTPSA id v185sm2443015pfb.14.2019.06.21.01.29.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 01:29:36 -0700 (PDT)
Date: Fri, 21 Jun 2019 18:29:27 +1000
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
	<1561032202.0qfct43s2c.astroid@bobo.none>
	<CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
In-Reply-To:
	<CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1561104674.cxm7sn77rx.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds's on June 21, 2019 3:21 am:
> On Thu, Jun 20, 2019 at 5:19 AM Nicholas Piggin <npiggin@gmail.com> wrote=
:
>>
>> The processor aliasing problem happens because the struct will
>> be initialised with stores using one base register (e.g., stack
>> register), and then same memory is loaded using a different
>> register (e.g., parameter register).
>=20
> Hmm. Honestly, I've never seen anything like that in any kernel profiles.
>=20
> Compared to the problems I _do_ see (which is usually the obvious
> cache misses, and locking), it must either be in the noise or it's
> some problem specific to whatever CPU you are doing performance work
> on?

No you're right, the performance hit from these flushes is not a
big hit that stands out in cycle counts. I just look at kernel code
for various flushes. Branches not surprisingly are usually the main
culprit, but they're normally not so interesting.

Static alias prediction seems to work well outside this case. It's
interesting, you need both a store ; load sequence that does not
predict well (e.g., using a different base register), and you also
need that load to be executed ahead of the store.

The small stack structure for arguments is the perfect case. Bad
pattern, and load executed right after store. Even then you also need
a reason to delay the store (e.g., source not ready or store queue
full), but those hazards do show up.

Now, even when all that goes wrong, there are dynamic heuristics that
can take over. So if you run a repetitive microbenchmark you won't
see it.

Some CPUs seem to be quite aggressive about giving up and turning off
the alias prediction globally if you take misses (Intel x86 used to do
that IIRC, not sure if they still do). So in that case you wouldn't
even see it show up in one place, everything will just run slightly
slower.

What I worry about is high rate direct IO workloads that see single
flushes in these paths as significant. Or if this thing creeps in to
the kernel too much and just slightly raises global misses enough,
then it will cause disambiguation to be significantly shut down.

Thanks,
Nick

=

