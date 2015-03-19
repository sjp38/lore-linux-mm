Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E41FB6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:08:37 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so55665539pab.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:08:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ww5si1295646pab.117.2015.03.19.01.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 01:08:36 -0700 (PDT)
Date: Thu, 19 Mar 2015 11:08:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/3] idle memory tracking
Message-ID: <20150319080818.GD29416@esperanza>
References: <cover.1426706637.git.vdavydov@parallels.com>
 <20150319021337.GD9153@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150319021337.GD9153@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 19, 2015 at 11:13:37AM +0900, Minchan Kim wrote:
> On Wed, Mar 18, 2015 at 11:44:33PM +0300, Vladimir Davydov wrote:
> >  1. Write 1 to /proc/sys/vm/set_idle.
> > 
> >     This will set the IDLE flag for all user pages. The IDLE flag is cleared
> >     when the page is read or the ACCESS/YOUNG bit is cleared in any PTE pointing
> >     to the page. It is also cleared when the page is freed.
> 
> We should scan all of pages periodically? I understand why you did but
> someone might not take care of unmapped pages so I hope it should be optional.
> if someone just want to catch mapped file+anon pages, he can do it
> by scanning of address space of the process he selects.
> Even, someone might want to scan just part of address space rather than
> all address space of the process. Acutally, I have such scenario.

You still can estimate the working set size of a particular process, or
even by a part of its address space, by setting the IDLE bit for all
user pages, but clearing refs for and analyzing only those pages you are
interested in. You can filter them by scanning /proc/PID/pagemap.

If you are concerned about performance, I don't think it would be an
issue: on my test machine setting the IDLE bit for 20 GB of user pages
takes about 150 ms. Provided that this kind of work is supposed to be
done relatively rarely (every several minutes or so), the overhead looks
negligible to me. Anyway, we can introduce /proc/PID/set_mem_idle for
setting the IDLE bit only on pages of a particular address space.

> 
> > 
> >  2. Wait some time.
> > 
> >  3. Write 6 to /proc/PID/clear_refs for each PID of interest.
> > 
> >     This will clear the IDLE flag for recently accessed pages.
> > 
> >  4. Count the number of idle pages as reported by /proc/kpageflags. One may use
> >     /proc/PID/pagemap and/or /proc/kpagecgroup to filter pages that belong to a
> >     certain application/container.
> > 
> 
> Adding two new page flags? I don't know it's okay for 64bit but there is no
> room for 32bit. Please take care of 32 bit. It would be good feature for
> embedded. How about using page_ext if you couldn't make room for page->flags
> for 32bit? You would add per-page meta data in there.

For the time being, I made it dependant on 64BIT explicitly, because I
am only interested in analyzing working set size of containers running
on big machines, but I admit one could use page_ext for storing the
additional flags if compiled for 32 bit.

> 
> Your suggestion is generic so my concern is overhead. On every iteration,
> we should set/clear/investigate page flags. I don't know how much overhead
> is in there but it surely could be big if memory is big.
> Couldn't we do that at one go? Maybe, like mincore
> 
>         int idlecore(pid_t pid, void *addr, size_t length, unsigned char *vec)
> 
> So, we could know what pages of the process[pid] were idle by vec in
> [addr, lentgh] and reset idle of the pages for the process
> in the system call at one go.

I don't think adding yet another syscall for such a specialized feature
is a good idea. Besides, I want to keep the interface consistent with
/proc/PID/clear_refs, which IMO suits perfectly well for clearing the
IDLE flag on referenced pages. As I mentioned above, to reduce the
overhead in case the user is not interested in unmapped file pages, we
could introduce /proc/PID/set_mem_idle, though I think this only should
be done if there are complains about /proc/sys/vm/set_idle performance.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
