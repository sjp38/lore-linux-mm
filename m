Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41CFA6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:01:27 -0500 (EST)
Received: by padhx2 with SMTP id hx2so193867334pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:01:27 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id v17si54359660pbs.10.2015.11.16.18.01.25
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 18:01:26 -0800 (PST)
Date: Tue, 17 Nov 2015 09:59:50 +0800
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH 6/7] mm/gfp: make gfp_zonelist return directly and bool
Message-ID: <20151117015950.GA5867@yaowei-K42JY>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-7-git-send-email-baiyaowei@cmss.chinamobile.com>
 <alpine.DEB.2.10.1511160205010.18751@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511160205010.18751@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 16, 2015 at 02:05:46AM -0800, David Rientjes wrote:
> On Mon, 16 Nov 2015, Yaowei Bai wrote:
> 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 6523109..1da03f5 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -375,12 +375,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
> >   * virtual kernel addresses to the allocated page(s).
> >   */
> >  
> > -static inline int gfp_zonelist(gfp_t flags)
> > +static inline bool gfp_zonelist(gfp_t flags)
> >  {
> > -	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
> > -		return 1;
> > -
> > -	return 0;
> > +	return IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE);
> >  }
> >  
> >  /*
> 
> This function is used to index into a pgdat's node_zonelists[] array, bool 
> makes no sense.

Yes, you'r right, but i think hardcoding the index here is not a good idea.
How about this:

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6523109..14a6249 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -378,9 +378,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 static inline int gfp_zonelist(gfp_t flags)
 {
        if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
-               return 1;
+               return ZONELIST_NOFALLBACK;
 
-       return 0;
+       return ZONELIST_FALLBACK;
 }
 
 /*
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..9664d6c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -576,8 +576,6 @@ static inline bool zone_is_empty(struct zone *zone)
 /* Maximum number of zones on a zonelist */
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
-#ifdef CONFIG_NUMA
-
 /*
  * The NUMA zonelists are doubled because we need zonelists that restrict the
  * allocations to a single node for __GFP_THISNODE.
@@ -585,10 +583,13 @@ static inline bool zone_is_empty(struct zone *zone)
  * [0] : Zonelist with fallback
  * [1] : No fallback (__GFP_THISNODE)
  */
-#define MAX_ZONELISTS 2
-#else
-#define MAX_ZONELISTS 1
+enum {
+       ZONELIST_FALLBACK,
+#ifdef CONFIG_NUMA
+       ZONELIST_NOFALLBACK,
 #endif
+       MAX_ZONELISTS
+};
 
 /*
  * This struct contains information about a zone in a zonelist. It is stored


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
