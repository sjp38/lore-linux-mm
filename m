Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DA34C6B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:24:06 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so47709992pab.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:24:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id e6si13700492pat.29.2015.07.31.16.24.05
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 16:24:06 -0700 (PDT)
Message-ID: <55BC0392.2070205@intel.com>
Date: Fri, 31 Jul 2015 16:24:02 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com>
In-Reply-To: <55BB4027.7080200@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2015 02:30 AM, Xishi Qiu wrote:
> __free_one_page() will judge whether the the next-highest order is free,
> then add the block to the tail or not. So when we split large order block, 
> add the small block to the tail, it will reduce fragment.

It's an interesting idea, but what does it do in practice?  Can you
measure a decrease in fragmentation?

Further, the comment above the function says:
 * The order of subdivision here is critical for the IO subsystem.
 * Please do not alter this order without good reasons and regression
 * testing.

Has there been regression testing?

Also, this might not do very much good in practice.  If you are
splitting a high-order page, you are doing the split because the
lower-order lists are empty.  So won't that list_add() be to an empty
list most of the time?  Or does the __rmqueue_fallback()
largest->smallest logic dominate?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
