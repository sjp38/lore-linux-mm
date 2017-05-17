Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 755426B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:28:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 70so151170wmq.12
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:28:39 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id d33si1794533edd.209.2017.05.17.01.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 01:28:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 8833A1C25E7
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:28:37 +0100 (IST)
Date: Wed, 17 May 2017 09:28:36 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Message-ID: <20170517082836.whe3hggeew23nwvz@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
 <1494973607.21847.50.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1494973607.21847.50.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?iso-8859-15?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, May 17, 2017 at 08:26:47AM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2017-05-16 at 09:43 +0100, Mel Gorman wrote:
> > I'm not sure what you're asking here. migration is only partially
> > transparent but a move_pages call will be necessary to force pages onto
> > CDM if binding policies are not used so the cost of migration will be
> > invisible. Even if you made it "transparent", the migration cost would
> > be incurred at fault time. If anything, using move_pages would be more
> > predictable as you control when the cost is incurred.
> 
> One of the main point of this whole exercise is for applications to not
> have to bother with any of this and now you are bringing all back into
> their lap.
> 
> The base idea behind the counters we have on the link is for the HW to
> know when memory is accessed "remotely", so that the device driver can
> make decision about migrating pages into or away from the device,
> especially so that applications don't have to concern themselves with
> memory placement.
> 

There is only so much magic that can be applied and if the manual case
cannot be handled then the automatic case is problematic. You say that you
want kswapd disabled, but have nothing to handle overcommit sanely. You
want to disable automatic NUMA balancing yet also be able to automatically
detect when data should move from CDM (automatic NUMA balancing by design
couldn't move data to CDM without driver support tracking GPU accesses).

To handle it transparently, either the driver needs to do the work in which
case no special core-kernel support is needed beyond what already exists or
there is a userspace daemon like numad running in userspace that decides
when to trigger migrations on a separate process that is using CDM which
would need to gather information from the driver.

In either case, the existing isolation mechanisms are still sufficient as
long as the driver hot-adds the CDM memory from a userspace trigger that
it then responsible for setting up the isolation.

All that aside, this series has nothing to do with the type of magic
you describe and the feedback as given was "at this point, what you are
looking for does not require special kernel support or heavy wiring into
the core vm".

> Thus we want to reply on the GPU driver moving the pages around where
> most appropriate (where they are being accessed, either core memory or
> GPU memory) based on inputs from the HW counters monitoring the link.
> 

And if the driver is polling all the accesses, there are still no changes
required to the core vm as long as the driver does the hotplug and allows
userspace to isolate if that is what the applications desire.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
