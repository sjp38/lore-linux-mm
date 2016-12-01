Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 232FC6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 08:50:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so351595100pfb.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:50:20 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id n28si262143pgd.148.2016.12.01.05.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 05:50:19 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 3so4720230pgd.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:50:19 -0800 (PST)
Date: Thu, 1 Dec 2016 04:50:14 -0900
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161201135014.jrr65ptxczplmdkn@kmo-pixel>
References: <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
 <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
 <20161130203011.GB15989@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130203011.GB15989@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Marc MERLIN <marc@merlins.org>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Wed, Nov 30, 2016 at 03:30:11PM -0500, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 30, 2016 at 10:14:50AM -0800, Linus Torvalds wrote:
> > Tejun/Kent - any way to just limit the workqueue depth for bcache?
> > Because that really isn't helping, and things *will* time out and
> > cause those problems when you have hundreds of IO's queued on a disk
> > that likely as a write iops around ~100..
> 
> Yeah, easily.  I'm assuming it's gonna be the bcache_wq allocated in
> from bcache_init().  It's currently using 0 as @max_active and it can
> set to be any arbitrary number.  It'd be a very crude way to control
> what looks like a buffer bloat with IOs tho.  We can make it a bit
> more granular by splitting workqueues per bcache instance / purpose
> but for the long term the right solution seems to be hooking into
> writeback throttling mechanism that block layer just grew recently.

Agreed that the writeback code is the right place to do it. Within bcache we
can't really do anything smarter than just throw a hard limit on the number of
outstanding IOs and enforce it by blocking in generic_make_request(), and the
bcache code is the wrong place to do that - we don't know what the limit should
be there, and all the IOs look the same at that point so you'd probably still
end up with writeback starving everything else.

I could futz with the workqueue stuff, but that'd likely as not break some other
workload - I've spent enough time as it is fighting with workqueue concurrency
stuff in the past. My preference would be to just try and get Jens's stuff in.

That said, I'm not sure how I feel about Jens's exact approach... it seems to me
that this can really just live within the writeback code, I don't know why it
should involve the block layer at all. plus, if I understand correctly his code
has the effect of blocking in generic_make_request() to throttle, which means
due to the way the writeback code is structured we'll be blocking with page
locks held. I did my own thing in bcachefs, same idea but throttling in
writepages... it's dumb and simple but it's worked exceedingly well, as far as
actual usability and responsiveness:

https://evilpiepirate.org/git/linux-bcache.git/tree/drivers/md/bcache/fs-io.c?h=bcache-dev&id=acf766b2dd33b076fdce66c86363a3e26a9b70cf#n1002

that said - any kind of throttling for writeback will be a million times better
than the current situation...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
