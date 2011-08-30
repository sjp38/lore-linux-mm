Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFDE900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 02:08:24 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p7U68LJr025600
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 23:08:21 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by hpaq11.eem.corp.google.com with ESMTP id p7U68HFj017207
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 23:08:19 -0700
Received: by qwh5 with SMTP id 5so3612851qwh.6
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 23:08:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110829075731.GA32114@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
	<20110811210914.GB31229@cmpxchg.org>
	<CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
	<CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
	<20110829075731.GA32114@cmpxchg.org>
Date: Mon, 29 Aug 2011 23:08:16 -0700
Message-ID: <CALWz4iw4ojn7GUJgWDV9wqGeXf-Oy0uDx0yJUhJpkuP5tffMwA@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 12:57 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
>
> On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> > fix hierarchy_walk() to hold a reference to first mem_cgroup
> >
> > The first mem_cgroup returned from hierarchy_walk() is used to
> > terminate a round-trip. However there is no reference hold on
> > that which the first could be removed during the walking. The
> > patch including the following change:
> >
> > 1. hold a reference on the first mem_cgroup during the walk.
> > 2. rename the variable "root" to "target", which we found using
> > "root" is confusing in this content with root_mem_cgroup. better
> > naming is welcomed.
>
> Thanks for the report.
>
> This was actually not the only case that could lead to overlong (not
> necessarily endless) looping.
>
> With several scanning threads, a single thread may not encounter its
> first cgroup again for a long time, as the other threads would visit
> it.

Yes, that makes sense. And I think i found a issue on my patch which
it leaks reference count on the mem (first) which I can not do "rmdir"
after some memory pressure tests. So, please ignore the patch for now.

>
> I changed this to use scan generations. =A0Restarting the scan from id 0
> starts the next scan generation. =A0The iteration function returns NULL
> if the generation changed since a loop was started.
>
> This way, iterators can reliably detect whether they should call it
> quits without any requirements for previously encountered memcgs.

Ok, so if I have multiple threads hitting pressure under the same zone
and same memcg hierarchy tree, they all contribute to the single
iteration loop. And all the reclaimers will terminate if they together
made a full iteration under the hierarchy?

If so, i will look at your patch and no need for the fix i posted
early on. Meanwhile, I would be interested to look at some performance
data since the later one should save some cpu cycles going through
more memcgs than after the change.

Thanks

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
