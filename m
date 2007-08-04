Date: Sat, 4 Aug 2007 00:44:40 -0700 (PDT)
From: david@lang.hm
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <20070804070737.GA940@elte.hu>
Message-ID: <Pine.LNX.4.64.0708040032570.6905@asgard.lang.hm>
References: <20070803123712.987126000@chello.nl>
 <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
 <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2007, Ingo Molnar wrote:

> * Ingo Molnar <mingo@elte.hu> wrote:
>
>> There are positive reports in the never-ending "my system crawls like
>> an XT when copying large files" bugzilla entry:
>>
>>  http://bugzilla.kernel.org/show_bug.cgi?id=7372
>
> i forgot this entry:
>
> " We recently upgraded our office to gigabit Ethernet and got some big
>   AMD64 / 3ware boxes for file and vmware servers... only to find them
>   almost useless under any kind of real load. I've built some patched
>   2.6.21.6 kernels (using the bdi throttling patch you mentioned) to
>   see if our various Debian Etch boxes run better. So far my testing
>   shows a *great* improvement over the stock Debian 2.6.18 kernel on
>   our configurations. "
>
> and bdi has been in -mm in the past i think, so we also know (to a
> certain degree) that it does not hurt those workloads that are fine
> either.
>
> [ my personal interest in this is the following regression: every time i
>  start a large kernel build with DEBUG_INFO on a quad-core 4GB RAM box,
>  i get up to 30 seconds complete pauses in Vim (and most other tasks),
>  during plain editing of the source code. (which happens when Vim tries
>  to write() to its swap/undo-file.) ]

I have an issue that sounds like it's related.

I've got a syslog server that's got two Opteron 246 cpu's, 16G ram, 2x140G 
15k rpm drives (fusion MPT hardware mirroring), 16x500G 7200rpm SATA 
drives on 3ware 9500 cards (software raid6) running 2.6.20.3 with hz set 
at default and preempt turned off.

I have syslog doing buffered writes to the SCSI drives and every 5 min a 
cron job copies the data to the raid array.

I've found that if I do anything significant on the large raid array that 
the system looses a significant amount of the UDP syslog traffic, even 
though there should be pleanty of ram and cpu (and the spindles involved 
in the writes are not being touched), even a grep can cause up to 40% 
losses in the syslog traffic. I've experimented with nice levels (nicing 
down the grep and nicing up the syslogd) without a noticable effect on the 
losses.

I've been planning to try a new kernel with hz=1000 to see if that would 
help, and after that experiment with the various preempt settings, but it 
sounds like the per-device queues may actually be more relavent to the 
problem.

what would you suggest I test, and in what order and combination?

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
