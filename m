Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAB842802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 21:44:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u199so166642303pgb.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:44:37 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id l19si8522281pfa.168.2017.07.27.18.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 18:44:36 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id q85so19419168pfq.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:44:36 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 1/2] mm: migrate: prevent racy access to
 tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170728013423.GA358@jagdpanzerIV.localdomain>
Date: Thu, 27 Jul 2017 18:44:34 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <41EF8C12-A581-4514-AAEA-5F5DAA08D322@gmail.com>
References: <20170727114015.3452-1-namit@vmware.com>
 <20170727114015.3452-2-namit@vmware.com>
 <20170728013423.GA358@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> just my 5 silly cents,
>=20
> On (07/27/17 04:40), Nadav Amit wrote:
> [..]
>> static inline void set_tlb_flush_pending(struct mm_struct *mm)
>> {
>> -	mm->tlb_flush_pending =3D true;
>> +	atomic_inc(&mm->tlb_flush_pending);
>>=20
>> 	/*
>> 	 * Guarantee that the tlb_flush_pending store does not leak into =
the
>> @@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct =
mm_struct *mm)
>> static inline void clear_tlb_flush_pending(struct mm_struct *mm)
>> {
>> 	barrier();
>> -	mm->tlb_flush_pending =3D false;
>> +	atomic_dec(&mm->tlb_flush_pending);
>> }
>=20
> so, _technically_, set_tlb_flush_pending() can be nested, right? IOW,
>=20
> 	set_tlb_flush_pending()
> 	set_tlb_flush_pending()
> 	flush_tlb_range()
> 	clear_tlb_flush_pending()
> 	clear_tlb_flush_pending()  // if we miss this one, then
> 				   // ->tlb_flush_pending is !clear,
> 				   // even though we called
> 				   // clear_tlb_flush_pending()
>=20
> if so then set_ and clear_ are a bit misleading names for something
> that does atomic_inc()/atomic_dec() internally.
>=20
> especially when one sees this part
>=20
>> -	clear_tlb_flush_pending(mm);
>> +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
>> +	atomic_set(&mm->tlb_flush_pending, 0);
>> +#endif
>=20
> so we have clear_tlb_flush_pending() function which probably should
> set it to 0 as the name suggests (I see what you did tho), yet still
> do atomic_set() under ifdef-s.
>=20
> well, just nitpicks.

I see your point. Initially, I tried to keep exactly the same interface =
to
reduce the number of changes, but it might be misleading. I will change =
the
names (inc/dec_tlb_flush_pending). I will create =
init_tlb_flush_pending()
for initialization since you ask, but Minchan's changes would likely =
remove
the ifdef=E2=80=99s, making it a bit strange for a single use.

Anyhow, I=E2=80=99ll wait to see if there any other comments and then do =
it for v4.

Thanks,
Nadav


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
