Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9916B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:36:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l23so2117397pgc.10
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:36:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d190si3192080pfg.504.2017.10.26.00.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 00:36:53 -0700 (PDT)
Date: Thu, 26 Oct 2017 09:36:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171026073648.wwrdnfv5u3yegv62@dhcp22.suse.cz>
References: <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
 <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
 <20171024010633.GA2723@linux.intel.com>
 <20171024071906.64ikc733x53zmgzu@dhcp22.suse.cz>
 <20171025005314.GA2636@linux.intel.com>
 <20171025063852.nunaquo5wevayejf@dhcp22.suse.cz>
 <20171025220132.GA2614@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025220132.GA2614@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed 25-10-17 15:01:32, Sharath Kumar Bhat wrote:
> On Wed, Oct 25, 2017 at 08:38:52AM +0200, Michal Hocko wrote:
> > On Tue 24-10-17 17:53:14, Sharath Kumar Bhat wrote:
> > > On Tue, Oct 24, 2017 at 09:19:06AM +0200, Michal Hocko wrote:
> > > > On Mon 23-10-17 18:06:33, Sharath Kumar Bhat wrote:
> > [...]
> > > > > And moreover
> > > > > 'movable_node' is implemented with an assumption to provide the entire
> > > > > hotpluggable memory as movable zone. This ACPI override would be against
> > > > > that assumption.
> > > > 
> > > > This is true and in fact movable_node should become movable_memory over
> > > > time and only ranges marked as movable would become really movable. This
> > > > is a rather non-trivial change to do and there is not a great demand for
> > > > the feature so it is low on my TODO list.
> > > 
> > > Do you mean to have a single kernel command-line 'movable_memory=' for this
> > > purpose and remove all other kernel command-line parameters such as
> > > 'kernelcore=', 'movablecore=' and 'movable_node'?
> > 
> > yes.
> 
> Ok then I believe it will let user to specify multiple memory ranges so
> that admin can explicitly choose to have movable zones in either
> hotpluggable or non-hotpluggable memories. Because in this use case the
> requirement is to have the movable zones in both hotpluggable and
> non-hotpluggable memories.

Why? Please be more specific.

[...]

> > I am still confused. Why does the application even care about
> > movability?
> 
> Right its not about movability, since 'movable_node' assumes that the entire
> memory node is hotpluggable, to stay compatible with it the memory ranges of
> non-hotpluggable memory that we want to be movable zone should be exposed as
> a complete node. This increases the number of NUMA nodes and the total
> no.of such nodes changes as the movable memory requirement changes.

And that is the primary reason why this interface is a hack and should
be replaced.

> > > > That being said, I would really prefer to actually _remove_ kernel_core
> > > > parameter altogether. It is messy (just look at find_zone_movable_pfns_for_nodes
> > > > at al.) and the original usecase it has been added for [1] does not hold
> > > > anymore. Adding more stuff to workaround issues which can be handled
> > > > more cleanly is definitely not a right way to go.
> > > 
> > > I agree that kernelcore handling is non-trivial in that function. But the
> > > changes introduced by this patch are under 'movable_node' case handling in
> > > find_zone_movable_pfns_for_nodes() and it does not cause any change to the
> > > existing kernelcore behavior of the code. Also this enables all
> > > multi-kernel users to make use of this functionality untill later when
> > > new interface would be available for the same purpose.
> > 
> > The point is to not build on top and rather get rid of it completely.
> 
> I thought you mentioned its a low priority on the TODO list and you
> dont expect to see it in the near future. So till then there is no
> existing solution that one case use.

Feel free to work on it. But seriously. The whole memory hotplug land is
full of half ass solutions where everybody just cared about a specific
usecase without thinking more about a more generic way to implement the
feature. It's finally time to stop that kind of approach and finaly do
things properly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
