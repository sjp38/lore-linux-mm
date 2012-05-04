Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 299936B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 03:39:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4423959pbb.14
        for <linux-mm@kvack.org>; Fri, 04 May 2012 00:39:38 -0700 (PDT)
Date: Fri, 4 May 2012 00:38:10 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
Message-ID: <20120504073810.GA25175@lizard>
References: <20120501132409.GA22894@lizard>
 <20120501132620.GC24226@lizard>
 <4FA35A85.4070804@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FA35A85.4070804@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, May 04, 2012 at 01:26:45PM +0900, Minchan Kim wrote:
[...]
> > be useful for different use cases.
> 
> Why should we do it in kernel side?

Because currently you can't do this in userland, see below. Today
this would be effectively the same as constantly reading /proc/vmstat,
which is surely not friendly performance/context switches/battery
wise.

> If vmevent will have VMEVENT_ATTR_[FILE|MOCK|DIRTY|WRITEBACK|SHMEM|ANON|SWAP]_PAGES
> and so on which is needed by calculation, we can calculate it in userspace without
> forking /proc/vmstat to see it. So I think there is no problem to do it in userspace.

There are two problems.

1. Originally, the idea behind vmevent was that we should not expose all
   these mm details in vmevent, because it ties ABI with Linux internal
   memory representation;

2. If you have say a boolean '(A + B + C + ...) > X' attribute (which is
   exactly what blended attributes are), you can't just set up independent
   thresholds on A, B, C, ... and have the same effect.

   (What we can do, though, is... introduce arithmetic operators in
   vmevent. :-D But then, at the end, we'll probably implement in-kernel
   forth-like stack machine, with vmevent_config array serving as a
   sequence of op-codes. ;-)

If we'll give up on "1." (Pekka, ping), then we need to solve "2."
in a sane way: we'll have to add a 'NR_FILE_PAGES - NR_SHMEM -
<todo-locked-file-pages>' attribute, and give it a name.

RECLAIMABLE_CACHE_PAGES maybe?

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
