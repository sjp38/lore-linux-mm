Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9963A6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:43:49 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so28436370pdb.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 20:43:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id hb1si4142523pbd.184.2015.06.16.20.43.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 20:43:47 -0700 (PDT)
Date: Tue, 16 Jun 2015 20:43:34 -0700
From: Darren Hart <dvhart@infradead.org>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150617034334.GB29788@vmdeb7>
References: <201506141105.07171@pali>
 <20150615211816.GC16138@dhcp22.suse.cz>
 <201506152327.59907@pali>
 <20150616063346.GA24296@dhcp22.suse.cz>
 <20150616071523.GB5863@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150616071523.GB5863@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 16, 2015 at 09:15:23AM +0200, Pali Rohar wrote:
> On Tuesday 16 June 2015 08:33:46 Michal Hocko wrote:
> > On Mon 15-06-15 23:27:59, Pali Rohar wrote:
> > > On Monday 15 June 2015 23:18:16 Michal Hocko wrote:
> > > > On Sun 14-06-15 11:05:07, Pali Rohar wrote:
> > > > > Hello,
> > > > > 
> > > > > in drivers/platform/x86/dell-laptop.c is this part of code:
> > > > > 
> > > > > static int __init dell_init(void)
> > > > > {
> > > > > ...
> > > > > 
> > > > > 	/*
> > > > > 	
> > > > > 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical
> > > > > 	 addr * is passed to SMI handler.
> > > > > 	 */
> > > > > 	
> > > > > 	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
> > > > 
> > > > [...]
> > > > 
> > > > > 	buffer = page_address(bufferpage);
> > > > 
> > > > [...]
> > > > 
> > > > > fail_rfkill:
> > > > > 	free_page((unsigned long)bufferpage);
> > > > 
> > > > This one should be __free_page because it consumes struct page* and
> > > > it is the proper counter part for alloc_page. free_page, just to
> > > > make it confusing, consumes an address which has to be translated to
> > > > a struct page.
> > > > 
> > > > I have no idea why the API has been done this way and yeah, it is
> > > > really confusing.
> > > > 
> > > > [...]
> > > > 
> > > > > static void __exit dell_exit(void)
> > > > > {
> > > > > ...
> > > > > 
> > > > > 	free_page((unsigned long)buffer);
> > > 
> > > So both, either:
> > > 
> > >  free_page((unsigned long)buffer);
> > > 
> > > or
> > > 
> > >  __free_page(bufferpage);
> > > 
> > > is correct?
> > 
> > Yes. Although I would use __free_page variant as both seem to be
> > globally visible.
> > 

Michal - thanks for the context.

I'm surprised by your recommendation to use __free_page() out here in platform
driver land.

I'd also prefer that the driver consistently free the same address to avoid
confusion.

For these reasons, free_page((unsigned long)buffer) seems like the better
option.

Can you elaborate on why you feel __free_page() is a better choice?

-- 
Darren Hart
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
