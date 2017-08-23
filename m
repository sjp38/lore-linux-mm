Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3816828073C
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 00:55:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so6065760pfj.10
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 21:55:47 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q7si488837plk.486.2017.08.22.21.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 21:55:42 -0700 (PDT)
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <alpine.DEB.2.20.1708221620060.18344@nuc-kabylake>
 <403c809c-cd37-db66-5f33-3ea6b6bee52d@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6a72ed71-8096-9a61-e783-d750cdcaea01@linux.intel.com>
Date: Tue, 22 Aug 2017 21:55:41 -0700
MIME-Version: 1.0
In-Reply-To: <403c809c-cd37-db66-5f33-3ea6b6bee52d@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>, Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 08/22/2017 06:14 PM, kemi wrote:
> when performance is not important and when you want all tooling to work, you set:
> 
> 	sysctl vm.strict_stats=1
> 
> but if you can tolerate some possible tool breakage and some decreased
> counter precision, you can do:
> 
> 	sysctl vm.strict_stats=0

My other thought was to try to set vm.strict_stats=0 and move to
vm.strict_stats=1 (and issue a printk) when somebody reads
/proc/zoneinfo (or the other files where the expensive stats are displayed).

We'd need three modes for the expensive stats:

	1. Off by default
	2. On.  (#1 transforms to this by default when stats are read)
	3. Off permanently.  An *actual* tunable that someone could set
	   on systems that want to be able to read the stat files, don't
	   care about precision, and want the best performance.

That way, virtually everybody (who falls into mode #1 or #2) gets what
they want.  The only folks who have to mess with a tunable are the
really weird, picky ones who use option #3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
