Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2656B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:38:24 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j6so11256031wre.16
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 01:38:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si2968087edj.349.2017.11.24.01.38.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 01:38:22 -0800 (PST)
Date: Fri, 24 Nov 2017 10:38:19 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20171124093819.GA6072@quack2.suse.cz>
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
 <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
 <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
 <20171116130746.i642wszwvyb7q6hm@dhcp22.suse.cz>
 <20171124030236.GA28999@X58A-UD3R>
 <20171124081149.filhcoy6zh6ysrjj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124081149.filhcoy6zh6ysrjj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On Fri 24-11-17 09:11:49, Michal Hocko wrote:
> On Fri 24-11-17 12:02:36, Byungchul Park wrote:
> > On Thu, Nov 16, 2017 at 02:07:46PM +0100, Michal Hocko wrote:
> > > On Thu 16-11-17 21:48:05, Byungchul Park wrote:
> > > > On 11/16/2017 9:02 PM, Michal Hocko wrote:
> > > > > for each struct page. So you are doubling the size. Who is going to
> > > > > enable this config option? You are moving this to page_ext in a later
> > > > > patch which is a good step but it doesn't go far enough because this
> > > > > still consumes those resources. Is there any problem to make this
> > > > > kernel command line controllable? Something we do for page_owner for
> > > > > example?
> > > > 
> > > > Sure. I will add it.
> > > > 
> > > > > Also it would be really great if you could give us some measures about
> > > > > the runtime overhead. I do not expect it to be very large but this is
> > > > 
> > > > The major overhead would come from the amount of additional memory
> > > > consumption for 'lockdep_map's.
> > > 
> > > yes
> > > 
> > > > Do you want me to measure the overhead by the additional memory
> > > > consumption?
> > > > 
> > > > Or do you expect another overhead?
> > > 
> > > I would be also interested how much impact this has on performance. I do
> > > not expect it would be too large but having some numbers for cache cold
> > > parallel kbuild or other heavy page lock workloads.
> > 
> > Hello Michal,
> > 
> > I measured 'cache cold parallel kbuild' on my qemu machine. The result
> > varies much so I cannot confirm, but I think there's no meaningful
> > difference between before and after applying crossrelease to page locks.
> > 
> > Actually, I expect little overhead in lock_page() and unlock_page() even
> > after applying crossreleas to page locks, but only expect a bit overhead
> > by additional memory consumption for 'lockdep_map's per page.
> > 
> > I run the following instructions within "QEMU x86_64 4GB memory 4 cpus":
> > 
> >    make clean
> >    echo 3 > drop_caches
> >    time make -j4
> 
> Maybe FS people will help you find a more representative workload. E.g.
> linear cache cold file read should be good as well. Maybe there are some
> tests in fstests (or how they call xfstests these days).

So a relatively good test of page handling costs is to mmap cache hot file
and measure time to fault in all the pages in the mapping. That way IO and
filesystem stays out of the way and you measure only page table lookup,
page handling (taking page ref and locking the page), and instantiation of
the new PTE. Out of this page handling is actually the significant part.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
