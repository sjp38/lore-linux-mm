Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id CF2806B0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 07:18:52 -0500 (EST)
Message-ID: <512F4B3E.6030409@parallels.com>
Date: Thu, 28 Feb 2013 16:19:10 +0400
From: "Maxim V. Patlasov" <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [ATTEND][LSF/MM TOPIC] FUSE: write-back cache policy and other
 improvements
References: <511BAC51.4030309@parallels.com>
In-Reply-To: <511BAC51.4030309@parallels.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org

Adding linux-mm to cc:. One more point to discuss:

* balance_dirty_pages(): should we account NR_WRITEBACK_TEMP there? 
Currently, any FUSE user may consume arbitrary amount of RAM (stuck in 
kernel FUSE writeback) by intensive write to a huge mmap-ed area.

02/13/2013 07:08 PM, Maxim V. Patlasov D?D,N?DuN?:
> Hi,
>
> I'm interested in attending to discuss the latest advances in 
> accelerating FUSE and making it more friendly to distributed 
> file-systems. I'd like to propose and participate in the following 
> discussions in the upcoming LSF/MM:
>
> * write-back cache policy: one of the problems with the existing FUSE 
> implementation is that it uses the write-through cache policy which 
> results in performance problems on certain workloads. A good solution 
> of this is switching the FUSE page cache into a write-back policy. 
> With this file data are pushed to the userspace with big chunks which 
> lets the FUSE daemons handle requests in a more efficient manner.
>
> * optimize scatter-gather direct IO: dio performance can be improved 
> significantly by stuffing many io-vectors  into a single fuse request. 
> This is especially the case for device virtualization thread 
> performing i/o on behalf of virtual-machine it serves.
>
> * process direct IO asynchronously: both AIO and ordinary synchronous 
> direct IO can be boosted by submitting fuse requests in non-blocking 
> way (where it's possible) and either returning -EIOCBQUEUED or waiting 
> for their completions synchronously.
>
> * synchronous close(2): currently, in-kernel fuse sends release 
> request to userspace and returns without waiting for ACK from 
> userspace. Consequently, there is a gap when user regards the file 
> released while userspace fuse is still working on it. This leads to 
> unnecessary synchronization complications for file-systems with shared 
> access. That behaviour can be fixed by making close(2) synchronous.
>
> * throttle request allocations: currently, in-kernel fuse throttles 
> allocations of all fuse requests. Switching to the policy where only 
> background requests are throttled would improve the latency of 
> synchronous requests and resolve thundering herd problem of waking up 
> all threads blocked on fuse request allocations.
>
> Thanks,
> Maxim
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
