Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A40C6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 05:27:36 -0500 (EST)
Message-ID: <4EC63304.1060709@redhat.com>
Date: Fri, 18 Nov 2011 18:27:16 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com> <4EC361C0.7040309@redhat.com> <alpine.LFD.2.02.1111160911320.2446@tux.localdomain> <4EC3633D.6090900@redhat.com> <alpine.LSU.2.00.1111161634360.1957@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1111161634360.1957@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kay.sievers@vrfy.org

ao? 2011a1'11ae??17ae?JPY 09:31, Hugh Dickins a??e??:
> On Wed, 16 Nov 2011, Cong Wang wrote:
>> ao? 2011a1'11ae??16ae?JPY 15:12, Pekka Enberg a??e??:
>>> On Wed, 16 Nov 2011, Cong Wang wrote:
>>>>> What's the use case for this?
>>>>
>>>> Systemd needs it, see http://lkml.org/lkml/2011/10/20/275.
>>>> I am adding Kay into Cc.
>>>
>>> The post doesn't mention why it needs it, though.
>>>
>>
>> Right, I should mention this in the changelog. :-/
>
> Yes, but I think Pekka's point is that the page which you link to does not
> explain why Plumbers would want tmpfs to support fallocate() properly.
>
> What good is it going to do for them?  Why not just do it in userspace,
> either by dd if=/dev/zero of=tmpfsfile, or by mmap() and touch if very
> anxious to avoid the triple memset/memcpy (once reading from /dev/zero,
> once allocating tmpfs pages, once copying to tmpfs pages)?  Or splice().


It is not hard at all to implement this in kernel space, so this
will make systemd a little happier.

>
> I don't want to stand in the way of progress, but there's a lot of
> things tmpfs does not support (a persistent filesystem would be top
> of the list; but readahead, direct I/O, AIO, ....), and it may be
> better to continue not to support them unless there's good reason.
> tmpfs does not have a disk layout that we need to optimize.


True, and no one requests for these features so far? As systemd
developers need this light feature, fallocate, and it is not hard
to implement it, so why not? ;)

>
> I did not study your implementation in detail, but agree with Dave
> and Kame that (if it needs to be in kernel at all) you should reuse
> the existing code rather than repeating extracts: shmem_getpage_gfp()
> is the one place which looks after all of shmem page allocation, so
> I'd prefer you just make a loop of calls to that (with a new sgp_type
> if there's particular reason to do something differently in there).


Yes, while reworking on this patch, I did exactly what you said.

>
> I've not yet looked up the specification of fallocate(), but it
> looked surprising to be allocating pages up to the point where a
> page already exists (when shmem_add_to_page_cache will fail) and
> then giving up with -EEXIST.

You are right, I need to fix this.

>
> Seeing your Subject, I imagined at first that you would be implementing
> FALLOC_FL_PUNCH_HOLE support. That is on my list to do: tmpfs has its
> own peculiar madvise(MADV_REMOVE) support (and yes, you may question
> whether we were right to add that in) - we should be converting
> MADV_REMOVE to use FALLOC_FL_PUNCH_HOLE, and tmpfs to support that.
>

I will add this in my V2 patch.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
