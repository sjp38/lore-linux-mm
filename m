Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 61C4A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 02:33:53 -0400 (EDT)
Received: by wigg3 with SMTP id g3so98711458wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:33:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si22324645wiy.112.2015.06.15.23.33.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 23:33:51 -0700 (PDT)
Date: Tue, 16 Jun 2015 08:33:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150616063346.GA24296@dhcp22.suse.cz>
References: <201506141105.07171@pali>
 <20150615211816.GC16138@dhcp22.suse.cz>
 <201506152327.59907@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201506152327.59907@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Hans de Goede <hdegoede@redhat.com>, Darren Hart <dvhart@infradead.org>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 15-06-15 23:27:59, Pali Rohar wrote:
> On Monday 15 June 2015 23:18:16 Michal Hocko wrote:
> > On Sun 14-06-15 11:05:07, Pali Rohar wrote:
> > > Hello,
> > > 
> > > in drivers/platform/x86/dell-laptop.c is this part of code:
> > > 
> > > static int __init dell_init(void)
> > > {
> > > ...
> > > 
> > > 	/*
> > > 	
> > > 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical
> > > 	 addr * is passed to SMI handler.
> > > 	 */
> > > 	
> > > 	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
> > 
> > [...]
> > 
> > > 	buffer = page_address(bufferpage);
> > 
> > [...]
> > 
> > > fail_rfkill:
> > > 	free_page((unsigned long)bufferpage);
> > 
> > This one should be __free_page because it consumes struct page* and
> > it is the proper counter part for alloc_page. free_page, just to
> > make it confusing, consumes an address which has to be translated to
> > a struct page.
> > 
> > I have no idea why the API has been done this way and yeah, it is
> > really confusing.
> > 
> > [...]
> > 
> > > static void __exit dell_exit(void)
> > > {
> > > ...
> > > 
> > > 	free_page((unsigned long)buffer);
> 
> So both, either:
> 
>  free_page((unsigned long)buffer);
> 
> or
> 
>  __free_page(bufferpage);
> 
> is correct?

Yes. Although I would use __free_page variant as both seem to be
globally visible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
