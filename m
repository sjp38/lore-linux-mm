Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 943126B4AB3
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:45:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so24079651plb.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:45:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1-v6si5072928plx.278.2018.11.27.13.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 13:45:53 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wARLi4Vr031571
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:45:52 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p1cwx2nfr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:45:52 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 27 Nov 2018 21:45:49 -0000
Date: Tue, 27 Nov 2018 23:45:40 +0200
In-Reply-To: <alpine.LSU.2.11.1811271258070.4506@eggly.anvils>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com> <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils> <20181127105848.GD16502@rapoport-lnx> <alpine.LSU.2.11.1811271258070.4506@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is migrated
From: Mike Rapoport <rppt@linux.ibm.com>
Message-Id: <E1C5FE6D-7BF7-40F5-85F9-BBD86D53EFC2@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On November 27, 2018 11:08:50 PM GMT+02:00, Hugh Dickins <hughd@google=2Ec=
om> wrote:
>On Tue, 27 Nov 2018, Mike Rapoport wrote:
>> On Mon, Nov 26, 2018 at 11:27:07AM -0800, Hugh Dickins wrote:
>> >=20
>> > +/*
>> > + * A choice of three behaviors for wait_on_page_bit_common():
>> > + */
>> > +enum behavior {
>> > +	EXCLUSIVE,	/* Hold ref to page and take the bit when woken, like
>> > +			 * __lock_page() waiting on then setting PG_locked=2E
>> > +			 */
>> > +	SHARED,		/* Hold ref to page and check the bit when woken, like
>> > +			 * wait_on_page_writeback() waiting on PG_writeback=2E
>> > +			 */
>> > +	DROP,		/* Drop ref to page before wait, no check when woken,
>> > +			 * like put_and_wait_on_page_locked() on PG_locked=2E
>> > +			 */
>> > +};
>>=20
>> Can we please make it:
>>=20
>> /**
>>  * enum behavior - a choice of three behaviors for
>wait_on_page_bit_common()
>>  */
>> enum behavior {
>> 	/**
>> 	 * @EXCLUSIVE: Hold ref to page and take the bit when woken,
>> 	 * like __lock_page() waiting on then setting %PG_locked=2E
>> 	 */
>> 	EXCLUSIVE,
>> 	/**
>> 	 * @SHARED: Hold ref to page and check the bit when woken,
>> 	 * like wait_on_page_writeback() waiting on %PG_writeback=2E
>> 	 */
>> 	SHARED,
>> 	/**
>> 	 * @DROP: Drop ref to page before wait, no check when woken,
>> 	 * like put_and_wait_on_page_locked() on %PG_locked=2E
>> 	 */
>> 	DROP,
>> };
>
>I'm with Matthew, I'd prefer not: the first looks a more readable,
>less cluttered comment to me than the second: this is just an arg
>to an internal helper in mm/filemap=2Ec, itself not kernel-doc'ed=2E

Hmm, indeed, making this kernel-doc would be premature=2E
I was thinking about including this in a future description of the filemap=
 internals, but until that would get written lot of things may change=2E

>But the comment is not there for me: if consensus is that the
>second is preferable, then sure, we can change it over=2E
>
>Hugh

--=20
Sincerely yours,
Mike=2E
