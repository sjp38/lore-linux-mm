Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8D446B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 13:46:02 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so19056555lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:46:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt7si31157460wjb.85.2016.04.26.10.46.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 10:46:01 -0700 (PDT)
Subject: Re: [PATCH 21/28] mm, page_alloc: Avoid looking up the first zone in
 a zonelist twice
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-9-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FA958.6060200@suse.cz>
Date: Tue, 26 Apr 2016 19:46:00 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-9-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> The allocator fast path looks up the first usable zone in a zonelist
> and then get_page_from_freelist does the same job in the zonelist
> iterator. This patch preserves the necessary information.
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                        fastmark-v1r20             initonce-v1r20
> Min      alloc-odr0-1               364.00 (  0.00%)           359.00 (  1.37%)
> Min      alloc-odr0-2               262.00 (  0.00%)           260.00 (  0.76%)
> Min      alloc-odr0-4               214.00 (  0.00%)           214.00 (  0.00%)
> Min      alloc-odr0-8               186.00 (  0.00%)           186.00 (  0.00%)
> Min      alloc-odr0-16              173.00 (  0.00%)           173.00 (  0.00%)
> Min      alloc-odr0-32              165.00 (  0.00%)           165.00 (  0.00%)
> Min      alloc-odr0-64              161.00 (  0.00%)           162.00 ( -0.62%)
> Min      alloc-odr0-128             159.00 (  0.00%)           161.00 ( -1.26%)
> Min      alloc-odr0-256             168.00 (  0.00%)           170.00 ( -1.19%)
> Min      alloc-odr0-512             180.00 (  0.00%)           181.00 ( -0.56%)
> Min      alloc-odr0-1024            190.00 (  0.00%)           190.00 (  0.00%)
> Min      alloc-odr0-2048            196.00 (  0.00%)           196.00 (  0.00%)
> Min      alloc-odr0-4096            202.00 (  0.00%)           202.00 (  0.00%)
> Min      alloc-odr0-8192            206.00 (  0.00%)           205.00 (  0.49%)
> Min      alloc-odr0-16384           206.00 (  0.00%)           205.00 (  0.49%)
>
> The benefit is negligible and the results are within the noise but each
> cycle counts.

Hmm this indeed doesn't look too convincing to justify the patch. Also it's 
adding adding extra pointer dereferences by accessing zone via zoneref, and the 
next patch does the same with classzone_idx (stack saving shouldn't be that 
important when the purpose of alloc_context is to have all of it only once on 
stack). I don't feel strongly enough to NAK, but not convinced to ack either.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
