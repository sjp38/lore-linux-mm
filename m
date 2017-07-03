Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 616F16B0292
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 15:57:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so44009781wrf.5
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 12:57:26 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r13si2726950wmd.92.2017.07.03.12.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 12:57:23 -0700 (PDT)
Date: Mon, 3 Jul 2017 21:57:18 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
In-Reply-To: <20170703163204.GE11848@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1707032156320.2993@nanos>
References: <alpine.DEB.2.20.1706291803380.1861@nanos> <20170630092747.GD22917@dhcp22.suse.cz> <alpine.DEB.2.20.1706301210210.1748@nanos> <20170703163204.GE11848@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, 3 Jul 2017, Michal Hocko wrote:
> On Fri 30-06-17 12:15:21, Thomas Gleixner wrote:
> [...]
> > Sure. Just to make you to mull over more stuff, find below the patch which
> > moves all of this to use the cpuhotplug lock.
> > 
> > Thanks,
> > 
> > 	tglx
> > 
> > 8<--------------------
> > Subject: mm/memory-hotplug: Use cpu hotplug lock
> > From: Thomas Gleixner <tglx@linutronix.de>
> > Date: Thu, 29 Jun 2017 16:30:00 +0200
> > 
> > Most place which take the memory hotplug lock take the cpu hotplug lock as
> > well. Avoid the double locking and use the cpu hotplug lock for both.
> 
> Hmm, I am usually not a fan of locks conflating because it is then less
> clear what the lock actually protects. Memory and cpu hotplugs should
> be largely independent so I am not sure this patch simplify things a
> lot. It is nice to see few lines go away but I am little bit worried
> that we will enventually develop a separate locking again in future for
> some weird memory hotplug usecases.

Fair enough.

>  
> > Not-Yet-Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> [...]
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> [...]
> > @@ -2138,7 +2114,7 @@ void __ref remove_memory(int nid, u64 st
> >  
> >  	try_offline_node(nid);
> >  
> > -	mem_hotplug_done();
> > +	cpus_write_lock();
> 
> unlock you meant here, right?

Doh, -ENOQUILTREFRESH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
