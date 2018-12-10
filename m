Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 363458E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:17:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so7843535pgr.15
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:17:01 -0800 (PST)
Date: Mon, 10 Dec 2018 18:16:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
Message-ID: <20181210171656.GV1286@dhcp22.suse.cz>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
 <39aa34058fc9641346456463afc2082d@suse.de>
 <20181205191244.GV1286@dhcp22.suse.cz>
 <42699b27-c214-91fd-e7e9-d34e16e9bf9f@suse.cz>
 <20181207103200.GV1286@dhcp22.suse.cz>
 <cd1e398acf86909f12b58bbde1c509ba@suse.de>
 <1946d97a057fe8d5953732350fb2a070@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1946d97a057fe8d5953732350fb2a070@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Mon 10-12-18 14:53:22, osalvador@suse.de wrote:
> On 2018-12-07 11:35, osalvador@suse.de wrote:
> > On 2018-12-07 11:32, Michal Hocko wrote:
> > > On Fri 07-12-18 10:54:50, Vlastimil Babka wrote:
> > > > Well, __pageblock_pfn_to_page() has to be called for each
> > > > pageblock in
> > > > compaction, when zone_contiguous is false. And that's unchanged since
> > > > the introduction of zone_contiguous, so the numbers should still
> > > > hold.
> > > 
> > > OK, this means that we have to carefully re-evaluate zone_contiguous
> > > for
> > > each offline operation.
> 
> I started to think about this but some questions arose.
> 
> Actually, no matter what we do, if we re-evaluate zone_contiguous
> in the offline operation, zone_contiguous will be left unset.
> 
> set_zone_contiguous() calls __pageblock_pfn_to_page() in
> pageblock_nr_pages chunks to determine if the zone is contiguous,
> and checks the following:
> 
> * first/end pfn of the pageblock are valid sections
> * first pfn of the pageblock is online
> * we do not intersect different zones
> * first/end pfn belong to the same zone
> 
> Now, when dropping the shrink code and re-evaluating zone_contiguous in
> offline
> operation, set_zone_contiguous() will return false, leaving us with
> zone_contiguous
> unset.

Yeah. But does anything prevent us to alter the logic that the zone is
not contiguous iff there are offline holes or zones intermixed.
-- 
Michal Hocko
SUSE Labs
