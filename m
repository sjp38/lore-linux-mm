Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE196B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:41:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so6764725pfe.11
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:41:28 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id d23si598343pli.126.2017.07.17.18.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 18:41:27 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id o88so775006pfk.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:41:27 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrW3XP-nE9MxzbZZ0DxxQYFJ848_afeDvQ8UzY=-gwBjmQ@mail.gmail.com>
Date: Mon, 17 Jul 2017 18:40:54 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <4999C175-5C91-4DF8-98C5-350219421518@gmail.com>
References: <20170717180246.62277-1-namit@vmware.com>
 <CALCETrW3XP-nE9MxzbZZ0DxxQYFJ848_afeDvQ8UzY=-gwBjmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <namit@vmware.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Andy Lutomirski <luto@kernel.org> wrote:

> On Mon, Jul 17, 2017 at 11:02 AM, Nadav Amit <namit@vmware.com> wrote:
>> Setting and clearing mm->tlb_flush_pending can be performed by =
multiple
>> threads, since mmap_sem may only be acquired for read in =
task_numa_work.
>> If this happens, tlb_flush_pending may be cleared while one of the
>> threads still changes PTEs and batches TLB flushes.
>>=20
>> As a result, TLB flushes can be skipped because the indication of
>> pending TLB flushes is lost, for instance due to race between
>> migration and change_protection_range (just as in the scenario that
>> caused the introduction of tlb_flush_pending).
>>=20
>> The feasibility of such a scenario was confirmed by adding assertion =
to
>> check tlb_flush_pending is not set by two threads, adding artificial
>> latency in change_protection_range() and using sysctl to reduce
>> kernel.numa_balancing_scan_delay_ms.
>=20
> This thing is logically a refcount.  Should it be refcount_t?

I don=E2=80=99t think so. refcount_inc() would WARN_ONCE if the counter =
is zero
before the increase, although this is a valid scenario here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
