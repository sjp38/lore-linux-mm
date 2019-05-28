Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C93D1C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 23:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3398021019
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 23:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3398021019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D77A86B027F; Tue, 28 May 2019 19:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D01526B0287; Tue, 28 May 2019 19:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEFF46B0288; Tue, 28 May 2019 19:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56BA06B027F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 19:37:18 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id u12so92726lfu.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 16:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gou5tw8+3ixZMyd/NSLZFYfeQzp76ZKGRxJoYuIKzpU=;
        b=UkMGSq3xHTJF4BUpH2Efg0sw0iTUcrA1Qre6lj7cwA2PIEbdZ0reiQp6QEcoECqAIk
         w14SUd4rSkqxCyJKE9Hfw3uWqTYKK7/ye/fBEFj17sjJl/4uu9VjcVS7lGVww8dvhW0V
         IJ1liiSFBMRPc4HT7E8ma4C86UCaqmoDcrYRUL7fG+yloVfGngLZD9Fw4GVdwZPkbdms
         gyoCZb0x8+jEmMeQEa6GzS6VMzx46KGRLMiGqJ4qtOaxtAx4V5afJ17rMB5Zk6BtrlUL
         Plx5qDH8TEgWLVWxA4GqlGH7nMTRVoHnXhPQHQvs1BI4LFo8HNQxvu15xC1Tb2mXZ67l
         amrg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 62.142.5.117 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
X-Gm-Message-State: APjAAAX15YZAZv06l8jwWz5V1E9zEjEAa6jht6HmOmTgUv+mCosn7/5T
	nxKOIqsxkFVx0Ec5afVwJExmXmhpeef2l39z5rlPBSWgQZJLJdtrpd29qXSUydqe/9AcYIhv1ZQ
	Pw1oLVLnQe/FkiL9LCuhL+z6CZIn0H8uNXX4sXS1qOjHEamS+7hx0rzcRFHjOOcU=
X-Received: by 2002:a2e:5b92:: with SMTP id m18mr66343397lje.115.1559086637531;
        Tue, 28 May 2019 16:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6HKmVYItyBPskkja5qXNxtP7lxygW4OgIcETslS23IdW7VRXp+v+RaGzkcilNmG5NNB5V
X-Received: by 2002:a2e:5b92:: with SMTP id m18mr66343367lje.115.1559086636384;
        Tue, 28 May 2019 16:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559086636; cv=none;
        d=google.com; s=arc-20160816;
        b=J9QIo+QUc1YlXGdUNIiepi0dk6VRKfpMakVv2d8DF4u1z3xGpqcsJRvGjdxCgdBsDR
         jlO0/1Ih0yrlSN7CF7zy0IEkXI7QSVuUelzH3kWDm6+eUtBt2fRphN35TKI7vDR0dDNq
         XLNsvK662aKtkWLdUuc+63uBX6uxjaOJnlGpot+lmxLJZTKnGIOOdVN/t/j6A2DiMMiJ
         4h39P+YGGglMQuQTGjKnLVSj3klzfHM62lFOowBJ96bYfWzO5V97Svs6hpTtiDe7XDl5
         uhtHUU0/p0wRoSg8iFB+jyhh/p3bBUa1i1RmCPXtanoygb3fmznpKtilSGCb0uOLLdxh
         htfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gou5tw8+3ixZMyd/NSLZFYfeQzp76ZKGRxJoYuIKzpU=;
        b=OKLFK/74v3oqbkrb2KpiUcUEJNftVuTcbEOTOt5Jh+4csqill/ebcBME6GNVVGHKe/
         rB9zi9wwqzGsd368qbmmSv7uE/O3/jRpQZvrXrYoLtvgx4PAs22sM/5DOK+MUrVg2t4c
         FoYSyakp0Rq1fj5xEbPU60H53QowiNoWovHYtrEz4gEpsq927HDGiBkRZq+Q6eI+NaM0
         ZW0LQ+tru3jLs4AwZ4+PZNS2pt7XoKkKTy1oVWz6a6hMF2Vk0EQeHJmq9s77gTheHilV
         C7o92p2dnBy9zrmQdm/0nePgB/xPuOu60xllYKaxQ2QSto6bug+oOpdz47Y5KXsKssIM
         17IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 62.142.5.117 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from emh07.mail.saunalahti.fi (emh07.mail.saunalahti.fi. [62.142.5.117])
        by mx.google.com with ESMTPS id q8si14743521ljg.5.2019.05.28.16.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 16:37:16 -0700 (PDT)
Received-SPF: neutral (google.com: 62.142.5.117 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) client-ip=62.142.5.117;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 62.142.5.117 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from darkstar.musicnaut.iki.fi (85-76-68-2-nat.elisa-mobile.fi [85.76.68.2])
	by emh07.mail.saunalahti.fi (Postfix) with ESMTP id 7D5E4B00BE;
	Wed, 29 May 2019 02:37:15 +0300 (EEST)
Date: Wed, 29 May 2019 02:37:15 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
To: Paul Burton <paul.burton@mips.com>
Cc: "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: MIPS/CI20: BUG: Bad page state
Message-ID: <20190528233715.GB24195@darkstar.musicnaut.iki.fi>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
 <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
 <20190424204055.GB21072@darkstar.musicnaut.iki.fi>
 <20190424205016.yqtrlygqojii2rs6@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424205016.yqtrlygqojii2rs6@pburton-laptop>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 24, 2019 at 08:50:31PM +0000, Paul Burton wrote:
> On Wed, Apr 24, 2019 at 11:40:55PM +0300, Aaro Koskinen wrote:
> > On Wed, Apr 24, 2019 at 07:29:29PM +0000, Paul Burton wrote:
> > > On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> > > > I have been trying to get GCC bootstrap to pass on CI20 board, but it
> > > > seems to always crash. Today, I finally got around connecting the serial
> > > > console to see why, and it logged the below BUG.
> > > > 
> > > > I wonder if this is an actual bug, or is the hardware faulty?
> > > > 
> > > > FWIW, this is 32-bit board with 1 GB RAM. The rootfs is on MMC, as well
> > > > as 2 GB + 2 GB swap files.
> > > > 
> > > > Kernel config is at the end of the mail.
> > > 
> > > I'd bet on memory corruption, though not necessarily faulty hardware.
> > > 
> > > Unfortunately memory corruption on Ci20 boards isn't uncommon... Someone
> > > did make some tweaks to memory timings configured in the DDR controller
> > > which improved things for them a while ago:
> > > 
> > >   https://github.com/MIPS/CI20_u-boot/pull/18
> > > 
> > > Would you be up for testing with those tweaks? I'd be happy to help with
> > > updating U-Boot if needed.

I did some testing with CI20_u-boot ef995a1611f0, plus the timing fix
cherry picked. Didn't help, I still get random crashes (every time
different).

> > It's a purple one. Based on quick look all printings are identical to this
> > one:
> > https://images.anandtech.com/doci/8958/purple%20ci20_smaller_678x452.jpg
> 
> OK good to know - so it's a revision B board, which changed from Hynix
> to Samsung DDR:
> 
>   https://elinux.org/CI20_Hardware#Board_Revisions_and_changes
> 
> That's also the revision Gabriele who submitted the U-Boot pull request
> linked above has.

When checking the serial console with the original U-boot on NAND,
it prints:

	U-Boot SPL 2013.10-rc3-gb2e1fea (Dec 24 2014 - 10:24:52)
	SDRAM H5TQ2G83CFR initialization... done

That would suggest Hynix memory? But when checking the small print on
the chips, they clearly say K4B2G0846Q. The new U-Boot prints (for some
reason SPL printouts are missing):

	U-Boot 2013.10-rc3-g54c6a4817 (May 25 2019 - 14:37:07)

	Board: ci20 (r1) (Ingenic XBurst JZ4780 SoC)

So looks like both old and new U-boot are misdetecting the board as r1
board, and then probably using the wrong timings?

A.

