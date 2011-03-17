Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B30018D003F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:46:28 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p2HFkPhQ020550
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 08:46:25 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe19.cbf.corp.google.com with ESMTP id p2HFjm9A016847
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 08:46:24 -0700
Received: by qyk10 with SMTP id 10so2505681qyk.11
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 08:46:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
Date: Thu, 17 Mar 2011 08:46:23 -0700
Message-ID: <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple approach)
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Jan:

On Tue, Mar 8, 2011 at 2:31 PM, Jan Kara <jack@suse.cz> wrote:
>
> =A0Hello,
>
> =A0I'm posting second version of my IO-less balance_dirty_pages() patches=
. This
> is alternative approach to Fengguang's patches - much simpler I believe (=
only
> 300 lines added) - but obviously I does not provide so sophisticated cont=
rol.
> Fengguang is currently running some tests on my patches so that we can co=
mpare
> the approaches.
>
> The basic idea (implemented in the third patch) is that processes throttl=
ed
> in balance_dirty_pages() wait for enough IO to complete. The waiting is
> implemented as follows: Whenever we decide to throttle a task in
> balance_dirty_pages(), task adds itself to a list of tasks that are throt=
tled
> against that bdi and goes to sleep waiting to receive specified amount of=
 page
> IO completions. Once in a while (currently HZ/10, in patch 5 the interval=
 is
> autotuned based on observed IO rate), accumulated page IO completions are
> distributed equally among waiting tasks.
>
> This waiting scheme has been chosen so that waiting time in
> balance_dirty_pages() is proportional to
> =A0number_waited_pages * number_of_waiters.
> In particular it does not depend on the total number of pages being waite=
d for,
> thus providing possibly a fairer results.
>
> Since last version I've implemented cleanups as suggested by Peter Zilstr=
a.
> The patches undergone more throughout testing. So far I've tested differe=
nt
> filesystems (ext2, ext3, ext4, xfs, nfs), also a combination of a local
> filesystem and nfs. The load was either various number of dd threads or
> fio with several threads each dirtying pages at different speed.
>
> Results and test scripts can be found at
> =A0http://beta.suse.com/private/jack/balance_dirty_pages-v2/
> See README file for some explanation of test framework, tests, and graphs=
.
> Except for ext3 in data=3Dordered mode, where kjournald creates high
> fluctuations in waiting time of throttled processes (and also high latenc=
ies),
> the results look OK. Parallel dd threads are being throttled in the same =
way
> (in a 2s window threads spend the same time waiting) and also latencies o=
f
> individual waits seem OK - except for ext3 they fit in 100 ms for local
> filesystems. They are in 200-500 ms range for NFS, which isn't that nice =
but
> to fix that we'd have to modify current ratelimiting scheme to take into
> account on which bdi a page is dirtied. Then we could ratelimit slower BD=
Is
> more often thus reducing latencies in individual waits...
>
> The results for different bandwidths fio load is interesting. There are 8
> threads dirtying pages at 1,2,4,..,128 MB/s rate. Due to different task
> bdi dirty limits, what happens is that three most aggresive tasks get
> throttled so they end up at bandwidths 24, 26, and 30 MB/s and the lighte=
r
> dirtiers run unthrottled.
>
> I'm planning to run some tests with multiple SATA drives to verify whethe=
r
> there aren't some unexpected fluctuations. But currently I have some trou=
ble
> with the HW...
>
> As usual comments are welcome :).

The design of IO-less foreground throttling of writeback in the context of
memory cgroups is being discussed in the memcg patch threads (e.g.,
"[PATCH v6 0/9] memcg: per cgroup dirty page accounting"), but I've got
another concern as well.  And that's how restricting per-BDI writeback to a
single task will affect proposed changes for tracking and accounting of
buffered writes to the IO scheduler ("[RFC] [PATCH 0/6] Provide cgroup
isolation for buffered writes", https://lkml.org/lkml/2011/3/8/332 ).

It seems totally reasonable that reducing competition for write requests to
a BDI -- by using the flusher thread to "handle" foreground writeout --
would increase throughput to that device.  At Google, we experiemented with
this in a hacked-up fashion several months ago (FG task would enqueue a wor=
k
item and sleep for some period of time, wake up and see if it was below the
dirty limit), and found that we were indeed getting better throughput.

But if one of one's goals is to provide some sort of disk isolation based o=
n
cgroup parameters, than having at most one stream of write requests
effectively neuters the IO scheduler.  We saw that in practice, which led t=
o
abandoning our attempt at "IO-less throttling."

One possible solution would be to put some of the disk isolation smarts int=
o
the writeback path, so the flusher thread could choose inodes with this as =
a
criteria, but this seems ugly on its face, and makes my head hurt.

Otherwise, I'm having trouble thinking of a way to do effective isolation i=
n
the IO scheduler without having competing threads -- for different cgroups =
--
making write requests for buffered data.  Perhaps the best we could do woul=
d
be to enable IO-less throttling in writeback as a config option?

Thoughts?

Thanks,
Curt

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
