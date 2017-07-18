Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E119B6B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 00:52:54 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s21so712614oie.5
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:52:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a186si728640oii.205.2017.07.17.21.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 21:52:54 -0700 (PDT)
Received: from mail-ua0-f179.google.com (mail-ua0-f179.google.com [209.85.217.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 39D2322C96
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 04:52:53 +0000 (UTC)
Received: by mail-ua0-f179.google.com with SMTP id b64so10683795uab.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:52:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4999C175-5C91-4DF8-98C5-350219421518@gmail.com>
References: <20170717180246.62277-1-namit@vmware.com> <CALCETrW3XP-nE9MxzbZZ0DxxQYFJ848_afeDvQ8UzY=-gwBjmQ@mail.gmail.com>
 <4999C175-5C91-4DF8-98C5-350219421518@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jul 2017 21:52:31 -0700
Message-ID: <CALCETrW3ZtK6=-KtB5NC6SUhRujVVPeYwihj+puq9iiTcsSjOA@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <namit@vmware.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Mon, Jul 17, 2017 at 6:40 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Andy Lutomirski <luto@kernel.org> wrote:
>
>> On Mon, Jul 17, 2017 at 11:02 AM, Nadav Amit <namit@vmware.com> wrote:
>>> Setting and clearing mm->tlb_flush_pending can be performed by multiple
>>> threads, since mmap_sem may only be acquired for read in task_numa_work=
.
>>> If this happens, tlb_flush_pending may be cleared while one of the
>>> threads still changes PTEs and batches TLB flushes.
>>>
>>> As a result, TLB flushes can be skipped because the indication of
>>> pending TLB flushes is lost, for instance due to race between
>>> migration and change_protection_range (just as in the scenario that
>>> caused the introduction of tlb_flush_pending).
>>>
>>> The feasibility of such a scenario was confirmed by adding assertion to
>>> check tlb_flush_pending is not set by two threads, adding artificial
>>> latency in change_protection_range() and using sysctl to reduce
>>> kernel.numa_balancing_scan_delay_ms.
>>
>> This thing is logically a refcount.  Should it be refcount_t?
>
> I don=E2=80=99t think so. refcount_inc() would WARN_ONCE if the counter i=
s zero
> before the increase, although this is a valid scenario here.
>

Hmm.  Maybe a refcount that starts at 1?  My point is that, if someone
could force it to overflow, it would be bad.  Maybe this isn't worth
worrying about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
