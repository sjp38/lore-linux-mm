Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1508D6B0561
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 12:40:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v62so243816261pfd.10
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:40:30 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id d6si1631247plj.353.2017.07.28.09.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 09:40:28 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id k190so8354383pgk.4
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:40:28 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 2/2] mm: migrate: fix barriers around tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170728074256.7xsnoldtfuh7ywir@suse.de>
Date: Fri, 28 Jul 2017 09:40:24 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <4F474FD8-82BE-4881-AE47-40AA6A4091C1@gmail.com>
References: <20170727114015.3452-1-namit@vmware.com>
 <20170727114015.3452-3-namit@vmware.com>
 <20170728074256.7xsnoldtfuh7ywir@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, luto@kernel.org

Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Jul 27, 2017 at 04:40:15AM -0700, Nadav Amit wrote:
>> Reading tlb_flush_pending while the page-table lock is taken does not
>> require a barrier, since the lock/unlock already acts as a barrier.
>> Removing the barrier in mm_tlb_flush_pending() to address this issue.
>>=20
>> However, migrate_misplaced_transhuge_page() calls =
mm_tlb_flush_pending()
>> while the page-table lock is already released, which may present a
>> problem on architectures with weak memory model (PPC). To deal with =
this
>> case, a new parameter is added to mm_tlb_flush_pending() to indicate
>> if it is read without the page-table lock taken, and calling
>> smp_mb__after_unlock_lock() in this case.
>>=20
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>=20
> Conditional locking based on function arguements are often considered
> extremely hazardous. Conditional barriers are even more troublesome =
because
> it's simply too easy to get wrong.
>=20
> Revert b0943d61b8fa420180f92f64ef67662b4f6cc493 instead of this patch. =
It's
> not a clean revert but conflicts are due to comment changes. It moves
> the check back under the PTL and the impact is marginal given that
> it a spurious TLB flush will only occur when potentially racing with
> change_prot_range. Since that commit went in, a lot of changes have =
happened
> that alter the scan rate of automatic NUMA balancing so it shouldn't =
be a
> serious issue. It's certainly a nicer option than using conditional =
barriers.

Ok. Initially, I added a memory barrier only in
migrate_misplaced_transhuge_page(), and included a detailed comment =
about it
- I still think it is better. But since you feel confident the impact =
will
be relatively small, I will do the revert.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
