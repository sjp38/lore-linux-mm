Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51E3E6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 22:02:47 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u3so20557332pgn.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 19:02:47 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v75si10535151pfd.392.2017.11.23.19.02.45
        for <linux-mm@kvack.org>;
        Thu, 23 Nov 2017 19:02:45 -0800 (PST)
Date: Fri, 24 Nov 2017 12:02:36 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20171124030236.GA28999@X58A-UD3R>
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
 <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
 <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
 <20171116130746.i642wszwvyb7q6hm@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116130746.i642wszwvyb7q6hm@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On Thu, Nov 16, 2017 at 02:07:46PM +0100, Michal Hocko wrote:
> On Thu 16-11-17 21:48:05, Byungchul Park wrote:
> > On 11/16/2017 9:02 PM, Michal Hocko wrote:
> > > for each struct page. So you are doubling the size. Who is going to
> > > enable this config option? You are moving this to page_ext in a later
> > > patch which is a good step but it doesn't go far enough because this
> > > still consumes those resources. Is there any problem to make this
> > > kernel command line controllable? Something we do for page_owner for
> > > example?
> > 
> > Sure. I will add it.
> > 
> > > Also it would be really great if you could give us some measures about
> > > the runtime overhead. I do not expect it to be very large but this is
> > 
> > The major overhead would come from the amount of additional memory
> > consumption for 'lockdep_map's.
> 
> yes
> 
> > Do you want me to measure the overhead by the additional memory
> > consumption?
> > 
> > Or do you expect another overhead?
> 
> I would be also interested how much impact this has on performance. I do
> not expect it would be too large but having some numbers for cache cold
> parallel kbuild or other heavy page lock workloads.

Hello Michal,

I measured 'cache cold parallel kbuild' on my qemu machine. The result
varies much so I cannot confirm, but I think there's no meaningful
difference between before and after applying crossrelease to page locks.

Actually, I expect little overhead in lock_page() and unlock_page() even
after applying crossreleas to page locks, but only expect a bit overhead
by additional memory consumption for 'lockdep_map's per page.

I run the following instructions within "QEMU x86_64 4GB memory 4 cpus":

   make clean
   echo 3 > drop_caches
   time make -j4

The results are:

   # w/o page lock tracking

   At the 1st try,
   real     5m28.105s
   user     17m52.716s
   sys      3m8.871s

   At the 2nd try,
   real     5m27.023s
   user     17m50.134s
   sys      3m9.289s

   At the 3rd try,
   real     5m22.837s
   user     17m34.514s
   sys      3m8.097s

   # w/ page lock tracking

   At the 1st try,
   real     5m18.158s
   user     17m18.200s
   sys      3m8.639s

   At the 2nd try,
   real     5m19.329s
   user     17m19.982s
   sys      3m8.345s

   At the 3rd try,
   real     5m19.626s
   user     17m21.363s
   sys      3m9.869s

I think thers's no meaningful difference on my small machine.

--
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
