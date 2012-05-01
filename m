Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D81146B0083
	for <linux-mm@kvack.org>; Tue,  1 May 2012 11:38:37 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
	<CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
	<CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
	<x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com>
	<CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
Date: Tue, 01 May 2012 11:38:33 -0400
In-Reply-To: <CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
	(KOSAKI Motohiro's message of "Tue, 1 May 2012 11:34:04 -0400")
Message-ID: <x491un3nc7a.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, npiggin@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

KOSAKI Motohiro <kosaki.motohiro@gmail.com> writes:

> On Tue, May 1, 2012 at 11:11 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
>> KOSAKI Motohiro <kosaki.motohiro@gmail.com> writes:
>>
>>>> Hello,
>>>>
>>>> Thank you revisit this. But as far as my remember is correct, this iss=
ue is NOT
>>>> unaligned access issue. It's just get_user_pages(_fast) vs fork race i=
ssue. i.e.
>>>> DIRECT_IO w/ multi thread process should not use fork().
>>>
>>> The problem is, fork (and its COW logic) assume new access makes cow br=
eak,
>>> But page table protection can't detect a DMA write. Therefore DIO may o=
verride
>>> shared page data.
>>
>> Hm, I've only seen this with misaligned or multiple sub-page-sized reads
>> in the same page. =C2=A0AFAIR, aligned, page-sized I/O does not get spli=
t.
>> But, I could be wrong...
>
> If my remember is correct, the reproducer of past thread is misleading.
>
> dma_thread.c in
> http://lkml.indiana.edu/hypermail/linux/kernel/0903.1/01498.html has
> align parameter. But it doesn't only change align. Because of, every
> worker thread read 4K (pagesize), then
>  - when offset is page aligned
>     -> every page is accessed from only one worker
>  - when offset is not page aligned
>     -> every page is accessed from two workers
>
> But I don't remember why two threads are important things. hmm.. I'm
> looking into the code a while.
> Please don't 100% trust me.

I bet Andrea or Larry would remember the details.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
