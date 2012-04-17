Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 7A8F46B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 11:21:10 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f81dcf86-fb34-4e39-923b-3fd1862e60c6@default>
Date: Tue, 17 Apr 2012 08:20:58 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Followup: [PATCH -mm] make swapin readahead skip over holes
References: <7297ae3b-f3e1-480b-838f-69b0e09a733d@default>
 <4F8C7D59.1000402@redhat.com>
In-Reply-To: <4F8C7D59.1000402@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: Followup: [PATCH -mm] make swapin readahead skip over holes
>=20
> On 04/16/2012 02:34 PM, Dan Magenheimer wrote:
> > Hi Rik --
> >
> > For values of N=3D24 and N=3D28, your patch made the workload
> > run 4-9% percent faster.  For N=3D16 and N=3D20, it was 5-10%
> > slower.  And for N=3D36 and N=3D40, it was 30%-40% slower!
> >
> > Is this expected?  Since the swap "disk" is a partition
> > on the one active drive, maybe the advantage is lost due
> > to contention?
>=20
> There are several things going on here:
>=20
> 1) you are running a workload that thrashes
>=20
> 2) the speed at which data is swapped in is increased
>     with this patch
>=20
> 3) with only 1GB memory, the inactive anon list is
>     the same size as the active anon list
>=20
> 4) the above points combined mean that less of the
>     working set could be in memory at once
>=20
> One solution may be to decrease the swap cluster for
> small systems, when they are thrashing.
>=20
> On the other hand, for most systems swap is very much
> a special circumstance, and you want to focus on quickly
> moving excess stuff into swap, and moving it back into
> memory when needed.

Hmmm... as I look at this patch more, I think I get a
picture of what's going on and I'm still concerned.
Please correct me if I am misunderstanding:

What the patch does is increase the average size of
a "cluster" of sequential pages brought in per "read"
from the swap device.  As a result there are more pages
brought back into memory "speculatively" because it is
presumably cheaper to bring in more pages per disk seek,
even if it results in a lower "swapcache hit rate".
In effect, you've done the equivalent of increasing the
default swap cluster size (on average).

If the above is wrong, please cut here and ignore
the following. :-)  But in case it is right (or
close enough), let me continue...

In other words, you are both presuming a "swap workload"
that is more sequential than random for which this patch
improves performance, and assuming a "swap device"=20
for which the cost of a seek is high enough to overcome
the costs of filling the swap cache with pages that won't
be used.

While it is easy to write a simple test/benchmark that
swaps a lot (and we probably all have similar test code
that writes data into a huge bigger-than-RAM array and then
reads it back), such a test/benchmark is usually sequential,
so one would assume most swap testing is done with a
sequential-favoring workload.  The kernbench workload
apparently exercises swap quite a bit more randomly and
your patch makes it run slower for low and high levels
of swapping, while faster for moderate swapping.

I also suspect (without proof) that the patch will
result in lower performance on non-rotating devices, such
as SSDs.

(Sure one can change the swap cluster size to 1, but how
many users or even sysadmins know such a thing even
exists... so the default is important.)

I'm no I/O expert, but I suspect if one of the Linux
I/O developers proposed a patch that unilaterally made
all sequential I/O faster and all random I/O slower,
it would get torn to pieces.

I'm certainly not trying to tear your patch to pieces,
just trying to evaluate it.  Hope that's OK.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
