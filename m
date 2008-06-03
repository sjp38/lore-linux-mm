Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m53HmCpa007536
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 13:48:12 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m53Hm8fg094262
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 11:48:08 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m53Hm554022013
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 11:48:07 -0600
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080603100939.967775671@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
	 <20080603100939.967775671@amd.local0.net>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 10:48:02 -0700
Message-Id: <1212515282.8505.19.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 20:00 +1000, npiggin@suse.de wrote:
> +static __init int setup_hugepagesz(char *opt)
> +{
> +       unsigned long ps = memparse(opt, &opt);
> +       if (ps == PMD_SIZE) {
> +               hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
> +       } else if (ps == PUD_SIZE && cpu_has_gbpages) {
> +               hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> +       } else {
> +               printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
> +                       ps >> 20);
> +               return 0;
> +       }
> +       return 1;
> +}
> +__setup("hugepagesz=", setup_hugepagesz);
> +#endif

Hi Nick,

I was talking to Nish a bit about these bits.  I'm worried that this
setup isn't going to be very user friendly.

First of all, it seems a bit silly to require that users spell out all
of the huge page sizes at boot.  Shouldn't we allow the small sizes to
be runtime-added as well?

This also requires that users know at boot time which page sizes are
supported, and that might not be horribly feasible if you wanted to have
a common setup among a bunch of different machines, or if the supported
sizes can change with things as insignificant as firmware revisions
(they can on ppc).

So, here's what I propose.  At boot, the architecture calls
hugetlb_add_hstate() for every hardware-supported huge page size.  This,
of course, gets enumerated in Nish's  new sysfs interface.

Then, give the boot-time large page reservations either to hugepages= or
a new boot option.  But, instead of doing it in number of hpages, do it
in sizes like hugepages=10G.  Bootmem-alloc that area, and make it
available to the first hugetlbfs users that come along, regardless of
their hpage size.  Do whatever is simplest here when breaking down the
large area.

I *think* this could all be done on top of what you have here.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
