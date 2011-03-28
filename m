Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 31F218D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:56:34 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2SFTJpq015501
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:29:19 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 554DC6E803C
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:56:32 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2SFtVja108128
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:55:39 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2SFtTSJ009665
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:55:30 -0600
Subject: Re: [PATCH] xen/balloon: Memory hotplug support for Xen balloon
 driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110328094757.GJ13826@router-fw-old.local.net-space.pl>
References: <20110328094757.GJ13826@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 28 Mar 2011 08:55:27 -0700
Message-ID: <1301327727.31700.8354.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-03-28 at 11:47 +0200, Daniel Kiper wrote:
> 
> +static enum bp_state reserve_additional_memory(long credit)
> +{
> +       int nid, rc;
> +       u64 start;
> +       unsigned long balloon_hotplug = credit;
> +
> +       start = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
> +       balloon_hotplug = (balloon_hotplug & PAGE_SECTION_MASK) + PAGES_PER_SECTION;
> +       nid = memory_add_physaddr_to_nid(start); 

Is the 'balloon_hotplug' calculation correct?  I _think_ you're trying
to round up to the SECTION_SIZE_PAGES.  But, if 'credit' was already
section-aligned I think you'll unnecessarily round up to the next
SECTION_SIZE_PAGES boundary.  Should it just be:

	balloon_hotplug = ALIGN(balloon_hotplug, PAGES_PER_SECTION);

You might also want to consider some nicer units for those suckers.
'start_paddr' is _much_ easier to grok than 'start', for instance.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
