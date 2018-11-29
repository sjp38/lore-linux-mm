Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEDFB6B542B
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 14:21:53 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id 132so2538521wms.3
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 11:21:53 -0800 (PST)
Received: from mail.grenz-bonn.de (mail.grenz-bonn.de. [178.33.37.38])
        by mx.google.com with ESMTPS id z6si2150639wrs.63.2018.11.29.11.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 11:21:52 -0800 (PST)
Subject: Re: Question about the laziness of MADV_FREE
References: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
 <20181129180057.GZ6923@dhcp22.suse.cz>
From: =?UTF-8?Q?Niklas_Hamb=c3=bcchen?= <mail@nh2.me>
Message-ID: <1423043c-af4b-0288-9f42-e00be320491b@nh2.me>
Date: Thu, 29 Nov 2018 20:21:49 +0100
MIME-Version: 1.0
In-Reply-To: <20181129180057.GZ6923@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

Hello Michal,

thanks for the swift reply and patch!

> We batch multiple pages to become really lazyfree. This means that those
> pages are sitting on a per-cpu list (see mark_page_lazyfree). So the
> the number drift depends on the number of CPUs.

Is there an upper bound that I can rely on in order to judge how far off the accounting is (perhaps depending on the number of CPUs as you say)?
For example, if the drift is bounded to, say 10%, that would probably be fine, while if it could be off by 2x or so, that would make system inspection tough.

>> For my investigation it would be very useful if I could get accurate accounting.
>> How much work would the "If this is not desirable please file a bug report" bit entail?
> 
> What would be the reason to get the exact number?

Mainly to debug situations where programs run out of memory.
Quite similar to the third point on https://lore.kernel.org/patchwork/cover/755741/.

In such situations, the first thing people usually do is to look at RES and see if things are off.
The fact that RES may still showing memory usage from before can already send one down the wrong investigation path very quickly.
For example, my process takes up to 50 GB when processing some data, and MADV_FREEs it all when it's done and idling.
Due to the lazy freeing, RES will continue to show up as 50 GB even when idle, which may make people suspect a memory leak when there really is none.

In this specific case, one can at least consult proc's LazyFree to figure this out, but if you cannot rely on that number to be accurate either (and the docs not saying how inaccurate it is), it's easy to feel lost about it.

Thanks!
