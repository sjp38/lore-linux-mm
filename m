Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4216B0253
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:29:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k1so16632735pgq.2
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:29:34 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id g64si5217247pgc.762.2017.12.21.16.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 16:29:33 -0800 (PST)
Message-ID: <1513902570.3132.22.camel@HansenPartnership.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 21 Dec 2017 16:29:30 -0800
In-Reply-To: <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
	 <20171221130057.GA26743@wolff.to>
	 <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
	 <20171221151843.GA453@wolff.to>
	 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
	 <20171221153631.GA2300@wolff.to>
	 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
	 <20171221164221.GA23680@wolff.to>
	 <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Bruno Wolff III <bruno@wolff.to>, weiping zhang <zwp10758@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On Thu, 2017-12-21 at 10:02 -0700, Jens Axboe wrote:
> On 12/21/17 9:42 AM, Bruno Wolff III wrote:
> > 
> > On Thu, Dec 21, 2017 at 23:48:19 +0800,
> > A  weiping zhang <zwp10758@gmail.com> wrote:
> > > 
> > > > 
> > > > output you want. I never saw it for any kernels I compiled
> > > > myself. Only when I test kernels built by Fedora do I see it.
> > > > see it every boot ?
> > 
> > I don't look every boot. The warning gets scrolled of the screen.
> > Once I see the CPU hang warnings I know the boot is failing. I
> > don't always look at journalctl later to see what's there.
> 
> I'm going to revert a0747a859ef6 for now, since we're now 8 days into
> this and no progress has been made on fixing it.

I think this is correct. A If you build the kernel with
CONFIG_DEBUG_FS=N, you're definitely going to get the same hang
(because the debugfs_ functions fail with -ENODEV and the bdi will
never get registered). A This alone leads me to suspect the commit is
bogus because it's a randconfig/test accident waiting to happen.

We should still root cause the debugfs failure in this case, but I
really think debugfs files should be treated as optional, so a failure
in setting them up should translate to some sort of warning not a
failure to set up the bdi.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
