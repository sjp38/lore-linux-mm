Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id D5A326B0037
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 19:49:34 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id t60so12832430wes.6
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 16:49:34 -0800 (PST)
Received: from pandora.arm.linux.org.uk (gw-1.arm.linux.org.uk. [78.32.30.217])
        by mx.google.com with ESMTPS id r5si22447274wik.20.2014.01.02.16.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 16:49:34 -0800 (PST)
Date: Fri, 3 Jan 2014 00:47:16 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: ARM: mm: Could I change module space size or place modules in
	vmalloc area?
Message-ID: <20140103004716.GG7383@n2100.arm.linux.org.uk>
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <20140102101359.GU6589@tarshish> <002e01cf081c$44a11e70$cde35b50$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002e01cf081c$44a11e70$cde35b50$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: 'Baruch Siach' <baruch@tkos.co.il>, linux-mm@kvack.org, 'linux-arm-kernel' <linux-arm-kernel@lists.infradead.org>, 'HyoJun Im' <hyojun.im@lge.com>

On Fri, Jan 03, 2014 at 09:39:31AM +0900, Gioh Kim wrote:
> Thank you for reply.
> 
> > -----Original Message-----
> > From: Baruch Siach [mailto:baruch@tkos.co.il]
> > Sent: Thursday, January 02, 2014 7:14 PM
> > To: Gioh Kim
> > Cc: Russell King; linux-mm@kvack.org; linux-arm-kernel; HyoJun Im
> > Subject: Re: ARM: mm: Could I change module space size or place modules in
> > vmalloc area?
> > 
> > Hi Gioh,
> > 
> > On Thu, Jan 02, 2014 at 07:04:13PM +0900, Gioh Kim wrote:
> > > I run out of module space because I have several big driver modules.
> > > I know I can strip the modules to decrease size but I need debug info
> > now.
> > 
> > Are you sure you need the debug info in kernel memory? I don't think the
> > kernel is actually able to parse DWARF. You can load stripped binaries
> > into the kernel, and still use the debug info with whatever tool you have.
> 
> I agree you but driver developers of another team don't agree.
> I don't know why but they say they will strip drivers later :-(
> So I need to increase modules space size.

ARM can only branch relatively within +/- 32MB.  Hence, with a module
space of 16MB, modules can reach up to a maximum 16MB into the direct-
mapped kernel image.  As module space increases in size, so that figure
decreases.  So, if module space were to be 40MB, the maximum size of the
kernel binary would be 8MB.

You want to look at a line similar to this:

      .text : 0xc0008000 - 0xc031eda0   (3164 kB)

Also, note this:

    modules : 0xbf000000 - 0xc0000000   (  16 MB)

If the difference between the lowest module address (0xbf000000) and the
highest of .text is greater than 32MB, it's impossible to load modules -
they will fail to link.

What is the size of your kernel text? (show us the line(s) like the above.)

Thanks.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
