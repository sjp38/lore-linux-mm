Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF7886B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 20:46:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so366784666pfx.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 17:46:42 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id h128si5663075pfb.176.2016.08.02.17.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 17:46:42 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id y134so71310334pfg.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 17:46:42 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization follow-up
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20160802231229.GE32028@t510>
Date: Tue, 2 Aug 2016 17:46:40 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <AFCF5AC6-EBA9-4F5B-9E05-C5CBF9B3EDC7@gmail.com>
References: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com> <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com> <20160802231229.GE32028@t510>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org

Rafael Aquini <aquini@redhat.com> wrote:

> On Tue, Aug 02, 2016 at 03:27:06PM -0700, Nadav Amit wrote:
>> Rafael Aquini <aquini@redhat.com> wrote:
>>=20
>>> While backporting 71b3c126e611 ("x86/mm: Add barriers and document =
switch_mm()-vs-flush synchronization")
>>> we stumbled across a possibly missing barrier at flush_tlb_page().
>>=20
>> I too noticed it and submitted a similar patch that never got a =
response [1].
>=20
> As far as I understood Andy's rationale for the original patch you =
need
> a full memory barrier there in flush_tlb_page to get that =
cache-eviction
> race sorted out.

I am completely ok with your fix (except for the missing barrier in
set_tlb_ubc_flush_pending() ). However, I think mine should suffice. As =
far as
I saw, an atomic operation preceded every invocation of =
flush_tlb_page(). I
was afraid someone would send me to measure the patch performance impact =
so I
looked for one with the least impact.

See Intel SDM 8.2.2 "Memory Ordering in P6 and More Recent Processor =
Families"
for the reasoning behind smp_mb__after_atomic() . The result of an =
atomic
operation followed by smp_mb__after_atomic should be identical to =
smp_mb().

Regards,
Nadav




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
