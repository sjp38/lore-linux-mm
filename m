Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7808A6B0104
	for <linux-mm@kvack.org>; Sat,  5 May 2012 07:28:35 -0400 (EDT)
Received: by yhr47 with SMTP id 47so4872816yhr.14
        for <linux-mm@kvack.org>; Sat, 05 May 2012 04:28:34 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <CAHGf_=oOx1qPFEboQeuaeMKtveM2==BSDG=xdfRHz+gFx1GAfw@mail.gmail.com>
References: <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
 <CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
 <x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com> <CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
 <x491un3nc7a.fsf@segfault.boston.devel.redhat.com> <CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
 <20120502081705.GB16976@quack.suse.cz> <CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
 <20120502091837.GC16976@quack.suse.cz> <CAHGf_=qfuRZzb91ELEcArNaNHsfO4BBMPO8a-QRBzFNaT2ev_w@mail.gmail.com>
 <20120502192325.GA18339@quack.suse.cz> <CAHGf_=oOx1qPFEboQeuaeMKtveM2==BSDG=xdfRHz+gFx1GAfw@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Sat, 5 May 2012 23:28:13 +1200
Message-ID: <CAKgNAkjybL_hmVfONUHtCbBe_VxQHNHOrmWQErGWDUqHiczkFg@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Nick Piggin <npiggin@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On Thu, May 3, 2012 at 7:25 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> On Wed, May 2, 2012 at 3:23 PM, Jan Kara <jack@suse.cz> wrote:
>> On Wed 02-05-12 15:14:33, KOSAKI Motohiro wrote:
>>> Hello,
>>>
>>> >> I see what you mean.
>>> >>
>>> >> I'm not sure, though. For most apps it's bad practice I think. If yo=
u get into
>>> >> realm of sophisticated, performance critical IO/storage managers, it=
 would
>>> >> not surprise me if such concurrent buffer modifications could be all=
owed.
>>> >> We allow exactly such a thing in our pagecache layer. Although proba=
bly
>>> >> those would be using shared mmaps for their buffer cache.
>>> >>
>>> >> I think it is safest to make a default policy of asking for IOs agai=
nst private
>>> >> cow-able mappings to be quiesced before fork, so there are no surpri=
ses
>>> >> or reliance on COW details in the mm. Do you think?
>>> > =A0 =A0Yes, I agree that (and MADV_DONTFORK) is probably the best thi=
ng to have
>>> > in documentation. Otherwise it's a bit too hairy...
>>>
>>> I neglected this issue for years because Linus asked who need this and
>>> I couldn't
>>> find real world usecase.
>>>
>>> Ah, no, not exactly correct. Fujitsu proprietary database had such
>>> usecase. But they quickly fixed it. Then I couldn't find alternative us=
ecase.
>> =A0One of our customers hit this bug recently which is why I started to =
look
>> at this. But they also modified their application not to hit the problem=
.
>>
>>> I'm not sure why you say "hairy". Do you mean you have any use case of =
this?
>> =A0I meant that if we should describe conditions like "if you have page
>> aligned buffer and you don't write to it while the IO is running, the
>> problem also won't occur", then it's already too detailed and might
>> easily change in future kernels...

So, am I correct to assume that right text to add to the page is as below?

Nick, can you clarify what you mean by "quiesced"?

[[
O_DIRECT IOs should never be run concurrently with fork(2) system call,
when the memory buffer is anonymous memory, or comes from mmap(2)
with MAP_PRIVATE.

Any such IOs, whether submitted with asynchronous IO interface or from
another thread in the process, should be quiesced before fork(2) is called.
Failure to do so can result in data corruption and undefined behavior in
parent and child processes.

This restriction does not apply when the memory buffer for the O_DIRECT
IOs comes from mmap(2) with MAP_SHARED or from shmat(2).
Nor does this restriction apply when the memory buffer has been advised
as MADV_DONTFORK with madvise(2), ensuring that it will not be available
to the child after fork(2).
]]

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
