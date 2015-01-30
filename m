Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6845F6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:04:23 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so18487987qcx.11
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:04:23 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id b5si12502931qat.123.2015.01.29.18.04.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 18:04:22 -0800 (PST)
Received: by mail-qg0-f47.google.com with SMTP id z60so36371162qgd.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:04:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANcMJZALAz1WKjo+8VbUMWBpS117gaZht-b7jBLJWT9VVN83=g@mail.gmail.com>
References: <1421079554-30899-1-git-send-email-cpandya@codeaurora.org>
	<20150115170324.GD7008@dhcp22.suse.cz>
	<CANcMJZALAz1WKjo+8VbUMWBpS117gaZht-b7jBLJWT9VVN83=g@mail.gmail.com>
Date: Thu, 29 Jan 2015 18:04:22 -0800
Message-ID: <CAABpnA-xQ05WySLnxryXz4zkKVRm2NKtoAc4w7MCdTWUjF1TJg@mail.gmail.com>
Subject: Re: [PATCH] lowmemorykiller: Avoid excessive/redundant calling of LMK
From: Rom Lemarchand <romlem@android.com>
Content-Type: multipart/alternative; boundary=001a113a5d5eef3577050dd5056a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Weijie Yang <weijie.yang@samsung.com>, Chintan Pandya <cpandya@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Anton Vorontsov <anton@enomsg.org>, Android Kernel Team <kernel-team@android.com>

--001a113a5d5eef3577050dd5056a
Content-Type: text/plain; charset=UTF-8

On Jan 29, 2015 4:44 PM, "John Stultz" <john.stultz@linaro.org> wrote:
>
> On Thu, Jan 15, 2015 at 9:03 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 12-01-15 21:49:14, Chintan Pandya wrote:
> >> The global shrinker will invoke lowmem_shrink in a loop.
> >> The loop will be run (total_scan_pages/batch_size) times.
> >> The default batch_size will be 128 which will make
> >> shrinker invoking 100s of times. LMK does meaningful
> >> work only during first 2-3 times and then rest of the
> >> invocations are just CPU cycle waste. Fix that by returning
> >> to the shrinker with SHRINK_STOP when LMK doesn't find any
> >> more work to do. The deciding factor here is, no process
> >> found in the selected LMK bucket or memory conditions are
> >> sane.
> >
> > lowmemory killer is broken by design and this one of the examples which
> > shows why. It simply doesn't fit into shrinkers concept.
> >
> > The count_object callback simply lies and tells the core that all
> > the reclaimable LRU pages are scanable and gives it this as a number
> > which the core uses for total_scan. scan_objects callback then happily
> > ignore nr_to_reclaim and does its one time job where it iterates over
> > _all_ tasks and picks up the victim and returns its rss as a return
> > value. This is just a subset of LRU pages of course so it continues
> > looping until total_scan goes down to 0 finally.
> >
> > If this really has to be a shrinker then, shouldn't it evaluate the OOM
> > situation in the count callback and return non zero only if OOM and then
> > the scan callback would kill and return nr_to_reclaim.
> >
> > Or even better wouldn't it be much better to use vmpressure to wake
> > up a kernel module which would simply check the situation and kill
> > something?
> >
> > Please do not put only cosmetic changes on top of broken concept and try
> > to think about a proper solution that is what staging is for AFAIU.
> >
> > The code is in this state for quite some time and I would really hate if
> > it got merged just because it is in staging for too long and it is used
> > out there.
>
> So the in-kernel low-memory-killer is hopefully on its way out.
>
> With Lollipop on some devices, Android is using the mempressure
> notifiers to kill processes from userland. However, not all devices
> have moved to this new model (and possibly some resulting performance
> issues are being worked out? Its not clear).  So hopefully we can drop
> it soon, but I'd like to make sure we don't get only a half-working
> solution upstream before we do remove it.
>
> thanks
> -john
>

We are still working on a user space replacement to LMK. We have definitely
had issues with LMKd and so stayed with the in kernel one for all the
lollipop devices we shipped. Issues were mostly related to performance,
timing of OOM notifications and when under intense memory pressure we ran
into issues where even opening a file would fail due to no RAM being
available.
But as John said, it's WIP and hopefully we'll be able to drop the in
kernel one soon.

-Rom

--001a113a5d5eef3577050dd5056a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">On Jan 29, 2015 4:44 PM, &quot;John Stultz&quot; &lt;<a href=
=3D"mailto:john.stultz@linaro.org">john.stultz@linaro.org</a>&gt; wrote:<br=
>
&gt;<br>
&gt; On Thu, Jan 15, 2015 at 9:03 AM, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>
&gt; &gt; On Mon 12-01-15 21:49:14, Chintan Pandya wrote:<br>
&gt; &gt;&gt; The global shrinker will invoke lowmem_shrink in a loop.<br>
&gt; &gt;&gt; The loop will be run (total_scan_pages/batch_size) times.<br>
&gt; &gt;&gt; The default batch_size will be 128 which will make<br>
&gt; &gt;&gt; shrinker invoking 100s of times. LMK does meaningful<br>
&gt; &gt;&gt; work only during first 2-3 times and then rest of the<br>
&gt; &gt;&gt; invocations are just CPU cycle waste. Fix that by returning<b=
r>
&gt; &gt;&gt; to the shrinker with SHRINK_STOP when LMK doesn&#39;t find an=
y<br>
&gt; &gt;&gt; more work to do. The deciding factor here is, no process<br>
&gt; &gt;&gt; found in the selected LMK bucket or memory conditions are<br>
&gt; &gt;&gt; sane.<br>
&gt; &gt;<br>
&gt; &gt; lowmemory killer is broken by design and this one of the examples=
 which<br>
&gt; &gt; shows why. It simply doesn&#39;t fit into shrinkers concept.<br>
&gt; &gt;<br>
&gt; &gt; The count_object callback simply lies and tells the core that all=
<br>
&gt; &gt; the reclaimable LRU pages are scanable and gives it this as a num=
ber<br>
&gt; &gt; which the core uses for total_scan. scan_objects callback then ha=
ppily<br>
&gt; &gt; ignore nr_to_reclaim and does its one time job where it iterates =
over<br>
&gt; &gt; _all_ tasks and picks up the victim and returns its rss as a retu=
rn<br>
&gt; &gt; value. This is just a subset of LRU pages of course so it continu=
es<br>
&gt; &gt; looping until total_scan goes down to 0 finally.<br>
&gt; &gt;<br>
&gt; &gt; If this really has to be a shrinker then, shouldn&#39;t it evalua=
te the OOM<br>
&gt; &gt; situation in the count callback and return non zero only if OOM a=
nd then<br>
&gt; &gt; the scan callback would kill and return nr_to_reclaim.<br>
&gt; &gt;<br>
&gt; &gt; Or even better wouldn&#39;t it be much better to use vmpressure t=
o wake<br>
&gt; &gt; up a kernel module which would simply check the situation and kil=
l<br>
&gt; &gt; something?<br>
&gt; &gt;<br>
&gt; &gt; Please do not put only cosmetic changes on top of broken concept =
and try<br>
&gt; &gt; to think about a proper solution that is what staging is for AFAI=
U.<br>
&gt; &gt;<br>
&gt; &gt; The code is in this state for quite some time and I would really =
hate if<br>
&gt; &gt; it got merged just because it is in staging for too long and it i=
s used<br>
&gt; &gt; out there.<br>
&gt;<br>
&gt; So the in-kernel low-memory-killer is hopefully on its way out.<br>
&gt;<br>
&gt; With Lollipop on some devices, Android is using the mempressure<br>
&gt; notifiers to kill processes from userland. However, not all devices<br=
>
&gt; have moved to this new model (and possibly some resulting performance<=
br>
&gt; issues are being worked out? Its not clear).=C2=A0 So hopefully we can=
 drop<br>
&gt; it soon, but I&#39;d like to make sure we don&#39;t get only a half-wo=
rking<br>
&gt; solution upstream before we do remove it.<br>
&gt;<br>
&gt; thanks<br>
&gt; -john<br>
&gt;</p>
<p dir=3D"ltr">We are still working on a user space replacement to LMK. We =
have definitely had issues with LMKd and so stayed with the in kernel one f=
or all the lollipop devices we shipped. Issues were mostly related to perfo=
rmance, timing of OOM notifications and when under intense memory pressure =
we ran into issues where even opening a file would fail due to no RAM being=
 available.<br>
But as John said, it&#39;s WIP and hopefully we&#39;ll be able to drop the =
in kernel one soon.</p>
<p dir=3D"ltr">-Rom<br>
</p>

--001a113a5d5eef3577050dd5056a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
