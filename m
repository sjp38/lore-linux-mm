Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 771316B0083
	for <linux-mm@kvack.org>; Wed,  9 May 2012 14:34:18 -0400 (EDT)
Received: by vbzb23 with SMTP id b23so813453vbz.11
        for <linux-mm@kvack.org>; Wed, 09 May 2012 11:34:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205091224460.11225@router.home>
References: <1336503339-18722-1-git-send-email-pshelar@nicira.com>
	<1336504276.3752.2600.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1205081417120.27713@router.home>
	<CALnjE+pExzAS4bk89RD4XJtHtSyB2g0qMsqdrGWPuD27axiNBw@mail.gmail.com>
	<alpine.DEB.2.00.1205091224460.11225@router.home>
Date: Wed, 9 May 2012 11:34:17 -0700
Message-ID: <CALnjE+qWHv4Egqm=+UoP6t-Bm6B=ZSjv82cmfxYdbZiFC65f3Q@mail.gmail.com>
Subject: Re: [PATCH] mm: sl[auo]b: Use atomic bit operations to update page-flags.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Wed, May 9, 2012 at 10:25 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 9 May 2012, Pravin Shelar wrote:
>
>> On Tue, May 8, 2012 at 12:22 PM, Christoph Lameter <cl@linux.com> wrote:
>> > On Tue, 8 May 2012, Eric Dumazet wrote:
>> >
>> >> On Tue, 2012-05-08 at 11:55 -0700, Pravin B Shelar wrote:
>> >> > Transparent huge pages can change page->flags (PG_compound_lock)
>> >> > without taking Slab lock. So sl[auo]b need to use atomic bit
>> >> > operation while changing page->flags.
>> >> > Specificly this patch fixes race between compound_unlock and slab
>> >> > functions which does page-flags update. This can occur when
>> >> > get_page/put_page is called on page from slab object.
>> >>
>> >>
>> >> But should get_page()/put_page() be called on a page own by slub ?
>> >
>> > Can occur in slab allocators if the slab memory is used for DMA. I dont
>> > like the performance impact of the atomics. In particular slab_unlock() in
>> > slub is or used to be a hot path item. It is still hot on arches that do
>> > not support this_cpu_cmpxchg_double. With the cmpxchg_double only the
>> > debug mode is affected.
>> >
>>
>> I agree this would impact performance. I am not sure how else we can
>> fix this issue. As far as slab_unlock in hot path case is concerned,
>> it is more likely to corrupt page->flags in that case.
>
> Dont modify any page flags from THP logic if its a slab page? THP cannot
> break up or merge slab pages anyways.

Good idea, I will post patch soon.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
