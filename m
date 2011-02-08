Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E2F398D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 13:17:13 -0500 (EST)
Date: Tue, 8 Feb 2011 19:17:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
Message-ID: <20110208181709.GL3347@random.random>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201153857.GA18740@random.random>
 <1296580547.27022.3370.camel@nimitz>
 <20110201203936.GB16981@random.random>
 <1296593801.27022.3920.camel@nimitz>
 <20110202000750.GC16981@random.random>
 <1297187674.6737.12145.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1297187674.6737.12145.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Tue, Feb 08, 2011 at 09:54:34AM -0800, Dave Hansen wrote:
> Just FYI, I did some profiling on a workload that constantly split and
> joined pages.  Very little of the overhead was in the scanning itself,
> so I think you're dead-on here.

Yep, my way to deduce it has been to set both to 100%, and check the
rate of increase of
/sys/kernel/mm/transparent_hugepage/khugepaged/full_scans vs
/sys/kernel/mm/ksm/full_scans and the differences is enormous. So a
100% CPU ksmd scan can probably be followed more than well with a 1%
CPU khugepaged scan and probably achieve the exact same hugepage ratio
of a 100% khugepaged scan. The default khugepaged scan is super
paranoid (it has to be, considering the default ksm scan is
zero). Maybe we can still increase the default pages_to_scan a bit. I
suspect most of the current cost should be in the scheduler and that
only accounts for 1 kthread schedule event every 10 sec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
