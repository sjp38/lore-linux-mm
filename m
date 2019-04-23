Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F8B5C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37E3A206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:55:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37E3A206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C900B6B0003; Tue, 23 Apr 2019 08:55:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C666A6B0006; Tue, 23 Apr 2019 08:55:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B54636B0007; Tue, 23 Apr 2019 08:55:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 953EB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:55:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 54so14537263qtn.15
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:55:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=etfNyz8cAK+UZbLRhLbBHua3of8IV3cvQGBrSNX9OiI=;
        b=ATyNos0da8IueyR6ZSeVvCRUw4YHLoHc21k4OhPirliQfxwVvRsHb4VnI1QfTVXg4s
         oCOwEivdD0b5w18sT3EbNTvb1/3OtzbnLcZpleZyJdYp5tEiDuWHnS2OX+qpSXffPcje
         npzYdwSyXteI6qzEiHlEBhJUMTqMtCnF7bI2o5EsUjzJG5Rep/LprqGtk3m0bHemEop8
         Sz85WUWKOKCSNvcjTePAmb7Miq9RcdBSvyeSF0AYZX/MfyvH01wq8cvV8Ml8Z8UKxHEl
         9U2yvSelhj95mt6vwjN86jNRGIAPUDcrrV7XkFo2JkYbHf20Ow1Aa8qvSu7DsDr8OapX
         cjKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXbt8j7IbZYWeqAkBAQlPzXXtxlANCKd4uQHLUcgM4wy12RA+wc
	uLYPXsNvTxyeU7I9bHQGy22fV6WqPBSaZ1DdhGdbIXFNfLTsRKcPGdQ+i29qe3TfReoltVagSHZ
	IFtRkRw5aQVQun0Nju8xa5rOQOTYBcJvATjyBhynZ6huDn8Cx0K6ctGAG4L57tPgtdw==
X-Received: by 2002:a05:620a:13a5:: with SMTP id m5mr19232343qki.34.1556024151393;
        Tue, 23 Apr 2019 05:55:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLBrqJ63/1AVrPEexovcZ1BLtz9DZYIdkMVopk2RGW7V77ndN0PyvTUE2xvCqQsd9cI7UC
X-Received: by 2002:a05:620a:13a5:: with SMTP id m5mr19232298qki.34.1556024150739;
        Tue, 23 Apr 2019 05:55:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556024150; cv=none;
        d=google.com; s=arc-20160816;
        b=n1cOJhTarDD/X0yGOIPD/Oi8FqNDimec5F3E+3AgIcKWmUeBvJQYzd2q3d9FvSscsO
         jk++RZk4Cs8GN5U9IgzBJ6FzL/XwrREyGhhboC5hwYrx4U+OXNLdaDMogpcyBWdATLs0
         SadiOWiCzFVb8hm4Ow+TflSt7TT1mF1OV+f230HOCWCx6lDPbZhQoi93Bv4Y3RUbQObq
         7fSSi7XAXghPHBEnBEvxKW6QBjLuEr+82XOPsbRFYFSU3fPqCv/FTDLsnPzha5dTHJVK
         ZDGmaVvCEE2gZ+cR8xNob88ex5BFs84rduZiNm9fbC8zS845S7bdOHKEhG2/q1hb5QFX
         qOeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=etfNyz8cAK+UZbLRhLbBHua3of8IV3cvQGBrSNX9OiI=;
        b=c8DBYgZYrI2zFH9vCeVL0cpXV0GjuysXLkySPB4HHzf7gU5bvzg8QxxJpux+8B2pMn
         6OperQOA0yErXwxEzYnBj3VYx+FkA6BvhnR83toeDlvXou2366lPlYXM9bbY/XHurkIp
         yVERXSr9YwxWJVCVZji/8AoSl19/2g1gsrURk6+WQLfNk3VSLjg0V8/6uql2TR9cNRTg
         XhidVDMP1PqsTZFpuFT44fneoGHmwkjTIPKL/WqHmcRt7rVWNrykkvzJmICRbp8yNlFc
         JLLV4RCDtN4wJG7Q3VLW6rKqb9pG9WD1dx3ezOK3AeNn8vk+XPpAsrbXgp71G5OFNH9e
         TQ1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s81si4845537qke.192.2019.04.23.05.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 05:55:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of msnitzer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=msnitzer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AB9A30ADBC8;
	Tue, 23 Apr 2019 12:55:39 +0000 (UTC)
Received: from localhost (unknown [10.18.25.174])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2F3DE6013B;
	Tue, 23 Apr 2019 12:55:20 +0000 (UTC)
Date: Tue, 23 Apr 2019 08:55:19 -0400
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
Message-ID: <20190423125519.GA7104@redhat.com>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423083135.GA11158@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 23 Apr 2019 12:55:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23 2019 at  4:31am -0400,
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Apr 22, 2019 at 10:27:45AM -0300, Mauro Carvalho Chehab wrote:
> 
> >  .../{atomic_bitops.txt => atomic_bitops.rst}  |  2 +
> 
> What's happend to atomic_t.txt, also NAK, I still occationally touch
> these files.

Seems Mauro's point is in the future we need to touch these .rst files
in terms of ReST compatible changes.

I'm dreading DM documentation changes in the future.. despite Mauro and
Jon Corbet informing me that ReST is simple, etc.

Mike

