Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2336B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 01:13:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so12934373pge.13
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 22:13:26 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0083.outbound.protection.outlook.com. [104.47.34.83])
        by mx.google.com with ESMTPS id q11si821069pgc.617.2018.01.31.22.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 22:13:25 -0800 (PST)
From: "He, Roger" <Hongbo.He@amd.com>
Subject: RE: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
Date: Thu, 1 Feb 2018 06:13:20 +0000
Message-ID: <MWHPR1201MB0127CEE71F679F43BF0D25B6FDFA0@MWHPR1201MB0127.namprd12.prod.outlook.com>
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <20180129163114.GH21609@dhcp22.suse.cz>
 <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <20180130075553.GM21609@dhcp22.suse.cz>
 <9060281e-62dd-8775-2903-339ff836b436@amd.com>
 <20180130101823.GX21609@dhcp22.suse.cz>
 <7d5ce7ab-d16d-36bc-7953-e1da2db350bf@amd.com>
 <20180130122853.GC21609@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hi Michal:

How about only =20
EXPORT_SYMBOL_GPL(total_swap_pages) ?

Thanks
Roger(Hongbo.He)

-----Original Message-----
From: He, Roger=20
Sent: Wednesday, January 31, 2018 1:52 PM
To: 'Michal Hocko' <mhocko@kernel.org>; Koenig, Christian <Christian.Koenig=
@amd.com>
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; dri-devel@lists.freed=
esktop.org
Subject: RE: [PATCH] mm/swap: add function get_total_swap_pages to expose t=
otal_swap_pages

	I do think you should completely ignore the size of the swap space. IMHO y=
ou should forbid further allocations when your current 	buffer storage cann=
ot be reclaimed. So you need some form of feedback mechanism that would tel=
l you: "Your buffers have 	grown too much". If you cannot do that then simp=
ly assume that you cannot swap at all rather than rely on having some porti=
on 	of it for yourself.=20

If we assume the swap cache size is zero always, that is overkill for GTT s=
ize actually user can get. And not make sense as well I think.

	There are many other users of memory outside of your subsystem. Any scalin=
g based on the 50% of resource belonging to me is 	simply broken.

And that is only a threshold to avoid  overuse  rather than really reserved=
 to TTM at the start. In addition, for most cases TTM only uses a little or=
 not use swap disk at all. Only special test case use more or probably that=
 is intentional.


Thanks
Roger(Hongbo.He)

-----Original Message-----
From: Michal Hocko [mailto:mhocko@kernel.org]
Sent: Tuesday, January 30, 2018 8:29 PM
To: Koenig, Christian <Christian.Koenig@amd.com>
Cc: He, Roger <Hongbo.He@amd.com>; linux-mm@kvack.org; linux-kernel@vger.ke=
rnel.org; dri-devel@lists.freedesktop.org
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose t=
otal_swap_pages

On Tue 30-01-18 11:32:49, Christian K=F6nig wrote:
> Am 30.01.2018 um 11:18 schrieb Michal Hocko:
> > On Tue 30-01-18 10:00:07, Christian K=F6nig wrote:
> > > Am 30.01.2018 um 08:55 schrieb Michal Hocko:
> > > > On Tue 30-01-18 02:56:51, He, Roger wrote:
> > > > > Hi Michal:
> > > > >=20
> > > > > We need a API to tell TTM module the system totally has how=20
> > > > > many swap cache.  Then TTM module can use it to restrict how=20
> > > > > many the swap cache it can use to prevent triggering OOM.  For=20
> > > > > Now we set the threshold of swap size TTM used as 1/2 * total=20
> > > > > size and leave the rest for others use.
> > > > Why do you so much memory? Are you going to use TB of memory on=20
> > > > large systems? What about memory hotplug when the memory is added/r=
eleased?
> > > For graphics and compute applications on GPUs it isn't unusual to=20
> > > use large amounts of system memory.
> > >=20
> > > Our standard policy in TTM is to allow 50% of system memory to be=20
> > > pinned for use with GPUs (the hardware can't do page faults).
> > >=20
> > > When that limit is exceeded (or the shrinker callbacks tell us to=20
> > > make room) we wait for any GPU work to finish and copy buffer=20
> > > content into a shmem file.
> > >=20
> > > This copy into a shmem file can easily trigger the OOM killer if=20
> > > there isn't any swap space left and that is something we want to avoi=
d.
> > >=20
> > > So what we want to do is to apply this 50% rule to swap space as=20
> > > well and deny allocation of buffer objects when it is exceeded.
> > How does that help when the rest of the system might eat swap?
>=20
> Well it doesn't, but that is not the problem here.
>=20
> When an application keeps calling malloc() it sooner or later is=20
> confronted with an OOM killer.
>=20
> But when it keeps for example allocating OpenGL textures the=20
> expectation is that this sooner or later starts to fail because we run=20
> out of memory and not trigger the OOM killer.

There is nothing like running out of memory and not triggering the OOM kill=
er. You can make a _particular_ allocation to bail out without the oom kill=
er. Just use __GFP_NORETRY. But that doesn't make much difference when you =
have already depleted your memory and live with the bare remainings. Any de=
sperate soul trying to get its memory will simply trigger the OOM.

> So what we do is to allow the application to use all of video memory +=20
> a certain amount of system memory + swap space as last resort fallback (e=
.g.
> when you Alt+Tab from your full screen game back to your browser).
>=20
> The problem we try to solve is that we haven't limited the use of swap=20
> space somehow.

I do think you should completely ignore the size of the swap space. IMHO yo=
u should forbid further allocations when your current buffer storage cannot=
 be reclaimed. So you need some form of feedback mechanism that would tell =
you: "Your buffers have grown too much". If you cannot do that then simply =
assume that you cannot swap at all rather than rely on having some portion =
of it for yourself. There are many other users of memory outside of your su=
bsystem. Any scaling based on the 50% of resource belonging to me is simply=
 broken.
--
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
