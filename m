Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEAE38E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 11:39:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x20-v6so1486511eda.22
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:39:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y38-v6si756079ede.152.2018.09.26.08.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 08:39:25 -0700 (PDT)
Date: Wed, 26 Sep 2018 17:39:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
Message-ID: <20180926153921.GC6278@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <20180926073831.GC6278@dhcp22.suse.cz>
 <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 26-09-18 08:24:56, Alexander Duyck wrote:
> On 9/26/2018 12:38 AM, Michal Hocko wrote:
> > On Tue 25-09-18 13:20:12, Alexander Duyck wrote:
> > [...]
> > > +	vm_debug[=options]	[KNL] Available with CONFIG_DEBUG_VM=y.
> > > +			May slow down system boot speed, especially when
> > > +			enabled on systems with a large amount of memory.
> > > +			All options are enabled by default, and this
> > > +			interface is meant to allow for selectively
> > > +			enabling or disabling specific virtual memory
> > > +			debugging features.
> > > +
> > > +			Available options are:
> > > +			  P	Enable page structure init time poisoning
> > > +			  -	Disable all of the above options
> > 
> > I agree with Dave that this is confusing as hell. So what does vm_debug
> > (without any options means). I assume it's NOP and all debugging is
> > enabled and that is the default. What if I want to disable _only_ the
> > page struct poisoning. The weird lookcing `-' will disable all other
> > options that we might gather in the future.
> 
> With no options it works just like slub_debug and enables all available
> options. So in our case it is a NOP since we wanted the debugging enabled by
> default.

But isn't slub_debug more about _adding_ debugging features? While you
want to effectively disbale some debugging features here? So if you want
to follow that pattern then it would be something like
vm_debug_disable=page_poisoning,$OTHER_FUTURE_DEBUG_OPTIONS

why would you want to enable something when CONFIG_DEBUG_VM=y just
enables everything?

> > Why cannot you simply go with [no]vm_page_poison[=on/off]?
> 
> That is what I had to begin with, but Dave Hansen and Dan Williams suggested
> that I go with a slub_debug style interface so we could extend it in the
> future.

Please let's not over-engineer this. If you really need an umbrella
parameter then make a list of things to disable.
-- 
Michal Hocko
SUSE Labs
