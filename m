Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37EF3C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D17C2208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:26:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jUOdYjXb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D17C2208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 699FF6B0003; Wed, 19 Jun 2019 06:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 622F98E0002; Wed, 19 Jun 2019 06:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49D5C8E0001; Wed, 19 Jun 2019 06:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E86756B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:26:50 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id d15so1139564wrx.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 03:26:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YFOuuDPHS3QNn8VKFuojZaSfGLUUo0b1zU6yyzH4L70=;
        b=p2btEJ3XVSgUCoIKErxySap01uk4t+YTOMUd2Z/QzqI+6Q1KxeMimY2Rg6iNXcc2nv
         V4sWJxNC3HKc0/OQcLhu4YUYdbeRZN0OOKRHgy3+X2O3gczklskE+KR59K57KqFbiQHH
         UiYSQ9VZF9Oe5qwqJLhMSOYjvmGhZQ0l/+uubAZ8dM5b1RY3fLiyx3od4jmfYgXTJQe5
         1omAWqFKaxYZaqulUY56Csxf0Ed1EZ/oakYjN+1VEqSD9IzENG7ZWEq0VfD09uthNJdF
         8vTJfXRCZhOWQyYgVKV56QyPy+Vqi6fxc70VmJ8iQ8DO/bGzXdyhZFZnn4ECnr2vLctQ
         lY5w==
X-Gm-Message-State: APjAAAWHGdAYdkn1yVBjEKz+yoZLj7D3igl9vfh70rRNbuKxq0nGbklD
	135o4KbX6uqGGocp1RkEL2GYYkL6ChO083iBfUvWSRNR2X4c864Y6aPpK6blP+v2qCigA80vXJR
	yxq3XdRGdKLDdIe+OzEuFAO14/U0dzI1ZL3KFMv2BY/E/wglWLlPubSPNiQazqOI=
X-Received: by 2002:a5d:56c1:: with SMTP id m1mr2429228wrw.26.1560940010514;
        Wed, 19 Jun 2019 03:26:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwVM9qMFO7RgFL2mNZQTXsAdoN+4WXAVQDjEhfSd10Qu4fukik4XFwqlEzGjsOE+bduc2a
X-Received: by 2002:a5d:56c1:: with SMTP id m1mr2429166wrw.26.1560940009599;
        Wed, 19 Jun 2019 03:26:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560940009; cv=none;
        d=google.com; s=arc-20160816;
        b=QNWiA1+oIBRxEHsBcyET4UTsq5Kx/WCrHhBWqJoDjkVXWBKSMqE+vvicEvzAEr8UQ0
         AjRa3Gw6255pmPAD2KfUT7KtcKHE/J9LxeLIT637Kn+YDpQAC8M6Cw1lE4tg77VWbjpb
         4/PFg161ErX8zTZ/qj+NCwHi7s1taajXfpPQu17nAbzJFN1aqCMSGDw78RCVf+rVVY9/
         V/jYu2XFR0eJsOgas1iMcFQLoH0tOuoUjFDavSPjendsSvFEXprzhI1vIHWKsnFZ8c94
         1KI1JqNuBgh/nQBDPoOQiKk1wO65yYvtSdOE1or031NhSXZmAAVkhcH2WW9pAlAWPkGm
         ZwNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YFOuuDPHS3QNn8VKFuojZaSfGLUUo0b1zU6yyzH4L70=;
        b=bYa8tOsD8eHliLVyUihuLahu/01CnPw2TkybOOwi7L9clVmaGrrq1Zn/ZZjtEXv1M2
         VnePP0+2a6XATdVaM3lsBd6zMxndpGIaG8KE5rO6DcAZ/5AcZgh6F5kRZvU1bRvK7/Cg
         aD+Xu47HHSyudKwWE/DTlQlD9+OPxY39W2vOGVK2qjpWS+OcmgOpJaeuQx7aKmkJr7XT
         +4pA2NNXMRKr3tyNKPhUzazACfGtabQJmKISllor6loIUIEZdhKGoaGzt1zqjlJQSiYE
         pmutaoIu+Ers3A+7kbsvOMX5QWkn2U0X+mSpikswnyoLpmQmFuIysJjdw6MJ6Q7iX5Aa
         qLTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=casper.20170209 header.b=jUOdYjXb;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 85.118.1.10 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from casper.infradead.org (casper.infradead.org. [85.118.1.10])
        by mx.google.com with ESMTPS id j21si843629wmh.157.2019.06.19.03.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 03:26:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 85.118.1.10 as permitted sender) client-ip=85.118.1.10;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=casper.20170209 header.b=jUOdYjXb;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 85.118.1.10 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:References:In-Reply-To:Message-ID:Subject:Cc:To:From:Date:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YFOuuDPHS3QNn8VKFuojZaSfGLUUo0b1zU6yyzH4L70=; b=jUOdYjXbPDpIqxwy+em4PxKM0J
	xkdPx5H7WoOJmCChJicEuS8Dw2vGo7mwneAjeyi/LT8ATPVb5S+ALOXm5/Rzu/m/bwxiNabowOpId
	KTNbE0GjSU9RtfDT+1PQcqgQun5phOiqhIxET9CZjXTzuGBuEwZDsnS3H6c2LYMh2oOiNmhFWz4QI
	5LpiOvcGTG0XtZtaCQLIVUZgfoYZriCL5J7XK54Z/NAaIsvntp4qlD7U9stNDGJMYfNjWdO4E24E6
	pE61p2yrvQvZslNH6L8H9NPDI9f0qIvVnf5BvnYePk9zRpaO9pe2QH39CgKVXQtIf0orgbPicFQeU
	WxI16YxA==;
Received: from 177.133.86.196.dynamic.adsl.gvt.net.br ([177.133.86.196] helo=coco.lan)
	by casper.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdXjq-0002py-Ny; Wed, 19 Jun 2019 10:22:47 +0000
Date: Wed, 19 Jun 2019 07:22:18 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, Mauro Carvalho
 Chehab <mchehab@infradead.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Johannes
 Berg <johannes@sipsolutions.net>, Kurt Schwemmer
 <kurt.schwemmer@microsemi.com>, Logan Gunthorpe <logang@deltatee.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Alan Stern
 <stern@rowland.harvard.edu>, Andrea Parri
 <andrea.parri@amarulasolutions.com>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>,
 Nicholas Piggin <npiggin@gmail.com>, David Howells <dhowells@redhat.com>,
 Jade Alglave <j.alglave@ucl.ac.uk>, Luc Maranget <luc.maranget@inria.fr>,
 "Paul E. McKenney" <paulmck@linux.ibm.com>, Akira Yokosawa
 <akiyks@gmail.com>, Daniel Lustig <dlustig@nvidia.com>, Stuart Hayes
 <stuart.w.hayes@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Darren Hart <dvhart@infradead.org>, Kees Cook
 <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>, Ohad Ben-Cohen
 <ohad@wizery.com>, Bjorn Andersson <bjorn.andersson@linaro.org>, Corey
 Minyard <minyard@acm.org>, Marc Zyngier <marc.zyngier@arm.com>, William
 Breathitt Gray <vilhelm.gray@gmail.com>, Jaroslav Kysela <perex@perex.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>, Anil S
 Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller"
 <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Johannes
 Thumshirn <morbidrsa@gmail.com>, Steffen Klassert
 <steffen.klassert@secunet.com>, Sudip Mukherjee
 <sudipm.mukherjee@gmail.com>, Andreas =?UTF-8?B?RsOkcmJlcg==?=
 <afaerber@suse.de>, Manivannan Sadhasivam
 <manivannan.sadhasivam@linaro.org>, Rodolfo Giometti
 <giometti@enneenne.com>, Richard Cochran <richardcochran@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, Sumit Semwal
 <sumit.semwal@linaro.org>, Gustavo Padovan <gustavo@padovan.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Kirti Wankhede
 <kwankhede@nvidia.com>, Alex Williamson <alex.williamson@redhat.com>,
 Cornelia Huck <cohuck@redhat.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, Maarten
 Lankhorst <maarten.lankhorst@linux.intel.com>, Maxime Ripard
 <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, Farhan Ali
 <alifm@linux.ibm.com>, Eric Farman <farman@linux.ibm.com>, Halil Pasic
 <pasic@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily
 Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Harry Wei <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>,
 Evgeniy Polyakov <zbr@ioremap.net>, Jerry Hoemann <jerry.hoemann@hpe.com>,
 Wim Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck
 <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>, Arnd Bergmann
 <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Bartosz
 Golaszewski <bgolaszewski@baylibre.com>, Andy Shevchenko
 <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
 linux-wireless@vger.kernel.org, Linux PCI <linux-pci@vger.kernel.org>,
 "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>,
 platform-driver-x86@vger.kernel.org, Kernel Hardening
 <kernel-hardening@lists.openwall.com>, linux-remoteproc@vger.kernel.org,
 openipmi-developer@lists.sourceforge.net, linux-crypto@vger.kernel.org,
 Linux ARM <linux-arm-kernel@lists.infradead.org>, netdev
 <netdev@vger.kernel.org>, linux-pwm <linux-pwm@vger.kernel.org>, dri-devel
 <dri-devel@lists.freedesktop.org>, kvm@vger.kernel.org, Linux Fbdev
 development list <linux-fbdev@vger.kernel.org>, linux-s390@vger.kernel.org,
 linux-watchdog@vger.kernel.org, "moderated list:DMA BUFFER SHARING
 FRAMEWORK" <linaro-mm-sig@lists.linaro.org>, linux-gpio
 <linux-gpio@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619072218.4437f891@coco.lan>
In-Reply-To: <CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Daniel,

Em Wed, 19 Jun 2019 11:05:57 +0200
Daniel Vetter <daniel@ffwll.ch> escreveu:

> On Tue, Jun 18, 2019 at 10:55 PM Mauro Carvalho Chehab
> <mchehab+samsung@kernel.org> wrote:
> > diff --git a/Documentation/gpu/drm-mm.rst b/Documentation/gpu/drm-mm.rst
> > index fa30dfcfc3c8..b0f948d8733b 100644
> > --- a/Documentation/gpu/drm-mm.rst
> > +++ b/Documentation/gpu/drm-mm.rst
> > @@ -320,7 +320,7 @@ struct :c:type:`struct file_operations <file_operations>` get_unmapped_area
> >  field with a pointer on :c:func:`drm_gem_cma_get_unmapped_area`.
> >
> >  More detailed information about get_unmapped_area can be found in
> > -Documentation/nommu-mmap.rst
> > +Documentation/driver-api/nommu-mmap.rst  
> 
> Random drive-by comment: Could we convert these into hyperlinks within
> sphinx somehow, without making them less useful as raw file references
> (with vim I can just type 'gf' and it works, emacs probably the same).
> -Daniel

Short answer: I don't know how vim/emacs would recognize Sphinx tags.

There are two ways of doing hyperlinks to local files. The first one is to 
add a label at the other file and use a reference to such label, e. g. at
nommu-mmap.rst, you would add a label like:

	.. _drm_nommu-mmap:

at the beginning of the file.

Then, at drm-mm.rst, you would use :ref:`drm_nommu-mmap` (there are a
few other alternative tags that would work the same way).

The advantage is that you could move/rename documents anytime, without
needing to take care of it.

Perhaps it could be possible a tool like cscope to parse those in
order to provide such automation for Sphinx. I dunno.

-

The other way is to use:

	:doc:`nommu-mmap.rst` (if both files are at the same dir)

The :doc: path is the current directory. So, if a file at, let's say,
Documentation/gpu wants to refer another file at driver-api, it would
need to write it as:

	:doc:`../driver-api/nommu-mmap.rst`

I'm not sure if vim/emacs recognizes this syntax, though.

Perhaps this tag could be used as:

	:doc:`Documentation/driver-api/nommu-mmap.rst <../driver-api/nommu-map.rst`

But that looks too ugly to my taste.

-

On this conversion, I opted to not touch this. We may consider trying
to replace those 


Thanks,
Mauro

