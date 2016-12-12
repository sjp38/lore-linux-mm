Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65B196B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 03:24:33 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so21985305wjo.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:24:33 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y6si43412459wjh.73.2016.12.12.00.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 00:24:32 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so9601427wme.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:24:31 -0800 (PST)
Date: Mon, 12 Dec 2016 09:24:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er kernels
Message-ID: <20161212082429.GA18163@dhcp22.suse.cz>
References: <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161209160946.GE4334@dhcp22.suse.cz>
 <fd029311-f0fe-3d1f-26d2-1f87576b14da@wiesinger.com>
 <20161209173018.GA31809@dhcp22.suse.cz>
 <a7ebcdbe-9feb-a88f-594c-161e7daa5818@wiesinger.com>
 <dce6a53e-9c13-2a17-ecef-824883506f72@suse.cz>
 <5e7490ea-4e59-7965-bc4d-171f9d60e439@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e7490ea-4e59-7965-bc4d-171f9d60e439@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat 10-12-16 14:50:34, Gerhard Wiesinger wrote:
[...]
> IMHO: The OOM killer should NOT kick in even on the highest workloads if
> there is swap available.

This is not so simple. Take a heavy swap trashing situation as an
example. You still have a lot of swap space and an anonymous memory
which can be swapped out but if the workload simply keeps refaulting
the swapped out memory all the time then you can barely make any further
progress and end up in the swap IO hell. Invoking the OOM killer in such
a situation would be a relief to make the system usable again.

> https://www.spinics.net/lists/linux-mm/msg113665.html
> 
> Yeah, but I do think that "oom when you have 156MB free and 7GB
> reclaimable, and haven't even tried swapping" counts as obviously
> wrong.

No question about this part of course.

> So Linus also thinks that trying swapping is a must have. And there
> always was enough swap available in my cases. Then it should swap
> out/swapin all the time (which worked well in kernel 2.4/2.6 times).
> 
> Another topic: Why does the kernel prefer to swap in/swap out instead of use
> cache pages/buffers (see vmstat 1 output below)?

In the vast majority cases it is quite contrary. We heavily bias page
cache reclaim in favor of the anonymous memory. Have a look at
get_scan_count function which determines the balance.

I would need to see /proc/vmstat collected during this time period to
tell you more about why the particular balance was used.

[...]

> With kernel 4.7./4.8 it was really reaproduceable at every dnf update. With
> 4.9rc8 it has been much much better. So something must have changed, too.

that is good to hear but I it would be much better to collect reclaim
related data so that we can analyse what is actually going on here.

> As far as I understood it the order is 2^order kB pagesize. I don't think it
> makes a difference when swap is not used which order the memory allocation
> request is.
> 
> BTW: What were the commit that introduced the regression anf fixed it in
> 4.9?

I cannot really answer this without actually understanding what is going
on here and for that I do not have the relevant data.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
