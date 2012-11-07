Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 610576B004D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:46:52 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1258447pbb.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 03:46:51 -0800 (PST)
Date: Wed, 7 Nov 2012 03:43:46 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121107114346.GA32565@lizard>
References: <20121107105348.GA25549@lizard>
 <20121107112136.GA31715@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121107112136.GA31715@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 07, 2012 at 01:21:36PM +0200, Kirill A. Shutemov wrote:
[...]
> Sorry, I didn't follow previous discussion on this, but could you
> explain what's wrong with memory notifications from memcg?
> As I can see you can get pretty similar functionality using memory
> thresholds on the root cgroup. What's the point?

There are a few reasons we don't use cgroup notifications:

1. We're not interested in the absolute number of pages/KB of available
   memory, as provided by cgroup memory controller. What we're interested
   in is the amount of easily reclaimable memory and new memory
   allocations' cost.

   We can have plenty of "free" memory, of which say 90% will be caches,
   and say 10% idle. But we do want to differentiate these types of memory
   (although not going into details about it), i.e. we want to get
   notified when kernel is reclaiming. And we also want to know when the
   memory comes from swapping others' pages out (well, actually we don't
   call it swap, it's "new allocations cost becomes high" -- it might be a
   result of many factors (swapping, fragmentation, etc.) -- and userland
   might analyze the situation when this happens).

   Exposing all the VM details to userland is not an option -- it is not
   possible to build a stable ABI on this. Plus, it makes it really hard
   for userland to deal with all the low level details of Linux VM
   internals.

   So, no, raw numbers of "free/used KBs" are not interesting at all.

1.5. But it is important to understand that vmpressure_fd() is not
     orthogonal to cgroups (like it was with vmevent_fd()). We want it to
     be "cgroup'able" too. :) But optionally.

2. The last time I checked, cgroups memory controller did not (and I guess
   still does not) not account kernel-owned slabs. I asked several times
   why so, but nobody answered.
   
   But no, this is not the main issue -- per "1.", we're not interested in
   kilobytes.

3. Some folks don't like cgroups: it has a penalty for kernel size, for
   performance and memory wastage. But again, it's not the main issue with
   memcg.

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
