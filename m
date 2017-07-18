Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 574DB6B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 01:11:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a2so10306060pgn.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 22:11:15 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id y61si949274plh.274.2017.07.17.22.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 22:11:14 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id q85so1350721pfq.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 22:11:14 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrW3ZtK6=-KtB5NC6SUhRujVVPeYwihj+puq9iiTcsSjOA@mail.gmail.com>
Date: Mon, 17 Jul 2017 22:11:10 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <24FFBC12-AFF4-4799-A6E5-51F330226483@gmail.com>
References: <20170717180246.62277-1-namit@vmware.com>
 <CALCETrW3XP-nE9MxzbZZ0DxxQYFJ848_afeDvQ8UzY=-gwBjmQ@mail.gmail.com>
 <4999C175-5C91-4DF8-98C5-350219421518@gmail.com>
 <CALCETrW3ZtK6=-KtB5NC6SUhRujVVPeYwihj+puq9iiTcsSjOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <namit@vmware.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Andy Lutomirski <luto@kernel.org> wrote:

> On Mon, Jul 17, 2017 at 6:40 PM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>> Andy Lutomirski <luto@kernel.org> wrote:
>>=20
>>> On Mon, Jul 17, 2017 at 11:02 AM, Nadav Amit <namit@vmware.com> =
wrote:
>>>> Setting and clearing mm->tlb_flush_pending can be performed by =
multiple
>>>> threads, since mmap_sem may only be acquired for read in =
task_numa_work.
>>>> If this happens, tlb_flush_pending may be cleared while one of the
>>>> threads still changes PTEs and batches TLB flushes.
>>>>=20
>>>> As a result, TLB flushes can be skipped because the indication of
>>>> pending TLB flushes is lost, for instance due to race between
>>>> migration and change_protection_range (just as in the scenario that
>>>> caused the introduction of tlb_flush_pending).
>>>>=20
>>>> The feasibility of such a scenario was confirmed by adding =
assertion to
>>>> check tlb_flush_pending is not set by two threads, adding =
artificial
>>>> latency in change_protection_range() and using sysctl to reduce
>>>> kernel.numa_balancing_scan_delay_ms.
>>>=20
>>> This thing is logically a refcount.  Should it be refcount_t?
>>=20
>> I don=E2=80=99t think so. refcount_inc() would WARN_ONCE if the =
counter is zero
>> before the increase, although this is a valid scenario here.
>=20
> Hmm.  Maybe a refcount that starts at 1?  My point is that, if someone
> could force it to overflow, it would be bad.  Maybe this isn't worth
> worrying about.

I don=E2=80=99t think it is a issue. At most you can have one =
task_numa_work() per
core running in any given moment.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
