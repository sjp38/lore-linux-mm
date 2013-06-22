Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 22B926B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 21:28:05 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fo12so8147800lab.39
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 18:28:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130622002744.GA29172@lizard.mcd26095.sjc.wayport.net>
References: <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
	<20130619125329.GB16457@dhcp22.suse.cz>
	<000401ce6d5c$566ac620$03405260$%kim@samsung.com>
	<20130620121649.GB27196@dhcp22.suse.cz>
	<001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
	<001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
	<20130621012234.GF11659@bbox>
	<20130621091944.GC12424@dhcp22.suse.cz>
	<20130621162743.GA2837@gmail.com>
	<20130621164413.GA4759@gmail.com>
	<20130622002744.GA29172@lizard.mcd26095.sjc.wayport.net>
Date: Sat, 22 Jun 2013 10:28:02 +0900
Message-ID: <CAOK=xRMzZkk-r1TXRgdk-tZ+6AvXGij511y=PFcw5Smnt1rOHw@mail.gmail.com>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Kyungmin Park <kyungmin.park@samsung.com>, hannes@cmpxchg.org, rob@landley.net, linux-mm@kvack.org, rientjes@google.com, Minchan Kim <minchan@kernel.org>, kirill@shutemov.name, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com

2013. 6. 22. =BF=C0=C0=FC 9:27=BF=A1 "Anton Vorontsov" <anton@enomsg.org>=
=B4=D4=C0=CC =C0=DB=BC=BA:
>
> On Sat, Jun 22, 2013 at 01:44:14AM +0900, Minchan Kim wrote:
> [...]
> > 3. The reclaimed could be greater than scanned in vmpressure_evnet
> >    by several reasons. Totally, It could trigger wrong event.
>
> Yup, and in that case the best we can do is just ignore the event (i.e.
> not pass it to the userland): thing is, based on the fact that
> 'reclaimed > scanned' we can't actually conclude anything about the
> pressure: it might be still high, or we actually freed enough.
>
> Thanks,
>
> Anton
>
> p.s. I was somewhat sure that someone sent a patch to ignore 'reclaimed >
> scanned' situation, but I cannot find it in my mailbox. Maybe I was
> dreaming about it? :)

I have suggested it as follows and Minchan reviewed it.
I'll send it again after applying Minchan's opinion.
Thanks,

Hyunhee Kim.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

On Wed, Jun 05, 2013 at 05:31:30PM +0900, Hyunhee Kim wrote:
 > Hi, Anton,
 >

Sorry, I'm not Anton but I involved a little bit when this feature was
 developed so may I answer your qeustion?


> When calculating pressure level in vmpressure_calc_level, I observed that=
 "reclaimed" becomes larger than "scanned".
 > In this case, since these values are "unsigned long", pressure
returns wrong value and critical event is triggered even on low state.
 > Do you think that it is possible?


True, we have a few reasons.

Culprits I can think easily are THP page reclaiming or bails out reclaiming
 by fatal signal in shrink_inactive_list.
 I guess you don't enable THP so I think culprit is latter.


> If so, in this case, should we make "reclaimed" equal to "scanned"?
 > When I tested as below, it could trigger reasonable events.
 >
 > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
 > +static enum vmpressure_levels vmpressure_calc_level(unsigned long scann=
ed,
 > +                                                 unsigned long reclaime=
d)
 > +{
 > +     unsigned long scale =3D scanned + reclaimed;
 > +     unsigned long pressure;
 > +     if (reclaimed > scanned)
 > +             reclaimed =3D scanned;


Could we simply return VMPRESSURE_LOW?
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
