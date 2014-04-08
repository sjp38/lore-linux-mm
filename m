Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id E92C86B0036
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 16:51:31 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id mx12so1308392bkb.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 13:51:31 -0700 (PDT)
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
        by mx.google.com with ESMTPS id nr10si1684866bkb.71.2014.04.08.13.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 13:51:30 -0700 (PDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so1266202bkz.23
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 13:51:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
	<1396883443-11696-3-git-send-email-mgorman@suse.de>
	<5342C517.2020305@citrix.com>
	<20140407154935.GD7292@suse.de>
	<20140407161910.GJ1444@moon>
	<20140407182854.GH7292@suse.de>
	<5342FC0E.9080701@zytor.com>
	<20140407193646.GC23983@moon>
	<5342FFB0.6010501@zytor.com>
	<20140407212535.GJ7292@suse.de>
	<CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
	<e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
Date: Tue, 8 Apr 2014 13:51:28 -0700
Message-ID: <CAKbGBLjO7pneg_5nXcRXK-9iToZvPkJVZ=AQBfaZkZjU9iN2BA@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
From: Steven Noonan <steven@uplinklabs.net>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Apr 8, 2014 at 8:16 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> <snark>
>
> Of course, it would also be preferable if Amazon (or anything else) didn't need Xen PV :(

Well Amazon doesn't expose NUMA on PV, only on HVM guests.

> On April 7, 2014 9:04:53 PM PDT, Steven Noonan <steven@uplinklabs.net> wrote:
>>On Mon, Apr 7, 2014 at 2:25 PM, Mel Gorman <mgorman@suse.de> wrote:
>>> On Mon, Apr 07, 2014 at 12:42:40PM -0700, H. Peter Anvin wrote:
>>>> On 04/07/2014 12:36 PM, Cyrill Gorcunov wrote:
>>>> > On Mon, Apr 07, 2014 at 12:27:10PM -0700, H. Peter Anvin wrote:
>>>> >> On 04/07/2014 11:28 AM, Mel Gorman wrote:
>>>> >>>
>>>> >>> I had considered the soft-dirty tracking usage of the same bit.
>>I thought I'd
>>>> >>> be able to swizzle around it or a further worst case of having
>>soft-dirty and
>>>> >>> automatic NUMA balancing mutually exclusive. Unfortunately upon
>>examination
>>>> >>> it's not obvious how to have both of them share a bit and I
>>suspect any
>>>> >>> attempt to will break CRIU.  In my current tree, NUMA_BALANCING
>>cannot be
>>>> >>> set if MEM_SOFT_DIRTY which is not particularly satisfactory.
>>Next on the
>>>> >>> list is examining if _PAGE_BIT_IOMAP can be used.
>>>> >>
>>>> >> Didn't we smoke the last user of _PAGE_BIT_IOMAP?
>>>> >
>>>> > Seems so, at least for non-kernel pages (not considering this bit
>>references in
>>>> > xen code, which i simply don't know but i guess it's used for
>>kernel pages only).
>>>> >
>>>>
>>>> David Vrabel has a patchset which I presumed would be pulled through
>>the
>>>> Xen tree this merge window:
>>>>
>>>> [PATCHv5 0/8] x86/xen: fixes for mapping high MMIO regions (and
>>remove
>>>> _PAGE_IOMAP)
>>>>
>>>> That frees up this bit.
>>>>
>>>
>>> Thanks, I was not aware of that patch.  Based on it, I intend to
>>force
>>> automatic NUMA balancing to depend on !XEN and see what the reaction
>>is. If
>>> support for Xen is really required then it potentially be re-enabled
>>if/when
>>> that series is merged assuming they do not need the bit for something
>>else.
>>>
>>
>>Amazon EC2 does have large memory instance types with NUMA exposed to
>>the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
>>(to me anyway) if we didn't require !XEN.
>
> --
> Sent from my mobile phone.  Please pardon brevity and lack of formatting.
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
