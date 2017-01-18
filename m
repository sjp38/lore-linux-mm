Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 664DB6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:53:19 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so1995294wmv.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:53:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v26si5811813wrv.93.2017.01.18.01.53.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:53:18 -0800 (PST)
Date: Wed, 18 Jan 2017 10:53:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/4] mm, page_alloc: fix check for NULL preferred_zone
Message-ID: <20170118095317.GL7015@dhcp22.suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-2-vbabka@suse.cz>
 <20170118093131.GH7015@dhcp22.suse.cz>
 <cb06ee3c-6bf6-9755-870e-d6ddba7ef827@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb06ee3c-6bf6-9755-870e-d6ddba7ef827@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 18-01-17 10:45:33, Vlastimil Babka wrote:
> On 01/18/2017 10:31 AM, Michal Hocko wrote:
> > On Tue 17-01-17 23:16:07, Vlastimil Babka wrote:
> > > Since commit c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in
> > > a zonelist twice") we have a wrong check for NULL preferred_zone, which can
> > > theoretically happen due to concurrent cpuset modification. We check the
> > > zoneref pointer which is never NULL and we should check the zone pointer.
> > > 
> > > Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
> > > Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > > ---
> > >  mm/page_alloc.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 34ada718ef47..593a11d8bc6b 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3763,7 +3763,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> > >  	 */
> > >  	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
> > >  					ac.high_zoneidx, ac.nodemask);
> > > -	if (!ac.preferred_zoneref) {
> > > +	if (!ac.preferred_zoneref->zone) {
> > 
> > When can the ->zone be NULL?
> 
> Either we get a genuinely screwed nodemask, or there's a concurrent cpuset
> update and nodes in zonelist are ordered in such a way that we see all of
> them as not being available to us in the nodemask/current->mems_alowed, when
> we iterate the zonelist, so we reach the end of zonelist. The zonelists are
> terminated with a zoneref with NULL zone pointer.

Thanks for the clarification.  Please add a big fat comment in
first_zones_zonelist about this potential case.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
