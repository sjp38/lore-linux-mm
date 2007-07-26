Date: Thu, 26 Jul 2007 15:17:57 +0100
Subject: bind_zonelist() - are we definitely sizing this correctly?
Message-ID: <20070726141756.GB18825@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, Christoph Lameter <clameter@sgi.com>, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I was looking closer at bind_zonelist() and it has the following snippet

        struct zonelist *zl;
        int num, max, nd;
        enum zone_type k;

        max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
        max++;                  /* space for zlcache_ptr (see mmzone.h) */
        zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
        if (!zl)
                return ERR_PTR(-ENOMEM);

That set off alarm bells because we are allocating based on the size of a
zone, not the size of the zonelist.

This is the definition of struct zonelist

struct zonelist {
        struct zonelist_cache *zlcache_ptr;                  // NULL or &zlcache
        struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
#ifdef CONFIG_NUMA
        struct zonelist_cache zlcache;                       // optional ...
#endif
};

Important thing to note here is that zlcache is after *zones and it is
not a pointer. zlcache in turn is defined as

struct zonelist_cache {
        unsigned short z_to_n[MAX_ZONES_PER_ZONELIST];          /* zone->nid */
        DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);      /* zone full? */
        unsigned long last_full_zap;            /* when last zap'd (jiffies) */
};

This is on NUMA only and it's a big structure.

The intention of bind_zonelist() appears to be that we only allocate enough
memory to hold all the zones in the active nodes. This was fine in 2.6.19
but now with zlcache after *zones[], I think we are in danger of allocating
too little memory and any reading of zlcache may be reading randomness when
MPOL_BIND is in use because it will be using the full offset within the
structure whether the memory is allocated or not.

At the risk of sounding stupid, what obvious thing am I missing that makes
this work?

If I'm right and this is broken and we still want to allocate as little memory
as possible, zlcache has to move before zones and the call to kmalloc needs
to take the size of zlcache into account.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
