Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E32A36B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 02:20:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v189so8433385wmf.4
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 23:20:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a43si3125307wrc.18.2018.04.03.23.20.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 23:20:41 -0700 (PDT)
Date: Wed, 4 Apr 2018 08:20:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404062039.GC6312@dhcp22.suse.cz>
References: <20180403110612.GM5501@dhcp22.suse.cz>
 <20180403075158.0c0a2795@gandalf.local.home>
 <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <20180403101753.3391a639@gandalf.local.home>
 <20180403161119.GE5501@dhcp22.suse.cz>
 <20180403185627.6bf9ea9b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403185627.6bf9ea9b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue 03-04-18 18:56:27, Steven Rostedt wrote:
[...]
> From your earlier email:
> 
> > Except that it doesn't work. si_mem_available is not really suitable for
> > any allocation estimations. Its only purpose is to provide a very rough
> > estimation for userspace. Any other use is basically abuse. The
> > situation can change really quickly. Really it is really hard to be
> > clever here with the volatility the memory allocations can cause.
> 
> Now can you please explain to me why si_mem_available is not suitable
> for my purpose.

Several problems. It is overly optimistic especially when we are close
to OOM. The available pagecache or slab reclaimable objects might be pinned
long enough that your allocation based on that estimation will just make
the situation worse and result in OOM. More importantly though, your
allocations are GFP_KERNEL, right, that means that such an allocation
will not reach to ZONE_MOVABLE or ZONE_HIGMEM (32b systems) while the
pagecache will. So you will get an overestimate of how much you can
allocate.

Really si_mem_available is for proc/meminfo and a rough estimate of the
free memory because users tend to be confused by seeing MemFree too low
and complaining that the system has eaten all their memory. I have some
skepticism about how useful it is in practice apart from showing it in
top or alike tools. The memory is simply not usable immediately or
without an overall and visible effect on the whole system.

HTH
-- 
Michal Hocko
SUSE Labs
