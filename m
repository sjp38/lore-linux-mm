Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3F486B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:59:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l15so64921820lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:59:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 67si11148682wmd.22.2016.04.15.02.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:59:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so4743607wma.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:59:51 -0700 (PDT)
Date: Fri, 15 Apr 2016 11:59:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Terrible disk performance when files cached > 4GB
Message-ID: <20160415095950.GB32386@dhcp22.suse.cz>
References: <201604151020.33627.colum.paget@axiomgb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604151020.33627.colum.paget@axiomgb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colum Paget <colum.paget@axiomgb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 15-04-16 10:20:33, Colum Paget wrote:
> Hi all,
> 
> I suspect that many people will have reported this, but I thought I'd drop you 
> a line just in case everyone figures someone else has reported it. It's 
> possible we're just doing something wrong and so encountering this problem, 
> but I can't find anyone saying they've found a solution, and the problem 
> doesn't seem to be present in 3.x kernels, which makes us think it could be a 
> bug.
> 
> We are seeing a problem in 4.4.5 and 4.4.6 32-bit 'hugemem' kernels running on 
> machines with > 4GB ram.

I would generally discourage you from using much more than 4G on 32b
system. Lowmem mem pressure is a real problem which is inherent to the
highmem kernels.

> The problem results in disk performance dropping 
> from 120 MB/s to 1MB/s or even less. 3.18.x 32-bit kernels do not seem to 
> exhibit this behaviour, or at least we can't make it happen reliably. We've 
> tried 3.14.65 and 3.14.65 and they don't exhibit the same degree of problem.

I would expect this is due to dirty memory throttling. Highmem is not
considered dirtyable normally (see global_dirtyable_memory) and so all
the writers will get throttled earlier. Basically any change to how much
memory can be dirtied in in the lowmem will change the balance for you.

> We've not yet been able to test 64 bit kernels, it will be a while before we 
> can. We've been able to reproduce the problem on multiple machines with 
> different hardware configs, and with different kernel configs as regards 
> SMP , NUMA support and transparent hugepages.
> 
> This problem can be reproduced thusly:

Have you tried
echo 1 > /proc/sys/vm/highmem_is_dirtyable

Please note that this might help but it is a double edge sword because
it might cause pre mature OOM killers in certain loads. 32b is simply
not that great with a lot of memory.

HTH
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
