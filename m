Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id EB6256B005C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:23:40 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so3062210igb.9
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:23:40 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id f20si47314141icc.101.2014.07.21.10.23.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:23:40 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 11:23:39 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9764119D8040
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:23:25 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHM1xs1049008
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:22:01 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHNYkT006798
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:23:35 -0600
Date: Mon, 21 Jul 2014 10:23:31 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140721172331.GB4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Jiang,

On 11.07.2014 [15:37:17 +0800], Jiang Liu wrote:
> Previously we have posted a patch fix a memory crash issue caused by
> memoryless node on x86 platforms, please refer to
> http://comments.gmane.org/gmane.linux.kernel/1687425
> 
> As suggested by David Rientjes, the most suitable fix for the issue
> should be to use cpu_to_mem() rather than cpu_to_node() in the caller.
> So this is the patchset according to David's suggestion.

Hrm, that is initially what David said, but then later on in the thread,
he specifically says he doesn't think memoryless nodes are the problem.
It seems like the issue is the order of onlining of resources on a
specifix x86 platform?

memoryless nodes in and of themselves don't cause the kernel to crash.
powerpc boots with them (both previously without
CONFIG_HAVE_MEMORYLESS_NODES and now with it) and is functional,
although it does lead to some performance issues I'm hoping to resolve.
In fact, David specifically says that the kernel crash you triggered
makes sense as cpu_to_node() points to an offline node?

In any case, a blind s/cpu_to_node/cpu_to_mem/ is not always correct.
There is a semantic difference and in some cases the allocator already
do the right thing under covers (falls back to nearest node) and in some
cases it doesn't.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
