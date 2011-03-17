Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 097258D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 14:55:47 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p2HIta6x029662
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:55:36 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe16.cbf.corp.google.com with ESMTP id p2HIsdnt012969
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:55:35 -0700
Received: by qwk3 with SMTP id 3so2640628qwk.33
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:55:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110317173223.GG4116@quack.suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
	<AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
	<20110317173223.GG4116@quack.suse.cz>
Date: Thu, 17 Mar 2011 11:55:34 -0700
Message-ID: <AANLkTimwUrvyEJdF7s2XZCv4JaC_rsTA1Rg9u68xMs=O@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple approach)
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 17, 2011 at 10:32 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 17-03-11 08:46:23, Curt Wohlgemuth wrote:
>> On Tue, Mar 8, 2011 at 2:31 PM, Jan Kara <jack@suse.cz> wrote:
>> The design of IO-less foreground throttling of writeback in the context =
of
>> memory cgroups is being discussed in the memcg patch threads (e.g.,
>> "[PATCH v6 0/9] memcg: per cgroup dirty page accounting"), but I've got
>> another concern as well. =A0And that's how restricting per-BDI writeback=
 to a
>> single task will affect proposed changes for tracking and accounting of
>> buffered writes to the IO scheduler ("[RFC] [PATCH 0/6] Provide cgroup
>> isolation for buffered writes", https://lkml.org/lkml/2011/3/8/332 ).
>>
>> It seems totally reasonable that reducing competition for write requests=
 to
>> a BDI -- by using the flusher thread to "handle" foreground writeout --
>> would increase throughput to that device. =A0At Google, we experiemented=
 with
>> this in a hacked-up fashion several months ago (FG task would enqueue a =
work
>> item and sleep for some period of time, wake up and see if it was below =
the
>> dirty limit), and found that we were indeed getting better throughput.
>>
>> But if one of one's goals is to provide some sort of disk isolation base=
d on
>> cgroup parameters, than having at most one stream of write requests
>> effectively neuters the IO scheduler. =A0We saw that in practice, which =
led to
>> abandoning our attempt at "IO-less throttling."

> =A0Let me check if I understand: The problem you have with one flusher
> thread is that when written pages all belong to a single memcg, there is
> nothing IO scheduler can prioritize, right?

Correct.  Well, perhaps.  Given that the memory cgroups and the IO
cgroups may not overlap, it's possible that write requests from a
single memcg might be targeted to multiple IO cgroups, and scheduling
priorities can be maintained.  Of course, the other way round might be
the case as well.

The point is just that from however many memcgs the flusher thread is
working on behalf of, there's only a single stream of requests, which
are *likely* for a single IO cgroup, and hence there's nothing to
prioritize.

>> One possible solution would be to put some of the disk isolation smarts =
into
>> the writeback path, so the flusher thread could choose inodes with this =
as a
>> criteria, but this seems ugly on its face, and makes my head hurt.
> =A0Well, I think it could be implemented in a reasonable way but then you
> still miss reads and direct IO from the mix so it will be a poor isolatio=
n.

Um, not really, would it?  Presumably there are separate tasks
(directly) issuing simultaneous requests for reads, and DIO writes;
these should interact just fine with writes from the single flusher
thread.

> But maybe we could propagate the information from IO scheduler to flusher
> thread? If IO scheduler sees memcg has run out of its limit, it could hin=
t
> to a flusher thread that it should switch to an inode from a different me=
mcg.
> But still the details get nasty as I think about them (how to pick next
> memcg, how to pick inodes,...). Essentially, we'd have to do with flusher
> threads what old pdflush did when handling congested devices. Ugh.

Yeah, plus what I said above, that memcgs and IO cgroups aren't
necessarily the same cgroups.

>> Otherwise, I'm having trouble thinking of a way to do effective isolatio=
n in
>> the IO scheduler without having competing threads -- for different cgrou=
ps --
>> making write requests for buffered data. =A0Perhaps the best we could do=
 would
>> be to enable IO-less throttling in writeback as a config option?

> =A0Well, nothing prevents us to choose to do foreground writeback throttl=
ing
> for memcgs and IO-less one without them but as Christoph writes, this
> doesn't seem very compeling either... I'll let this brew in my head for
> some time and maybe something comes.

I agree with Christoph too; I mainly wanted to get the issue out
there, and will be thinking on it more as well.

Thanks,
Curt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
