Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83D116B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:10:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f9-v6so9270648plo.17
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:10:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9-v6si2475320pln.45.2018.04.10.04.10.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 04:10:07 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:10:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180410111001.GD21835@dhcp22.suse.cz>
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz>
 <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz>
 <20180410110242.GC2041@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410110242.GC2041@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 10-04-18 14:02:42, Cyrill Gorcunov wrote:
> On Tue, Apr 10, 2018 at 12:42:15PM +0200, Michal Hocko wrote:
> > On Tue 10-04-18 12:40:47, Cyrill Gorcunov wrote:
> > > On Tue, Apr 10, 2018 at 11:09:17AM +0200, Michal Hocko wrote:
> > > > On Tue 10-04-18 05:52:54, Yang Shi wrote:
> > > > [...]
> > > > > So, introduce a new spinlock in mm_struct to protect the concurrent
> > > > > access to arg_start|end, env_start|end and others except start_brk and
> > > > > brk, which are still protected by mmap_sem to avoid concurrent access
> > > > > from do_brk().
> > > > 
> > > > Is there any fundamental problem with brk using the same lock?
> > > 
> > > Seems so. Look into mm/mmap.c:brk syscall which reads and writes
> > > brk value under mmap_sem ('cause of do_brk called inside).
> > 
> > Why cannot we simply use the lock when the value is updated?
> 
> Because do_brk does vma manipulations, for this reason it's
> running under down_write_killable(&mm->mmap_sem). Or you
> mean something else?

Yes, all we need the new lock for is to get a consistent view on brk
values. I am simply asking whether there is something fundamentally
wrong by doing the update inside the new lock while keeping the original
mmap_sem locking in the brk path. That would allow us to drop the
mmap_sem lock in the proc path when looking at brk values.

-- 
Michal Hocko
SUSE Labs
