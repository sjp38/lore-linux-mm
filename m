Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D93F6B0069
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:43:19 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q83so147829750iod.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 10:43:19 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0157.hostedemail.com. [216.40.44.157])
        by mx.google.com with ESMTPS id n70si5826035ith.121.2016.08.19.10.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 10:43:18 -0700 (PDT)
Message-ID: <1471628595.3893.23.camel@perches.com>
Subject: Re: [PATCH 0/2] fs, proc: optimize smaps output formatting
From: Joe Perches <joe@perches.com>
Date: Fri, 19 Aug 2016 10:43:15 -0700
In-Reply-To: <1471601580-17999-1-git-send-email-mhocko@kernel.org>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
	 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 2016-08-19 at 12:12 +0200, Michal Hocko wrote:
> Hi,
> this is rebased on top of next-20160818. Joe has pointed out that
> meminfo is using a similar trick so I have extracted guts of what we
> have already and made it more generic to be usable for smaps as well
> (patch 1). The second patch then replaces seq_printf with seq_write
> and show_val_kb which should have smaller overhead and my measuring (in
> kvm) shows quite a nice improvements. I hope kvm is not playing tricks
> on me but I didn't get to test on a real HW.


Hi Michal.

A few comments:

For the first patch:

I think this isn't worth the expansion in object size (x86-64 defconfig)

$ size fs/proc/meminfo.o*
   text	   data	    bss	    dec	    hex	filename
   2698	      8	      0	   2706	    a92	fs/proc/meminfo.o.new
   2142	      8	      0	   2150	    866	fs/proc/meminfo.o.old

Creating a new static in task_mmu would be smaller and faster code.

There are only 3 other uses of %8lu in fs/proc/task_nommu.c and
those use bytes not kB.

There are a few other likely not performance sensitive similar
uses in <arch>/mm

$ git grep -E "seq_printf.*%8lu kB" arch
arch/x86/mm/pageattr.c:	seq_printf(m, "DirectMap4k:    %8lu kB\n",
arch/x86/mm/pageattr.c:	seq_printf(m, "DirectMap2M:    %8lu kB\n",
arch/x86/mm/pageattr.c:	seq_printf(m, "DirectMap4M:    %8lu kB\n",
arch/x86/mm/pageattr.c:		seq_printf(m, "DirectMap1G:    %8lu kB\n",
arch/s390/mm/pageattr.c:	seq_printf(m, "DirectMap4k:    %8lu kB\n",
arch/s390/mm/pageattr.c:	seq_printf(m, "DirectMap1M:    %8lu kB\n",
arch/s390/mm/pageattr.c:	seq_printf(m, "DirectMap2G:    %8lu kB\n",

For the second patch:

seq_show starts with a PAGE_SIZE buffer and if that buffer isn't
big enough, seq_show redoes the entire output done to that point
into a new buffer << 1 until the buffer is big enough to hold
the output.

So I expect this case of multiple pages / megabytes worth of smap
output (40MB in your pathological case) would be rather faster if
single_open_size was used appropriately for expected output size.

And this would definitely be faster if seq_has_overflowed() was
used somewhere in the iteration loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
