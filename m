Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12DAB8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:57:49 -0500 (EST)
Received: by qyk10 with SMTP id 10so603273qyk.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 05:57:48 -0800 (PST)
Message-ID: <4D383F6C.1070308@vflare.org>
Date: Thu, 20 Jan 2011 08:58:04 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zcache: page cache compression support
References: <9e7aa896-ed1f-4d50-8227-3a922be39949@default>	<4D382B99.7070005@vflare.org>	<20110120124730.GA7284@infradead.org> <AANLkTim4t4zT5W0TJ7Vwzb568u1W6vz3b_cZirfK0Uhs@mail.gmail.com>
In-Reply-To: <AANLkTim4t4zT5W0TJ7Vwzb568u1W6vz3b_cZirfK0Uhs@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 01/20/2011 08:16 AM, Pekka Enberg wrote:
> Hi Christoph,
>
> On Thu, Jan 20, 2011 at 07:33:29AM -0500, Nitin Gupta wrote:
>>> I just started looking into kztmem (weird name!) but on
>>> the high level it seems so much similar to zcache with some
>>> dynamic resizing added (callback for shrinker interface).
>>>
>>> Now, I'll try rebuilding zcache according to new cleancache
>>> API as provided by these set of patches. This will help refresh
>>> whatever issues I was having back then with pagecache
>>> compression and maybe pick useful bits/directions from
>>> new kztmem work.
> On Thu, Jan 20, 2011 at 2:47 PM, Christoph Hellwig<hch@infradead.org>  wrote:
>> Yes, we shouldn't have two drivers doing almost the same in the
>> tree.  Also adding core hooks for staging drivers really is against
>> the idea of staging of having a separate crap tree.  So it would be
>> good to get zcache into a state where we can merge it into the
>> proper tree first.  And then we can discuss if adding an abstraction
>> layer between it and the core VM really makes sense, and if it does
>> how.   But I'm pretty sure there's now need for multiple layers of
>> abstraction for something that's relatively core VM functionality.
>>
>> E.g. the abstraction should involve because of it's users, not the
>> compressed caching code should involve because it's needed to present
>> a user for otherwise useless code.
> I'm not sure which hooks you're referring to but for zcache we did this:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=b3a27d0529c6e5206f1b60f60263e3ecfd0d77cb
>
> I completely agree with getting zcache merged properly before going
> for the cleancache stuff.
>

These hooks are for zram (generic, in-memory compressed block devices)
which can also be used as swap disks. Without that swap notify hook, we
could not free [compressed] swap pages as soon as they are marked free.

For zcache (which does pagecache compression), we need separate set
of hooks, currently known as "cleancache" [1]. These hooks are very
minimal but not sure if they are accepted yet (they are present in
linux-next tree only, see: mm/cleancache.c, include/linux/cleancache.h

[1] cleancache: http://lwn.net/Articles/393013/

Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
