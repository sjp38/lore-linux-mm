Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C6F886B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 01:28:06 -0500 (EST)
Date: Wed, 3 Feb 2010 14:27:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] [RFC] 512K readahead size with thrashing safe
	readahead
Message-ID: <20100203062756.GB22890@localhost>
References: <20100202152835.683907822@intel.com> <20100202223803.GF3922@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202223803.GF3922@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Vivek,

On Wed, Feb 03, 2010 at 06:38:03AM +0800, Vivek Goyal wrote:
> On Tue, Feb 02, 2010 at 11:28:35PM +0800, Wu Fengguang wrote:
> > Andrew,
> > 
> > This is to lift default readahead size to 512KB, which I believe yields
> > more I/O throughput without noticeably increasing I/O latency for today's HDD.
> > 
> 
> Hi Fengguang,
> 
> I was doing a quick test with the patches. I was using fio to run some
> sequential reader threads. I have got one access to one Lun from an HP
> EVA. In my case it looks like with the patches throughput has come down.

Thank you for the quick testing!

This patchset does 3 things:

1) 512K readahead size
2) new readahead algorithms
3) new readahead tracing/stats interfaces

(1) will impact performance, while (2) _might_ impact performance in
case of bugs.

Would you kindly retest the patchset with readahead size manually set
to 128KB?  That would help identify the root cause of the performance
drop:

        DEV=sda
        echo 128 > /sys/block/$DEV/queue/read_ahead_kb

The readahead stats provided by the patchset are very useful for
analyzing the problem:

        mount -t debugfs none /debug
        
        # for each benchmark:
                echo > /debug/readahead/stats  # reset counters
                # do benchmark
                cat /debug/readahead/stats     # check counters

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
