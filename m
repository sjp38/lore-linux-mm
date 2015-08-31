Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id CFCF46B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:20:50 -0400 (EDT)
Received: by wicjd9 with SMTP id jd9so5428824wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:20:50 -0700 (PDT)
Received: from smtp.enix.org (smtp.enix.org. [193.19.211.146])
        by mx.google.com with ESMTPS id gi9si12143378wic.20.2015.08.31.09.20.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 09:20:49 -0700 (PDT)
Message-ID: <55E47EDC.6090205@enix.org>
Date: Mon, 31 Aug 2015 18:20:44 +0200
From: =?windows-1252?Q?S=E9bastien_Wacquiez?= <sw@enix.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v4
References: <1429983942-4308-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1429983942-4308-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/25/2015 07:45 PM, Mel Gorman wrote:

> The performance impact is documented in the changelogs but in the optimistic
> case on a 4-socket machine the full series reduces interrupts from 900K
> interrupts/second to 60K interrupts/second.


Hello to the list,


this patch have a huge (positive) performance impact on my setup.

In the goal of building the best ever CDN, I run varnish web cache over
very big boxes (dual xeon 12 cores, 256 Gb Ram, 24 SSd, 2*40G ethernet).

Without going into varnish internal, it help to know that varnish have
multiple storage backend (memory, file, etc), and that the file backend,
(the one you use when you have caches drives), don't use read/write
syscall but mmap.

The raw performances of this server are very good : when using varnish
with memory storage only, it push 80Gbps of network traffic easily. When
reading/writing from/to the drives, you get 10GB/s of data. And you can
do both at the same time without performance loss.

Anyway, without this patch, using file storage backend and after warmup,
the performance of the server was limited to a frustrating 14 Gbps. At
start, varnish read from the http backend at ~ 30 Gbps, cache the data
in his huge mmap, the system write it to the disk, stream it to the
client, so everything looks ok. But instead of becoming quicker when the
hitrate goes up (as we alread have data in the cache), it became slower
and slower, to finally freeze for like 4-5 seconds every 10 sec or so.

After analysis, I found out the bottleneck is the system's capacity
to find free memory. If I get it correctly, when you read a "swapped
out" page of a mmaped file, the kernel have to find some free memory to
put the data it'll read from the drive. In my case, the disk are quick
enough to handle the change almost in real time, so I've a lot of
potential free memory (ie Inactive(file)). Really freeing this memory
(either in direct or hard reclaim) is done relatively slowly, ie, after
some tuning to avoid any direct reclaim (which was causing the freeze),
I ended up having 2 kswapd (it's a bi-socket numa node) process eating
100% of cpu for ~ 14 Gbps of traffic (or ~1.5 Millions reclaims/s)

After a chat with Rik van Riel and Mel Gorman, they suggest me to try
this patch, and the limitation immediately jumped at 33 Gbps, which was
in fact my upstream capacity, after a while I was able to achieve
60 Gbps without experiencing any issue.
Even the freezing part, happening in direct reclaim mode, is a lot
smoother ; on my test rig it sufficiently quick to not be seen as
unavailability by my supervision (which wasn't the case before).

The bad news is that after some time (like 24h) of stress testing, the
performance degrade, I guess due to some kind of fragmentation. Still,
the performance seems to be maintained to a higher level than the
vanilla kernel.

I suppose that this patch could also help a lot with database (which
often mmap their data) which have to reread huge dataset frequently.


Thanks a lot to Rik and Mel for the provided help, and feel free to mail
me if you have question.


Regards,


Sebastien Wacquiez

PS : the test were conducted with a 4.0.0 kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
