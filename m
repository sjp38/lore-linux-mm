Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 916C86B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 07:27:12 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p11so8939215qtg.19
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 04:27:12 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z16si3309901qta.419.2018.02.19.04.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 04:27:11 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180219094735.g4sm4kxawjnojgyd@suse.de>
Date: Mon, 19 Feb 2018 12:26:39 +0000
Content-Transfer-Encoding: 7bit
Message-Id: <CB73A16F-5B32-4681-86E3-00786C67ADEF@oracle.com>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219094735.g4sm4kxawjnojgyd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>



> On 19 Feb 2018, at 09:47, Mel Gorman <mgorman@suse.de> wrote:
> 
> On Sun, Feb 18, 2018 at 04:47:55PM +0000, robert.m.harris@oracle.com wrote:
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
>> 
>> Signed-off-by: Robert M. Harris <robert.m.harris@oracle.com>
> 
> You have to update sysctl_extfrag_threshold as well for the new bounds.

This patch makes its default value zero.

> It effectively makes it a no-op but it was a no-op already and adjusting
> that default should be supported by data indicating it's safe.

Would it be acceptable to demonstrate using tracing that in both the
pre- and post-patch cases

  1. compaction is attempted regardless of fragmentation index,
     excepting that

  2. reclaim is preferred even for non-zero fragmentation during
     an extreme shortage of memory

?

Robert Harris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
