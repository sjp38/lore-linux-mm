Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 831FB6B02B9
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:24:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v12-v6so641371wmc.1
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:24:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12-v6si648741edk.399.2018.05.15.09.24.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 09:24:24 -0700 (PDT)
Date: Tue, 15 May 2018 16:24:23 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: Are media drivers abusing of GFP_DMA? - was: Re: [LSF/MM TOPIC
 NOTES] x86 ZONE_DMA love
Message-ID: <20180515162422.GG27853@wotan.suse.de>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180505130815.53a26955@vento.lan>
 <3561479.qPIcrWnXEC@avalon>
 <20180507121916.4eb7f5b2@vento.lan>
 <547252fc-dc74-93c6-fc77-be1bfb558787@st.com>
 <20180514073503.3da05fc6@vento.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180514073503.3da05fc6@vento.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Fabien DESSENNE <fabien.dessenne@st.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Jean Christophe TROTIN <jean-christophe.trotin@st.com>, Yasunari Takiguchi <Yasunari.Takiguchi@sony.com>, Sakari Ailus <sakari.ailus@linux.intel.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Mon, May 14, 2018 at 07:35:03AM -0300, Mauro Carvalho Chehab wrote:
> Hi Fabien,
> 
> Em Mon, 14 May 2018 08:00:37 +0000
> Fabien DESSENNE <fabien.dessenne@st.com> escreveu:
> 
> > On 07/05/18 17:19, Mauro Carvalho Chehab wrote:
> > > Em Mon, 07 May 2018 16:26:08 +0300
> > > Laurent Pinchart <laurent.pinchart@ideasonboard.com> escreveu:
> > >  
> > >> Hi Mauro,
> > >>
> > >> On Saturday, 5 May 2018 19:08:15 EEST Mauro Carvalho Chehab wrote:  
> > >>> There was a recent discussion about the use/abuse of GFP_DMA flag when
> > >>> allocating memories at LSF/MM 2018 (see Luis notes enclosed).
> > >>>
> > >>> The idea seems to be to remove it, using CMA instead. Before doing that,
> > >>> better to check if what we have on media is are valid use cases for it, or
> > >>> if it is there just due to some misunderstanding (or because it was
> > >>> copied from some other code).
> > >>>
> > >>> Hans de Goede sent us today a patch stopping abuse at gspca, and I'm
> > >>> also posting today two other patches meant to stop abuse of it on USB
> > >>> drivers. Still, there are 4 platform drivers using it:
> > >>>
> > >>> 	$ git grep -l -E "GFP_DMA\\b" drivers/media/
> > >>> 	drivers/media/platform/omap3isp/ispstat.c
> > >>> 	drivers/media/platform/sti/bdisp/bdisp-hw.c
> > >>> 	drivers/media/platform/sti/hva/hva-mem.c  
> > 
> > Hi Mauro,
> > 
> > The two STI drivers (bdisp-hw.c and hva-mem.c) are only expected to run 
> > on ARM platforms, not on x86.
> > Since this thread deals with x86 & DMA trouble, I am not sure that we 
> > actually have a problem for the sti drivers.
> > 
> > There are some other sti drivers that make use of this GFP_DMA flag 
> > (drivers/gpu/drm/sti/sti_*.c) and it does not seem to be a problem.
> > 
> > Nevertheless I can see that the media sti drivers depend on COMPILE_TEST 
> > (which is not the case for the DRM ones).
> > Would it be an acceptable solution to remove the COMPILE_TEST dependency?
> 
> This has nothing to do with either x86 

Actually it does.

> or COMPILE_TEST. The thing is
> that there's a plan for removing GFP_DMA from the Kernel[1], 

That would not be possible given architectures use GFP_DMA for other
things and there are plenty of legacy x86 drivers which still need to be
around. So the focus from mm folks shifted to letting x86 folks map
GFP_DMA onto the CMA pool. Long term, this is nothing that driver developers
need to care for, but just knowing internally behind the scenes there is some
cleaning up being done in terms of architecture.

> as it was
> originally meant to be used only by old PCs, where the DMA controllers
> used only  on the bottom 16 MB memory address (24 bits).

This is actually the part that is x86 specific.

Each other architecture may use it for some other definition and it seems
some architectures use GFP_DMA all over the place. So the topic really should
be about x86.

> IMHO, it is 
> very unlikely that any ARM SoC have such limitation.

Right, how the flag is used on other architectures varies, so in fact the
focus for cleaning up for now should be an x86 effort. Whether or not
other architectures do something silly with GFP_DMA is beyond the scope
of what was discussed.

  Luis
