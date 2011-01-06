Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11D1B6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 21:51:21 -0500 (EST)
Received: by iwn40 with SMTP id 40so16646917iwn.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 18:51:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106095211.b35f012b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
	<20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
	<20110106095211.b35f012b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 6 Jan 2011 11:51:20 +0900
Message-ID: <AANLkTinimmHnNJrbDNefN+H6p=ZPDg_SfY4YYO_XW-kV@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 6, 2011 at 9:52 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 5 Jan 2011 15:47:48 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>
>> On Wed, 5 Jan 2011 13:48:50 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> > Hi,
>> >
>> > On Wed, Jan 5, 2011 at 1:00 PM, Daisuke Nishimura
>> > <nishimura@mxp.nes.nec.co.jp> wrote:
>> > > Hi.
>> > >
>> > > This is a fix for a problem which has bothered me for a month.
>> > >
>> > > =3D=3D=3D
>> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> > >
>> > > In current implimentation, mem_cgroup_end_migration() decides whethe=
r the page
>> > > migration has succeeded or not by checking "oldpage->mapping".
>> > >
>> > > But if we are tring to migrate a shmem swapcache, the page->mapping =
of it is
>> > > NULL from the begining, so the check would be invalid.
>> > > As a result, mem_cgroup_end_migration() assumes the migration has su=
cceeded
>> > > even if it's not, so "newpage" would be freed while it's not uncharg=
ed.
>> > >
>> > > This patch fixes it by passing mem_cgroup_end_migration() the result=
 of the
>> > > page migration.
>> > >
>> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> >
>> > Nice catch. I don't oppose the patch.
>> Thank you for your review.
>>
>
> Nice catch.
>
>
>> > But as looking the code in unmap_and_move, I feel part of mem cgroup
>> > migrate is rather awkward.
>> >
>> > int unmap_and_move()
>> > {
>> > =A0 =A0charge =3D mem_cgroup_prepare_migration(xxx);
>> > =A0 =A0..
>> > =A0 =A0BUG_ON(charge); <-- BUG if it is charged?
>> > =A0 =A0..
>> > uncharge:
>> > =A0 =A0if (!charge) =A0 =A0<-- why do we have to uncharge !charge?
>> > =A0 =A0 =A0 mem_group_end_migration(xxx);
>> > =A0 =A0..
>> > }
>> >
>> > 'charge' local variable isn't good. How about changing "uncharge" or w=
hatever?
>> hmm, I agree that current code seems a bit confusing, but I can't think =
of
>> better name to imply the result of 'charge'.
>>
>> And considering more, I can't understand why we need to check "if (!char=
ge)"
>> before mem_cgroup_end_migration() becase it must be always true and, IMH=
O,
>> mem_cgroup_end_migration() should do all necesarry checks to avoid doubl=
e uncharge.
>
> ok, please remove it.
> Before this commit, http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/=
linux-2.6.git;a=3Dcommitdiff;h=3D01b1ae63c2270cbacfd43fea94578c17950eb548;h=
p=3Dbced0520fe462bb94021dcabd32e99630c171be2
>
> "mem" is not passed as argument and this was the reason for the vairable =
"charge".
>
> We can check "charge is in moving" by checking "mem =3D=3D NULL".

I will send the patch after Andrew picks Daisuke's patch up.
Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
