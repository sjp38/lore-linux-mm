Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id E20B36B0036
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 03:01:27 -0500 (EST)
Received: by mail-ve0-f179.google.com with SMTP id jw12so961685veb.24
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 00:01:27 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id n7si105442qac.85.2014.01.08.00.01.25
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 00:01:27 -0800 (PST)
Date: Tue, 7 Jan 2014 00:10:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [numa shrinker] 9b17c62382: -36.6% regression on sparse file copy
Message-ID: <20140106131042.GA5145@destitution>
References: <20140106082048.GA567@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106082048.GA567@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, lkp@linux.intel.com

On Mon, Jan 06, 2014 at 04:20:48PM +0800, fengguang.wu@intel.com wrote:
> Hi Dave,
> 
> We noticed throughput drop in test case
> 
>         vm-scalability/300s-lru-file-readtwice (*)
> 
> between v3.11 and v3.12, and it's still low as of v3.13-rc6:
> 
>           v3.11                      v3.12                  v3.13-rc6
> ---------------  -------------------------  -------------------------
>   14934707 ~ 0%     -48.8%    7647311 ~ 0%     -47.6%    7829487 ~ 0%  vm-scalability.throughput
>              ^^     ^^^^^^
>         stddev%    change%

What does this vm-scalability.throughput number mean?

> (*) The test case basically does
> 
>         truncate -s 135080058880 /tmp/vm-scalability.img
>         mkfs.xfs -q /tmp/vm-scalability.img
>         mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability 
> 
>         nr_cpu=120
>         for i in $(seq 1 $nr_cpu)
>         do     
>                 sparse_file=/tmp/vm-scalability/sparse-lru-file-readtwice-$i
>                 truncate $sparse_file -s 36650387592
>                 dd if=$sparse_file of=/dev/null &
>                 dd if=$sparse_file of=/dev/null &
>         done

So a page cache load of reading 120x36GB files twice concurrently?
There's no increase in system time, so it can't be that the
shrinkers are running wild.

FWIW, I'm at LCA right now, so it's going to be a week before I can
look at this, so if you can find any behavioural difference in the
shrinkers (e.g. from perf profiles, on different filesystems, etc)
I'd appreciate it...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
