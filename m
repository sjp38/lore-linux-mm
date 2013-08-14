Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AD0426B0034
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:16:15 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 14 Aug 2013 17:16:14 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BAEB5C90043
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:16:09 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7ELGBTU164526
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:16:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7ELGAMP022636
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:16:11 -0400
Date: Wed, 14 Aug 2013 16:16:07 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
Message-ID: <20130814211607.GB17423@variantweb.net>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130814194348.GB10469@kroah.com>
 <520BE30D.3070401@sr71.net>
 <20130814203546.GA6200@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814203546.GA6200@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 14, 2013 at 01:35:46PM -0700, Greg Kroah-Hartman wrote:
> On Wed, Aug 14, 2013 at 01:05:33PM -0700, Dave Hansen wrote:
> > On 08/14/2013 12:43 PM, Greg Kroah-Hartman wrote:
> > > On Wed, Aug 14, 2013 at 02:31:45PM -0500, Seth Jennings wrote:
> > >> ppc64 has a normal memory block size of 256M (however sometimes as low
> > >> as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
> > >> 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
> > >> entries per block that's around 80k items that need be created at boot
> > >> time in sysfs.  Some systems go up to 16TB where the issue is even more
> > >> severe.
> > > 
> > > The x86 developers are working with larger memory sizes and they haven't
> > > seen the problem in this area, for them it's in other places, as I
> > > referred to in my other email.
> > 
> > The SGI guys don't run normal distro kernels and don't turn on memory
> > hotplug, so they don't see this.  I do the same in my testing of
> > large-memory x86 systems to speed up my boots.  I'll go stick it back in
> > there and see if I can generate some numbers for a 1TB machine.
> > 
> > But, the problem on x86 is at _worst_ 1/8 of the problem on ppc64 since
> > the SECTION_SIZE is so 8x bigger by default.
> > 
> > Also, the cost of creating sections on ppc is *MUCH* higher than x86
> > when amortized across the number of pages that you're initializing.  A
> > section on ppc64 has to be created for each (2^24/2^16)=256 pages while
> > one on x86 is created for each (2^27/2^12)=32768 pages.
> > 
> > Thus, x86 folks with our small pages and large sections tend to be
> > focused on per-page costs.  The ppc folks with their small sections and
> > larger pages tend to be focused on the per-section costs.
> 
> Ah, thanks for the explaination, now it makes more sense why they are
> both optimizing in different places.

Yes, thanks Dave for explaining that for me :)

> 
> But a "cleanup" patch first, and then the "change the logic to go
> faster" would be better here, so that we can review what is really
> happening.

Will do.

> 
> thanks,
> 
> greg k-h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
