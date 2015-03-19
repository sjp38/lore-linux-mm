Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9F76B006C
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 08:51:09 -0400 (EDT)
Received: by weop45 with SMTP id p45so56404569weo.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 05:51:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ib9si1995898wjb.198.2015.03.19.05.51.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 05:51:05 -0700 (PDT)
Message-ID: <550AC636.9030406@suse.cz>
Date: Thu, 19 Mar 2015 13:51:02 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to non-privileged
 userspace
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name> <20150316211122.GD11441@amd> <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com> <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
In-Reply-To: <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Mark Seaborn <mseaborn@chromium.org>
Cc: Pavel Machek <pavel@ucw.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On 03/17/2015 02:21 AM, Andy Lutomirski wrote:
> On Mon, Mar 16, 2015 at 5:49 PM, Mark Seaborn <mseaborn@chromium.org> wrote:
>> On 16 March 2015 at 14:11, Pavel Machek <pavel@ucw.cz> wrote:
>>
>>> Can we do anything about that? Disabling cache flushes from userland
>>> should make it no longer exploitable.
>>
>> Unfortunately there's no way to disable userland code's use of
>> CLFLUSH, as far as I know.
>>
>> Maybe Intel or AMD could disable CLFLUSH via a microcode update, but
>> they have not said whether that would be possible.
> 
> The Intel people I asked last week weren't confident.  For one thing,
> I fully expect that rowhammer can be exploited using only reads and
> writes with some clever tricks involving cache associativity.  I don't
> think there are any fully-associative caches, although the cache
> replacement algorithm could make the attacks interesting.

I've been thinking the same. But maybe having to evict e.g. 16-way cache would
mean accessing 16x more lines which could reduce the frequency for a single line
below dangerous levels. Worth trying, though :)

BTW, by using clever access patterns and measurement of access latencies one
could also possibly determine which cache lines alias/colide, without needing to
read pagemap. It would just take longer. Hugepages make that simpler as well.

I just hope we are not going to disable lots of stuff including clflush and e.g.
transparent hugepages just because some part of the currently sold hardware is
vulnerable...

Vlastimil

> --Andy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
