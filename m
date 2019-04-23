Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4470C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:35:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B85A218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:35:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B85A218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 199ED6B0003; Tue, 23 Apr 2019 16:35:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149186B0005; Tue, 23 Apr 2019 16:35:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 010E26B0007; Tue, 23 Apr 2019 16:35:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBAF66B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:35:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r5so4294139pgb.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:35:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=NWym8ed0ac5YijevlL+9P33gekKbYTV5W+hQH97w1zw=;
        b=SA5c3ZHMHjRdhbvsbJ47D/zHfTC9J/jUP/15YhBfDYyqmjkKum6tTG6/o1ThLq4U/R
         Pbt15GzW9N0YD51MonmVp4VukuUZp4Ke5IHQeBy+2rG/nYJsD9VRLfQJXOmvAkJ1nCuR
         Vzv5B2SPstbeuPVDEgnFbkARWmnWMWp1M49G+mLjj9HDlypwABaWlnsQOl7RheZKwqKC
         m1kFOx2xEG1RKGoI/ckgVC2sNUmQJFJ0v/dZQfskn2hP5WJISUfaNZ5u+uHP92xfJTis
         DNbReFfMAP6T16LY6WAsCyBoHOHn7FhbU0MahQg5NgNjHYLBPVFFsMs6McVzfRrrvKgj
         rp4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAWWxAA+gQ5+3zKAebKzaU41NM9kBdombJz5Fwf7xuAdxsPxmFWn
	unYPvfeG9YOJhntNK0QyyefbiT7hhIJf4rcuGbsJ1kx3+aRyceE5DZ7lUFnKKPqKz50aRyRiiMR
	z0J3UDi6qAUdNEBsktVtmCdliTbOvLTO7Syk65GI/BHwUsA3uNWa9RnXYMZ7DAypiZw==
X-Received: by 2002:a17:902:1d4a:: with SMTP id u10mr2724153plu.272.1556051711336;
        Tue, 23 Apr 2019 13:35:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcuvTYntd0mBLpytNvUJOmPTHA0lradzs56+/wRuCU7L15r4OA1XbIr4eDBOlY7euF9fto
X-Received: by 2002:a17:902:1d4a:: with SMTP id u10mr2724109plu.272.1556051710671;
        Tue, 23 Apr 2019 13:35:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556051710; cv=none;
        d=google.com; s=arc-20160816;
        b=I7AZlEok12KufmVOgaCeSVcV6DI3xbj5+d0gH4ahvhNisTN1GQzVW+krLyqtbwx1Ss
         ibPOb/7jnKuaYsP22tdOaGv33uDMHLbNbf8NYYE4fw06Su8hmpYNhSwstXMJ9HDbQejU
         vVm8XpSzYzxVx9HpukfSOHQnKERr9Bz6VObdZ6fLZSYmzW7UXLwNPnKDYvXoS3IEtG5p
         TrywtaiHqKhYn4AbxHuSl0gPtKLu9BCNJJXKHLeaidqmMAUBv32Mif/u/TJuUS9QIaB9
         sXQlUL0iCXLr3Cqf3ORudtTcA8HD51Ncei/XEQvpEgTFPsXMXdUu+VUQPxU6+2cxKXEi
         o3NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=NWym8ed0ac5YijevlL+9P33gekKbYTV5W+hQH97w1zw=;
        b=mVYYLywmGM4gGpO2k9ZrI5ZIdeebOL8SP5DhSm7Udqngc4I53IoXLCOsmldVasnyJe
         LxJi1j4m40nUJrpxdkuk6HfaNEA1X7sjS8z01tuWswP0WGEZWhTAEQ+Nhos7i4o3zHUZ
         +4OeMT9nW0oJ95KZbtQWr702IQ0eevRT7+6nml1lJswSHL3MOhUI7Z4YDOGv98jBGS/n
         WE05lIl7sOlmBMhEDIYzcupwOY61/pNnY125JZg7oewMQqcm76hcu4Ar2AeVdUpyuG0j
         x/6GlcVcHek6jKwhy1TdAfpdB1JPhcXBbUdrlD5+lrOXMHJpPfXwSwZCrDv9LSRCS7Mv
         Cb3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id e92si17672217pld.252.2019.04.23.13.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 13:35:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 5739A2DD;
	Tue, 23 Apr 2019 20:34:42 +0000 (UTC)
Date: Tue, 23 Apr 2019 14:34:38 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mike Snitzer
 <snitzer@redhat.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>,
 Mauro Carvalho Chehab <mchehab@infradead.org>,
 linux-kernel@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
 Kurt Schwemmer <kurt.schwemmer@microsemi.com>, Logan Gunthorpe
 <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Alasdair Kergon
 <agk@redhat.com>, dm-devel@redhat.com, Kishon Vijay Abraham I
 <kishon@ti.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland
 <mark.rutland@arm.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter
 <daniel@ffwll.ch>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
 Ning Sun <ning.sun@intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon
 <will.deacon@arm.com>, Alan Stern <stern@rowland.harvard.edu>, Andrea Parri
 <andrea.parri@amarulasolutions.com>, Boqun Feng <boqun.feng@gmail.com>,
 Nicholas Piggin <npiggin@gmail.com>, David Howells <dhowells@redhat.com>,
 Jade Alglave <j.alglave@ucl.ac.uk>, Luc Maranget <luc.maranget@inria.fr>,
 "Paul E. McKenney" <paulmck@linux.ibm.com>, Akira Yokosawa
 <akiyks@gmail.com>, Daniel Lustig <dlustig@nvidia.com>, "David S. Miller"
 <davem@davemloft.net>, Andreas =?UTF-8?B?RsOkcmJlcg==?= <afaerber@suse.de>,
 Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>, Cornelia Huck
 <cohuck@redhat.com>, Farhan Ali <alifm@linux.ibm.com>, Eric Farman
 <farman@linux.ibm.com>, Halil Pasic <pasic@linux.ibm.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Harry Wei <harryxiyou@gmail.com>, Alex Shi
 <alex.shi@linux.alibaba.com>, Jerry Hoemann <jerry.hoemann@hpe.com>, Wim
 Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck <linux@roeck-us.net>,
 Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King
 <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, "James E.J. Bottomley"
 <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Guan Xuetao <gxt@pku.edu.cn>, Jens Axboe <axboe@kernel.dk>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Matt Mackall
 <mpm@selenic.com>, Herbert Xu <herbert@gondor.apana.org.au>, Corey Minyard
 <minyard@acm.org>, Sumit Semwal <sumit.semwal@linaro.org>, Linus Walleij
 <linus.walleij@linaro.org>, Bartosz Golaszewski
 <bgolaszewski@baylibre.com>, Darren Hart <dvhart@infradead.org>, Andy
 Shevchenko <andy@infradead.org>, Stuart Hayes <stuart.w.hayes@gmail.com>,
 Jaroslav Kysela <perex@perex.cz>, Alex Williamson
 <alex.williamson@redhat.com>, Kirti Wankhede <kwankhede@nvidia.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Steffen
 Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>,
 Emese Revfy <re.emese@gmail.com>, James Morris <jmorris@namei.org>, "Serge
 E. Hallyn" <serge@hallyn.com>, linux-wireless@vger.kernel.org,
 linux-pci@vger.kernel.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org,
 tboot-devel@lists.sourceforge.net, linux-arch@vger.kernel.org,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-s390@vger.kernel.org, kvm@vger.kernel.org,
 linux-watchdog@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-block@vger.kernel.org,
 linux-crypto@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
 linaro-mm-sig@lists.linaro.org, linux-gpio@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mm@kvack.org, kernel-hardening@lists.openwall.com,
 linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 56/79] docs: Documentation/*.txt: rename all ReST
 files to *.rst
Message-ID: <20190423143438.6a7ce0f2@lwn.net>
In-Reply-To: <20190423171944.7ac6db54@coco.lan>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
	<cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
	<20190423083135.GA11158@hirez.programming.kicks-ass.net>
	<20190423125519.GA7104@redhat.com>
	<20190423130132.GT4038@hirez.programming.kicks-ass.net>
	<20190423103053.07cf2149@lwn.net>
	<20190423171158.GG12232@hirez.programming.kicks-ass.net>
	<20190423115349.589c3d50@lwn.net>
	<20190423171944.7ac6db54@coco.lan>
Organization: LWN.net
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2019 17:19:44 -0300
Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:

> Anyway, one of the things that occurred to me is that maybe
> some scripting work or a ReST extension could do something to parse
> "Documentation/foo" as :doc:`Documentation/foo` without needing to 
> explicitly use any ReST specific tags.

That probably makes sense too.  People do want to link to specific
subsections within documents, though; maybe we could allow
"Documentation/foo#bar" for that.  Such "markup" could even be useful for
people reading the plain-text files.

Thanks,

jon

