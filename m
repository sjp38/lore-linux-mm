Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14E7A4405B6
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:20:15 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c4so14931584wrd.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 10:20:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j131si458281wmg.63.2017.02.15.10.20.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 10:20:13 -0800 (PST)
Date: Wed, 15 Feb 2017 18:20:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170215182010.reoahjuei5eaxr5s@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
> 	This four patches define CDM node with HugeTLB & Buddy allocation
> isolation. Please refer to the last RFC posting mentioned here for more

Always include the background with the changelog itself. Do not assume that
people are willing to trawl through a load of past postings to assemble
the picture. I'm only taking a brief look because of the page allocator
impact but it does not appear that previous feedback was addressed.

In itself, the series does very little and as Vlastimil already pointed
out, it's not a good idea to try merge piecemeal when people could not
agree on the big picture (I didn't dig into it).

The only reason I'm commenting at all is to say that I am extremely opposed
to the changes made to the page allocator paths that are specific to
CDM. It's been continual significant effort to keep the cost there down
and this is a mess of special cases for CDM. The changes to hugetlb to
identify "memory that is not really memory" with special casing is also
quite horrible.

It's completely unclear that even if one was to assume that CDM memory
should be expressed as nodes why such systems do not isolate all processes
from CDM nodes by default and then allow access via memory policies or
cpusets instead of special casing the page allocator fast path. It's also
completely unclear what happens if a device should then access the CDM
and how that should be synchronised with the core, if that is even possible.

It's also unclear if this is even usable by an application in userspace
at this point in time. If it is and the special casing is needed then the
regions should be isolated from early mem allocations in the arch layer
that is CDM aware, initialised late, and then setup userspace to isolate
all but privileged applications from the CDM nodes. Do not litter the core
with is_cdm_whatever checks.

At best this is incomplete because it does not look as if it could be used
by anything properly and the fast path alterations are horrible even if
it could be used. As it is, it should not be merged in my opinion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
