Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC694C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B48AA245BC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:47:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l/j965oT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B48AA245BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B3E76B0272; Tue,  4 Jun 2019 07:47:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58B0C6B0273; Tue,  4 Jun 2019 07:47:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1D16B0274; Tue,  4 Jun 2019 07:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 148EF6B0272
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:47:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so6608370pfj.4
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:47:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Dqp69e2uVFEsGCK8JhiQUI0eIhdoGk5h13T4mTC3vdY=;
        b=TwPzg2PyOp36d90qIIGv+Z+qGQ5sU5BMkrjM7Gvn5zWoq3CbmtVGhfSHjFMqZ4FmPO
         /9i0VsCzSH/mycfl1b5CJw4/FgtU6f/vxLqUj2WSrcmlQZd7ToyRm52TsQ+0bjl90D8e
         a+zu859Tnx7ZsEWl/Q907AOQXEh1GPchonwDxgs6ivUH2j4JJrcbi5QzkrzwpUvuiPwK
         4OWXxxrCs88cnGOL6l8l8mFrmHkiDXZN+XSEeNn0J++5vTDSxmXBPOB10XVmIzon5xvF
         XYRz0+pSxH6YDDUB9bNnn3dQIkmunvq+2iF5SbaRlJ2S17iJwzGVZgxhQ0ZSx0KzQ/zM
         Kjkg==
X-Gm-Message-State: APjAAAW+kG6s9lm//Rmtplr49lLuXUSajoH4AQk0HT6uDG5guV+i0HUF
	urDk6nuRgF4zo2ticZeo/KZiWUuMAG9o0LWry3ENrjs/ReKIMlks0SfpzVyY4loO4qBxUR4FRKT
	TA72l8GxBAp0Y5O5MIlvxo2rR0kw4Gquw8rx6t1JJGVOAUJ3K9D8gltlJ1Mpp0TAulw==
X-Received: by 2002:a63:f44f:: with SMTP id p15mr34342566pgk.65.1559648828779;
        Tue, 04 Jun 2019 04:47:08 -0700 (PDT)
X-Received: by 2002:a63:f44f:: with SMTP id p15mr34342509pgk.65.1559648828217;
        Tue, 04 Jun 2019 04:47:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648828; cv=none;
        d=google.com; s=arc-20160816;
        b=iBi38hUq5hrkTi7fszk1A/XzwA8CrmscY7NoQ8ljlTO2RUiAXV2wx1pm+z1LUT2Me+
         OI67F8t6IwXvJ5QBzd3w8XzS4QFmyotjb5Oh6MCAJommVdZcqaRQ4HmC3mWEEQHvVyoe
         QQnv7hQguNH5n7WZqa8h8t78TZvNcFdTjj9svWXYlNuh4PH5JqPYxnkLkZgMH15nCPd2
         RXr4FAwCR3iJOfTWIubHs13N6sSQOUdlxk0P7pwCPMJJ2qQRBwSEE1AlUaqjQLk/d5Bh
         xYhxwTbSd53tsvRReANZC8X7DjNc1GRf/X8X3BrFVF07rku7SgUli0jqdfAFOXz7R6ht
         x/VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Dqp69e2uVFEsGCK8JhiQUI0eIhdoGk5h13T4mTC3vdY=;
        b=cVfFU8yj0P8P0sb1Y1DLbYmCNzOgXOKVpKMcaf1nc3oPNm10V9Qs4cylEnDdLL14su
         Cl5hxhlEY+gjQYgiAtYLK/+lm5wkUwoDoHG9bQj9pwfGwLT3aX0Q7ijwzCCdNn5smj51
         Q291VZOgl4uu0fVgZoo240Ljz07BAGIFjSZfz3KfgpRy/lghHci08i5EQvShgELgs0AF
         XQhI6SLk+AoWBjJkPUL2RevIsR+IZhopf9xyqrvBN1kKkuR/V9o+F2ReAFOllXeVrVUK
         +eZiny1VqBRBO+OOYd4jPA0jB5WOUOvrcnqGtvo7cAfADXibjQF6e8/ZmYcKCthhkpjL
         mEgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="l/j965oT";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor7348825pld.47.2019.06.04.04.47.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 04:47:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="l/j965oT";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Dqp69e2uVFEsGCK8JhiQUI0eIhdoGk5h13T4mTC3vdY=;
        b=l/j965oTYVXJlxTYWvckE8VTMI089RUFBuoqrrqtaXuZS/XGL2imWUR4Yj62ofLJ5B
         DgxG1n0xNvR+Z1Q2WKLjXP4Ic6bW7ST7vC/dzKmyj0IUR6vTT0z9AontN1QI8ObMfrqT
         YfQOny7N2gMtvrAIhPa+UYF2M069gzxKv7PwiRWZjJ1iI6LDinGjOYSS+sjqs5grnF0B
         e9aJoVfdsnL4PaWC5CyQ3SVTmBWLITUXFdUA/VEb4rquThulv4tr3tFv4LY7s8DA7Ygg
         QJSsuhRnspRaLycykpAiwScHW5uSOeCZARUrOt7CO58SxO5d7ZxzOztZ8o9JgluM7fHh
         Jptw==
X-Google-Smtp-Source: APXvYqxxKCotfIzPUp2KWeKyy9ei43iIKcJ+7sjPmxGSimbHW7NgNBX2aQnmBFtOckHX4w3Dtt0BdqhA9Y8aOzwYWxs=
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr36931113plh.147.1559648827583;
 Tue, 04 Jun 2019 04:47:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-2-hch@lst.de>
 <431c7395-2327-2f7c-cc8f-b01412b74e10@oracle.com> <20190604072706.GF15680@lst.de>
In-Reply-To: <20190604072706.GF15680@lst.de>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 13:46:56 +0200
Message-ID: <CAAeHK+xtFwY+S0VY-yyb+i_+GnSjYHfgYHB9Ss=r9xxZZvsKFw@mail.gmail.com>
Subject: Re: [PATCH 01/16] uaccess: add untagged_addr definition for other arches
To: Christoph Hellwig <hch@lst.de>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org, linux-sh@vger.kernel.org, 
	sparclinux@vger.kernel.org, PowerPC <linuxppc-dev@lists.ozlabs.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, "the arch/x86 maintainers" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 9:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jun 03, 2019 at 09:16:08AM -0600, Khalid Aziz wrote:
> > Could you reword above sentence? We are already starting off with
> > untagged_addr() not being no-op for arm64 and sparc64. It will expand
> > further potentially. So something more along the lines of "Define it as
> > noop for architectures that do not support memory tagging". The first
> > paragraph in the log can also be rewritten to be not specific to arm64.
>
> Well, as of this patch this actually is a no-op for everyone.
>
> Linus, what do you think of applying this patch (maybe with a slightly
> fixed up commit log) to 5.2-rc so that we remove a cross dependency
> between the series?

(I have adjusted the patch description and have just sent it out
separately from the series).

