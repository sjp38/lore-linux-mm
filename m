Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52C2B6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:11:44 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d17so1558623wrc.9
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:11:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n56si7802236wrf.297.2018.01.30.02.11.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 02:11:43 -0800 (PST)
Date: Tue, 30 Jan 2018 11:11:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug not increasing the total RAM
Message-ID: <20180130101141.GW21609@dhcp22.suse.cz>
References: <20180130083006.GB1245@in.ibm.com>
 <20180130091600.GA26445@dhcp22.suse.cz>
 <20180130092815.GR21609@dhcp22.suse.cz>
 <20180130095345.GC1245@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130095345.GC1245@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pasha.tatashin@oracle.com, Andrew Morton <akpm@linux-foundation.org>

[Cc Andrew - thread starts here
 http://lkml.kernel.org/r/20180130083006.GB1245@in.ibm.com]

On Tue 30-01-18 15:23:45, Bharata B Rao wrote:
> On Tue, Jan 30, 2018 at 10:28:15AM +0100, Michal Hocko wrote:
> > On Tue 30-01-18 10:16:00, Michal Hocko wrote:
> > > On Tue 30-01-18 14:00:06, Bharata B Rao wrote:
> > > > Hi,
> > > > 
> > > > With the latest upstream, I see that memory hotplug is not working
> > > > as expected. The hotplugged memory isn't seen to increase the total
> > > > RAM pages. This has been observed with both x86 and Power guests.
> > > > 
> > > > 1. Memory hotplug code intially marks pages as PageReserved via
> > > > __add_section().
> > > > 2. Later the struct page gets cleared in __init_single_page().
> > > > 3. Next online_pages_range() increments totalram_pages only when
> > > >    PageReserved is set.
> > > 
> > > You are right. I have completely forgot about this late struct page
> > > initialization during onlining. memory hotplug really doesn't want
> > > zeroying. Let me think about a fix.
> > 
> > Could you test with the following please? Not an act of beauty but
> > we are initializing memmap in sparse_add_one_section for memory
> > hotplug. I hate how this is different from the initialization case
> > but there is quite a long route to unify those two... So a quick
> > fix should be as follows.
> 
> Tested on Power guest, fixes the issue. I can now see the total memory
> size increasing after hotplug.

Thanks for your quick testing. Here we go with the fix.
