Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE626C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 697732187F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Wvx1FUNr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 697732187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 098F58E0003; Wed, 19 Jun 2019 11:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04A638E0001; Wed, 19 Jun 2019 11:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7AED8E0003; Wed, 19 Jun 2019 11:54:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD38C8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:54:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so10068511pla.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:54:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AdWAClAsfgdFDOJ8SthOKZD1SKi8T6yPStutUze/gU0=;
        b=EEdQK1cw1b4fCEnKpAMGIR5n8zuzTt72FcyAnAI7i6NHOEPUshUJPOQtk2AVHB3p9T
         0ROAZpRhbTHy1dyWgEsFu8tPersGF5fMXbR25TeaUG3kt1zT9hE6aWv8pKtfhD9WF6si
         DPhNrDeUozgzv2C0rx/rK2MELqJNceQdKz0+8HcdUVbf25/YLjRKAoi00xN7s90Q2cbE
         /pA/05eycgGS/FZ1va5Zkun80hj7ceu3XjftXGzs06KYEuNC/4zE3iiOrrJgeY6KPO/b
         AVrybxUVwA/qJXCJK/0YAPbIvLDOXCmRAz8pjzOdmjALe8pfdVmBqsm691TL4jTLOpUe
         3hOQ==
X-Gm-Message-State: APjAAAWkSkmhBZtp0L7x8Ma43S8s/LZj9pcyZeN3kv5uW78ZoeCKQu7Q
	KcY6evulgPnhDMDVFaefYlCfwcIqdwolG158tEjuRcTHPt6r4h6MUT76xHFXW0ePrdUQwvkYOuD
	BBw47g/cT3NlRn8HwCOKOw6AoBiRm33laTK+pSafNbzi5E2MLk9JVzPfS1nQrYWA=
X-Received: by 2002:a63:dc11:: with SMTP id s17mr8542858pgg.47.1560959656146;
        Wed, 19 Jun 2019 08:54:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2O6cE9PWyFe1G/voZKhoXL/Mj29WThn+04MmkPmu7Y4QMaJk00rqE1TsqPbIID0gCg/HE
X-Received: by 2002:a63:dc11:: with SMTP id s17mr8542818pgg.47.1560959655259;
        Wed, 19 Jun 2019 08:54:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560959655; cv=none;
        d=google.com; s=arc-20160816;
        b=f57ojLQwB0Agzb7wOh6BAHM+KqzJDlnstEqVjdNFLYEv4nR3LUHv0lHYm8nHY4nxvk
         YvZfll0wu3z6UwwGAOfWMtrTpDnhNQZLkM+numJicKziuOLb7kM3E+T048TEVD306JYZ
         kJyvIoC7/9VCsP8KWu2Sb3R91u+pdsJDv2GOFC5vcTbZHAeBqHQjfxd1hhSDPWnIRUJG
         5EqBQqE683Bbtme/uxVpw7/X0RvrihFftmJR9+UvtGSqBwopo3N5unvWX11dQ9+AJBRp
         VH0TwabzLf9r0W9eGB0yCV/phA+NMZG5I3GkJNNY6FTmyVQp9ByKORpltlaApRfmsSbM
         LK6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AdWAClAsfgdFDOJ8SthOKZD1SKi8T6yPStutUze/gU0=;
        b=m9LF2CQo8R71qLCSswrSVCB09gxftZnTFfLJ+RcoFeC25ph4ONnSxWDk47lDHEC8E7
         Eq/9zKdnk5LKhrEy1rtcGL4Kw+ycjTCctZJq2b9qkswTEvwZHaMYov6zOIFGTNjQ0lYx
         V07iF2psErLTysw1hKM7TbAbE3JIvcdjmlxI3O02Zh7WOQHJUPMrc8nvVvHFWrNo7FCa
         kU3KksEuVG9k8szQM9XySx2T9G7XQOTtEHjbhH1+Q0Bpm1x6x4T8pSt1wb34ptmsnUmM
         ya2ijLy4fh/ekTJf9pDXhAF9L8VKaToEfkuL0r8RGVdbjP2qvnIlczQngc7nKfFZP70n
         LWmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wvx1FUNr;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m11si1642947pjs.35.2019.06.19.08.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 08:54:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wvx1FUNr;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-ID:Subject:Cc:To:
	From:Date:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=AdWAClAsfgdFDOJ8SthOKZD1SKi8T6yPStutUze/gU0=; b=Wvx1FUNrzE5YYXD5o9Dr+bO15
	j1jeHYKfNRQGrDYwaCKhV/IdcRcjftWo+6hZ9RsS1kDngLy+TbYtXv1fko94u+vEKt1BBzU2sdhjg
	CydrwMLlm7xIXkbJOGt2uQuYKBIGFuzPeNeEXPom6V32KWbdN0OU18OrYqnsexrt6KiKsqsBok1yy
	TuOWNGqGLnekOhD/iibLN0pQ/Ugf5N9OnwV+gMWzGT++sgnCVsLyTxO35KjFZlGSh8oakU3SXUij6
	oiSlX5OoOWCm0zB60t1LkC7V8sI6jj3RleF1e66cuyOgNtwJ0de7ZMt9PT/xeTXTPsL+IVmbgU1nE
	98zoAB5yw==;
Received: from 177.133.86.196.dynamic.adsl.gvt.net.br ([177.133.86.196] helo=coco.lan)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdcub-000669-Sg; Wed, 19 Jun 2019 15:54:14 +0000
Date: Wed, 19 Jun 2019 12:54:10 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: David Howells <dhowells@redhat.com>, Linux Doc Mailing List
 <linux-doc@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, Asmaa Mnebhi
 <Asmaa@mellanox.com>, Vladimir Oltean <olteanv@gmail.com>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619125410.6da59ea6@coco.lan>
In-Reply-To: <20190619085458.08872dbb@lwn.net>
References: <20190619072218.4437f891@coco.lan>
	<cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
	<11422.1560951550@warthog.procyon.org.uk>
	<20190619111528.3e2665e3@coco.lan>
	<20190619085458.08872dbb@lwn.net>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Em Wed, 19 Jun 2019 08:54:58 -0600
Jonathan Corbet <corbet@lwn.net> escreveu:

> [Trimming the CC list from hell made sense, but it might have been better
> to leave me on it...]
> 
> On Wed, 19 Jun 2019 11:15:28 -0300
> Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:
> 
> > Em Wed, 19 Jun 2019 14:39:10 +0100
> > David Howells <dhowells@redhat.com> escreveu:
> >   
> > > Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:
> > >     
> > > > > > -Documentation/nommu-mmap.rst
> > > > > > +Documentation/driver-api/nommu-mmap.rst        
> > > 
> > > Why is this moving to Documentation/driver-api?      
> > 
> > Good point. I tried to do my best with those document renames, but
> > I'm pretty sure some of them ended by going to the wrong place - or
> > at least there are arguments in favor of moving it to different
> > places :-)  
> 
> I think that a lot of this might also be an argument for slowing down just
> a little bit.  I really don't think that blasting through and reformatting
> all of our text documents is the most urgent problem right now and, in
> cases like this, it might create others.
> 
> Organization of the documentation tree is important; it has never really
> gotten any attention so far, and we're trying to make it better.  But
> moving documents will, by its nature, annoy people.  We can generally get
> past that, but I'd really like to avoid moving things twice.  In general,
> I would rather see a single document converted, read critically and
> updated, and carefully integrated with the rest than a hundred of them
> swept into different piles...
> 
> See what I'm getting at?

I see what you mean, and I agree with this principle. That's basically 
why I split the patches into two groups. 

The first group (with comes first) does just the conversion
and renames from txt to rst, adding a :orphan: to the stuff that was
just converted.

On this series, those are patches 1 to 11. I was already expecting
some heat on patch 1.

The next group of patches do the renaming part. Those are the ones that
actually took me a lot more time, as I needed to quickly read several docs
in order to understand what's happening, before proposing a change.

That's also the group of patches were I expect more active comments,
as there are several cases where this is not obvious.

Yet, from what I saw, there are some documents that sounds easy to
move, like Documentation/laptops, with (except if I missed something)
clearly belongs to admin-guide.

Applying the second patch series and patches 2 to 11 from this third
series is, IMHO, a good thing to do.

-

IMO, patches 1 and 12 are important, as, after those patches, the
/Documentation dir becomes a lot cleaner:

	$ ls -F Documentation/
	ABI/              fb/              locking/        s390/
	accounting/       features/        logo.gif        scheduler/
	acpi/             filesystems/     logo.txt        scsi/
	admin-guide/      firmware_class/  m68k/           security/
	arm/              firmware-guide/  maintainer/     sh/
	arm64/            fpga/            Makefile        sound/
	auxdisplay/       gpio/            media/          sparc/
	block/            gpu/             mic/            sphinx/
	bpf/              hid/             mips/           sphinx-static/
	cdrom/            hwmon/           misc-devices/   spi/
	Changes@          i2c/             Module.symvers  SubmittingPatches
	CodingStyle       ia64/            netlabel/       target/
	conf.py           ide/             networking/     timers/
	core-api/         iio/             nios2/          trace/
	cpu-freq/         index.rst        openrisc/       translations/
	crypto/           infiniband/      output/         usb/
	devicetree/       input/           packing.txt     userspace-api/
	dev-tools/        ioctl/           parisc/         virtual/
	DocBook/          IPMB.txt         PCI/            vm/
	doc-guide/        isdn/            pcmcia/         w1/
	docutils.conf     kbuild/          power/          watchdog/
	dontdiff          Kconfig          powerpc/        wimax/
	driver-api/       kernel-hacking/  process/        x86/
	EDID/             leds/            RCU/            xtensa/
	fault-injection/  livepatch/       riscv/

Being easy to identify when someone tries to add a new text file there
without thinking on where it would fit[1], and to reorganize the
directory tree in a way that it will fit our needs.

[1] Btw, there are some two files at linux-next, incrementally
    increasing the Documentation/ mess:

	   IPMB.txt and packing.txt.

   Added on those commits:

	commit 51bd6f291583684f495ea498984dfc22049d7fd2
	Author: Asmaa Mnebhi <Asmaa@mellanox.com>
	Date:   Mon Jun 10 14:57:02 2019 -0400

	    Add support for IPMB driver

	commit 554aae35007e49f533d3d10e788295f7141725bc
	Author: Vladimir Oltean <olteanv@gmail.com>
	Date:   Thu May 2 23:23:29 2019 +0300

	    lib: Add support for generic packing operations

   We'll never finish organizing documents while people don't stop
   adding new files to Documentation/ directory.


Thanks,
Mauro

