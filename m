Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C8C8F6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:53:02 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 14 Aug 2013 17:53:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DB13938C8027
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:52:56 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7ELqwkm134270
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:52:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7ELqv4a028458
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:52:58 -0400
Date: Wed, 14 Aug 2013 16:52:53 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
Message-ID: <20130814215253.GC17423@variantweb.net>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130814194348.GB10469@kroah.com>
 <520BE30D.3070401@sr71.net>
 <20130814203546.GA6200@kroah.com>
 <CAE9FiQUz6Ev0nbCoSbH7E=+zeJr6GKwR4B-z8+zJTRDPeF=jeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQUz6Ev0nbCoSbH7E=+zeJr6GKwR4B-z8+zJTRDPeF=jeA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Aug 14, 2013 at 02:37:26PM -0700, Yinghai Lu wrote:
> On Wed, Aug 14, 2013 at 1:35 PM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> > On Wed, Aug 14, 2013 at 01:05:33PM -0700, Dave Hansen wrote:
> >> On 08/14/2013 12:43 PM, Greg Kroah-Hartman wrote:
> >> > On Wed, Aug 14, 2013 at 02:31:45PM -0500, Seth Jennings wrote:
> >> >> ppc64 has a normal memory block size of 256M (however sometimes as low
> >> >> as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
> >> >> 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
> >> >> entries per block that's around 80k items that need be created at boot
> >> >> time in sysfs.  Some systems go up to 16TB where the issue is even more
> >> >> severe.
> >> >
> >> > The x86 developers are working with larger memory sizes and they haven't
> >> > seen the problem in this area, for them it's in other places, as I
> >> > referred to in my other email.
> >>
> >> The SGI guys don't run normal distro kernels and don't turn on memory
> >> hotplug, so they don't see this.  I do the same in my testing of
> >> large-memory x86 systems to speed up my boots.  I'll go stick it back in
> >> there and see if I can generate some numbers for a 1TB machine.
> >>
> >> But, the problem on x86 is at _worst_ 1/8 of the problem on ppc64 since
> >> the SECTION_SIZE is so 8x bigger by default.
> >>
> >> Also, the cost of creating sections on ppc is *MUCH* higher than x86
> >> when amortized across the number of pages that you're initializing.  A
> >> section on ppc64 has to be created for each (2^24/2^16)=256 pages while
> >> one on x86 is created for each (2^27/2^12)=32768 pages.
> >>
> >> Thus, x86 folks with our small pages and large sections tend to be
> >> focused on per-page costs.  The ppc folks with their small sections and
> >> larger pages tend to be focused on the per-section costs.
> >
> > Ah, thanks for the explaination, now it makes more sense why they are
> > both optimizing in different places.
> 
> I had one local patch that sent before, it will probe block size for
> generic x86_64.
> set it to 2G looks more reasonable for system with 1T+ ram.

If I am understanding you correctly, you are suggesting we make the block size
a boot time tunable.  It can't be a runtime tunable since the memory blocks are
currently created a boot time.

On ppc64, we can't just just choose a memory block size since it must align
with the underlying LMB (logical memory block) size, set in the hardware ahead
of time.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
