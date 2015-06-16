Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2E16B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:15:28 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so4818893lbb.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:15:27 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id bu10si247351wjc.55.2015.06.16.00.15.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 00:15:26 -0700 (PDT)
Received: by wigg3 with SMTP id g3so99575784wig.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:15:25 -0700 (PDT)
Date: Tue, 16 Jun 2015 09:15:23 +0200
From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150616071523.GB5863@pali>
References: <201506141105.07171@pali>
 <20150615211816.GC16138@dhcp22.suse.cz>
 <201506152327.59907@pali>
 <20150616063346.GA24296@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150616063346.GA24296@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Darren Hart <dvhart@infradead.org>
Cc: Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tuesday 16 June 2015 08:33:46 Michal Hocko wrote:
> On Mon 15-06-15 23:27:59, Pali RohA!r wrote:
> > On Monday 15 June 2015 23:18:16 Michal Hocko wrote:
> > > On Sun 14-06-15 11:05:07, Pali RohA!r wrote:
> > > > Hello,
> > > > 
> > > > in drivers/platform/x86/dell-laptop.c is this part of code:
> > > > 
> > > > static int __init dell_init(void)
> > > > {
> > > > ...
> > > > 
> > > > 	/*
> > > > 	
> > > > 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical
> > > > 	 addr * is passed to SMI handler.
> > > > 	 */
> > > > 	
> > > > 	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
> > > 
> > > [...]
> > > 
> > > > 	buffer = page_address(bufferpage);
> > > 
> > > [...]
> > > 
> > > > fail_rfkill:
> > > > 	free_page((unsigned long)bufferpage);
> > > 
> > > This one should be __free_page because it consumes struct page* and
> > > it is the proper counter part for alloc_page. free_page, just to
> > > make it confusing, consumes an address which has to be translated to
> > > a struct page.
> > > 
> > > I have no idea why the API has been done this way and yeah, it is
> > > really confusing.
> > > 
> > > [...]
> > > 
> > > > static void __exit dell_exit(void)
> > > > {
> > > > ...
> > > > 
> > > > 	free_page((unsigned long)buffer);
> > 
> > So both, either:
> > 
> >  free_page((unsigned long)buffer);
> > 
> > or
> > 
> >  __free_page(bufferpage);
> > 
> > is correct?
> 
> Yes. Although I would use __free_page variant as both seem to be
> globally visible.
> 

Michal, thank you for explaining this situation!

Darren, I will prepare patch which will fix code and use __free_page().

(Btw, execution on fail_rfkill label caused kernel panic)

-- 
Pali RohA!r
pali.rohar@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
