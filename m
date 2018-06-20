Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A061D6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 20:31:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w23-v6so482399pgv.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:31:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s188-v6sor247142pgc.205.2018.06.19.17.31.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 17:31:32 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
Date: Tue, 19 Jun 2018 17:31:27 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

at 4:08 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:

>=20
>=20
> On 6/19/18 3:17 PM, Nadav Amit wrote:
>> at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com>
>>  wrote:
>>=20
>>=20
>>> When running some mmap/munmap scalability tests with large memory =
(i.e.
>>>=20
>>>> 300GB), the below hung task issue may happen occasionally.
>>>>=20
>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>>       Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>> message.
>>> ps              D    0 14018      1 0x00000004
>>>=20
>>>=20
>> (snip)
>>=20
>>=20
>>> Zapping pages is the most time consuming part, according to the
>>> suggestion from Michal Hock [1], zapping pages can be done with =
holding
>>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>>> mmap_sem to manipulate vmas.
>>>=20
>> Does munmap() =3D=3D MADV_DONTNEED + munmap() ?
>=20
> Not exactly the same. So, I basically copied the page zapping used by =
munmap instead of calling MADV_DONTNEED.
>=20
>>=20
>> For example, what happens with userfaultfd in this case? Can you get =
an
>> extra #PF, which would be visible to userspace, before the munmap is
>> finished?
>>=20
>=20
> userfaultfd is handled by regular munmap path. So, no change to =
userfaultfd part.

Right. I see it now.

>=20
>>=20
>> In addition, would it be ok for the user to potentially get a zeroed =
page in
>> the time window after the MADV_DONTNEED finished removing a PTE and =
before
>> the munmap() is done?
>>=20
>=20
> This should be undefined behavior according to Michal. This has been =
discussed in  https://lwn.net/Articles/753269/.

Thanks for the reference.

Reading the man page I see: "All pages containing a part of the =
indicated
range are unmapped, and subsequent references to these pages will =
generate
SIGSEGV.=E2=80=9D

To me it sounds pretty well-defined, and this implementation does not =
follow
this definition. I would expect the man page to be updated and indicate =
that
the behavior has changed.

Regards,
Nadav=
