Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF90A6B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 06:14:24 -0500 (EST)
Received: by iwn40 with SMTP id 40so4107215iwn.14
        for <linux-mm@kvack.org>; Mon, 24 Jan 2011 03:14:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110124104510.GW2232@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
	<20110124101402.GT2232@cmpxchg.org>
	<20110124191535.514ef2d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110124104510.GW2232@cmpxchg.org>
Date: Mon, 24 Jan 2011 20:14:22 +0900
Message-ID: <AANLkTi=sg5HpCTdXgEVYS5rCqtoVVho6dxn8giwZ4kmY@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg : comment, style fixes for recent patch of move_parent
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2011/1/24 Johannes Weiner <hannes@cmpxchg.org>:
> On Mon, Jan 24, 2011 at 07:15:35PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Mon, 24 Jan 2011 11:14:02 +0100
>> Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>> > On Fri, Jan 21, 2011 at 03:37:26PM +0900, KAMEZAWA Hiroyuki wrote:
>> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > >
>> > > A fix for 987eba66e0e6aa654d60881a14731a353ee0acb4
>> > >
>> > > A clean up for mem_cgroup_move_parent().
>> > > =A0- remove unnecessary initialization of local variable.
>> > > =A0- rename charge_size -> page_size
>> > > =A0- remove unnecessary (wrong) comment.
>> > >
>> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > > ---
>> > > =A0mm/memcontrol.c | =A0 17 +++++++++--------
>> > > =A01 file changed, 9 insertions(+), 8 deletions(-)
>> > >
>> > > Index: mmotm-0107/mm/memcontrol.c
>> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > > --- mmotm-0107.orig/mm/memcontrol.c
>> > > +++ mmotm-0107/mm/memcontrol.c
>> > > @@ -2265,7 +2265,7 @@ static int mem_cgroup_move_parent(struct
>> > > =A0 struct cgroup *cg =3D child->css.cgroup;
>> > > =A0 struct cgroup *pcg =3D cg->parent;
>> > > =A0 struct mem_cgroup *parent;
>> > > - int charge =3D PAGE_SIZE;
>> > > + int page_size;
>> > > =A0 unsigned long flags;
>> > > =A0 int ret;
>> > >
>> > > @@ -2278,22 +2278,23 @@ static int mem_cgroup_move_parent(struct
>> > > =A0 =A0 =A0 =A0 =A0 goto out;
>> > > =A0 if (isolate_lru_page(page))
>> > > =A0 =A0 =A0 =A0 =A0 goto put;
>> > > - /* The page is isolated from LRU and we have no race with splittin=
g */
>> > > - charge =3D PAGE_SIZE << compound_order(page);
>> > > +
>> > > + page_size =3D PAGE_SIZE << compound_order(page);
>> >
>> > Okay, so you remove the wrong comment, but that does not make the code
>> > right. =A0What protects compound_order from reading garbage because th=
e
>> > page is currently splitting?
>> >
>>
>> =3D=3D
>> static int mem_cgroup_move_account(struct page_cgroup *pc,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *from, struct mem_cgro=
up *to,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool uncharge, int charge_size)
>> {
>> =A0 =A0 =A0 =A0 int ret =3D -EINVAL;
>> =A0 =A0 =A0 =A0 unsigned long flags;
>>
>> =A0 =A0 =A0 =A0 if ((charge_size > PAGE_SIZE) && !PageTransHuge(pc->page=
))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>> =3D=3D
>>
>> This is called under compound_lock(). Then, if someone breaks THP,
>> -EBUSY and retry.
>
> This charge_size contains exactly the garbage you just read from an
> unprotected compound_order(). =A0It could be anything if the page is
> split concurrently.

Then, my recent fix to LRU accounting which use compound_order() is racy, t=
oo ?

I'll replace compound_order() with
  if (PageTransHuge(page))
      size =3D HPAGE_SIZE.

Does this work ?
If there are no way to aquire size of page without lock, I need to add one.
Any idea?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
