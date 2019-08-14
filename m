Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 751A4C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 485AB214C6
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 485AB214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4BE16B0003; Wed, 14 Aug 2019 14:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFC406B0005; Wed, 14 Aug 2019 14:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B396B6B0007; Wed, 14 Aug 2019 14:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id 93C8E6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:32:39 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 331D552B8
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:32:39 +0000 (UTC)
X-FDA: 75821879238.01.yard71_5151f72a98315
X-HE-Tag: yard71_5151f72a98315
X-Filterd-Recvd-Size: 3018
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:32:38 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 512CEAF5B;
	Wed, 14 Aug 2019 18:32:37 +0000 (UTC)
Date: Wed, 14 Aug 2019 20:32:35 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 4/5] mm/memory_hotplug: Make sure the pfn is aligned
 to the order when onlining
Message-ID: <20190814183235.GJ17933@dhcp22.suse.cz>
References: <20190814154109.3448-1-david@redhat.com>
 <20190814154109.3448-5-david@redhat.com>
 <b47ebf69-77eb-4a77-0fbc-631175aca979@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b47ebf69-77eb-4a77-0fbc-631175aca979@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 14-08-19 18:09:16, David Hildenbrand wrote:
> On 14.08.19 17:41, David Hildenbrand wrote:
> > Commit a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher
> > order") assumed that any PFN we get via memory resources is aligned to
> > to MAX_ORDER - 1, I am not convinced that is always true. Let's play safe,
> > check the alignment and fallback to single pages.
> > 
> > Cc: Arun KS <arunks@codeaurora.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: David Hildenbrand <david@redhat.com>
> > ---
> >  mm/memory_hotplug.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 63b1775f7cf8..f245fb50ba7f 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -646,6 +646,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  	 */
> >  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1ul << order) {
> >  		order = min(MAX_ORDER - 1, get_order(PFN_PHYS(end_pfn - pfn)));
> > +		/* __free_pages_core() wants pfns to be aligned to the order */
> > +		if (unlikely(!IS_ALIGNED(pfn, 1ul << order)))
> > +			order = 0;
> >  		(*online_page_callback)(pfn_to_page(pfn), order);
> >  	}
> >  
> > 
> 
> @Michal, if you insist, we can drop this patch. "break first and fix
> later" is not part of my DNA :)

I do not insist but have already expressed that I am not a fan of this
change. Also I think that "break first" is quite an over statement here.

-- 
Michal Hocko
SUSE Labs

