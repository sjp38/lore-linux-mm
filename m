Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E80B76B04B3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:04:15 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w187so16630107pgb.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:04:15 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m9si11784569plk.240.2017.07.27.09.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 09:04:14 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 125so7495413pgi.5
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:04:14 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170727072113.dpv2nsqaft3inpru@suse.de>
Date: Thu, 27 Jul 2017 09:04:11 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <68D28CCA-10CC-48F8-A38F-B682A98A4BA5@gmail.com>
References: <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox> <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com> <20170726234025.GA4491@bbox>
 <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com> <20170727003434.GA537@bbox>
 <77AFE0A4-FE3D-4E05-B248-30ADE2F184EF@gmail.com>
 <AACB7A95-A1E1-4ACD-812F-BD9F8F564FD7@gmail.com> <20170727070420.GA1052@bbox>
 <20170727072113.dpv2nsqaft3inpru@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Jul 27, 2017 at 04:04:20PM +0900, Minchan Kim wrote:
>>> There is one issue I forgot: pte_accessible() on x86 regards
>>> mm_tlb_flush_pending() as an indication for NUMA migration. But now =
the code
>>> does not make too much sense:
>>>=20
>>>        if ((pte_flags(a) & _PAGE_PROTNONE) &&
>>>                        mm_tlb_flush_pending(mm))
>>>=20
>>> Either we remove the _PAGE_PROTNONE check or we need to use the =
atomic field
>>> to count separately pending flushes due to migration and due to =
other
>>> reasons. The first option is safer, but Mel objected to it, because =
of the
>>> performance implications. The second one requires some thought on =
how to
>>> build a single counter for multiple reasons and avoid a potential =
overflow.
>>>=20
>>> Thoughts?
>>=20
>> I'm really new for the autoNUMA so not sure I understand your concern
>> If your concern is that increasing places where add up pending count,
>> autoNUMA performance might be hurt. Right?
>> If so, above _PAGE_PROTNONE check will filter out most of cases?
>> Maybe, Mel could answer.
>=20
> I'm not sure what I'm being asked. In the case above, the TLB flush =
pending
> is only relevant against autonuma-related races so only those PTEs are
> checked to limit overhead. It could be checked on every PTE but it's
> adding more compiler barriers or more atomic reads which do not appear
> necessary. If the check is removed, a comment should be added =
explaining
> why every PTE has to be checked.

I considered breaking tlb_flush_pending to two: tlb_flush_pending_numa =
and
tlb_flush_pending_other (they can share one atomic64_t field). This way,
pte_accessible() would only consider =E2=80=9Ctlb_flush_pending_numa", =
and the
changes that Minchan proposed would not increase the number unnecessary =
TLB
flushes.

However, considering the complexity of the TLB flushes scheme, and the =
fact
I am not fully convinced all of these TLB flushes are indeed =
unnecessary, I
will put it aside.

Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
