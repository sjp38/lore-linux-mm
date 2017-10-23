Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6601A6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:03:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e64so16562650pfk.0
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 09:03:20 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y92si1787525plb.23.2017.10.23.09.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 09:03:18 -0700 (PDT)
Date: Mon, 23 Oct 2017 09:03:14 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023160314.GA11853@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
 <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Oct 23, 2017 at 02:52:13PM +0200, Michal Hocko wrote:
> On Fri 20-10-17 16:32:09, Sharath Kumar Bhat wrote:
> > Currently when booted with the 'movable_node' kernel command-line the user
> > can not have both the functionality of 'movable_node' and at the same time
> > specify more movable memory than the total size of hotpluggable memories.
> > 
> > This is a problem because it limits the total amount of movable memory in
> > the system to the total size of hotpluggable memories and in a system the
> > total size of hotpluggable memories can be very small or all hotpluggable
> > memories could have been offlined. The 'movable_node' parameter was aimed
> > to provide the entire memory of hotpluggable NUMA nodes to applications
> > without any kernel allocations in them. The 'movable_node' option will be
> > useful if those hotpluggable nodes have special memory like MCDRAM as in
> > KNL which is a high bandwidth memory and the user would like to use all of
> > it for applications. But in doing so the 'movable_node' command-line poses
> > this limitation and does not allow the user to specify more movable memory
> > in addition to the hotpluggable memories.
> > 
> > With this change the existing 'movablecore=' and 'kernelcore=' command-line
> > parameters can be specified in addition to the 'movable_node' kernel
> > parameter. This allows the user to boot the kernel with an increased amount
> > of movable memory in the system and still have only movable memory in
> > hotpluggable NUMA nodes.
> 
> I really detest making the already cluttered kernelcore* handling even
> more so. Why cannot your MCDRAM simply announce itself as hotplugable?
> Also it is not really clear to me how can you control that only your
> specific memory type gets into movable zone.
> -- 
> Michal Hocko
> SUSE Labs

In the example MCDRAM is already being announced as hotpluggable and
'movable_node' is also used to ensure that there is no kernel allocations
in that. This is a required functionality but when done so user can not have
movable zone in other non-hotpluggable memories in addition to hotpluggable
memory.

This change wont affect any of the present use cases such as 'kernelcore='
or 'movablecore=' or using only 'movable_node'. They continue to work as
before.

In addition to those it lets admin to specify 'kernelcore=' or
'movablecore=' when using 'movable_node' command-line

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
