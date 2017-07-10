Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED7C6B0491
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:28:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u110so22382381wrb.14
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:28:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 27si7889973wry.54.2017.07.10.01.28.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 01:28:09 -0700 (PDT)
Date: Mon, 10 Jul 2017 10:28:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Message-ID: <20170710082805.GD19185@dhcp22.suse.cz>
References: <20170703211415.11283-1-jglisse@redhat.com>
 <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz>
 <20170705143528.GB3305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170705143528.GB3305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Wed 05-07-17 10:35:29, Jerome Glisse wrote:
> On Tue, Jul 04, 2017 at 02:51:13PM +0200, Michal Hocko wrote:
> > On Mon 03-07-17 17:14:14, Jerome Glisse wrote:
> > > HMM pages (private or public device pages) are ZONE_DEVICE page and
> > > thus you can not use page->lru fields of those pages. This patch
> > > re-arrange the uncharge to allow single page to be uncharge without
> > > modifying the lru field of the struct page.
> > > 
> > > There is no change to memcontrol logic, it is the same as it was
> > > before this patch.
> > 
> > What is the memcg semantic of the memory? Why is it even charged? AFAIR
> > this is not a reclaimable memory. If yes how are we going to deal with
> > memory limits? What should happen if go OOM? Does killing an process
> > actually help to release that memory? Isn't it pinned by a device?
> > 
> > For the patch itself. It is quite ugly but I haven't spotted anything
> > obviously wrong with it. It is the memcg semantic with this class of
> > memory which makes me worried.
> 
> So i am facing 3 choices. First one not account device memory at all.
> Second one is account device memory like any other memory inside a
> process. Third one is account device memory as something entirely new.
> 
> I pick the second one for two reasons. First because when migrating
> back from device memory it means that migration can not fail because
> of memory cgroup limit, this simplify an already complex migration
> code. Second because i assume that device memory usage is a transient
> state ie once device is done with its computation the most likely
> outcome is memory is migrated back. From this assumption it means
> that you do not want to allow a process to overuse regular memory
> while it is using un-accounted device memory. It sounds safer to
> account device memory and to keep the process within its memcg
> boundary.
> 
> Admittedly here i am making an assumption and i can be wrong. Thing
> is we do not have enough real data of how this will be use and how
> much of an impact device memory will have. That is why for now i
> would rather restrict myself to either not account it or account it
> as usual.
> 
> If you prefer not accounting it until we have more experience on how
> it is use and how it impacts memory resource management i am fine with
> that too. It will make the migration code slightly more complex.

I can see why you want to do this but the semantic _has_ to be clear.
And as such make sure that the exiting task will simply unpin and
invalidate all the device memory (assuming this memory is not shared
which I am not sure is even possible).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
