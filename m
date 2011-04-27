Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8469000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:15:58 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3R1FsbU030295
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:15:56 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by kpbe12.cbf.corp.google.com with ESMTP id p3R1FZWx004554
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:15:53 -0700
Received: by qyk2 with SMTP id 2so1670375qyk.7
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:15:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427094902.D170.A69D9226@jp.fujitsu.com>
References: <20110426101631.F34C.A69D9226@jp.fujitsu.com>
	<BANLkTikteGwLXiG9GVDrMkrruUoTieADfQ@mail.gmail.com>
	<20110427094902.D170.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 18:15:52 -0700
Message-ID: <BANLkTin+UxRdkPDdu322jqSv1FV6WSYtYg@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, Apr 26, 2011 at 5:47 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > =A0{
>> > > =A0 =A0 =A0 struct xfs_mount *mp;
>> > > =A0 =A0 =A0 struct xfs_perag *pag;
>> > > =A0 =A0 =A0 xfs_agnumber_t =A0ag;
>> > > =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 reclaimable;
>> > > + =A0 =A0 int nr_to_scan =3D sc->nr_slab_to_reclaim;
>> > > + =A0 =A0 gfp_t gfp_mask =3D sc->gfp_mask;
>> >
>> > And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim
>> > poped up new question.
>> > Why don't we pass more clever slab shrinker target? Why do we need pas=
s
>> > similar two argument?
>> >
>>
>> I renamed the nr_slab_to_reclaim and nr_scanned in shrink struct.
>
> Oh no. that's not naming issue. example, Nick's previous similar patch pa=
ss
> zone-total-pages and how-much-scanned-pages. (ie shrink_slab don't calcul=
ate
> current magical target scanning objects anymore)
> =A0 =A0 =A0 =A0ie, =A0"4 * =A0max_pass =A0* (scanned / nr- lru_pages-in-z=
ones)"
>
> Instead, individual shrink_slab callback calculate this one.
> see git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.g=
it
>
> I'm curious why you change the design from another guy's previous very si=
milar effort and
> We have to be convinced which is better.

Thank you for the pointer. My patch is intended to consolidate all
existing parameters passed from reclaim code
to the shrinker.

Talked w/ Nick and Andrew from last LSF,  we agree that this patch
will be useful for other extensions later which allows us easily
adding extensions to the shrinkers without shrinker files. Nick and I
talked about the effort later to pass the nodemask down to the
shrinker. He is cc-ed in the thread. Another thing I would like to
repost is to add the reclaim priority down to the shrinker, which we
won't throw tons of page caches pages by reclaiming one inode slab
object.

--Ying



>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
