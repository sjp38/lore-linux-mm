Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5A896B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 09:08:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so3586111wmi.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:08:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si89318063wjy.176.2017.01.06.06.08.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 06:08:07 -0800 (PST)
Date: Fri, 6 Jan 2017 15:08:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-ID: <20170106140805.GO5556@dhcp22.suse.cz>
References: <bug-190841-27@https.bugzilla.kernel.org/>
 <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
 <20170105123341.GQ21618@dhcp22.suse.cz>
 <CAJABK0MAX2jz+U-00x1xM7EEFEe3_h-nwnEdG9axJKrzuqTBjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJABK0MAX2jz+U-00x1xM7EEFEe3_h-nwnEdG9axJKrzuqTBjQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladyslav Frolov <frolvlad@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu 05-01-17 22:26:53, Vladyslav Frolov wrote:
[...]
> > Even without memcg involved. Are there any strong reasons you cannot reuse an existing cgroup?
> 
> I run concurrent executions (I run cgmemtime
> [https://github.com/gsauthof/cgmemtime] to measure high-water memory
> usage of a group of processes), so I cannot reuse a single cgroup, and
> I, currently, cannot maintain a pool of cgroups (it will add extra
> complexity in my code, and will require cgmemtime patching, while
> older kernels just worked fine). Do you believe there is no bug there
> and it is just slow by design?

> There are a few odd things here:
> 
> 1. 4.7+ kernels perform 20 times *slower* while postponing should in
> theory speed things up due to "async" nature
> 2. Other cgroup creation/cleaning work like a charm, it is only
> `memory` cgroup making my system overloaded
> 
> > echo 1 > $CGROUP_BASE/memory.force_empty
> 
> This didn't help at alll.

OK, then it is not just the page cache staying behind which prevents
those memcgs go away. Another reason might be kmem charges. Memcg kernel
memory accounting has been enabled by default since 4.6 AFAIR. You say
4.7+ has seen a slowdown though so this might be completely unrelated.
But it would be good to see whether the same happens with kernel command
line:
cgroup.memory=nokmem
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
