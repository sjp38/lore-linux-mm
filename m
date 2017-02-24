Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6272F6B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:42:17 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so3628089itc.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:42:17 -0800 (PST)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id n185si2364117itc.107.2017.02.24.10.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 10:42:16 -0800 (PST)
Received: by mail-it0-x22d.google.com with SMTP id 203so32316190ith.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:42:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAEe=SxnHWw0aU6SUO6Ce2YCDxmP4KgmrbShh0uudkuBO1FEFWg@mail.gmail.com>
References: <20170222120121.12601-1-mhocko@kernel.org> <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
 <20170224093405.GD19161@dhcp22.suse.cz> <CAEe=SxnHWw0aU6SUO6Ce2YCDxmP4KgmrbShh0uudkuBO1FEFWg@mail.gmail.com>
From: Rom Lemarchand <romlem@google.com>
Date: Fri, 24 Feb 2017 10:42:15 -0800
Message-ID: <CAABpnA-Pqn-ptF03b-Am5MWZTfPwF6NiBMp5MnqRetauC5V9Tw@mail.gmail.com>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Content-Type: multipart/alternative; boundary=94eb2c05a380bb684905494b16c0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Murray <timmurray@google.com>, Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Riley Andrews <riandrews@android.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>

--94eb2c05a380bb684905494b16c0
Content-Type: text/plain; charset=UTF-8

+surenb

On Fri, Feb 24, 2017 at 10:38 AM, Tim Murray <timmurray@google.com> wrote:

> Hi all, I've recently been looking at lowmemorykiller, userspace lmkd, and
> memory cgroups on Android.
>
> First of all, no, an Android device will probably not function without a
> kernel or userspace version of lowmemorykiller. Android userspace expects
> that if there are many apps running in the background on a machine and the
> foreground app allocates additional memory, something on the system will
> kill background apps to free up more memory. If this doesn't happen, I
> expect that at the very least you'll see page cache thrashing, and you'll
> probably see the OOM killer run regularly, which has a tendency to cause
> Android userspace to restart. To the best of my knowledge, no device has
> shipped with a userspace lmkd.
>
> Second, yes, the current design and implementation of lowmemorykiller are
> unsatisfactory. I now have some concrete evidence that the design of
> lowmemorykiller is directly responsible for some very negative user-visible
> behaviors (particularly the triggers for when to kill), so I'm currently
> working on an overhaul to the Android memory model that would use mem
> cgroups and userspace lmkd to make smarter decisions about reclaim vs
> killing. Yes, this means that we would move to vmpressure (which will
> require improvements to vmpressure). I can't give a firm ETA for this, as
> it's still in the prototype phase, but the initial results are promising.
>
> On Fri, Feb 24, 2017 at 1:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
>> On Thu 23-02-17 21:36:00, Martijn Coenen wrote:
>> > On Thu, Feb 23, 2017 at 9:24 PM, John Stultz <john.stultz@linaro.org>
>> wrote:
>> [...]
>> > > This is reportedly because while the mempressure notifiers provide a
>> > > the signal to userspace, the work the deamon then has to do to look up
>> > > per process memory usage, in order to figure out who is best to kill
>> > > at that point was too costly and resulted in poor device performance.
>> >
>> > In particular, mempressure requires memory cgroups to function, and we
>> > saw performance regressions due to the accounting done in mem cgroups.
>> > At the time we didn't have enough time left to solve this before the
>> > release, and we reverted back to kernel lmkd.
>>
>> I would be more than interested to hear details. We used to have some
>> visible charge path performance footprint but this should be gone now.
>>
>> [...]
>> > > It would be great however to get a discussion going here on what the
>> > > ulmkd needs from the kernel in order to efficiently determine who best
>> > > to kill, and how we might best implement that.
>> >
>> > The two main issues I think we need to address are:
>> > 1) Getting the right granularity of events from the kernel; I once
>> > tried to submit a patch upstream to address this:
>> > https://lkml.org/lkml/2016/2/24/582
>>
>> Not only that, the implementation of tht vmpressure needs some serious
>> rethinking as well. The current one can hit critical events
>> unexpectedly. The calculation also doesn't consider slab reclaim
>> sensibly.
>>
>> > 2) Find out where exactly the memory cgroup overhead is coming from,
>> > and how to reduce it or work around it to acceptable levels for
>> > Android. This was also on 3.10, and maybe this has long been fixed or
>> > improved in more recent kernel versions.
>>
>> 3e32cb2e0a12 ("mm: memcontrol: lockless page counters") has improved
>> situation a lot as all the charging is lockless since then (3.19).
>> --
>> Michal Hocko
>> SUSE Labs
>>
>
>

--94eb2c05a380bb684905494b16c0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">+surenb</div><div class=3D"gmail_extra"><br><div class=3D"=
gmail_quote">On Fri, Feb 24, 2017 at 10:38 AM, Tim Murray <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:timmurray@google.com" target=3D"_blank">timmurray@go=
ogle.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div dir=
=3D"ltr"><div>Hi all, I&#39;ve recently been looking at lowmemorykiller, us=
erspace lmkd, and memory cgroups on Android.</div><div><br></div><div>First=
 of all, no, an Android device will probably not function without a kernel =
or userspace version of lowmemorykiller. Android userspace expects that if =
there are many apps running in the background on a machine and the foregrou=
nd app allocates additional memory, something on the system will kill backg=
round apps to free up more memory. If this doesn&#39;t happen, I expect tha=
t at the very least you&#39;ll see page cache thrashing, and you&#39;ll pro=
bably see the OOM killer run regularly, which has a tendency to cause Andro=
id userspace to restart. To the best of my knowledge, no device has shipped=
 with a userspace lmkd.</div><div><br></div><div>Second, yes, the current d=
esign and implementation of lowmemorykiller are unsatisfactory. I now have =
some concrete evidence that the design of lowmemorykiller is directly respo=
nsible for some very negative user-visible behaviors (particularly the trig=
gers for when to kill), so I&#39;m currently working on an overhaul to the =
Android memory model that would use mem cgroups and userspace lmkd to make =
smarter decisions about reclaim vs killing. Yes, this means that we would m=
ove to vmpressure (which will require improvements to vmpressure). I can&#3=
9;t give a firm ETA for this, as it&#39;s still in the prototype phase, but=
 the initial results are promising.</div></div><div class=3D"HOEnZb"><div c=
lass=3D"h5"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Fr=
i, Feb 24, 2017 at 1:34 AM, Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span>=
 wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex"><span>On Thu 23-02-17 21:36:00, M=
artijn Coenen wrote:<br>
&gt; On Thu, Feb 23, 2017 at 9:24 PM, John Stultz &lt;<a href=3D"mailto:joh=
n.stultz@linaro.org" target=3D"_blank">john.stultz@linaro.org</a>&gt; wrote=
:<br>
</span>[...]<br>
<span>&gt; &gt; This is reportedly because while the mempressure notifiers =
provide a<br>
&gt; &gt; the signal to userspace, the work the deamon then has to do to lo=
ok up<br>
&gt; &gt; per process memory usage, in order to figure out who is best to k=
ill<br>
&gt; &gt; at that point was too costly and resulted in poor device performa=
nce.<br>
&gt;<br>
&gt; In particular, mempressure requires memory cgroups to function, and we=
<br>
&gt; saw performance regressions due to the accounting done in mem cgroups.=
<br>
&gt; At the time we didn&#39;t have enough time left to solve this before t=
he<br>
&gt; release, and we reverted back to kernel lmkd.<br>
<br>
</span>I would be more than interested to hear details. We used to have som=
e<br>
visible charge path performance footprint but this should be gone now.<br>
<br>
[...]<br>
<span>&gt; &gt; It would be great however to get a discussion going here on=
 what the<br>
&gt; &gt; ulmkd needs from the kernel in order to efficiently determine who=
 best<br>
&gt; &gt; to kill, and how we might best implement that.<br>
&gt;<br>
&gt; The two main issues I think we need to address are:<br>
&gt; 1) Getting the right granularity of events from the kernel; I once<br>
&gt; tried to submit a patch upstream to address this:<br>
&gt; <a href=3D"https://lkml.org/lkml/2016/2/24/582" rel=3D"noreferrer" tar=
get=3D"_blank">https://lkml.org/lkml/2016/2/2<wbr>4/582</a><br>
<br>
</span>Not only that, the implementation of tht vmpressure needs some serio=
us<br>
rethinking as well. The current one can hit critical events<br>
unexpectedly. The calculation also doesn&#39;t consider slab reclaim<br>
sensibly.<br>
<span><br>
&gt; 2) Find out where exactly the memory cgroup overhead is coming from,<b=
r>
&gt; and how to reduce it or work around it to acceptable levels for<br>
&gt; Android. This was also on 3.10, and maybe this has long been fixed or<=
br>
&gt; improved in more recent kernel versions.<br>
<br>
</span>3e32cb2e0a12 (&quot;mm: memcontrol: lockless page counters&quot;) ha=
s improved<br>
situation a lot as all the charging is lockless since then (3.19).<br>
<span class=3D"m_7941618007938351630HOEnZb"><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div>
</div></div></blockquote></div><br></div>

--94eb2c05a380bb684905494b16c0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
