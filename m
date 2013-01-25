Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 38DA46B0008
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 19:15:57 -0500 (EST)
Date: Fri, 25 Jan 2013 11:15:27 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301250015.r0P0FR3t003475@como.maths.usyd.edu.au>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
In-Reply-To: <20130124151603.GD21818@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, jack@suse.cz
Cc: 695182@bugs.debian.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Jan,

> I think he found the culprit of the problem being min_free_kbytes was not
> properly reflected in the dirty throttling. ... Paul please correct me
> if I'm wrong.

Sorry but have to correct you.

I noticed and patched/corrected two problems, one with (setpoint-dirty)
in bdi_position_ratio(), another with min_free_kbytes not subtracted
from dirtyable memory. Fixing those problems, singly or in combination,
did not help in avoiding OOM: running
  n=0; while [ $n -lt 99 ]; do dd bs=1M count=1024 if=/dev/zero of=x$n; ((n=$n+1)); done
still produces an OOM after a few files written (on a PAE machine with
over 32GB RAM).

Also, a quite similar OOM may be produced on any PAE machine with
  n=0; while [ $n -lt 33000 ]; do sleep 600 & ((n=n+1)); done
This was tested on machines with as low as just 3GB RAM ... and
curiously the same machine with "plain" (not PAE but HIGHMEM4G)
kernel handles the same "sleep test" without any problems.

(Thus I now think that the remaining bug is not with writeback.)

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
