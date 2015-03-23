Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3886B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:36:57 -0400 (EDT)
Received: by wibg7 with SMTP id g7so59929251wib.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:36:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si13873183wiv.60.2015.03.23.15.36.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 15:36:55 -0700 (PDT)
Message-ID: <55109588.2050305@suse.cz>
Date: Mon, 23 Mar 2015 23:36:56 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to non-privileged
 userspace
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name> <20150316211122.GD11441@amd> <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com> <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com> <550AC636.9030406@suse.cz> <20150323212559.GF14779@amd>
In-Reply-To: <20150323212559.GF14779@amd>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andy Lutomirski <luto@amacapital.net>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On 23.3.2015 22:26, Pavel Machek wrote:
> On Thu 2015-03-19 13:51:02, Vlastimil Babka wrote:
>> On 03/17/2015 02:21 AM, Andy Lutomirski wrote:
>>> On Mon, Mar 16, 2015 at 5:49 PM, Mark Seaborn <mseaborn@chromium.org> wrote:
>>>
>>> The Intel people I asked last week weren't confident.  For one thing,
>>> I fully expect that rowhammer can be exploited using only reads and
>>> writes with some clever tricks involving cache associativity.  I don't
>>> think there are any fully-associative caches, although the cache
>>> replacement algorithm could make the attacks interesting.
>>
>> I've been thinking the same. But maybe having to evict e.g. 16-way cache would
>> mean accessing 16x more lines which could reduce the frequency for a single line
>> below dangerous levels. Worth trying, though :)
> 
> How many ways do recent CPU L1 caches have?

My i7 based desktop has 8-way L1, 8-way L2, 16-way L3. And it seems to be
alarmingly vulnerable to the double-sided rowhammer variant. But to reliably
miss L3 it seems I need at least 96 addresses colliding in L3, which are then
also in different dram rows. Which naturally reduces frequency for the target
pair of rows. I've been able so far to reduce/mask the overhead so that the
target rows are accessed with 11x lower frequency than with clflush. Which
doesn't seem enough to trigger bit flips. But maybe I can improve it further :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
