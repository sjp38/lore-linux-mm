Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F78A6B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 22:00:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so261206097pfe.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:00:35 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id t13si7023985pas.225.2016.04.16.19.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 19:00:34 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id e128so68735777pfe.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:00:34 -0700 (PDT)
Date: Sat, 16 Apr 2016 19:00:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 03/31] huge tmpfs: huge=N mount option and
 /proc/sys/vm/shmem_huge
In-Reply-To: <20160411111705.GE22996@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1604161849500.1896@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051413580.5965@eggly.anvils> <20160411111705.GE22996@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Apr 2016, Kirill A. Shutemov wrote:
> On Tue, Apr 05, 2016 at 02:15:05PM -0700, Hugh Dickins wrote:
> > Plumb in a new "huge=1" or "huge=0" mount option to tmpfs: I don't
> > want to get into a maze of boot options, madvises and fadvises at
> > this stage, nor extend the use of the existing THP tuning to tmpfs;
> > though either might be pursued later on.  We just want a way to ask
> > a tmpfs filesystem to favor huge pages, and a way to turn that off
> > again when it doesn't work out so well.  Default of course is off.
> > 
> > "mount -o remount,huge=N /mountpoint" works fine after mount:
> > remounting from huge=1 (on) to huge=0 (off) will not attempt to
> > break up huge pages at all, just stop more from being allocated.
> > 
> > It's possible that we shall allow more values for the option later,
> > to select different strategies (e.g. how hard to try when allocating
> > huge pages, or when to map hugely and when not, or how sparse a huge
> > page should be before it is split up), either for experiments, or well
> > baked in: so use an unsigned char in the superblock rather than a bool.
> 
> Make the value a string from beginning would be better choice in my
> opinion. As more allocation policies would be implemented, number would
> not make much sense.

I'll probably agree about the strings.  Though we have not in fact
devised any more allocation policies so far, and perhaps never will
at this mount level.

> 
> For record, my implementation has four allocation policies: never, always,
> within_size and advise.

I'm sceptical who will get into choosing "within_size".

> 
> > 
> > No new config option: put this under CONFIG_TRANSPARENT_HUGEPAGE,
> > which is the appropriate option to protect those who don't want
> > the new bloat, and with which we shall share some pmd code.  Use a
> > "name=numeric_value" format like most other tmpfs options.  Prohibit
> > the option when !CONFIG_TRANSPARENT_HUGEPAGE, just as mpol is invalid
> > without CONFIG_NUMA (was hidden in mpol_parse_str(): make it explicit).
> > Allow setting >0 only if the machine has_transparent_hugepage().
> > 
> > But what about Shmem with no user-visible mount?  SysV SHM, memfds,
> > shared anonymous mmaps (of /dev/zero or MAP_ANONYMOUS), GPU drivers'
> > DRM objects, ashmem.  Though unlikely to suit all usages, provide
> > sysctl /proc/sys/vm/shmem_huge to experiment with huge on those.  We
> > may add a memfd_create flag and a per-file huge/non-huge fcntl later.
> 
> I use sysfs knob instead:
> 
> /sys/kernel/mm/transparent_hugepage/shmem_enabled
> 
> And string values there as well. It's better match current THP interface.

It's certainly been easier for me, to get it up and running without
having to respect all the anon THP knobs.  But I do expect some
pressure to conform a bit more now.

Hugh

> 
> > And allow shmem_huge two further values: -1 for use in emergencies,
> > to force the huge option off from all mounts; and (currently) 2,
> > to force the huge option on for all - very useful for testing.
> 
> In my case, it's "deny" and "force".
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
