Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mA4FNP45000852
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 10:23:25 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA4FM6mO1314820
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 10:22:07 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA4FLrPs005773
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 08:21:54 -0700
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <200811040954.34969.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <200811040808.36464.rjw@sisk.pl> <1225784174.12673.547.camel@nimitz>
	 <200811040954.34969.rjw@sisk.pl>
Content-Type: text/plain
Date: Tue, 04 Nov 2008 07:21:51 -0800
Message-Id: <1225812111.12673.577.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-04 at 09:54 +0100, Rafael J. Wysocki wrote:
> To handle this, I need to know two things:
> 1) what changes of the zones are possible due to memory hotplugging
> (i.e.    can they grow, shring, change boundaries etc.)

All of the above. 

> 2) what kind of locking is needed to prevent zones from changing.

The amount of locking is pretty minimal.  We depend on some locking in
sysfs to keep two attempts to online from stepping on the other.

There is the zone_span_seq*() set of functions.  These are used pretty
sparsely, but we do use them in page_outside_zone_boundaries() to notice
when a zone is resized.

There are also the pgdat_resize*() locks.  Those are more for internal
use guarding the sparsemem structures and so forth.

Could you describe a little more why you need to lock down zone
resizing?  Do you *really* mean zones, or do you mean "the set of memory
on the system"?  Why walk zones instead of pgdats?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
