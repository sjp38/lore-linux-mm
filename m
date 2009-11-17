Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F21A6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 07:51:20 -0500 (EST)
Received: by pwi9 with SMTP id 9so4695147pwi.6
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 04:51:18 -0800 (PST)
Message-ID: <4B029C40.2020803@gmail.com>
Date: Tue, 17 Nov 2009 21:51:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
References: <20091117161711.3DDA.A69D9226@jp.fujitsu.com> <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk> <20091117200618.3DFF.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091117200618.3DFF.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Sorry for the noise. 
While I am typing, my mail client already send the mail. :(.
This is genuine.

KOSAKI Motohiro wrote:
>> On Tue, 17 Nov 2009 16:17:50 +0900 (JST)
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>>> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
>>> memory, anyone must not prevent it. Otherwise the system cause
>>> mysterious hang-up and/or OOM Killer invokation.
>> So now what happens if we are paging and all our memory is tied up for
>> writeback to a device or CIFS etc which can no longer allocate the memory
>> to complete the write out so the MM can reclaim ?
> 
> Probably my answer is not so simple. sorry.
> 
> reason1: MM reclaim does both dropping clean memory and writing out dirty pages.

Who write out dirty pages?
If block driver can't allocate pages for flushing, It means VM can't reclaim
dirty pages after all.

> reason2: if all memory is exhausted, maybe we can't recover it. it is
> fundamental limitation of Virtual Memory subsystem. and, min-watermark is
> decided by number of system physcal memory, but # of I/O issue (i.e. # of
> pages of used by writeback thread) is mainly decided # of devices. 
> then, we can't gurantee min-watermark is sufficient on any systems.
> Only reasonable solution is mempool like reservation, I think.

I think it's because mempool reserves memory. 
(# of I/O issue\0 is hard to be expected.
How do we determine mempool size of each block driver?
For example,  maybe, server use few I/O for nand. 
but embedded system uses a lot of I/O. 

We need another knob for each block driver?

I understand your point. but it's not simple. 
I think, for making sure VM's pages, block driver need to distinguish 
normal flush path and flush patch for reclaiming. 
So In case of flushing for reclaiming, block driver have to set PF_MEMALLOC. 
otherwise, it shouldn't set PF_MEMALLOC.


> IOW, any reservation memory shouldn't share unrelated subsystem. otherwise
> we lost any gurantee.
> 
> So, I think we need to hear why many developer don't use mempool,
> instead use PF_MEMALLOC.
> 
>> Am I missing something or is this patch set not addressing the case where
>> the writeback thread needs to inherit PF_MEMALLOC somehow (at least for
>> the I/O in question and those blocking it)
> 
> Yes, probably my patchset isn't perfect. honestly I haven't understand
> why so many developer prefer to use PF_MEMALLOC.
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
