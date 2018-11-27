Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 824D06B48CF
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 10:55:57 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id h68so23290740qke.3
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 07:55:57 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b48si3394090qtk.45.2018.11.27.07.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 07:55:56 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm: warn only once if page table misaccounting is
 detected
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181127155213.GB27075@linux.intel.com>
Date: Tue, 27 Nov 2018 08:55:47 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0AD1CE43-3B5B-4D4B-963B-056D749F196E@oracle.com>
References: <20181127083603.39041-1-heiko.carstens@de.ibm.com>
 <20181127155213.GB27075@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>



> On Nov 27, 2018, at 8:52 AM, Sean Christopherson =
<sean.j.christopherson@intel.com> wrote:
>=20
> On Tue, Nov 27, 2018 at 09:36:03AM +0100, Heiko Carstens wrote:
>> Use pr_alert_once() instead of pr_alert() if page table misaccounting
>> has been detected.
>>=20
>> If this happens once it is very likely that there will be numerous
>> other occurrence as well, which would flood dmesg and the console =
with
>> hardly any added information. Therefore print the warning only once.
>>=20
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>> ---
>> kernel/fork.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index 07cddff89c7b..c887e9eba89f 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
>> 	}
>>=20
>> 	if (mm_pgtables_bytes(mm))
>> -		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: =
%ld\n",
>> -				mm_pgtables_bytes(mm));
>> +		pr_alert_once("BUG: non-zero pgtables_bytes on freeing =
mm: %ld\n",
>> +			      mm_pgtables_bytes(mm));
>=20
> I found the print-always behavior to be useful when developing a =
driver
> that mucked with PTEs directly via vmf_insert_pfn() and had issues =
with
> racing against exit_mmap().  It was nice to be able to recompile only
> the driver and rely on dmesg to let me know when I messed up yet =
again.
>=20
> Would pr_alert_ratelimited() suffice?

Actually, I really like that idea.

There are certainly times when it is useful to see a cascade of =
messages, within reason;
one there are so many they overflow the dmesg buffer they're of limited =
usefulness.

Something like a pr_alert() that could rate limit to a preset value, =
perhaps a default of
fifty or so, could prove quite useful indeed without being an all or =
once choice.

    William Kucharski=
