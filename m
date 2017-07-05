Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3AF76B039F
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 10:35:35 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 134so118508457qkh.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 07:35:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f3si21349940qkh.102.2017.07.05.07.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 07:35:35 -0700 (PDT)
Date: Wed, 5 Jul 2017 10:35:29 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Message-ID: <20170705143528.GB3305@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
 <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170704125113.GC14727@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Tue, Jul 04, 2017 at 02:51:13PM +0200, Michal Hocko wrote:
> On Mon 03-07-17 17:14:14, Jerome Glisse wrote:
> > HMM pages (private or public device pages) are ZONE_DEVICE page and
> > thus you can not use page->lru fields of those pages. This patch
> > re-arrange the uncharge to allow single page to be uncharge without
> > modifying the lru field of the struct page.
> > 
> > There is no change to memcontrol logic, it is the same as it was
> > before this patch.
> 
> What is the memcg semantic of the memory? Why is it even charged? AFAIR
> this is not a reclaimable memory. If yes how are we going to deal with
> memory limits? What should happen if go OOM? Does killing an process
> actually help to release that memory? Isn't it pinned by a device?
> 
> For the patch itself. It is quite ugly but I haven't spotted anything
> obviously wrong with it. It is the memcg semantic with this class of
> memory which makes me worried.

So i am facing 3 choices. First one not account device memory at all.
Second one is account device memory like any other memory inside a
process. Third one is account device memory as something entirely new.

I pick the second one for two reasons. First because when migrating
back from device memory it means that migration can not fail because
of memory cgroup limit, this simplify an already complex migration
code. Second because i assume that device memory usage is a transient
state ie once device is done with its computation the most likely
outcome is memory is migrated back. From this assumption it means
that you do not want to allow a process to overuse regular memory
while it is using un-accounted device memory. It sounds safer to
account device memory and to keep the process within its memcg
boundary.

Admittedly here i am making an assumption and i can be wrong. Thing
is we do not have enough real data of how this will be use and how
much of an impact device memory will have. That is why for now i
would rather restrict myself to either not account it or account it
as usual.

If you prefer not accounting it until we have more experience on how
it is use and how it impacts memory resource management i am fine with
that too. It will make the migration code slightly more complex.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
