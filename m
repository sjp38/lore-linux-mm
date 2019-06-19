Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29146C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:44:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4A852084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OXehKNII"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4A852084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ACA76B0003; Wed, 19 Jun 2019 07:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65C5F8E0002; Wed, 19 Jun 2019 07:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 523A58E0001; Wed, 19 Jun 2019 07:44:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01F366B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:44:19 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b6so1211430wrp.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:44:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=P4p0lEgtRoDQcgzLi/inI+oeUsfDK0bgbuVkWRc+gr8=;
        b=U1MoqDyDJKVnYpRUIqimxhdSu8eCSB+1UTAMSjULN34ORWzwUwK/TMb8lJ1C4lQJxD
         cESDsPULvnq0M2usN6gSf5T5hVTw5FtFqxerkUkGjxFLjP3Q7lFjI73pUKOGHzBsfRT9
         LOjoc5prXLHSwC1s9MI6BPgvm78aHS8zUN9r7YmKC9P2IxXUF5/WgEniC4vytX8zCfVk
         n5tBf1ZfVFJOly4IBhA4PeCm+IWH0PTtVV4GsefMNeGzqUhKROpwfHDrXMnzbewDQ1j4
         SmnYjV/qGRXsQ+C8maQZ4wkQ4X4aUXaMjWyzZ/iJb51BwSxpHJ2Bq3lDL9aW/KG1KdSu
         V1IQ==
X-Gm-Message-State: APjAAAWMb7Cgarr0rCOveXlsOuafy7LVG08gZau5KWrcZAMCGTc6bnWx
	WTXcMvSaFmrcZ5JmM6hOqOnLWDFQ2awUdqmVgSXglfmBWmQ4qG+eo18GBm02K73Z1mbn1gQtlXz
	nUr5MftSZ0G6yzjUyNillsPQgibvMIa/sh5YRAa+oDKXVBRcCDt/rv0kzHUI6hku4Og==
X-Received: by 2002:a1c:6545:: with SMTP id z66mr7893407wmb.77.1560944658559;
        Wed, 19 Jun 2019 04:44:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH8UqLLRvfo9x/cZWOmT2qj6HueRKF3WO7hIA/VeUvH9IXVA9WQtFUIZjvY6ZsJyleL//u
X-Received: by 2002:a1c:6545:: with SMTP id z66mr7893342wmb.77.1560944657778;
        Wed, 19 Jun 2019 04:44:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560944657; cv=none;
        d=google.com; s=arc-20160816;
        b=ic9nO8h6PU+KOmaS1d3l3w/tQyY+GmShBpPYm9K5tc4KeKli7At6QpohuzKwwz0OBt
         0rTNnljs+a3C58R64sV4Vj52zaoXSWj8lL3pOvqKY6UhSmxPqy7ffjyCFUkCXamBq3VP
         Qd4A9uEVyogRFvgP0oU/w/DqCH+KEDUGBp9v9q8zyNP97EWXkdjxrrHMUk/LZ9jq6zIK
         kHOXuC8fjAk8Mvr9iEhK72oI14Gk3XfqNFqNWr4NMBrvBXU8S2lSSahnjqra7RVmmKOK
         c7nRdsXP0cxQ6sZUJN+vT8vmW8SWSBqyn8gbmo1xP+ItZvsyKxweyeyTKJqoHtPyXkfo
         eUAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=P4p0lEgtRoDQcgzLi/inI+oeUsfDK0bgbuVkWRc+gr8=;
        b=RZ/yDKWUtzjexEL/+MviZsQlfzU7Uyk4zrEl6D54AYGuNdTRFCAbXMxwpz2p+dFi8P
         7W6OQTjytynYu4m5nYlMIFA1qdo1Pf+Zm0ndRiEATf3mDN7TRq86o/MU3Dy76q0EDL+N
         trkp0bUmcEXk9N2fY7XBnkXwjwp1q7FkProWjSvGNXOKKn2P3XRY2cEqWINtPN5+e+9z
         Rs5uMknyS/KFvcTy0fIZdhRh4Y995RPOmDbQAcqtAH4eSBI5vDTRVp6A2R07iuK0cvdw
         8XhBRfiIbrOBfqPDZFaVX3kp0v/hVL9p2FOAsiz3piv92TWW+Vz9GfvamcULwtMo1JAP
         S0lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OXehKNII;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id z2si915567wma.41.2019.06.19.04.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 04:44:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OXehKNII;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=P4p0lEgtRoDQcgzLi/inI+oeUsfDK0bgbuVkWRc+gr8=; b=OXehKNIIK5+7AJqrCcGuPeVQM
	sVAS9t3w53Uf+9ZjZ4Oq/miXG9m8YOfsNDtBNH0H+PLoL0OD3hYR4lqfcnlqXXkk9st/FSykuUJVj
	/2Cp6IiZzuYUsS4mDt+wjwiHTlu6tEjE6fjTRmD0JgHToB8P6+J5KsBowqTn7mC/e8A9hunO6Rxcp
	nktlcUBXd6KFAhFC4z/P+88TooWUE6AEv5ZOHdPEAJfCQDchI9f5L0jLpFx7f6DONdb+LnMmzG8ll
	aUPisfZJyyV7qB30UzBVViMk7eKAp8qgDwCq4VHjBTPt1rWquWLxrXMCrWzlFFJjuNkmeHsoD0UZl
	Ruhswmm0g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdZ0Q-0006kA-QD; Wed, 19 Jun 2019 11:43:59 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6377820796506; Wed, 19 Jun 2019 13:43:56 +0200 (CEST)
Date: Wed, 19 Jun 2019 13:43:56 +0200
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
Message-ID: <20190619114356.GP3419@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 05:53:17PM -0300, Mauro Carvalho Chehab wrote:

>  .../{ => driver-api}/atomic_bitops.rst        |  2 -

That's a .txt file, big fat NAK for making it an rst.

>  .../{ => driver-api}/futex-requeue-pi.rst     |  2 -

>  .../{ => driver-api}/gcc-plugins.rst          |  2 -

>  Documentation/{ => driver-api}/kprobes.rst    |  2 -
>  .../{ => driver-api}/percpu-rw-semaphore.rst  |  2 -

More NAK for rst conversion

>  Documentation/{ => driver-api}/pi-futex.rst   |  2 -
>  .../{ => driver-api}/preempt-locking.rst      |  2 -

>  Documentation/{ => driver-api}/rbtree.rst     |  2 -

>  .../{ => driver-api}/robust-futex-ABI.rst     |  2 -
>  .../{ => driver-api}/robust-futexes.rst       |  2 -

>  .../{ => driver-api}/speculation.rst          |  8 +--
>  .../{ => driver-api}/static-keys.rst          |  2 -

>  .../{ => driver-api}/this_cpu_ops.rst         |  2 -

>  Documentation/locking/rt-mutex.rst            |  2 +-

NAK. None of the above have anything to do with driver-api.

