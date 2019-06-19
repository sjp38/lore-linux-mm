Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A80B8C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 694452064A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:43:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NNCmFmFT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 694452064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0236F6B0006; Wed, 19 Jun 2019 06:43:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F16528E0002; Wed, 19 Jun 2019 06:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDC938E0001; Wed, 19 Jun 2019 06:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF2206B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:43:08 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w17so20639618iom.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 03:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m16f9ue1VFiC0DkFO5F5uINqAIvhMmZvVgKeJd9wfsY=;
        b=nQmH3MrEU3o/gmDNaPN8t/xg1iYMexQdGkk/tCugHeA+DvdSunJZkqYEHYK+bkYeA6
         /vy+/wvyOwFGBt6zUQsK2jmjKmjmj6pHmkcgANWAHRgA+WlQp3FEMrjVycGLyclq7SC9
         4jZLaqDTcZs8xpsyHNrn1Hu4+rIJv2zV2y1l0+qhOmf4cctneGmLsuVHA2XGojUwfK/J
         zi1nYPHtZWkkdCVKmcGqCKOwzoUEGlXKMlIcjnL0PR1QVqNCi2dqdN09CYcg1C+yWMY3
         +q6IGPyPbVXIwekgh/xPUI0OviDF8KVCphjxLbkP2Eju+ePKRFmPqNUk9kvFUfD+KhkA
         ZSVA==
X-Gm-Message-State: APjAAAW1ocEaXQ4q2AyrVO1F7jRtU7fyqksDUjdKy0L86qhbwNskuAbD
	TJIYrW9ErRPaH1rKPOMlgX+gxSOCtQ9k0gtHUyO2gQr0c012Qn7fPRwK93HmnBb5NM1MHI8VEMq
	xOt3oLOCxfpuuAdV8dqKnSutqDt4H8YEkZzn5Gyd1uDNDwoF3JcfkutGZptCKqiXpdQ==
X-Received: by 2002:a5d:8747:: with SMTP id k7mr10419736iol.20.1560940988524;
        Wed, 19 Jun 2019 03:43:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+rLWf9Cg/dinHT7L73RYrXxVoR4BRkxysQHAF18BP5d3/1vaArK2rpsVtmWSL9uMPPh9J
X-Received: by 2002:a5d:8747:: with SMTP id k7mr10419682iol.20.1560940987681;
        Wed, 19 Jun 2019 03:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560940987; cv=none;
        d=google.com; s=arc-20160816;
        b=RYvQt4ZnGH4Goj0Sg2aR0UmA4l02/vurw4TIoAcUIbzJn04g31jlJnsZP/Jbmcicxt
         nMJycTk96/ElInAq8+JD5syoxg3LHAZ2IFlH9fRXDrUtnsXzZFofcybtRwG1lzboExBl
         dBp46JO+f/mXOYeYtHlq87JpxMPOJJxCSJm240fnX8wNn7qLsHcdxmOSy0Vv84uozuNQ
         FNsMk6NepW1MYNJA22ldE7D0vTr511f/l9Mg4r5BMcxud8xCEtHWTWCeOkNdXJxaiR5c
         Qmd05N7iBmmA3IPX5t5r+UndseZc5eTl9q1sQ1q+dqAxdunffwD0ku3TCHJLlUAzNgCl
         86BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m16f9ue1VFiC0DkFO5F5uINqAIvhMmZvVgKeJd9wfsY=;
        b=gOsqSR7jGm7+FMmZ0W15pZvoT22rKncgHuxvhZknGNVVfz0RM6vSkRxZ3PQZNTN/1V
         jIHf5gl66lFu7gUCly9HEdMVcyK7IRAds1KIR7QjrcO2UCaK5R1zxukcwHcKOZ4U5btK
         cjA9u4fhMQfdoLC9QxDODwo16rBS0HphFLkK41HZDs1/uKLnULOXPCNuzwS7m8n+SMEM
         fvfFz8e6tM44tccwSJLbeHcWz1X+hfHzkOhdfce9AxtwWiQdca+XCczX4AVye77oRbII
         UkuLfbeIRQJ4hOEANf2CuipoLwBKwxxDRMPJVd9u6RkbysL8cElkfrfDEU/P8ux9cRdO
         E7aA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=NNCmFmFT;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id 195si24661073jaa.78.2019.06.19.03.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 03:43:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=NNCmFmFT;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=m16f9ue1VFiC0DkFO5F5uINqAIvhMmZvVgKeJd9wfsY=; b=NNCmFmFTbay0EtIcKhS6MVrGl
	AdplcSD+3WFy0yuGIcmTpCJPXrfb55Lpu2H797MTbB6ew5vKohxoJSQJLtIC/C2gEN00R3UVsIYdk
	odvorgfBGIM5ZpvJM6uL3VI0bU22NQpoEeUUFz+Qq+N4xgBsUVncaZjurZV2iJ+3aQP5JQXidntqu
	+L1KkgDQZHNmUbATT3kjxJVRF+EClVGvxhKRuhAQkfGjP/Y38SLSfoc4EkRuJvyz2Mh8Rgw/5+zcv
	hP5pBkdqtyojMN8no8YOonPn5fOmDREMC15lAYsx4mRCklZKOVfPXs+KTV497tIaRpmhDdfuXR6ce
	ZM4YeuitQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdY38-0006TK-Ru; Wed, 19 Jun 2019 10:42:43 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id AA9C320098E60; Wed, 19 Jun 2019 12:42:39 +0200 (CEST)
Date: Wed, 19 Jun 2019 12:42:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Daniel Vetter <daniel@ffwll.ch>,
	Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
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
	David Airlie <airlied@linux.ie>,
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
	linux-wireless@vger.kernel.org,
	Linux PCI <linux-pci@vger.kernel.org>,
	"open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	linux-remoteproc@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linux-crypto@vger.kernel.org,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>,
	linux-pwm <linux-pwm@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>, kvm@vger.kernel.org,
	Linux Fbdev development list <linux-fbdev@vger.kernel.org>,
	linux-s390@vger.kernel.org, linux-watchdog@vger.kernel.org,
	"moderated list:DMA BUFFER SHARING FRAMEWORK" <linaro-mm-sig@lists.linaro.org>,
	linux-gpio <linux-gpio@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619104239.GM3419@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
 <CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
 <20190619072218.4437f891@coco.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619072218.4437f891@coco.lan>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 07:22:18AM -0300, Mauro Carvalho Chehab wrote:
> Hi Daniel,
> 
> Em Wed, 19 Jun 2019 11:05:57 +0200
> Daniel Vetter <daniel@ffwll.ch> escreveu:
> 
> > On Tue, Jun 18, 2019 at 10:55 PM Mauro Carvalho Chehab
> > <mchehab+samsung@kernel.org> wrote:
> > > diff --git a/Documentation/gpu/drm-mm.rst b/Documentation/gpu/drm-mm.rst
> > > index fa30dfcfc3c8..b0f948d8733b 100644
> > > --- a/Documentation/gpu/drm-mm.rst
> > > +++ b/Documentation/gpu/drm-mm.rst
> > > @@ -320,7 +320,7 @@ struct :c:type:`struct file_operations <file_operations>` get_unmapped_area
> > >  field with a pointer on :c:func:`drm_gem_cma_get_unmapped_area`.
> > >
> > >  More detailed information about get_unmapped_area can be found in
> > > -Documentation/nommu-mmap.rst
> > > +Documentation/driver-api/nommu-mmap.rst  
> > 
> > Random drive-by comment: Could we convert these into hyperlinks within
> > sphinx somehow, without making them less useful as raw file references
> > (with vim I can just type 'gf' and it works, emacs probably the same).
> > -Daniel
> 
> Short answer: I don't know how vim/emacs would recognize Sphinx tags.

No, the other way around, Sphinx can recognize local files and treat
them special. That way we keep the text readable.

Same with that :c:func:'foo' crap, that needs to die, and Sphinx needs
to be taught about foo().

