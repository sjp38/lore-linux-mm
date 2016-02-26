Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id CD1236B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 14:50:20 -0500 (EST)
Received: by mail-qk0-f177.google.com with SMTP id s5so35891773qkd.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:50:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f185si14575599qhd.52.2016.02.26.11.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 11:50:19 -0800 (PST)
Date: Fri, 26 Feb 2016 20:50:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160226195015.GK1180@redhat.com>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160225195613.GZ2854@techsingularity.net>
 <20160225230219.GF1180@redhat.com>
 <20160226111316.GB2854@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160226111316.GB2854@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Mel,

On Fri, Feb 26, 2016 at 11:13:16AM +0000, Mel Gorman wrote:
> 1. By default, "madvise" and direct reclaim/compaction for applications
>    that specifically requested that behaviour. This will avoid breaking
>    MADV_HUGEPAGE which you mentioned in a few places

Defragging memory synchronously only under madvise is fine with me.

> 2. "never" will never reclaim anything and was the default behaviour of
>    version 1 but will not be the default in version 2.
> 3. "defer" will wake kswapd which will reclaim or wake kcompactd
>    whichever is necessary. This is new but avoids stalls while helping
>    khugepaged do its work quickly in the near future.

This is an kABI visible change, but it should be ok. I'm not aware of
any program that parses that file and could get confused.

"defer" sounds an interesting default option if it could be made to
work better.

> 4. "always" will direct reclaim/compact just like todays behaviour

I suspect there are a number of apps that took advantage of the
"always" setting without realizing it, but we only could notice the
ones that don't. In any case those apps can start to call
MADV_HUGEPAGE if they don't already and that will provide a definitive
fix. With this approach MADV_HUGEPAGE will provide the same
reliability in allocation as before so there will be no problem then.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
