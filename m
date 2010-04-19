Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A07476B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 14:14:34 -0400 (EDT)
Date: Mon, 19 Apr 2010 19:14:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: error at compaction  (Re: mmotm 2010-04-15-14-42 uploaded
Message-ID: <20100419181442.GA19264@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org> <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 19, 2010 at 07:01:33PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> mmotm 2010-04-15-14-42 
> 
> When I tried 
>  # echo 0 > /proc/sys/vm/compaction
> 
> I see following.
> 
> My enviroment was 
>   2.6.34-rc4-mm1+ (2010-04-15-14-42) (x86-64) CPUx8
>   allocating tons of hugepages and reduce free memory.
> 
> What I did was:
>   # echo 0 > /proc/sys/vm/compact_memory
> 
> Hmm, I see this kind of error at migation for the 1st time..
> my.config is attached. Hmm... ?
> 
> (I'm sorry I'll be offline soon.)

That's ok, thanks you for the report. I'm afraid I made little progress
as I spent most of the day on other bugs but I do have something for
you.

First, I reproduced the problem using your .config. However, the problem does
not manifest with the .config I normally use which is derived from the distro
kernel configuration (Debian Lenny). So, there is something in your .config
that triggers the problem. I very strongly suspect this is an interaction
between migration, compaction and page allocation debug. Compaction takes
pages directly off the buddy list and I bet you a shiny penny they are still
unmapped when the copy takes place resulting in your oops.

I'll verify the theory tomorrow but it's a plausible explanation. On a
different note, where did config options like the following come out of?

CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11" 

I don't think they are a factor but I'm curious.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
