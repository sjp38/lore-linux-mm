Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EB75E6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:30:13 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4RF2owx000578
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:02:50 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RFU6Jb116340
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:30:06 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RFU60m015431
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:30:06 -0400
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 27 May 2011 08:30:03 -0700
Message-ID: <1306510203.22505.69.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Fri, 2011-05-27 at 18:01 +0530, Ankita Garg wrote:
> +typedef struct mem_region_list_data {
> +       struct zone zones[MAX_NR_ZONES];
> +       int nr_zones;
> +
> +       int node;
> +       int region;
> +
> +       unsigned long start_pfn;
> +       unsigned long spanned_pages;
> +} mem_region_t;
> +
> +#define MAX_NR_REGIONS    16 

Don't do the foo_t thing.  It's out of style and the pg_data_t is a
dinosaur.

I'm a bit surprised how little discussion of this there is in the patch
descriptions.  Why did you choose this structure?  What are the
downsides of doing it this way?  This effectively breaks up the zone's
LRU in to MAX_NR_REGIONS LRUs.  What effects does that have?

How big _is_ a 'struct zone' these days?  This patch will increase their
effective size by 16x.

Since one distro kernel basically gets run on *EVERYTHING*, what will
MAX_NR_REGIONS be in practice?  How many regions are there on the
largest systems that will need this?  We're going to be doing many
linear searches and iterations over it, so it's pretty darn important to
know.  What does this do to lmbench numbers sensitive to page
allocations?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
