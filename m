Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA9AC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B6B220645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B6B220645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E3016B000A; Tue, 23 Apr 2019 09:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BA506B000C; Tue, 23 Apr 2019 09:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3566B000D; Tue, 23 Apr 2019 09:21:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAF5C6B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:21:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o34so14639870qte.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PSmtLJklp98Cj1gxD0XbRieCl/5xuUBl8hL78+oIhLQ=;
        b=TUxrs907j1kYm/p4j3lY5mI9ZlZvCn0FVP0Iu6hZKkqn9MBzoayEwVieK8Wl4xq27T
         +I7lHVBi2Ow1pEH6bpehZxDjolKcZNPsfGY0ZdKsJzZZ3tuewTPfRcBiar/nF7MCEZAW
         m1B1dmvY1kcHUtJ1JC4MIcZgeHkJJzk38+4wCl4kyfPTnHXMc8Het8ueU/y2vIBDOiXl
         Ld1vjnmiwIpd7AtypRnZ/TzDnXtpdflBpzjrWOCdYO6nq35Puv6dHZ+lAWcCS1IYnwPE
         cNRtsNzOM+kHzmL709TGUiJZWQUFpgff80G7HM85xf79rq32AnmcTrrD/9TE0mtzP/fV
         ulLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUcdEZwArdGR82OEihIzuDX14lNyNO/VKlf8+udaXuRrK14p1Fw
	D6AmqTQeYZwtHFYVICisMTmg8wYG06NspFUHlzHVIyL/onM7RNnt94DpVu/O+INm81ZJ9hClxjc
	3chs0iuQG2Nf5j8UfbqZuiV4+VovQRmUvoeAZxzGxuo0W5XNvznIy4q0PU5A5ZrzHNg==
X-Received: by 2002:aed:23ac:: with SMTP id j41mr20595661qtc.181.1556025675530;
        Tue, 23 Apr 2019 06:21:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdYeENMvFrKCwzxiVB9rxfL8n5eoinXbBOY9yzKEe8sPCPnTDtpn6S07qGx92rQ9gzVbHM
X-Received: by 2002:aed:23ac:: with SMTP id j41mr20595586qtc.181.1556025674576;
        Tue, 23 Apr 2019 06:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556025674; cv=none;
        d=google.com; s=arc-20160816;
        b=MGTkrENvMLiIbryRIaA+s4droZ7oNXNSoPkqY46NpSX1xfRAG6XdvsSq1hLoR5rdfI
         L/sDFJpbHvCiLTylYPthnh0qFF0CsmlYjz5j5AfUppmW5Lif/biuntMx91+9vx5EtQL7
         n+RsRzw+rvXOVVHAHKOnN+RryQ040KPAApKW+DL7b3Fp1IGoEUcQ3MJfrdVEoVqaIAGo
         ruC12QmGGakKsYL8TlP0mz21QvvVNPYXoWBh3UrF0KMEqWdMLM5C3HDS37VSMivrFXn/
         HBxWBSCYqF5wNGXBYk8kswqgcxN9YH5wwcUSKiE+rxzSxdIVcNm4PjILm44j8i17GnvB
         x1kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PSmtLJklp98Cj1gxD0XbRieCl/5xuUBl8hL78+oIhLQ=;
        b=Cn9lbba5PdeqPp/Ll3bZ7Kfrr/y/XjICGXmYGyP6NasDzzKqxirq4/nIPftEgyWWnr
         DMwWwpHCnrT8wktmuqnHEbqrlxHl5rTW6DDk45/T0BIkaaPBE9F8N73D/pW8pNKbOzK/
         rNkllXNdOvQA0t8HZp7iRRFstFUDu9QWI3Hov31GKe/DSUWtUUgxZILiqg3uBEMWyAWO
         G2qxNcU3kRfM+i9Xz/G3ajM4nwzyceh/jQ9OzxxyYfITQ7swDJKnC9JUm3YactKmYI4N
         UysKrrzpm9fvs9IaveM41iI90VqND4buQ694VJy3vog5WY7V17dbcU3cECt9S4ppHmR5
         B4zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a24si2132963qvf.201.2019.04.23.06.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 06:21:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BC3962D7F5;
	Tue, 23 Apr 2019 13:21:12 +0000 (UTC)
Received: from localhost (unknown [10.18.25.174])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A27E11001E8C;
	Tue, 23 Apr 2019 13:21:01 +0000 (UTC)
Date: Tue, 23 Apr 2019 09:21:00 -0400
From: Mike Snitzer <snitzer@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alasdair Kergon <agk@redhat.com>, dm-devel@redhat.com,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, Ning Sun <ning.sun@intel.com>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Boqun Feng <boqun.feng@gmail.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Jade Alglave <j.alglave@ucl.ac.uk>,
	Luc Maranget <luc.maranget@inria.fr>,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Akira Yokosawa <akiyks@gmail.com>,
	Daniel Lustig <dlustig@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>,
	Cornelia Huck <cohuck@redhat.com>, Farhan Ali <alifm@linux.ibm.com>,
	Eric Farman <farman@linux.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Harry Wei <harryxiyou@gmail.com>,
	Alex Shi <alex.shi@linux.alibaba.com>,
	Jerry Hoemann <jerry.hoemann@hpe.com>,
	Wim Van Sebroeck <wim@linux-watchdog.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org, Russell King <linux@armlinux.org.uk>,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>, Guan Xuetao <gxt@pku.edu.cn>,
	Jens Axboe <axboe@kernel.dk>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Matt Mackall <mpm@selenic.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Corey Minyard <minyard@acm.org>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>,
	Darren Hart <dvhart@infradead.org>,
	Andy Shevchenko <andy@infradead.org>,
	Stuart Hayes <stuart.w.hayes@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Alex Williamson <alex.williamson@redhat.com>,
	Kirti Wankhede <kwankhede@nvidia.com>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-fbdev@vger.kernel.org, tboot-devel@lists.sourceforge.net,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
	kvm@vger.kernel.org, linux-watchdog@vger.kernel.org,
	linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linaro-mm-sig@lists.linaro.org, linux-gpio@vger.kernel.org,
	platform-driver-x86@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-mm@kvack.org,
	kernel-hardening@lists.openwall.com,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 56/79] docs: Documentation/*.txt: rename all ReST
 files to *.rst
Message-ID: <20190423132100.GB7132@redhat.com>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
 <20190423125519.GA7104@redhat.com>
 <20190423130132.GT4038@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423130132.GT4038@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 23 Apr 2019 13:21:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23 2019 at  9:01am -0400,
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Apr 23, 2019 at 08:55:19AM -0400, Mike Snitzer wrote:
> > On Tue, Apr 23 2019 at  4:31am -0400,
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Mon, Apr 22, 2019 at 10:27:45AM -0300, Mauro Carvalho Chehab wrote:
> > > 
> > > >  .../{atomic_bitops.txt => atomic_bitops.rst}  |  2 +
> > > 
> > > What's happend to atomic_t.txt, also NAK, I still occationally touch
> > > these files.
> > 
> > Seems Mauro's point is in the future we need to touch these .rst files
> > in terms of ReST compatible changes.
> > 
> > I'm dreading DM documentation changes in the future.. despite Mauro and
> > Jon Corbet informing me that ReST is simple, etc.
> 
> Well, it _can_ be simple, I've seen examples of rst that were not far
> from generated HTML contents. And I must give Jon credit for not
> accepting that atrocious crap.
> 
> But yes, I have 0 motivation to learn or abide by rst. It simply doesn't
> give me anything in return. There is no upside, only worse text files :/

Right, but these changes aren't meant for our benefit.  They are for
users who get cleaner web accessible Linux kernel docs.  Seems the
decision has been made that the users' benefit, and broader
modernization of Linux docs, outweighs the inconvenience for engineers
who maintain the content of said documentation.

This kind of thing happens a lot these days: pile on engineers, they can
take it :/

