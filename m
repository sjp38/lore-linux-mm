Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 465226B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 03:50:26 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Date: Mon, 9 Jan 2012 08:49:41 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904554A01@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195612.GB19181@suse.de>
 <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
 <4F063FC0.8000907@gmail.com>
In-Reply-To: <4F063FC0.8000907@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: ext KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
> Sent: 06 January, 2012 02:27
> To: Moiseichuk Leonid (Nokia-MP/Helsinki)
=20
> > Android OOM (AOOM) is a different thing. Briefly Android OOM is a safet=
y
> belt,
> >but I try to introduce look-ahead radar to stop before hitting wall.
>=20
> You explained why we shouldn't merge neither you nor android notification
> patches.
> Many embedded developers tried to merge their own patch and claimed
> "Hey! my patch
> is completely different from another one". That said, their patches can't=
 be
> used
> each other use case, just for them.

Pardon me but these patches doing really different thing. Having notificati=
on doesn't mean all you software will handle them correct. In open platform=
 you might have "bad entity" which will be killed by OOM.
In we used default OOM killer but Android OOM probably works better in some=
 other conditions even from my point of view it may trigger false OOMs due =
to base on NR_FREE_PAGES which are more interesting for kernel for than for=
 user-space.=20

> Systemwide global notification itself is not bad idea. But we definitely =
choose
> just one implementation. thus, you need to get agree with other embedded
> people.

Agree. That is point for discussion. One is already available through memcg=
 but problem is in memcg and how we use it.

> >  UsedMemory =3D (MemTotal - MemFree - Buffers - Cached - SwapCached) +
> >                                               (SwapTotal - SwapFree)
>=20
> If you spent a few time to read past discuttion, you should have understa=
nd
> your fomula
> is broken and unacceptable. Think, mlocked (or pinning by other way) cach=
e
> can't be discarded.=20

In theory you are right about mlocked pages.  So I will add deduction for N=
R_MLOCK
In practice typical desktop system has mlocked =3D 0. Also code pages are s=
hared, so mlocking has 0 effect.
For data pages the some library like http://maemo.gitorious.org/maemo-tools=
/libmlocknice could be used.
Anyhow, on  n9 we have only  5.3 MB mlocked memory from 1024MB.

> And, When system is under swap thrashing, userland notification is useles=
s.

Well, cgroups CPU shares and ionice seems to me better but as a quick solut=
ion extension with LRU_ACTIVE_ANON + LRU_ACTIVE_FILE could be done easily.

>  I don't think you tested w/ swap environment heavily.

n770, n800, n810 have optional in-file swapping.
n900 has permanent 768 MB swap partition.
n9 uses in-RAM lzo compressed 256 MB swap.

All of them tested, tuned and works fine for majority use-cases.

> While you are getting stuck to make nokia specific feature, I'm
> recommending you
> maintain your local patch yourself.

Thanks for advices, but I have better idea which is less destructive for MM=
.
Maybe it will more successful, at least for maintenance as a local patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
