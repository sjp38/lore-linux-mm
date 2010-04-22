Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 814C56B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:18:16 -0400 (EDT)
Received: by pwi10 with SMTP id 10so23340pwi.14
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 07:18:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100422141404.GA30306@csn.ul.ie>
References: <alpine.DEB.2.00.1004211004360.4959@router.home>
	 <alpine.DEB.2.00.1004211027120.4959@router.home>
	 <20100421153421.GM30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211038020.4959@router.home>
	 <20100422092819.GR30306@csn.ul.ie>
	 <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
	 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100422141404.GA30306@csn.ul.ie>
Date: Thu, 22 Apr 2010 23:18:14 +0900
Message-ID: <p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 11:14 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Apr 22, 2010 at 07:51:53PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Thu, 22 Apr 2010 19:31:06 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > On Thu, 22 Apr 2010 19:13:12 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
>> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > > > Hmm..in my test, the case was.
>> > > >
>> > > > Before try_to_unmap:
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0mapcount=3D1, SwapCache, remap_swapcach=
e=3D1
>> > > > After remap
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0mapcount=3D0, SwapCache, rc=3D0.
>> > > >
>> > > > So, I think there may be some race in rmap_walk() and vma handling=
 or
>> > > > anon_vma handling. migration_entry isn't found by rmap_walk.
>> > > >
>> > > > Hmm..it seems this kind patch will be required for debug.
>> > >
>>
>> Ok, here is my patch for _fix_. But still testing...
>> Running well at least for 30 minutes, where I can see bug in 10minutes.
>> But this patch is too naive. please think about something better fix.
>>
>> =3D=3D
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> At adjust_vma(), vma's start address and pgoff is updated under
>> write lock of mmap_sem. This means the vma's rmap information
>> update is atoimic only under read lock of mmap_sem.
>>
>>
>> Even if it's not atomic, in usual case, try_to_ummap() etc...
>> just fails to decrease mapcount to be 0. no problem.
>>
>> But at page migration's rmap_walk(), it requires to know all
>> migration_entry in page tables and recover mapcount.
>>
>> So, this race in vma's address is critical. When rmap_walk meet
>> the race, rmap_walk will mistakenly get -EFAULT and don't call
>> rmap_one(). This patch adds a lock for vma's rmap information.
>> But, this is _very slow_.
>
> Ok wow. That is exceptionally well-spotted. This looks like a proper bug
> that compaction exposes as opposed to a bug that compaction introduces.
>
>> We need something sophisitcated, light-weight update for this..
>>
>
> In the event the VMA is backed by a file, the mapping i_mmap_lock is take=
n for
> the duration of the update and is =C2=A0taken elsewhere where the VMA inf=
ormation
> is read such as rmap_walk_file()
>
> In the event the VMA is anon, vma_adjust currently talks no locks and you=
r
> patch introduces a new one but why not use the anon_vma lock here? Am I
> missing something that requires the new lock?

rmap_walk_anon doesn't hold vma's anon_vma->lock.
It holds page->anon_vma->lock.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
