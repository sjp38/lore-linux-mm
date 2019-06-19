Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3474DC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:50:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E098D2084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:50:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RJJ57mC3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E098D2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87B3F6B0003; Wed, 19 Jun 2019 07:50:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82C4C8E0002; Wed, 19 Jun 2019 07:50:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CCFA8E0001; Wed, 19 Jun 2019 07:50:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E22B6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:50:19 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l11so1233279wrv.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:50:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7oirUMfZfxrr3jt+2AGQfs6G9jdxOgY1bbAc2dQvRYU=;
        b=s+4OvfdC9yf6NheJRKoV1PEYZF2iuv22CZakTyeYYjPIcHcI3jjM99PFA8FL8OaMPS
         BcVXNfYydjcyBpg2oSoPRiMbsJUHsM8n9BYrJChNgKhPEYsjCajxYTNmLPjwsveC+3df
         t93oYolDLt0D0NBACxHuT1pTWdL3hSY2H9dNVVnhGbmahRGAGu7hPDUcHUvGOjvRGKeg
         1ueOfL3kulVp3+oyxQiJLhzbP4Gv46XYWbB7EV1puPxArDMQKKLPMA+OYKhzpexJ9qyE
         0YyMDRaRl1Ojw5Fg79WJWVmzM3UtvejhDW/kS5CfJF0gmbq8l3B78srrp1rYOJc/UxGR
         HcEw==
X-Gm-Message-State: APjAAAWWvr6E+kRiSvnLQxGOEdt26avotiqN9nd6+cHInB4nKQzIIEu8
	TIQR5xnp5XYWD/zm8QmKCSIYKWyvOdYERNvCEdH2FrHy+DvatPKO4GGkoF/4NHK773m7Jlrkfhp
	Y5auxroFUfOrmsJIHZFKNQ4HhAFtK9wiaFADEHKKpMMsHToBiMZD7eBDi5KEx4KlWeQ==
X-Received: by 2002:a1c:f918:: with SMTP id x24mr7671489wmh.132.1560945018698;
        Wed, 19 Jun 2019 04:50:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9opFdPO1UNYnGKaPnqLw02DNJhqQc8kbDsXVnNNz/OzTZHPt3z4y8vhI+6v5KwgBu5+Be
X-Received: by 2002:a1c:f918:: with SMTP id x24mr7671426wmh.132.1560945017952;
        Wed, 19 Jun 2019 04:50:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560945017; cv=none;
        d=google.com; s=arc-20160816;
        b=Mn0lFxo7rgat/21X1Xu3CykN7GOlu6Be9jEA4Wv8NvyEEdGGUX2r/bOTtNAxmGiRjv
         cng0t5WUO6q+K6oYR564rt9yGhZDtNeTipmfhq0ioQZmXRc4q1/ob0ZWHPnOoQXbQ0tg
         vJ98TpXVuvOtvKCixvPrroYzWvXwlqvrCIOH8tIAInwQaVhisJHdby0E1cqaF4ZWQl1U
         Off8S6Pf+FLlys1+0qXSUjZKCf5y2pqZbLiuCa4B0PCZmjWXRkTYwZ2zvLH3vpHm5Xil
         bJmd6Vah8bEg/HH0fC+EGy+xXLu+TlYyBgf7sSiUcC+oLcUKEoWQZB2X7Rs/AdYiM1sU
         GV0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7oirUMfZfxrr3jt+2AGQfs6G9jdxOgY1bbAc2dQvRYU=;
        b=fv2Q/cPwdiqU+loYkga2XTNzzFh4z+xdrlO0BD8kpimZeb6T1uqYvoIZGF5k/iTRgz
         8H3i0TKNfOYioxap0++5HGrckgEvK1lCM2396yZiG2oRn5yxnClra/kxIDNcGl4D/TWc
         sTJ04NYjj9jlPuYpOCH7oQ001RD+sRplTesKh+dPuVR1ZM9nziSyqcHSWsFLPQYPs0W3
         mpkplN2duFc+JCLKD2fZR/s5A2itbFuBas5jMTqJY+G6gSRr3boxT6JW9wNF2SX8ZXSU
         o43lD1XXzx3JNrswlQ1A2UGzbCArHxNP3I5MHsB8sKnwTjXRW/V3FwbOKQJHctNdyxri
         foNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RJJ57mC3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id m1si1007877wmm.63.2019.06.19.04.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 04:50:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RJJ57mC3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7oirUMfZfxrr3jt+2AGQfs6G9jdxOgY1bbAc2dQvRYU=; b=RJJ57mC3DoX4kmddHgf5MWl9f
	oPK2yo/u2EHO8ARc3+li0s71dUu67poqYF5V4aRQXwOjK8shgHJKYJ8PiAO3UukIhPTajqEgv18iU
	OptU4Zr2lC+iG4vvVCcWyxJXHYyUsUsx/U6IgYzFc3jrAD83SR6GqQlHXfhR/OhY8BWk8JGk2R0Gz
	1RsXgSdtweWI95Z4nJ8aUWS5Re+UPN+FY9Oo5bHqiRTDq1NdxtrEtJGp6D+dYrQ2nE+zbU9MY+Yq9
	2yPO5RIFuWHTrUVI4Q0Uox4zIGAVgkA/uRk4XaxcLrPcMeuKkixtyyK3r60moDLN8Sf4Cm5O9yPmI
	dmu0mNEZQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdZ6O-0006n8-Oc; Wed, 19 Jun 2019 11:50:09 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 87EA1201F45EC; Wed, 19 Jun 2019 13:50:07 +0200 (CEST)
Date: Wed, 19 Jun 2019 13:50:07 +0200
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
Message-ID: <20190619115007.GR3463@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
 <20190619114356.GP3419@hirez.programming.kicks-ass.net>
 <20190619114551.GQ3463@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619114551.GQ3463@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:45:51PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 19, 2019 at 01:43:56PM +0200, Peter Zijlstra wrote:
> > On Tue, Jun 18, 2019 at 05:53:17PM -0300, Mauro Carvalho Chehab wrote:
> > 
> > >  .../{ => driver-api}/atomic_bitops.rst        |  2 -
> > 
> > That's a .txt file, big fat NAK for making it an rst.
> 
> Also, how many bloody times do I have to keep telling this? It is
> starting to get _REALLY_ annoying.

Also, cross-posting to moderated lists is rude.

