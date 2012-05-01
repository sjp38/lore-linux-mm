Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 41C5F6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 11:50:47 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so3633683obb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 08:50:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x491un3nc7a.fsf@segfault.boston.devel.redhat.com>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
	<CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
	<CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
	<x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com>
	<CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
	<x491un3nc7a.fsf@segfault.boston.devel.redhat.com>
Date: Wed, 2 May 2012 01:50:46 +1000
Message-ID: <CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On 2 May 2012 01:38, Jeff Moyer <jmoyer@redhat.com> wrote:
> KOSAKI Motohiro <kosaki.motohiro@gmail.com> writes:
>
>> On Tue, May 1, 2012 at 11:11 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
>>> KOSAKI Motohiro <kosaki.motohiro@gmail.com> writes:
>>>
>>>>> Hello,
>>>>>
>>>>> Thank you revisit this. But as far as my remember is correct, this is=
sue is NOT
>>>>> unaligned access issue. It's just get_user_pages(_fast) vs fork race =
issue. i.e.
>>>>> DIRECT_IO w/ multi thread process should not use fork().
>>>>
>>>> The problem is, fork (and its COW logic) assume new access makes cow b=
reak,
>>>> But page table protection can't detect a DMA write. Therefore DIO may =
override
>>>> shared page data.
>>>
>>> Hm, I've only seen this with misaligned or multiple sub-page-sized read=
s
>>> in the same page. =C2=A0AFAIR, aligned, page-sized I/O does not get spl=
it.
>>> But, I could be wrong...
>>
>> If my remember is correct, the reproducer of past thread is misleading.
>>
>> dma_thread.c in
>> http://lkml.indiana.edu/hypermail/linux/kernel/0903.1/01498.html has
>> align parameter. But it doesn't only change align. Because of, every
>> worker thread read 4K (pagesize), then
>> =C2=A0- when offset is page aligned
>> =C2=A0 =C2=A0 -> every page is accessed from only one worker
>> =C2=A0- when offset is not page aligned
>> =C2=A0 =C2=A0 -> every page is accessed from two workers
>>
>> But I don't remember why two threads are important things. hmm.. I'm
>> looking into the code a while.
>> Please don't 100% trust me.
>
> I bet Andrea or Larry would remember the details.

KOSAKI-san is correct, I think.

The race is something like this:

DIO-read
    page =3D get_user_pages()
                                                        fork()
                                                            COW(page)
                                                         touch(page)
    DMA(page)
    page_cache_release(page);

So whether parent or child touches the page, determines who gets the
actual DMA target, and who gets the copy.

2 threads are not required, but it makes the race easier to code and a
larger window, I suspect.

It can also be hit with a single thread, using AIO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
