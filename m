Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 538DD6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 05:55:11 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w62so2017047wes.29
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 02:55:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wx10si9662400wjc.17.2014.02.03.02.55.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 02:55:09 -0800 (PST)
Date: Mon, 3 Feb 2014 11:55:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: That greedy Linux VM cache
Message-ID: <20140203105508.GB2495@dhcp22.suse.cz>
References: <CA+sTkh4fYZr-8vBuhA0c1BRt5D7oNiK=KrSF+kJ2KRW7e_LFaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+sTkh4fYZr-8vBuhA0c1BRt5D7oNiK=KrSF+kJ2KRW7e_LFaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Podlesny <for.poige+linux@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[Adding linux-mm to the CC]

On Fri 31-01-14 00:58:16, Igor Podlesny wrote:
>    Hello!
> 
>    Probably every Linux newcomer's going to have concerns regarding
> low free memory and hear an explanation from Linux old fellows that's
> actually there's plenty of -- it's just cached, but when it's needed
> for applications it's gonna be used -- on demand. I also thought so
> until recently I noticed that even when free memory's is almost
> exhausted (~ 75 Mib), and processes are in sleep_on_page_killable, the

This means that the page has to be written back in order to be dropped.
How much dirty memory you have (comparing to the total size of the page
cache)?
What does your /proc/sys/vm/dirty_ratio say?
How fast is your storage?

Also, is this 32b or 64b system?

> cache is somewhat like ~ 500 MiB and it's not going to return back
> what it's gained. Naturally, vm.drop_caches 3 doesn't squeeze it as
> well. That drama has been happening on rather
> outdated-but-yet-still-has-2GiB-of-RAM notebook with kernel from 3.10
> till 3.12.9 (3.13 is the first release for a long time which simply
> freezes the notebook so cold, that SysRq_B's not working, but that's
> another story). Everything RAM demanding just yet crawls, load average
> is getting higher and there's no paging out, but on going disk mostly
> _read_ and a bit write activity. If vm.swaPPineSS not 0, it's swapping
> out, but not much, right now I ran Chromium (in addition to long-run
> Firefox) and only 32 MiB went to swap, load avg. ~ 7
> 
>    Again: 25 % is told (by top, free and finally /proc/meminfo) to be
> cached, but kinda greedy.
> 
>    I came across similar issue report:
> http://www.spinics.net/lists/linux-btrfs/msg11723.html but still
> questions remain:
> 
>    * How to analyze it? slabtop doesn't mention even 100 MiB of slab

snapshoting /proc/meminfo and /proc/vmstat every second or two while
your load is bad might tell us more. 

>    * Why that's possible?

That is hard to tell withou some numbers. But it might be possible that
you are seeing the same issue as reported and fixed here: 
http://marc.info/?l=linux-kernel&m=139060103406327&w=2

Especially when you are using tmpfs (e.g. as a backing storage for /tmp)

>    * The system is on Btrfs but /home is on XFS, so disk I/O might be
> related to text segment paging? But anyway this leads us to question,
> hey, there's 500 MiB free^Wcached.
> 
>    While I'm thinking about moving system back to XFS...
> 
>    P. S. While writing these, swapped ~ 100 MiB, and cache reduced(!)
> to 377 MiB, Firefox is mostly in "D" -- sleep_on_page_killable, so is
> Chrome, load avg. ~ 7. I had to close Skype to be able to finish that
> letter, and cached mem. now is 439 MiB. :) I know it's time to
> upgrade, but hey, cached memory is free memory, right?
> 
> -- 
> End of message. Next message?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
