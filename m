Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7736B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 07:15:00 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id x4so7915159qkc.7
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 04:15:00 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t8si1504813qth.244.2018.02.19.04.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 04:14:58 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180219082649.GD21134@dhcp22.suse.cz>
Date: Mon, 19 Feb 2018 12:14:26 +0000
Content-Transfer-Encoding: 7bit
Message-Id: <E718672A-91A0-4A5A-91B5-A6CF1E9BD544@oracle.com>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219082649.GD21134@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>



> On 19 Feb 2018, at 08:26, Michal Hocko <mhocko@kernel.org> wrote:
> 
> On Sun 18-02-18 16:47:55, robert.m.harris@oracle.com wrote:
>> From: "Robert M. Harris" <robert.m.harris@oracle.com>
>> 
>> __fragmentation_index() calculates a value used to determine whether
>> compaction should be favoured over page reclaim in the event of allocation
>> failure.  The calculation itself is opaque and, on inspection, does not
>> match its existing description.  The function purports to return a value
>> between 0 and 1000, representing units of 1/1000.  Barring the case of a
>> pathological shortfall of memory, the lower bound is instead 500.  This is
>> significant because it is the default value of sysctl_extfrag_threshold,
>> i.e. the value below which compaction should be avoided in favour of page
>> reclaim for costly pages.
>> 
>> This patch implements and documents a modified version of the original
>> expression that returns a value in the range 0 <= index < 1000.  It amends
>> the default value of sysctl_extfrag_threshold to preserve the existing
>> behaviour.
> 
> It is not really clear to me what is the actual problem you are trying
> to solve by this patch. Is there any bug or are you just trying to
> improve the current implementation to be more effective?

There is not a significant bug.

The first problem is that the mathematical expression in
__fragmentation_index() is opaque, particularly given the lack of
description in the comments or the original commit message.  This patch
provides such a description.

Simply annotating the expression did not make sense since the formula
doesn't work as advertised.  The fragmentation index is described as
being in the range 0 to 1000 but the bounds of the formula are instead
500 to 1000.  This patch changes the formula so that its lower bound is
0.

The fragmentation index is compared to the tuneable
sysctl_extfrag_threshold, which defaults to 500.  If the index is above
this value then compaction is preferred over page reclaim in the event
of allocation failure.  Given the issue above, the index will almost
always exceed the default threshold and compaction will occur even if
there is low fragmentation.  This patch changes the default value of the
tuneable to 0, meaning that the existing behaviour will be unchanged.
Changing sysctl_extfrag_threshold back to something non-zero in a future
patch would effect the behaviour intended by the original code but would
require more comprehensive testing since it would modify the kernel's
performance under memory pressure.

Robert Harris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
