Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 6 Feb 2013 10:41:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130206104117.GO21389@suse.de>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130204160624.5c20a8a0.akpm@linux-foundation.org>
 <20130205115722.GF21389@suse.de>
 <CANN689GVFYTqs0wxX3bKZtyBcWf6=gLvS8hFG-65htsnPDknSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CANN689GVFYTqs0wxX3bKZtyBcWf6=gLvS8hFG-65htsnPDknSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lin Feng <linfeng@cn.fujitsu.com>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 05, 2013 at 06:26:51PM -0800, Michel Lespinasse wrote:
> Just nitpicking, but:
> 
> On Tue, Feb 5, 2013 at 3:57 AM, Mel Gorman <mgorman@suse.de> wrote:
> > +static inline bool zone_is_idx(struct zone *zone, enum zone_type idx)
> > +{
> > +       /* This mess avoids a potentially expensive pointer subtraction. */
> > +       int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> > +       return zone_off == idx * sizeof(*zone);
> > +}
> 
> Maybe:
> return zone == zone->zone_pgdat->node_zones + idx;
> ?
> 

Not a nit at all. Yours is more readable but it generates more code. A
single line function that uses the helper generates 0x3f bytes of code
(mostly function entry/exit) with your version and 0x39 bytes with mine. The
difference in efficiency is marginal as your version uses lea to multiply
by a constant but it's still slightly heavier.

The old code is fractionally better, your version is more readable so it's
up to Andrew really. Right now I think he's gone with his own version with
zone_idx() in the name of readability whatever sparse has to say about
the matter.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
