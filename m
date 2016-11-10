Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06E0B280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:36:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so12127948wmu.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:36:13 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id m187si1814076wmf.112.2016.11.10.08.36.12
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 08:36:12 -0800 (PST)
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <alpine.DEB.2.20.1611092227200.3501@nanos>
 <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
 <alpine.DEB.2.20.1611100959040.3501@nanos>
 <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
From: Matt Redfearn <matt.redfearn@imgtec.com>
Message-ID: <db056fb5-82b3-c17e-46ce-263872ef7334@imgtec.com>
Date: Thu, 10 Nov 2016 16:36:10 +0000
MIME-Version: 1.0
In-Reply-To: <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

Hi Jason,


On 10/11/16 11:41, Jason A. Donenfeld wrote:
> On Thu, Nov 10, 2016 at 10:03 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> If you want to go with that config, then you need
>> local_bh_disable()/enable() to fend softirqs off, which disables also
>> preemption.
> Thanks. Indeed this is what I want.
>
>>> What clever tricks do I have at my disposal, then?
>> Make MIPS use interrupt stacks.
> Yea, maybe I'll just implement this. It clearly is the most correct solution.
> @MIPS maintainers: would you merge something like this if done well?
> Are there reasons other than man-power why it isn't currently that
> way?

I don't see a reason not to do this - I'm taking a look into it.

Thanks,
Matt

>> Does the slowdown come from the kmalloc overhead or mostly from the less
>> efficient code?
>>
>> If it's mainly kmalloc, then you can preallocate the buffer once for the
>> kthread you're running in and be done with it. If it's the code, then bad
>> luck.
> I fear both. GCC can optimize stack variables in ways that it cannot
> optimize various memory reads and writes.
>
> Strangely, the solution that appeals to me most at the moment is to
> kmalloc (or vmalloc?) a new stack, copy over thread_info, and fiddle
> with the stack registers. I don't see any APIs, however, for a
> platform independent way of doing this. And maybe this is a horrible
> idea. But at least it'd allow me to keep my stack-based code the
> same...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
