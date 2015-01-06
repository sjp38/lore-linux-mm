Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6306B00CF
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 10:03:06 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so30564439pdb.32
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 07:03:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id oc3si70807748pbb.130.2015.01.06.07.03.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 07:03:03 -0800 (PST)
Date: Tue, 6 Jan 2015 10:02:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Dirty pages underflow on 3.14.23
Message-ID: <20150106150250.GA26895@phnom.home.cmpxchg.org>
References: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 05, 2015 at 06:05:59PM -0500, Mikulas Patocka wrote:
> Hi
> 
> I would like to report a memory management bug where the dirty pages count 
> underflowed.
> 
> It happened after some time that the Dirty pages count underflowed, as can 
> be seen in /proc/meminfo. The underflow condition was persistent, 
> /proc/meminfo was showing the big value even when the system was 
> completely idle. The counter never returned to zero.
> 
> The system didn't crash, but it became very slow - because of the big 
> value in the "Dirty" field, lazy writing was not working anymore, any 
> process that created a dirty page triggered immediate writeback, which 
> slowed down the system very much. The only fix was to reboot the machine.
> 
> The kernel version where this happened is 3.14.23. The kernel is compiled 
> without SMP and with peemption. The system is single-core 32-bit x86.
> 
> The bug probably happened during git pull or apt-get update, though one 
> can't be sure that these commands caused it.
> 
> I see that 3.14.24 containes some fix for underflow (commit 
> 6619741f17f541113a02c30f22a9ca22e32c9546, upstream commit 
> abe5f972912d086c080be4bde67750630b6fb38b), but it doesn't seem that that 
> commit fixes this condition. If you have a commit that could fix this, say 
> it.

That's an unrelated counter, but there is a known dirty underflow
problem that was addressed in 87a7e00b206a ("mm: protect
set_page_dirty() from ongoing truncation").  It should make it into
the stable kernels in the near future.  Can you reproduce this issue?

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
