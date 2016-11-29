Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A68886B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 18:01:39 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j65so319796500iof.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 15:01:39 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id k204si45646240iok.169.2016.11.29.15.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Nov 2016 15:01:39 -0800 (PST)
Date: Tue, 29 Nov 2016 15:01:35 -0800
From: Marc MERLIN <marc@merlins.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of RAM that should be free
Message-ID: <20161129230135.GM7179@merlins.org>
References: <20161122160629.uzt2u6m75ash4ved@merlins.org> <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com> <20161123063410.GB2864@dhcp22.suse.cz> <20161128072315.GC14788@dhcp22.suse.cz> <20161129155537.f6qgnfmnoljwnx6j@merlins.org> <20161129160751.GC9796@dhcp22.suse.cz> <20161129163406.treuewaqgt4fy4kh@merlins.org> <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com> <20161129174019.fywddwo5h4pyix7r@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129174019.fywddwo5h4pyix7r@merlins.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 29, 2016 at 09:40:19AM -0800, Marc MERLIN wrote:
> Thanks for the reply and suggestions.
> 
> On Tue, Nov 29, 2016 at 09:07:03AM -0800, Linus Torvalds wrote:
> > On Tue, Nov 29, 2016 at 8:34 AM, Marc MERLIN <marc@merlins.org> wrote:
> > > Now, to be fair, this is not a new problem, it's just varying degrees of
> > > bad and usually only happens when I do a lot of I/O with btrfs.
> > 
> > One situation where I've seen something like this happen is
> > 
> >  (a) lots and lots of dirty data queued up
> >  (b) horribly slow storage
> 
> In my case, it is a 5x 4TB HDD with 
> software raid 5 < bcache < dmcrypt < btrfs
> bcache is currently half disabled (as in I removed the actual cache) or
> too many bcache requests pile up, and the kernel dies when too many
> workqueues have piled up.
> I'm just kind of worried that since I'm going through 4 subsystems
> before my data can hit disk, that's a lot of memory allocations and
> places where data can accumulate and cause bottlenecks if the next
> subsystem isn't as fast.
> 
> But this shouldn't be "horribly slow", should it? (it does copy a few
> terabytes per day, not fast, but not horrible, about 30MB/s or so)
> 
> > Sadly, our defaults for "how much dirty data do we allow" are somewhat
> > buggered. The global defaults are in "percent of memory", and are
> > generally _much_ too high for big-memory machines:
> > 
> >     [torvalds@i7 linux]$ cat /proc/sys/vm/dirty_ratio
> >     20
> >     [torvalds@i7 linux]$ cat /proc/sys/vm/dirty_background_ratio
> >     10
> 
> I can confirm I have the same.
> 
> > says that it only starts really throttling writes when you hit 20% of
> > all memory used. You don't say how much memory you have in that
> > machine, but if it's the same one you talked about earlier, it was
> > 24GB. So you can have 4GB of dirty data waiting to be flushed out.
> 
> Correct, 24GB and 4GB.
> 
> > And we *try* to do this per-device backing-dev congestion thing to
> > make things work better, but it generally seems to not work very well.
> > Possibly because of inconsistent write speeds (ie _sometimes_ the SSD
> > does really well, and we want to open up, and then it shuts down).
> > 
> > One thing you can try is to just make the global limits much lower. As in
> > 
> >    echo 2 > /proc/sys/vm/dirty_ratio
> >    echo 1 > /proc/sys/vm/dirty_background_ratio
> 
> I will give that a shot, thank you.

And, after 5H of copying, not a single hang, or USB disconnect, or anything.
Obviously this seems to point to other problems in the code, and I have no
idea which layer is a culprit here, but reducing the buffers absolutely
helped a lot.

Thanks much,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
