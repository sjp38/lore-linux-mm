Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16476C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:06:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C04962080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:06:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="gnP9HHMG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C04962080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ADF86B0003; Wed, 19 Jun 2019 05:06:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65EC28E0002; Wed, 19 Jun 2019 05:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54D868E0001; Wed, 19 Jun 2019 05:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7376B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:06:11 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id 189so5509334oii.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=u3kWunp1yg8qsBlz075d3zHcl3e5zCJuL+usdOTYmOc=;
        b=pbd4ZL6+k/o511wDzRbX90yeXWuwNXho1pIvGM9UWRlliDzFLbywV0YPo/lEkQRvKc
         vI7dnfeyQThDcA6NVJMBhqZsh88tZGNc5/f/nk9uSSLabT3QTfaskpbKXtwixStKkJfa
         PpwH4ZE86HMkQsaDicb+6mF4OCREgVzfr6ieOJSsYKGlVIBiOygF08gsmpXnwAvlsd7J
         LhOMM1+5PjBiHSxJiJmWmy29Th/IA6vzXyxmpfLGjbk4rVvdF1Rc05Ka9oqiu0Aaep1k
         LNRyVMnpEltEhUfTcMI5Xts+udUuPG7o0A3l2yH7anCPcn6h5pgNkytoocOZUlEaXYIX
         a7Vg==
X-Gm-Message-State: APjAAAWnZJjeRZfHFtAiZLI64+fuoe/ojCfyYdIxUoifUWt6SD6XyEa8
	/IZHeTH/aJ65jDxX1NM/7aZeojd8HbNNwBrtqZ3B9yQ6NjIJZSIoWDmyD5ydo5EqkU+6/jgeEF0
	Ur0Sb/U9gI/nrRPzglECgFiO5ViO543Cinqq/oKjskzbZW2nUonu49x5IwuW9sEyJ3Q==
X-Received: by 2002:aca:1b04:: with SMTP id b4mr2131940oib.157.1560935170747;
        Wed, 19 Jun 2019 02:06:10 -0700 (PDT)
X-Received: by 2002:aca:1b04:: with SMTP id b4mr2131913oib.157.1560935170058;
        Wed, 19 Jun 2019 02:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935170; cv=none;
        d=google.com; s=arc-20160816;
        b=wf+9iWoLIrnerwBpfKVvmSh4UAto9zKHC/HJO1dsATq7FuS/bsXwj3d2x9tUkaooAg
         tkIQ97JEXtjA2EQ/ZDlfpqpruz3Ij8kkyMG5i3Szd3X/1rOqKIfmhgT5p7/7BW0xQC+z
         ykL/RczW19h+Xfp86DRUQvcmUWXLgDoXA9/5rHdkryOPMAbrkQhtX9LX3mPOj8hoEDgI
         AT7c211REs9X+fKNv6nM5tU2BQJOkBnEtUkfr0FP/IJ/nvTAe2QVY+k5d0H/Z5ONdr2M
         +U5SGpz33XeHbJpe6lJSV5sMRPlGOoIzBYahhheBFY1c3FT/ExyiPBK14dLOYdUS5eAV
         ruSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=u3kWunp1yg8qsBlz075d3zHcl3e5zCJuL+usdOTYmOc=;
        b=wX33IqU0Ud41SAWoVuqhT/wUpzU7+IRSX8DMduJEjXp+QSwTqPPjlmXBnGPHF0e9nR
         YBBvJZ7LgXkJX1FNMftlQCLYy3YNv8XT7CiiQb2RpvVAJxp/O6A7MP9X21fCdRLVHl/j
         AIkj7F+UjifG6iPwRtZUPfTWxdEmbl4S7OUDj7rCOaCO0k35QUphufS6ReS9olQvIXNM
         4hTjEryEJ1ZRV1eceHosklzwfL/8JYDylJqlqsXxYmWazM9NBcQB4645Ang8cLv0Uf5m
         W3hkLoiPghSwp2WTfZJXvZBaGXyF2iR/4rSSXYTKMTpy6+eYbhvqmiZsUAVwr3yb4Eh+
         1ebw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=gnP9HHMG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m22sor8668189otl.129.2019.06.19.02.06.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 02:06:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=gnP9HHMG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=u3kWunp1yg8qsBlz075d3zHcl3e5zCJuL+usdOTYmOc=;
        b=gnP9HHMGYKwK9IsnAHwypqrW+QHPyyxL5VsMOQFqOBt9sxJJN5Q28pik6LLPgli2C3
         8U4+LuFuA2pG4azWksKAC4dzSQH2hr74fm1ub0T1PmruwOzmCDKQaqlsvoLqIxDcuIwv
         c4hN54DM8GwFFMGvP3sPTRofnN8sE6FGqYkHE=
X-Google-Smtp-Source: APXvYqzG/v8GSMVQIarAoClCL4IFuEHrrKyRFYYJXnbvihoMS3DzXDAwuocRw/1b+9yFPJR2Hoa9o9P/lmOprXYAeyI=
X-Received: by 2002:a9d:4b95:: with SMTP id k21mr21462009otf.281.1560935169757;
 Wed, 19 Jun 2019 02:06:09 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560890771.git.mchehab+samsung@kernel.org> <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
In-Reply-To: <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Wed, 19 Jun 2019 11:05:57 +0200
Message-ID: <CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main dir
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, 
	Mauro Carvalho Chehab <mchehab@infradead.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Johannes Berg <johannes@sipsolutions.net>, Kurt Schwemmer <kurt.schwemmer@microsemi.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Alan Stern <stern@rowland.harvard.edu>, 
	Andrea Parri <andrea.parri@amarulasolutions.com>, Will Deacon <will.deacon@arm.com>, 
	Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, 
	Nicholas Piggin <npiggin@gmail.com>, David Howells <dhowells@redhat.com>, 
	Jade Alglave <j.alglave@ucl.ac.uk>, Luc Maranget <luc.maranget@inria.fr>, 
	"Paul E. McKenney" <paulmck@linux.ibm.com>, Akira Yokosawa <akiyks@gmail.com>, 
	Daniel Lustig <dlustig@nvidia.com>, Stuart Hayes <stuart.w.hayes@gmail.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Darren Hart <dvhart@infradead.org>, Kees Cook <keescook@chromium.org>, 
	Emese Revfy <re.emese@gmail.com>, Ohad Ben-Cohen <ohad@wizery.com>, 
	Bjorn Andersson <bjorn.andersson@linaro.org>, Corey Minyard <minyard@acm.org>, 
	Marc Zyngier <marc.zyngier@arm.com>, William Breathitt Gray <vilhelm.gray@gmail.com>, 
	Jaroslav Kysela <perex@perex.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>, 
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, 
	Masami Hiramatsu <mhiramat@kernel.org>, Johannes Thumshirn <morbidrsa@gmail.com>, 
	Steffen Klassert <steffen.klassert@secunet.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, 
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>, 
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>, Rodolfo Giometti <giometti@enneenne.com>, 
	Richard Cochran <richardcochran@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, 
	Sumit Semwal <sumit.semwal@linaro.org>, Gustavo Padovan <gustavo@padovan.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Kirti Wankhede <kwankhede@nvidia.com>, 
	Alex Williamson <alex.williamson@redhat.com>, Cornelia Huck <cohuck@redhat.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, 
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
	Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, 
	Farhan Ali <alifm@linux.ibm.com>, Eric Farman <farman@linux.ibm.com>, 
	Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, 
	Harry Wei <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>, 
	Evgeniy Polyakov <zbr@ioremap.net>, Jerry Hoemann <jerry.hoemann@hpe.com>, 
	Wim Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck <linux@roeck-us.net>, 
	Guan Xuetao <gxt@pku.edu.cn>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, 
	Bartosz Golaszewski <bgolaszewski@baylibre.com>, Andy Shevchenko <andy@infradead.org>, 
	Jiri Slaby <jslaby@suse.com>, linux-wireless@vger.kernel.org, 
	Linux PCI <linux-pci@vger.kernel.org>, 
	"open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, platform-driver-x86@vger.kernel.org, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-remoteproc@vger.kernel.org, 
	openipmi-developer@lists.sourceforge.net, linux-crypto@vger.kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, netdev <netdev@vger.kernel.org>, 
	linux-pwm <linux-pwm@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, 
	kvm@vger.kernel.org, 
	Linux Fbdev development list <linux-fbdev@vger.kernel.org>, linux-s390@vger.kernel.org, 
	linux-watchdog@vger.kernel.org, 
	"moderated list:DMA BUFFER SHARING FRAMEWORK" <linaro-mm-sig@lists.linaro.org>, linux-gpio <linux-gpio@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:55 PM Mauro Carvalho Chehab
<mchehab+samsung@kernel.org> wrote:
> diff --git a/Documentation/gpu/drm-mm.rst b/Documentation/gpu/drm-mm.rst
> index fa30dfcfc3c8..b0f948d8733b 100644
> --- a/Documentation/gpu/drm-mm.rst
> +++ b/Documentation/gpu/drm-mm.rst
> @@ -320,7 +320,7 @@ struct :c:type:`struct file_operations <file_operations>` get_unmapped_area
>  field with a pointer on :c:func:`drm_gem_cma_get_unmapped_area`.
>
>  More detailed information about get_unmapped_area can be found in
> -Documentation/nommu-mmap.rst
> +Documentation/driver-api/nommu-mmap.rst

Random drive-by comment: Could we convert these into hyperlinks within
sphinx somehow, without making them less useful as raw file references
(with vim I can just type 'gf' and it works, emacs probably the same).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

