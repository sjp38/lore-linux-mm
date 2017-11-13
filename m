Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 716086B0038
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:39:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i5so12421556pfe.15
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 08:39:13 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v2si4541957plg.615.2017.11.13.08.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 08:39:12 -0800 (PST)
Date: Mon, 13 Nov 2017 16:33:05 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
Message-ID: <20171113163233.GA17016@castle>
References: <20171113160302.14409-1-guro@fb.com>
 <20171113161102.rieyg55drdqkri6e@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171113161102.rieyg55drdqkri6e@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 05:11:02PM +0100, Michal Hocko wrote:
> On Mon 13-11-17 16:03:02, Roman Gushchin wrote:
> > Currently we display some hugepage statistics (total, free, etc)
> > in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).
> > 
> > If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
> > /proc/meminfo output can be confusing, as non-default sized hugepages
> > are not reflected at all, and there are no signs that they are
> > existing and consuming system memory.
> 
> Yes this sucks but we do have per numa node per h-state stats in sysfs
> already /sys/devices/system/node/node*/hugepages
> 
> I know it is another source of the information but is there any reason
> you cannot use it?

Hi, Michal!

In my case, I didn't know in advance, that hugetlb pages are preallocated,
and spent some time trying to find "magically disappeared" several Gb of memory,
which are not reflected in any /proc/[meminfo,vmstat] counters.

IMO, /proc/meminfo should give a user a high-level overview of memory usage
in the system, without a need to look into other places. Of course, we always
have some amount of unaccounted memory, but it shouldn't be measured in Gb,
as in this case.

If you're worried about adding counters which will be 0 most of the time
for most users, we can print them conditionally, only if total number of
corresponding pages is not 0.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
