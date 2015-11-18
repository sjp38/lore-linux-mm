Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0008F6B0257
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 17:36:22 -0500 (EST)
Received: by lfaz4 with SMTP id z4so36548553lfa.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 14:36:22 -0800 (PST)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id zn4si3570995lbb.188.2015.11.18.14.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 14:36:21 -0800 (PST)
Received: by lfs39 with SMTP id 39so36462729lfs.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 14:36:20 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Wed, 18 Nov 2015 23:36:18 +0100
References: <201511102313.36685.arekm@maven.pl> <201511151549.35299.arekm@maven.pl> <20151116161518.GI14116@dhcp22.suse.cz>
In-Reply-To: <20151116161518.GI14116@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511182336.18231.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, htejun@gmail.com, cl@linux.com, linux-mm@kvack.org, xfs@oss.sgi.com

On Monday 16 of November 2015, Michal Hocko wrote:
> On Sun 15-11-15 15:49:35, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > > Arkadiusz Miskiewicz wrote:
> > > > On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > > > > I think that the vmstat statistics now have correct values.
> > > > >=20
> > > > > > But are these patches solving the problem or just hiding it?
> > > > >=20
> > > > > Excuse me but I can't judge.
> > > > >=20
> > > > > If you are interested in monitoring how vmstat statistics are
> > > > > changing under stalled condition, you can try below patch.
> > > >=20
> > > > Here is log with this and all previous patches applied:
> > > > http://ixion.pld-linux.org/~arekm/log-mm-5.txt.gz
> > >=20
> > > Regarding "Node 0 Normal" (min:7104kB low:8880kB high:10656kB),
> > > all free: values look sane to me. I think that your problem was solve=
d.
> >=20
> > Great, thanks!
> >=20
> > Will all (or part) of these patches
> >=20
> > http://sprunge.us/GYBb
>=20
> Migrate reserves are not a stable material I am afraid. "vmstat:
> explicitly schedule per-cpu work on the CPU we need it to run on"
> was not marked for stable either but I am not sure why it should make
> any difference for your load. I understand that testing this is really
> tedious but it would be better to know which of the patches actually
> made a difference.

Ok. In mean time I've tried 4.3.0 kernel + patches (the same as before + on=
e=20
more) on second server which runs even more rsnapshot processes and also us=
es=20
xfs on md raid 6.

Patches:
http://sprunge.us/DfIQ (debug patch from Tetsuo)
http://sprunge.us/LQPF (backport of things from git + one from ml)

The problem is now with high order allocations probably:
http://ixion.pld-linux.org/~arekm/log-mm-2srv-1.txt.gz

System is doing very slow progress and for example depmod run took 2 hours
http://sprunge.us/HGbE
Sometimes I was able to ssh-in, dmesg took 10-15 minutes but sometimes it=20
worked fast for short period.

Ideas?

ps. I also had one problem with low order allocation but only once and wasn=
't=20
able to reproduce so far. I was running kernel with backport patches but no=
=20
debug patch, so got only this in logs:
http://sprunge.us/WPXi

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
