Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB526B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 16:45:26 -0500 (EST)
Received: by wggz12 with SMTP id z12so1519392wgg.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:45:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f11si20015166wiw.53.2015.02.23.13.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 13:45:24 -0800 (PST)
Message-ID: <54EB9F71.3040004@suse.cz>
Date: Mon, 23 Feb 2015 22:45:21 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>	<20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>	<54E5296C.5040806@redhat.com> <20150223111621.bc73004f51af2ca8e2847944@linux-foundation.org> <54EB82D0.9080606@redhat.com>
In-Reply-To: <54EB82D0.9080606@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, keithr@alum.mit.edu, dvyukov@google.com

On 23.2.2015 20:43, Rik van Riel wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> On 02/23/2015 02:16 PM, Andrew Morton wrote:
>> On Wed, 18 Feb 2015 19:08:12 -0500 Rik van Riel <riel@redhat.com>
>> wrote:
>>>> If so, this might be rather undesirable behaviour in some
>>>> situations (and ditto the current behaviour for pte_none
>>>> ptes)?
>>>>
>>>> This can be tuned by adjusting khugepaged_max_ptes_none,
>> Here's a live one:
>> https://bugzilla.kernel.org/show_bug.cgi?id=93111
>>
>> Application does MADV_DONTNEED to free up a load of memory and
>> then khugepaged comes along and pages that memory back in again.
>> It seems a bit silly to do this after userspace has deliberately
>> discarded those pages!

OK that's a nice example how a more conservative default for
max_ptes_none would make sense even with the current aggressive
THP faulting.

>> Presumably MADV_NOHUGEPAGE can be used to prevent this, but it's a
>> bit of a hand-grenade.  I guess the MADV_DONTNEED manpage should be
>> updated to explain all this?

Probably, together with the tunable documentation. Seems like we
didn't add enough details to madvise manpage in the recent round :)

> That makes me wonder what a good value for khugepaged_max_ptes_none
> would be.
>
> Doubling the amount of memory a program uses seems quite unreasonable.
>
> Increasing the amount of memory a program uses by 512x seems totally
> unreasonable.
>
> Increasing the amount of memory a program uses by 20% might be
> reasonable, if that much memory is available, since that seems to
> be about how much performance improvement we have ever seen from
> THP.
>
> Andrew, Andrea, do you have any ideas on this?
>
> Is this something to just set, or should we ask Ebru to run
> a few different tests with this?

If there is a good test for this, sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
