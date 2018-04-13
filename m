Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDB86B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 02:56:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 195so709128wmf.0
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 23:56:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si592209edd.300.2018.04.12.23.56.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 23:56:21 -0700 (PDT)
Date: Fri, 13 Apr 2018 08:56:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180413065619.GD17484@dhcp22.suse.cz>
References: <20180410090917.GZ21835@dhcp22.suse.cz>
 <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz>
 <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz>
 <20180410122804.GD2041@uranus.lan>
 <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
 <8c19f1fb-7baf-fef3-032d-4e93cfc63932@linux.alibaba.com>
 <20180412121801.GE23400@dhcp22.suse.cz>
 <49c17035-1b8c-5fa3-9944-33467589d1f1@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <49c17035-1b8c-5fa3-9944-33467589d1f1@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-04-18 09:20:24, Yang Shi wrote:
> 
> 
> On 4/12/18 5:18 AM, Michal Hocko wrote:
> > On Tue 10-04-18 11:28:13, Yang Shi wrote:
> > > 
> > > On 4/10/18 9:21 AM, Yang Shi wrote:
> > > > 
> > > > On 4/10/18 5:28 AM, Cyrill Gorcunov wrote:
> > > > > On Tue, Apr 10, 2018 at 01:10:01PM +0200, Michal Hocko wrote:
> > > > > > > Because do_brk does vma manipulations, for this reason it's
> > > > > > > running under down_write_killable(&mm->mmap_sem). Or you
> > > > > > > mean something else?
> > > > > > Yes, all we need the new lock for is to get a consistent view on brk
> > > > > > values. I am simply asking whether there is something fundamentally
> > > > > > wrong by doing the update inside the new lock while keeping the
> > > > > > original
> > > > > > mmap_sem locking in the brk path. That would allow us to drop the
> > > > > > mmap_sem lock in the proc path when looking at brk values.
> > > > > Michal gimme some time. I guess  we might do so, but I need some
> > > > > spare time to take more precise look into the code, hopefully today
> > > > > evening. Also I've a suspicion that we've wracked check_data_rlimit
> > > > > with this new lock in prctl. Need to verify it again.
> > > > I see you guys points. We might be able to move the drop of mmap_sem
> > > > before setting mm->brk in sys_brk since mmap_sem should be used to
> > > > protect vma manipulation only, then protect the value modify with the
> > > > new arg_lock. Then we can eliminate mmap_sem stuff in prctl path, and it
> > > > also prevents from wrecking check_data_rlimit.
> > > > 
> > > > At the first glance, it looks feasible to me. Will look into deeper
> > > > later.
> > > A further look told me this might be *not* feasible.
> > > 
> > > It looks the new lock will not break check_data_rlimit since in my patch
> > > both start_brk and brk is protected by mmap_sem. The code flow might look
> > > like below:
> > > 
> > > CPU A                             CPU B
> > > --------                       --------
> > > prctl                               sys_brk
> > >                                        down_write
> > > check_data_rlimit           check_data_rlimit (need mm->start_brk)
> > >                                        set brk
> > > down_write                    up_write
> > > set start_brk
> > > set brk
> > > up_write
> > > 
> > > 
> > > If CPU A gets the mmap_sem first, it will set start_brk and brk, then CPU B
> > > will check with the new start_brk. And, prctl doesn't care if sys_brk is run
> > > before it since it gets the new start_brk and brk from parameter.
> > > 
> > > If we protect start_brk and brk with the new lock, sys_brk might get old
> > > start_brk, then sys_brk might break rlimit check silently, is that right?
> > > 
> > > So, it looks using new lock in prctl and keeping mmap_sem in brk path has
> > > race condition.
> > OK, I've admittedly didn't give it too much time to think about. Maybe
> > we do something clever to remove the race but can we start at least by
> > reducing the write lock to read on prctl side and use the dedicated
> > spinlock for updating values? That should close the above race AFAICS
> > and the read lock would be much more friendly to other VM operations.
> 
> Yes, is sounds feasible. We just need care about prctl is run before
> sys_brk. 

There will never be any before/after ordering here. It has never been.
We just need the two to be mutually exlusive. We do not really need that
for races with the page fault because the prctl doesn't modify the
layout AFAIU.

> So, you mean:
> 
> down_read
> spin_lock
> update all the values
> spin_unlock
> up_read

Yes.

-- 
Michal Hocko
SUSE Labs
