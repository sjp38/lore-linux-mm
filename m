Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id CB1F4900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 14:24:49 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id u10so3294259lbd.9
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 11:24:49 -0800 (PST)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id w8si2224113lbb.25.2015.02.04.11.24.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 11:24:48 -0800 (PST)
Received: by mail-lb0-f173.google.com with SMTP id p9so3325380lbv.4
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 11:24:47 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <54D2508A.9030804@suse.cz>
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz> <20150203105301.GC14259@node.dhcp.inet.fi>
 <54D0B43D.8000209@suse.cz> <54D0F56A.9050003@gmail.com> <54D22298.3040504@suse.cz>
 <CAKgNAkgOOCuzJz9whoVfFjqhxM0zYsz94B1+oH58SthC5Ut9sg@mail.gmail.com> <54D2508A.9030804@suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 4 Feb 2015 20:24:27 +0100
Message-ID: <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On 4 February 2015 at 18:02, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 02/04/2015 03:00 PM, Michael Kerrisk (man-pages) wrote:
>>
>> Hello Vlastimil,
>>
>> On 4 February 2015 at 14:46, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>>>
>>>>> - that covers mlocking ok, not sure if the rest fits the "shared page=
s"
>>>>> case
>>>>> though. I dont see any check for other kinds of shared pages in the
>>>>> code.
>>>>
>>>>
>>>> Agreed. "shared" here seems confused. I've removed it. And I've
>>>> added mention of "Huge TLB pages" for this error.
>>>
>>>
>>> Thanks.
>>
>>
>> I also added those cases for MADV_REMOVE, BTW.
>
>
> Right. There's also the following for MADV_REMOVE that needs updating:
>
> "Currently, only shmfs/tmpfs supports this; other filesystems return with
> the error ENOSYS."
>
> - it's not just shmem/tmpfs anymore. It should be best to refer to
> fallocate(2) option FALLOC_FL_PUNCH_HOLE which seems to be (more) up to
> date.
>
> - AFAICS it doesn't return ENOSYS but EOPNOTSUPP. Also neither error code=
 is
> listed in the ERRORS section.

Yup, I recently added that as well, based on a patch from Jan Chaloupka.

>>>>>>> - The word "will result" did sound as a guarantee at least to me. S=
o
>>>>>>> here it
>>>>>>> could be changed to "may result (unless the advice is ignored)"?
>>>>>>
>>>>>> It's too late to fix documentation. Applications already depends on
>>>>>> the
>>>>>> beheviour.
>>>>>
>>>>> Right, so as long as they check for EINVAL, it should be safe. It
>>>>> appears
>>>>> that
>>>>> jemalloc does.
>>>>
>>>> So, first a brief question: in the cases where the call does not error
>>>> out,
>>>> are we agreed that in the current implementation, MADV_DONTNEED will
>>>> always result in zero-filled pages when the region is faulted back in
>>>> (when we consider pages that are not backed by a file)?
>>>
>>> I'd agree at this point.
>>
>> Thanks for the confirmation.
>>
>>> Also we should probably mention anonymously shared pages (shmem). I thi=
nk
>>> they behave the same as file here.
>>
>> You mean tmpfs here, right? (I don't keep all of the synonyms straight.)
>
> shmem is tmpfs (that by itself would fit under "files" just fine), but al=
so
> sys V segments created by shmget(2) and also mappings created by mmap wit=
h
> MAP_SHARED | MAP_ANONYMOUS. I'm not sure if there's a single manpage to
> refer to the full list.

So, how about this text:

              After a successful MADV_DONTNEED operation, the seman=E2=80=
=90
              tics  of  memory  access  in  the specified region are
              changed: subsequent accesses of  pages  in  the  range
              will  succeed,  but will result in either reloading of
              the memory contents from the  underlying  mapped  file
              (for  shared file mappings, shared anonymous mappings,
              and shmem-based techniques such  as  System  V  shared
              memory  segments)  or  zero-fill-on-demand  pages  for
              anonymous private mappings.

Thanks,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
