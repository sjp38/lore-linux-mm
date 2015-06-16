Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 32AB06B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:12:16 -0400 (EDT)
Received: by laka10 with SMTP id a10so7834699lak.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:12:15 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id d3si933104wjr.121.2015.06.16.03.12.13
        for <linux-mm@kvack.org>;
        Tue, 16 Jun 2015 03:12:14 -0700 (PDT)
Date: Tue, 16 Jun 2015 12:12:12 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150616101211.GA25899@amd>
References: <201506141105.07171@pali>
 <20150615203645.GD83198@vmdeb7>
 <201506152242.30732@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201506152242.30732@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Darren Hart <dvhart@infradead.org>, Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 2015-06-15 22:42:30, Pali Rohar wrote:
> On Monday 15 June 2015 22:36:45 Darren Hart wrote:
> > On Sun, Jun 14, 2015 at 11:05:07AM +0200, Pali Rohar wrote:
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
> > > 	if (!bufferpage) {
> > > 	
> > > 		ret = -ENOMEM;
> > > 		goto fail_buffer;
> > > 	
> > > 	}
> > > 	buffer = page_address(bufferpage);
> > > 	
> > > 	ret = dell_setup_rfkill();
> > > 	
> > > 	if (ret) {
> > > 	
> > > 		pr_warn("Unable to setup rfkill\n");
> > > 		goto fail_rfkill;
> > > 	
> > > 	}
> > > 
> > > ...
> > > 
> > > fail_rfkill:
> > > 	free_page((unsigned long)bufferpage);
> > > 
> > > fail_buffer:
> > > ...
> > > }
> > > 
> > > Then there is another part:
> > > 
> > > static void __exit dell_exit(void)
> > > {
> > > ...
> > > 
> > > 	free_page((unsigned long)buffer);
> > 
> > I believe you are correct, and this should be bufferpage. Have you
> > observed any failures?
> 
> Rmmoding dell-laptop.ko works fine. There is no error in dmesg. I think 
> that buffer (and not bufferpage) should be passed to free_page(). So in 
> my opinion problem is at fail_rfkill: label and not in dell_exit().

You seem to be right. Interface is strange...

alloc_pages() returns struct page *,
__free_pages() takes struct page *,
free_pages() takes unsinged long.

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
