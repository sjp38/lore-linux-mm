Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AE7516B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 23:35:16 -0500 (EST)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TVxMB-0005SU-Ml
	for linux-mm@kvack.org; Wed, 07 Nov 2012 04:35:15 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so814598eek.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 20:35:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121106194859.8eec3043.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-2-git-send-email-ming.lei@canonical.com>
	<20121106152354.90150a3b.akpm@linux-foundation.org>
	<CACVXFVNs2JtEYQ3Y2rA8L89sAaMJ7TO-PxG3h4w+ihcZrBLtpg@mail.gmail.com>
	<20121106194859.8eec3043.akpm@linux-foundation.org>
Date: Wed, 7 Nov 2012 12:35:15 +0800
Message-ID: <CACVXFVMe5QyA_yTO=Bq0s-u6V3mTDZ5iK12SGYUNpT4VY_tLPw@mail.gmail.com>
Subject: Re: [PATCH v4 1/6] mm: teach mm by current context info to not do I/O
 during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 7, 2012 at 11:48 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>>
>> Firstly,  the patch follows the policy in the system suspend/resume situation,
>> in which the __GFP_FS is cleared, and basically the problem is very similar
>> with that in system PM path.
>
> I suspect that code is wrong.  Or at least, suboptimal.
>
>> Secondly, inside shrink_page_list(), pageout() may be triggered on dirty anon
>> page if __GFP_FS is set.
>
> pageout() should be called if GFP_FS is set or if GFP_IO is set and the
> IO is against swap.
>
> And that's what we want to happen: we want to enter the fs to try to
> turn dirty pagecache into clean pagecache without doing IO.  If we in
> fact enter the device drivers when GFP_IO was not set then that's a bug
> which we should fix.

OK, I got it, and I'll not clear GFP_FS in -v5.

>
>> IMO, if performing I/O can be completely avoided when __GFP_FS is set, the
>> flag can be kept, otherwise it is better to clear it in the situation.
>
> yup.
>
>> >
>> > Also, you can probably put the unlikely() inside memalloc_noio() and
>> > avoid repeating it at all the callsites.
>> >
>> > And it might be neater to do:
>> >
>> > /*
>> >  * Nice comment goes here
>> >  */
>> > static inline gfp_t memalloc_noio_flags(gfp_t flags)
>> > {
>> >         if (unlikely(current->flags & PF_MEMALLOC_NOIO))
>> >                 flags &= ~GFP_IOFS;
>> >         return flags;
>> > }
>>
>> But without the check in callsites, some local variables will be write
>> two times,
>> so it is better to not do it.
>
> I don't see why - we just modify the incoming gfp_t at the start of the
> function, then use it.
>
> It gets a bit tricky with those struct initialisations.  Things like
>
>         struct foo bar {
>                 .a = a1,
>                 .b = b1,
>         };
>
> should not be turned into
>
>         struct foo bar {
>                 .a = a1,
>         };
>
>         bar.b = b1;
>
> and we don't want to do
>
>         struct foo bar { };
>
>         bar.a = a1;
>         bar.b = b1;
>
> either, because these are indeed a double-write.  But we can do
>
>         struct foo bar {
>                 .flags = (flags = memalloc_noio_flags(flags)),
>                 .b = b1,
>         };
>
> which is a bit arcane but not toooo bad.  Have a think about it...

Got it, looks memalloc_noio_flags() neater, and I will take it in v5.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
