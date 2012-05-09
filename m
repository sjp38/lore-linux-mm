Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B07D66B00FF
	for <linux-mm@kvack.org>; Wed,  9 May 2012 03:18:37 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so2903594gge.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 00:18:36 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <CAPa8GCCaGQdOZoWCCLBLNtOV5_VS+sNvdC_PzrWauF0gSyizYg@mail.gmail.com>
References: <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
 <CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
 <x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com> <CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
 <x491un3nc7a.fsf@segfault.boston.devel.redhat.com> <CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
 <20120502081705.GB16976@quack.suse.cz> <CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
 <20120502091837.GC16976@quack.suse.cz> <CAHGf_=qfuRZzb91ELEcArNaNHsfO4BBMPO8a-QRBzFNaT2ev_w@mail.gmail.com>
 <20120502192325.GA18339@quack.suse.cz> <CAHGf_=oOx1qPFEboQeuaeMKtveM2==BSDG=xdfRHz+gFx1GAfw@mail.gmail.com>
 <CAKgNAkjybL_hmVfONUHtCbBe_VxQHNHOrmWQErGWDUqHiczkFg@mail.gmail.com>
 <CAHGf_=p4py5m1Pe1xon=9FcEEyf6AxW+Pc9Yy9gCvNtbXM_40A@mail.gmail.com>
 <CAPa8GCCh-RrjsQKzh9+Sxx-joRZw4qkpxR9n4svo+QopxAj_XQ@mail.gmail.com>
 <CAKgNAkh5TkwSzFVKVo5JUvkDWkzY8EaQNxJSQnv3fTHTdj0+FQ@mail.gmail.com> <CAPa8GCCaGQdOZoWCCLBLNtOV5_VS+sNvdC_PzrWauF0gSyizYg@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 9 May 2012 19:18:16 +1200
Message-ID: <CAKgNAkjLGqMyaeZsDpLUW+re2ViYcpVKOoh33vEJn5keBNLVXA@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On Wed, May 9, 2012 at 7:01 PM, Nick Piggin <npiggin@gmail.com> wrote:
> On 9 May 2012 15:35, Michael Kerrisk (man-pages) <mtk.manpages@gmail.com>=
 wrote:
>> On Wed, May 9, 2012 at 11:10 AM, Nick Piggin <npiggin@gmail.com> wrote:
>>> On 6 May 2012 01:29, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
>>>>> So, am I correct to assume that right text to add to the page is as b=
elow?
>>>>>
>>>>> Nick, can you clarify what you mean by "quiesced"?
>>>>
>>>> finished?
>>>
>>> Yes exactly. That might be a simpler word. Thanks!
>>
>> Thanks.
>>
>> But see below. I realize the text is still ambiguous.
>>
>>>>> [[
>>>>> O_DIRECT IOs should never be run concurrently with fork(2) system cal=
l,
>>>>> when the memory buffer is anonymous memory, or comes from mmap(2)
>>>>> with MAP_PRIVATE.
>>>>>
>>>>> Any such IOs, whether submitted with asynchronous IO interface or fro=
m
>>>>> another thread in the process, should be quiesced before fork(2) is c=
alled.
>>>>> Failure to do so can result in data corruption and undefined behavior=
 in
>>>>> parent and child processes.
>>>>>
>>>>> This restriction does not apply when the memory buffer for the O_DIRE=
CT
>>>>> IOs comes from mmap(2) with MAP_SHARED or from shmat(2).
>>>>> Nor does this restriction apply when the memory buffer has been advis=
ed
>>>>> as MADV_DONTFORK with madvise(2), ensuring that it will not be availa=
ble
>>>>> to the child after fork(2).
>>>>> ]]
>>
>> In the above, the status of a MAP_SHARED MAP_ANONYMOUS buffer is
>> unclear. The first paragraph implies that such a buffer is unsafe,
>> while the third paragraph implies that it *is* safe, thus
>> contradicting the first paragraph. Which is correct?
>
> Yes I see. It's because MAP_SHARED | MAP_ANONYMOUS isn't *really*
> anonymous from the virtual memory subsystem's point of view. But that
> just serves to confuse userspace I guess.
>
> Anything with MAP_SHARED, shmat, or MADV_DONTFORK is OK.
>
> Anything else (MAP_PRIVATE, brk, without MADV_DONTFORK) is
> dangerous. These type are used by standard heap allocators malloc,
> new, etc.

So, would the following text be okay:

       O_DIRECT I/Os should never be run concurrently with the fork(2)
       system call, if the memory buffer is a private  mapping  (i.e.,
       any  mapping  created  with  the mmap(2) MAP_PRIVATE flag; this
       includes memory allocated on the heap and statically  allocated
       buffers).  Any such I/Os, whether submitted via an asynchronous
       I/O interface or from another thread in the process, should  be
       completed  before  fork(2)  is  called.   Failure  to do so can
       result in data corruption and undefined behavior in parent  and
       child processes.  This restriction does not apply when the mem=E2=80=
=90
       ory buffer for the O_DIRECT I/Os was created using shmat(2)  or
       mmap(2)  with  the  MAP_SHARED flag.  Nor does this restriction
       apply when the memory buffer has been advised as  MADV_DONTFORK
       with  madvise(2), ensuring that it will not be available to the
       child after fork(2).

Thanks,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
