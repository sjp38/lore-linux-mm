Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id BEB136B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:17:08 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id f198so140899385wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:17:08 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id r84si17852345wma.59.2016.04.11.04.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:17:07 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id v188so81789467wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:17:07 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:17:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/31] huge tmpfs: huge=N mount option and
 /proc/sys/vm/shmem_huge
Message-ID: <20160411111705.GE22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051413580.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051413580.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 02:15:05PM -0700, Hugh Dickins wrote:
> Plumb in a new "huge=1" or "huge=0" mount option to tmpfs: I don't
> want to get into a maze of boot options, madvises and fadvises at
> this stage, nor extend the use of the existing THP tuning to tmpfs;
> though either might be pursued later on.  We just want a way to ask
> a tmpfs filesystem to favor huge pages, and a way to turn that off
> again when it doesn't work out so well.  Default of course is off.
> 
> "mount -o remount,huge=N /mountpoint" works fine after mount:
> remounting from huge=1 (on) to huge=0 (off) will not attempt to
> break up huge pages at all, just stop more from being allocated.
> 
> It's possible that we shall allow more values for the option later,
> to select different strategies (e.g. how hard to try when allocating
> huge pages, or when to map hugely and when not, or how sparse a huge
> page should be before it is split up), either for experiments, or well
> baked in: so use an unsigned char in the superblock rather than a bool.

Make the value a string from beginning would be better choice in my
opinion. As more allocation policies would be implemented, number would
not make much sense.

For record, my implementation has four allocation policies: never, always,
within_size and advise.

> 
> No new config option: put this under CONFIG_TRANSPARENT_HUGEPAGE,
> which is the appropriate option to protect those who don't want
> the new bloat, and with which we shall share some pmd code.  Use a
> "name=numeric_value" format like most other tmpfs options.  Prohibit
> the option when !CONFIG_TRANSPARENT_HUGEPAGE, just as mpol is invalid
> without CONFIG_NUMA (was hidden in mpol_parse_str(): make it explicit).
> Allow setting >0 only if the machine has_transparent_hugepage().
> 
> But what about Shmem with no user-visible mount?  SysV SHM, memfds,
> shared anonymous mmaps (of /dev/zero or MAP_ANONYMOUS), GPU drivers'
> DRM objects, ashmem.  Though unlikely to suit all usages, provide
> sysctl /proc/sys/vm/shmem_huge to experiment with huge on those.  We
> may add a memfd_create flag and a per-file huge/non-huge fcntl later.

I use sysfs knob instead:

/sys/kernel/mm/transparent_hugepage/shmem_enabled

And string values there as well. It's better match current THP interface.

> And allow shmem_huge two further values: -1 for use in emergencies,
> to force the huge option off from all mounts; and (currently) 2,
> to force the huge option on for all - very useful for testing.

In my case, it's "deny" and "force".

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
