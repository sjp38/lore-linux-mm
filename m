Date: Fri, 16 Dec 2005 11:00:03 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 3. (change build_zonelists)[3/5]
In-Reply-To: <43A1E9B3.7050203@austin.ibm.com>
References: <20051210194021.482A.Y-GOTO@jp.fujitsu.com> <43A1E9B3.7050203@austin.ibm.com>
Message-Id: <20051216095705.09EE.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > @@ -1602,12 +1606,16 @@ static int __init build_zonelists_node(p
> >  static inline int highest_zone(int zone_bits)
> >  {
> >  	int res = ZONE_NORMAL;
> > -	if (zone_bits & (__force int)__GFP_HIGHMEM)
> > -		res = ZONE_HIGHMEM;
> > -	if (zone_bits & (__force int)__GFP_DMA32)
> > -		res = ZONE_DMA32;
> > +
> >  	if (zone_bits & (__force int)__GFP_DMA)
> >  		res = ZONE_DMA;
> > +	if (zone_bits & (__force int)__GFP_DMA32)
> > +		res = ZONE_DMA32;
> > +	if (zone_bits & (__force int)__GFP_HIGHMEM)
> > +		res = ZONE_HIGHMEM;
> > +	if (zone_bits & (__force int)__GFP_EASY_RECLAIM)
> > +		res = ZONE_EASY_RECLAIM;
> > +
> >  	return res;
> >  }
> >  
> 
> These look to come in the wrong order here.  You want ZONE_EASY_RECLAIM to be 
> the highest zone, but this puts HIGHMEM, DMA32, and DMA ahead of it.  It in fact 
> seems to get the order exactly backward.

I think this is correct about it.

If these are used "else if", you are correct.
But, if zone_bits is __GFP_EASY_RECLAIM, then it fall through to
last line.

> 
> > Index: zone_reclaim/include/linux/gfp.h
> > ===================================================================
> > --- zone_reclaim.orig/include/linux/gfp.h	2005-12-06 14:12:43.000000000 +0900
> > +++ zone_reclaim/include/linux/gfp.h	2005-12-06 14:12:44.000000000 +0900
> > @@ -80,7 +80,7 @@ struct vm_area_struct;
> >  
> >  static inline int gfp_zone(gfp_t gfp)
> >  {
> > -	int zone = GFP_ZONEMASK & (__force int) gfp;
> > +	int zone = fls(GFP_ZONEMASK & (__force int) gfp);
> >  	BUG_ON(zone >= GFP_ZONETYPES);
> >  	return zone;
> >  }
> > 
> 
> Does this have endian issues?  I'm not too familiar with it.

I'm also not too familiar with it. But, if there is a difference.
I suppose generic_ffs() and generic_fls() is not generic. :-P

However, Kame-san tells me this patch is still wrong.
__GFP_EASY_RECLAIM is 0x04 on i386, so fls(__GFP_EASY_RECLAIM)
is 3. zone 3 is ZONE_HIGHMEM, not ZONE_EASY_RECLAIM.
This patch should be more considered. Ah.... 

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
