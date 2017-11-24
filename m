Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 141DC6B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 03:11:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m9so3021617wmd.0
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 00:11:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si96edb.27.2017.11.24.00.11.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 00:11:52 -0800 (PST)
Date: Fri, 24 Nov 2017 09:11:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20171124081149.filhcoy6zh6ysrjj@dhcp22.suse.cz>
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
 <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
 <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
 <20171116130746.i642wszwvyb7q6hm@dhcp22.suse.cz>
 <20171124030236.GA28999@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124030236.GA28999@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On Fri 24-11-17 12:02:36, Byungchul Park wrote:
> On Thu, Nov 16, 2017 at 02:07:46PM +0100, Michal Hocko wrote:
> > On Thu 16-11-17 21:48:05, Byungchul Park wrote:
> > > On 11/16/2017 9:02 PM, Michal Hocko wrote:
> > > > for each struct page. So you are doubling the size. Who is going to
> > > > enable this config option? You are moving this to page_ext in a later
> > > > patch which is a good step but it doesn't go far enough because this
> > > > still consumes those resources. Is there any problem to make this
> > > > kernel command line controllable? Something we do for page_owner for
> > > > example?
> > > 
> > > Sure. I will add it.
> > > 
> > > > Also it would be really great if you could give us some measures about
> > > > the runtime overhead. I do not expect it to be very large but this is
> > > 
> > > The major overhead would come from the amount of additional memory
> > > consumption for 'lockdep_map's.
> > 
> > yes
> > 
> > > Do you want me to measure the overhead by the additional memory
> > > consumption?
> > > 
> > > Or do you expect another overhead?
> > 
> > I would be also interested how much impact this has on performance. I do
> > not expect it would be too large but having some numbers for cache cold
> > parallel kbuild or other heavy page lock workloads.
> 
> Hello Michal,
> 
> I measured 'cache cold parallel kbuild' on my qemu machine. The result
> varies much so I cannot confirm, but I think there's no meaningful
> difference between before and after applying crossrelease to page locks.
> 
> Actually, I expect little overhead in lock_page() and unlock_page() even
> after applying crossreleas to page locks, but only expect a bit overhead
> by additional memory consumption for 'lockdep_map's per page.
> 
> I run the following instructions within "QEMU x86_64 4GB memory 4 cpus":
> 
>    make clean
>    echo 3 > drop_caches
>    time make -j4

Maybe FS people will help you find a more representative workload. E.g.
linear cache cold file read should be good as well. Maybe there are some
tests in fstests (or how they call xfstests these days).

> The results are:
> 
>    # w/o page lock tracking
> 
>    At the 1st try,
>    real     5m28.105s
>    user     17m52.716s
>    sys      3m8.871s
> 
>    At the 2nd try,
>    real     5m27.023s
>    user     17m50.134s
>    sys      3m9.289s
> 
>    At the 3rd try,
>    real     5m22.837s
>    user     17m34.514s
>    sys      3m8.097s
> 
>    # w/ page lock tracking
> 
>    At the 1st try,
>    real     5m18.158s
>    user     17m18.200s
>    sys      3m8.639s
> 
>    At the 2nd try,
>    real     5m19.329s
>    user     17m19.982s
>    sys      3m8.345s
> 
>    At the 3rd try,
>    real     5m19.626s
>    user     17m21.363s
>    sys      3m9.869s
> 
> I think thers's no meaningful difference on my small machine.

Yeah, this doesn't seem to indicate anything. Maybe moving the build to
shmem to rule out IO cost would tell more. But as I've said previously
page I do not really expect this would be very visible. It was more a
matter of my curiosity than an acceptance requirement. I think it is
much more important to make this runtime configurable because almost
nobody is going to enable the feature if it is only build time. The cost
is jut too high.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
