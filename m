Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 4C57F6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 07:31:19 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so737579dad.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 04:31:18 -0800 (PST)
Date: Wed, 7 Nov 2012 04:28:13 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121107122813.GA4968@lizard>
References: <20121107105348.GA25549@lizard>
 <20121107112136.GA31715@shutemov.name>
 <20121107114346.GA32565@lizard>
 <20121107121110.GA32402@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121107121110.GA32402@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, Glauber Costa <glommer@parallels.com>

On Wed, Nov 07, 2012 at 02:11:10PM +0200, Kirill A. Shutemov wrote:
[...]
> >    We can have plenty of "free" memory, of which say 90% will be caches,
> >    and say 10% idle. But we do want to differentiate these types of memory
> >    (although not going into details about it), i.e. we want to get
> >    notified when kernel is reclaiming. And we also want to know when the
> >    memory comes from swapping others' pages out (well, actually we don't
> >    call it swap, it's "new allocations cost becomes high" -- it might be a
> >    result of many factors (swapping, fragmentation, etc.) -- and userland
> >    might analyze the situation when this happens).
> > 
> >    Exposing all the VM details to userland is not an option
> 
> IIUC, you want MemFree + Buffers + Cached + SwapCached, right?
> It's already exposed to userspace.

How? If you mean vmstat, then no, that interface is not efficient at all:
we have to poll it from userland, which is no go for embedded (although,
as a workaround it can be done via deferrable timers in userland, which I
posted a few months ago).

But even with polling vmstat via deferrable timers, it leaves us with the
ugly timers-based approach (and no way to catch the pre-OOM conditions).
With vmpressure_fd() we have the synchronous notifications right from the
core (upon which, you can, if you want to, analyze the vmstat).

>> 2. The last time I checked, cgroups memory controller did not (and I guess
>>    still does not) not account kernel-owned slabs. I asked several times
>>    why so, but nobody answered.
>
> Almost there. Glauber works on it.

It's good to hear, but still, the number of "used KBs" is a bad (or
irrelevant) metric for the pressure. We'd still need to analyze the memory
in more details, and "'limit - used' KBs" doesn't tell us anything about
the cost of the available memory.

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
