Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 262ED6B0292
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 12:32:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b11so20120929wmh.0
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 09:32:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w28si11971043wra.157.2017.07.03.09.32.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 09:32:07 -0700 (PDT)
Date: Mon, 3 Jul 2017 18:32:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
Message-ID: <20170703163204.GE11848@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1706291803380.1861@nanos>
 <20170630092747.GD22917@dhcp22.suse.cz>
 <alpine.DEB.2.20.1706301210210.1748@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706301210210.1748@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri 30-06-17 12:15:21, Thomas Gleixner wrote:
[...]
> Sure. Just to make you to mull over more stuff, find below the patch which
> moves all of this to use the cpuhotplug lock.
> 
> Thanks,
> 
> 	tglx
> 
> 8<--------------------
> Subject: mm/memory-hotplug: Use cpu hotplug lock
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Thu, 29 Jun 2017 16:30:00 +0200
> 
> Most place which take the memory hotplug lock take the cpu hotplug lock as
> well. Avoid the double locking and use the cpu hotplug lock for both.

Hmm, I am usually not a fan of locks conflating because it is then less
clear what the lock actually protects. Memory and cpu hotplugs should
be largely independent so I am not sure this patch simplify things a
lot. It is nice to see few lines go away but I am little bit worried
that we will enventually develop a separate locking again in future for
some weird memory hotplug usecases.
 
> Not-Yet-Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[...]
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
[...]
> @@ -2138,7 +2114,7 @@ void __ref remove_memory(int nid, u64 st
>  
>  	try_offline_node(nid);
>  
> -	mem_hotplug_done();
> +	cpus_write_lock();

unlock you meant here, right?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
