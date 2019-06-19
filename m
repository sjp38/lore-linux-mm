Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ECE5C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:46:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F2332084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:46:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DhxC+ENO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F2332084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC9066B0003; Wed, 19 Jun 2019 07:46:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79C78E0002; Wed, 19 Jun 2019 07:46:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F28D8E0001; Wed, 19 Jun 2019 07:46:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4AD6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:46:04 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d15so1221545wrx.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:46:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8Ld1/gUBGA37LwDlAfN0RHjyQhkqgHav958Z4E1YaNk=;
        b=EmxBmhpLkRTXQAWYf+0Con+5YC98Whc6D93WRdIBHNi70sHQFIU5D6V3yD+moU2DkH
         G0f7fGKajeqOcsigM4sZGgwsaYJWqXLg9l6aAvyUB7iXmeP8ESxmzNRQEqG+K8Ljw8aW
         7aXwJ3SWORgGoKHRB9pzz72M4Gtm5wMcEdOKDxHacVlSPH3ppWW0Rtb4RdHV/VxGC40y
         2twgvqqNCSlbGKLuj/fGo7doDmnhotgsH2wZZqf1aTCgk06khYsGql1iOb15lmhJijSx
         Apg0PDVPPFE/RjAw/PAE7NQ7gl1KnB65zsTaOB0yRRL7kM6kxBKrpWmNNP0Sh0bCm6q2
         gdKg==
X-Gm-Message-State: APjAAAUe/u6pPtiENyRp4d0auvkIHaZvHoBLowo+l1t92X/CJvFJRxM2
	Syiy4rO14M5Xlp1vLM1DXHDGYplA8K7P4mq+geTAt8IbnoxtruGHkYubnTx8YEQ+XLYTRY9dgyM
	LCZVipF04EQa71BrqRZ+vc7lGxUVKnfzVMX3GRYmbEDNRTpKpr0oQ1EW3lZNaGlA6dw==
X-Received: by 2002:adf:afd5:: with SMTP id y21mr84629873wrd.12.1560944763786;
        Wed, 19 Jun 2019 04:46:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+t4cW7utEB/fHlfe98xLV968+B7BljtOv7KqDwTroSYjSEMWMmjEPwDL/MRMeZCGIr6lQ
X-Received: by 2002:adf:afd5:: with SMTP id y21mr84629821wrd.12.1560944763054;
        Wed, 19 Jun 2019 04:46:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560944763; cv=none;
        d=google.com; s=arc-20160816;
        b=ptHPMdPGaFjRoS+on/OxJNazyi7RApx5Xgv/UcZFcyVSreuaVi9nrKbTv0PDA50gtv
         PtBhnI1ebu/SsgmB20uF3/hUhpNpdlx3OWyqxbRAOwjPS3Vu+64CEvBUxMU8Vd/z3Rdt
         6SP8ffaquy4aFckvZHGDOaPAq4vPuwUmNzsHXmgGdgjRR7SNpw/padieueS3zRJySJEq
         KYgHC9beRiN1gk7/ZnEyqd3EjErz9Izt06edOkhP5hQzv4VYMGkR6MqVAfrozrQ3Qf3F
         g6pKmDwecMfnzwMQPC3t2Ridu4UzO++bX/Q25ImPOfarr12YQSa7N5Bn2f3VcPnok+4r
         Xv3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8Ld1/gUBGA37LwDlAfN0RHjyQhkqgHav958Z4E1YaNk=;
        b=VVrxiDCLIvDxSkxbUsjmEVziONRWyrD6vWw3MmDJ7uP0wdz2wqrpD+68ZS5+wTiZwA
         4Sn/s/wn5vPFik2aw8gNb3eRpxvpE20BaB2NrgiQkicijatR/nLnLtsNHLGtBJrDvTED
         Uyp98EYg5c9ylKOK9i8jPII/WVT9wFvJ/0CZQeaKo9yT1suAIotUv0QiHTcuz2xgSyTU
         d3fYz1F8JGZl6bhh2CcfwUvNhKW9PveJKTbZ04F88fEasqwoupYCY6wW9LCCwWCdQRfe
         QvMbNMQ7YIoM92UocUHrle6OyBDYkajZsmFYAdcWYivDjhGXlOFId6m7j6g1awh36SB4
         QCxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=DhxC+ENO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id m6si6762705wrn.240.2019.06.19.04.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 04:46:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=DhxC+ENO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8Ld1/gUBGA37LwDlAfN0RHjyQhkqgHav958Z4E1YaNk=; b=DhxC+ENOnd2Nk4b8T/HMJUPzz
	5WNVLKvDJcfUGbnM5+VTHFA2m91PvfuRuayR5ED5QmBv3lEawxZ5ApLG84FZIQYeVrko8q9k4XwU9
	FR7toCfnP0eO4dTCz2MYzpJDu0Pp0m8FTj4RiVREpibUIYeZN7luHs0i/Rr7l8KI09XjMPUDzeV1U
	927w887Wj92ThjXRQcqoyjlxYHUeG7U0dKoS3GeOQePvL63I3zBb+tyDtMTtMtEwmsyDX4GWZIyt0
	F6PZU9yN6ShrwEzJwdf2fXRGHvQ0w4XtpTkSLJeTIdMj3LE4T0i1tBWPOMtDb3yLncV0gNnoPYjHg
	tMoWXagEw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdZ2G-0006lF-SI; Wed, 19 Jun 2019 11:45:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A55D3201F98F6; Wed, 19 Jun 2019 13:45:51 +0200 (CEST)
Date: Wed, 19 Jun 2019 13:45:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Will Deacon <will.deacon@arm.com>,
	Boqun Feng <boqun.feng@gmail.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Jade Alglave <j.alglave@ucl.ac.uk>,
	Luc Maranget <luc.maranget@inria.fr>,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Akira Yokosawa <akiyks@gmail.com>,
	Daniel Lustig <dlustig@nvidia.com>,
	Stuart Hayes <stuart.w.hayes@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Darren Hart <dvhart@infradead.org>,
	Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Corey Minyard <minyard@acm.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	William Breathitt Gray <vilhelm.gray@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Naveen N. Rao" <naveen.n.rao@linux.ibm.com>,
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Johannes Thumshirn <morbidrsa@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Thierry Reding <thierry.reding@gmail.com>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Kirti Wankhede <kwankhede@nvidia.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, Farhan Ali <alifm@linux.ibm.com>,
	Eric Farman <farman@linux.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Harry Wei <harryxiyou@gmail.com>,
	Alex Shi <alex.shi@linux.alibaba.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Jerry Hoemann <jerry.hoemann@hpe.com>,
	Wim Van Sebroeck <wim@linux-watchdog.org>,
	Guenter Roeck <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>,
	Arnd Bergmann <arnd@arndb.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>,
	Andy Shevchenko <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-arch@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-remoteproc@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-pwm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-watchdog@vger.kernel.org, linaro-mm-sig@lists.linaro.org,
	linux-gpio@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619114551.GQ3463@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
 <20190619114356.GP3419@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619114356.GP3419@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:43:56PM +0200, Peter Zijlstra wrote:
> On Tue, Jun 18, 2019 at 05:53:17PM -0300, Mauro Carvalho Chehab wrote:
> 
> >  .../{ => driver-api}/atomic_bitops.rst        |  2 -
> 
> That's a .txt file, big fat NAK for making it an rst.

Also, how many bloody times do I have to keep telling this? It is
starting to get _REALLY_ annoying.


