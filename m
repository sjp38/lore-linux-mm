Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD8106B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:43:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so12329020wme.5
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 23:43:20 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id fj9si35490594wjb.13.2016.11.23.23.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 23:43:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 1B0D11C16EB
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 07:43:19 +0000 (GMT)
Date: Thu, 24 Nov 2016 07:43:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH] mm: page_alloc: High-order per-cpu page allocator
Message-ID: <20161124074318.a72wbn6lx5skxuxf@techsingularity.net>
References: <20161121155540.5327-1-mgorman@techsingularity.net>
 <4a9cdec4-b514-e414-de86-fc99681889d8@suse.cz>
 <20161123163351.6s76ijwnqoakgcud@techsingularity.net>
 <a1f8d311-1f69-b672-1dad-9867c212147f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a1f8d311-1f69-b672-1dad-9867c212147f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Nov 24, 2016 at 08:26:39AM +0100, Vlastimil Babka wrote:
> On 11/23/2016 05:33 PM, Mel Gorman wrote:
> > > > +
> > > > +static inline unsigned int pindex_to_order(unsigned int pindex)
> > > > +{
> > > > +	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
> > > > +}
> > > > +
> > > > +static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
> > > > +{
> > > > +	return (order == 0) ? migratetype : MIGRATE_PCPTYPES - 1 + order;
> > > 
> > > Here I think that "MIGRATE_PCPTYPES + order - 1" would be easier to
> > > understand as the array is for all migratetypes, but the order is shifted?
> > > 
> > 
> > As in migratetypes * costly_order ? That would be excessively large.
> 
> No, I just meant that instead of "MIGRATE_PCPTYPES - 1 + order" it could be
> "MIGRATE_PCPTYPES + order - 1" as we are subtracting from order, not
> migratetypes. Just made me confused a bit when seeing the code for the first
> time.
> 

Oh ok. At the time I was thinking in terms of the starting offset for
the high-order and this seemed more natural but I'm ok with it either
way.

As an aside, the sizing of the array was still wrong but I corrected
it yesterday shortly after sending the mail. I also realised that the
free_pcppages_bulk was not interleaving properly and it should be fixed
now. More tests are in progress.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
