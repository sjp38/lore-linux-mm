Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A66908D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 23:22:45 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p0R4Mgg3006466
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 20:22:43 -0800
Received: from iyj18 (iyj18.prod.google.com [10.241.51.82])
	by wpaz21.hot.corp.google.com with ESMTP id p0R4Me7o003043
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 20:22:41 -0800
Received: by iyj18 with SMTP id 18so1163617iyj.20
        for <linux-mm@kvack.org>; Wed, 26 Jan 2011 20:22:40 -0800 (PST)
Date: Wed, 26 Jan 2011 20:22:28 -0800
From: Mandeep Singh Baines <msb@chromium.org>
Subject: Re: [PATCH 1/6] mm/page_alloc: use appropriate printk priority
 level
Message-ID: <20110127042228.GX8008@google.com>
References: <20110125235700.GR8008@google.com>
 <1296084570-31453-2-git-send-email-msb@chromium.org>
 <4D40BD00.1090408@bluewatersys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D40BD00.1090408@bluewatersys.com>
Sender: owner-linux-mm@kvack.org
To: Ryan Mallon <ryan@bluewatersys.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ryan Mallon (ryan@bluewatersys.com) wrote:
> On 01/27/2011 12:29 PM, Mandeep Singh Baines wrote:
> > printk()s without a priority level default to KERN_WARNING. To reduce
> > noise at KERN_WARNING, this patch set the priority level appriopriately
> > for unleveled printks()s. This should be useful to folks that look at
> > dmesg warnings closely.
> > 
> > Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
> > ---
> 
> > @@ -4700,33 +4700,36 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> >  	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
> >  
> >  	/* Print out the zone ranges */
> > -	printk("Zone PFN ranges:\n");
> > +	printk(KERN_INFO "Zone PFN ranges:\n");
> >  	for (i = 0; i < MAX_NR_ZONES; i++) {
> >  		if (i == ZONE_MOVABLE)
> >  			continue;
> > -		printk("  %-8s ", zone_names[i]);
> > +		printk(KERN_INFO "  %-8s ", zone_names[i]);
> >  		if (arch_zone_lowest_possible_pfn[i] ==
> >  				arch_zone_highest_possible_pfn[i])
> >  			printk("empty\n");
> 
> Should be printk(KERN_CONT ... (or pr_cont).
> 
> >  		else
> > -			printk("%0#10lx -> %0#10lx\n",
> > +			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
> >  				arch_zone_lowest_possible_pfn[i],
> >  				arch_zone_highest_possible_pfn[i]);
> 
> The printk above doesn't have a trailing newline so this should be
> printk(KERN_CONT ...
> 
> There are a couple of other places in this patch series that also need
> to be fixed in a similar manner.
> 

D'oh. Good catch;)

The KERN_INFO here was unintentional. I had intended to leave it out.
The code I was looking at as a reference was just omitting KERN_ for
continuations. But I take it that the convention is to use KERN_CONT.
I'll fixup the patch series to use that.

I tried to use pr_ wherever the file was already using it or where I was
changing all printk()s. For files with many printk()s I just continued
using printk() to keep the patch small and also to avoid mixing printk
with pr_. However, if it is preferrable, I'm happy to replace all printk()s
with pr_ in the files I touch in the series.

> ~Ryan
> 
> -- 
> Bluewater Systems Ltd - ARM Technology Solution Centre
> 
> Ryan Mallon         		5 Amuri Park, 404 Barbadoes St
> ryan@bluewatersys.com         	PO Box 13 889, Christchurch 8013
> http://www.bluewatersys.com	New Zealand
> Phone: +64 3 3779127		Freecall: Australia 1800 148 751
> Fax:   +64 3 3779135			  USA 1800 261 2934

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
