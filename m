Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D45F681021
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 21:37:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y6so33934142pgy.5
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 18:37:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t15si8737127pgn.358.2017.02.16.18.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 18:37:47 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: swap_cluster_info lockdep splat
References: <20170216052218.GA13908@bbox>
	<87o9y2a5ji.fsf@yhuang-dev.intel.com>
	<alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
	<1487273646.2833.100.camel@linux.intel.com>
	<alpine.LSU.2.11.1702161702490.24224@eggly.anvils>
	<87efyx8t9o.fsf@yhuang-dev.intel.com>
Date: Fri, 17 Feb 2017 10:37:44 +0800
In-Reply-To: <87efyx8t9o.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Fri, 17 Feb 2017 10:07:15 +0800")
Message-ID: <87o9y17daf.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Huang, Ying" <ying.huang@intel.com> writes:

> Hi, Hugh,
>
> Hugh Dickins <hughd@google.com> writes:
>
>> On Thu, 16 Feb 2017, Tim Chen wrote:
>>> 
>>> > I do not understand your zest for putting wrappers around every little
>>> > thing, making it all harder to follow than it need be.A  Here's the patch
>>> > I've been running with (but you have a leak somewhere, and I don't have
>>> > time to search out and fix it: please try sustained swapping and swapoff).
>>> > 
>>> 
>>> Hugh, trying to duplicate your test case. A So you were doing swapping,
>>> then swap off, swap on the swap device and restart swapping?
>>
>> Repeated pair of make -j20 kernel builds in 700M RAM, 1.5G swap on SSD,
>> 8 cpus; one of the builds in tmpfs, other in ext4 on loop on tmpfs file;
>> sizes tuned for plenty of swapping but no OOMing (it's an ancient 2.6.24
>> kernel I build, modern one needing a lot more space with a lot less in use).
>>
>> How much of that is relevant I don't know: hopefully none of it, it's
>> hard to get the tunings right from scratch.  To answer your specific
>> question: yes, I'm not doing concurrent swapoffs in this test showing
>> the leak, just waiting for each of the pair of builds to complete,
>> then tearing down the trees, doing swapoff followed by swapon, and
>> starting a new pair of builds.
>>
>> Sometimes it's the swapoff that fails with ENOMEM, more often it's a
>> fork during build that fails with ENOMEM: after 6 or 7 hours of load
>> (but timings show it getting slower leading up to that).  /proc/meminfo
>> did not give me an immediate clue, Slab didn't look surprising but
>> I may not have studied close enough.
>
> Thanks for you information!
>
> Memory newly allocated in the mm-swap series are allocated via vmalloc,
> could you find anything special for vmalloc in /proc/meminfo?

I found a potential issue in the mm-swap series, could you try the
patches as below?

Best Regards,
Huang, Ying

----------------------------------------------------->
