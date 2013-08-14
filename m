Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 306DC6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:05:39 -0400 (EDT)
Message-ID: <520BE30D.3070401@sr71.net>
Date: Wed, 14 Aug 2013 13:05:33 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com> <20130814194348.GB10469@kroah.com>
In-Reply-To: <20130814194348.GB10469@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2013 12:43 PM, Greg Kroah-Hartman wrote:
> On Wed, Aug 14, 2013 at 02:31:45PM -0500, Seth Jennings wrote:
>> ppc64 has a normal memory block size of 256M (however sometimes as low
>> as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
>> 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
>> entries per block that's around 80k items that need be created at boot
>> time in sysfs.  Some systems go up to 16TB where the issue is even more
>> severe.
> 
> The x86 developers are working with larger memory sizes and they haven't
> seen the problem in this area, for them it's in other places, as I
> referred to in my other email.

The SGI guys don't run normal distro kernels and don't turn on memory
hotplug, so they don't see this.  I do the same in my testing of
large-memory x86 systems to speed up my boots.  I'll go stick it back in
there and see if I can generate some numbers for a 1TB machine.

But, the problem on x86 is at _worst_ 1/8 of the problem on ppc64 since
the SECTION_SIZE is so 8x bigger by default.

Also, the cost of creating sections on ppc is *MUCH* higher than x86
when amortized across the number of pages that you're initializing.  A
section on ppc64 has to be created for each (2^24/2^16)=256 pages while
one on x86 is created for each (2^27/2^12)=32768 pages.

Thus, x86 folks with our small pages and large sections tend to be
focused on per-page costs.  The ppc folks with their small sections and
larger pages tend to be focused on the per-section costs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
