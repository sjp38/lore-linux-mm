Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id E6A536B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 19:32:35 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md12so4760573pbc.2
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 16:32:35 -0700 (PDT)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id ei3si5398912pbc.350.2013.10.25.16.32.34
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 16:32:35 -0700 (PDT)
Date: Sat, 26 Oct 2013 00:32:25 +0100
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131025233225.GA32051@localhost>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
 <154617470.12445.1382725583671.JavaMail.mail@webmail11>
 <1999200.Zdacx0scmY@diego-arch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1999200.Zdacx0scmY@diego-arch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Diego Calleja <diegocg@gmail.com>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, david@lang.hm, neilb@suse.de, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

On Fri, Oct 25, 2013 at 09:40:13PM +0200, Diego Calleja wrote:
> El Viernes, 25 de octubre de 2013 18:26:23 Artem S. Tashkinov escribiA3:
> > Oct 25, 2013 05:26:45 PM, david wrote:
> > >actually, I think the problem is more the impact of the huge write later
> > >on.
> > Exactly. And not being able to use applications which show you IO
> > performance like Midnight Commander. You might prefer to use "cp -a" but I
> > cannot imagine my life without being able to see the progress of a copying
> > operation. With the current dirty cache there's no way to understand how
> > you storage media actually behaves.
> 
> 
> This is a problem I also have been suffering for a long time. It's not so much 
> how much and when the systems syncs dirty data, but how unreponsive the 
> desktop becomes when it happens (usually, with rsync + large files). Most 
> programs become completely unreponsive, specially if they have a large memory 
> consumption (ie. the browser). I need to pause rsync and wait until the 
> systems writes out all dirty data if I want to do simple things like scrolling 
> or do any action that uses I/O, otherwise I need to wait minutes.

That's a problem. And it's kind of independent of the dirty threshold
-- if you are doing large file copies in the background, it will lead
to continuous disk writes and stalls anyway -- the large dirty threshold
merely delays the write IO time.

> I have 16 GB of RAM and excluding the browser (which usually uses about half 
> of a GB) and KDE itself, there are no memory hogs, so it seem like it's 
> something that shouldn't happen. I can understand that I/O operations are 
> laggy when there is some other intensive I/O ongoing, but right now the system 
> becomes completely unreponsive. If I am unlucky and Konsole also becomes 
> unreponsive, I need to switch to a VT (which also takes time).
> 
> I haven't reported it before in part because I didn't know how to do it, "my 
> browser stalls" is not a very useful description and I didn't know what kind 
> of data I'm supposed to report.

What's the kernel you are running? And it's writing to a hard disk?
The stalls are most likely caused by either one of

1) write IO starves read IO
2) direct page reclaim blocked when
   - trying to writeout PG_dirty pages
   - trying to lock PG_writeback pages

Which may be confirmed by running

        ps -eo ppid,pid,user,stat,pcpu,comm,wchan:32
or
        echo w > /proc/sysrq-trigger    # and check dmesg

during the stalls. The latter command works more reliably.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
