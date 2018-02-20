Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9626B0009
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:19:02 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id v123so555422lfa.4
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 07:19:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l34sor456334lfi.44.2018.02.20.07.19.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 07:19:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180220133725.GC21243@bombadil.infradead.org>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
 <201802201156.4Z60eDwx%fengguang.wu@intel.com> <CAFqt6zagwbvs06yK6KPp1TE5Z-mXzv6Bh2rhFFAyjz3Nh0BXmA@mail.gmail.com>
 <20180220090820.GA153760@rodete-desktop-imager.corp.google.com>
 <CAFqt6zZeiU9uMq0kNJRBs_aBTmHvZZkaotJ6GnVOjT6Y3nyS9g@mail.gmail.com>
 <20180220125246.GB21243@bombadil.infradead.org> <20180220133725.GC21243@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 20 Feb 2018 20:48:58 +0530
Message-ID: <CAFqt6zYab6Spqf16ssAvEVrsGt4X2jkys85G8u-Aqgxa5_qpmw@mail.gmail.com>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, kbuild test robot <lkp@intel.com>, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

Hi Matthew,

On Tue, Feb 20, 2018 at 7:07 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Feb 20, 2018 at 04:52:46AM -0800, Matthew Wilcox wrote:
>> On Tue, Feb 20, 2018 at 04:25:15PM +0530, Souptick Joarder wrote:
>> > On Tue, Feb 20, 2018 at 2:38 PM, Minchan Kim <minchan@kernel.org> wrote:
>> > > Yub, bool could be more appropriate. However, there are lots of other places
>> > > in kernel where use int instead of bool.
>> > > If we fix every such places with each patch, it would be very painful.
>> > > If you believe it's really worth, it would be better to find/fix every
>> > > such places in one patch. But I'm not sure it's worth.
>> > >
>> >
>> > Sure, I will create patch series and send it.
>>
>> Please don't.  If you're touching a function for another reason, it's
>> fine to convert it to return bool.  A series of patches converting every
>> function in the kernel that could be converted will not make friends.
>
> ... but if you're looking for something to do, here's something from my
> TODO list that's in the same category.

Thanks. I would like to take it.
>
> The vm_ops fault, huge_fault, page_mkwrite and pfn_mkwrite handlers are
> currently defined to return an int (see linux/mm.h).  Unlike the majority
> of functions which return int, these functions are supposed to return
> one or more of the VM_FAULT flags.  There's general agreement that this
> should become a new typedef, vm_fault_t.  We can do a gradual conversion;
> start off by adding
>
> typedef int vm_fault_t;
>
> to linux/mm.h.  Then the individual drivers can be converted (one patch
> per driver) to return vm_fault_t from those handlers (probably about
> 180 patches, so take it slowly).  Once all drivers are converted, we
> can change that typedef to:
>
> typedef enum {
>         VM_FAULT_OOM    = 1,
>         VM_FAULT_SIGBUS = 2,
>         VM_FAULT_MAJOR  = 4,
> ...
> } vm_fault_t;
>
> and then the compiler will warn if anyone tries to introduce a new handler
> that returns int.
>

Let me go through the shared details and will reply you back
before making any changes.

-Souptick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
