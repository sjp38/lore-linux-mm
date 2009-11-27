Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 52FB86B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 02:08:22 -0500 (EST)
Received: by fxm9 with SMTP id 9so1215144fxm.10
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 23:08:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <661de9470911261908i4bb51e91v649025e6c75bd91b@mail.gmail.com>
References: <cover.1259255307.git.kirill@shutemov.name>
	 <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259255307.git.kirill@shutemov.name>
	 <8524ba285f6dd59cda939c28da523f344cdab3da.1259255307.git.kirill@shutemov.name>
	 <20091127092035.bbf2efdc.nishimura@mxp.nes.nec.co.jp>
	 <20091127114511.bbb43d5a.kamezawa.hiroyu@jp.fujitsu.com>
	 <661de9470911261908i4bb51e91v649025e6c75bd91b@mail.gmail.com>
Date: Fri, 27 Nov 2009 09:08:19 +0200
Message-ID: <cc557aab0911262308h452e836fo94c11c2d051e98a0@mail.gmail.com>
Subject: Re: [PATCH RFC v0 2/3] res_counter: implement thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 27, 2009 at 5:08 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> On Fri, Nov 27, 2009 at 8:15 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Fri, 27 Nov 2009 09:20:35 +0900
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>>
>>> Hi.
>>> >
>>> > @@ -73,6 +76,7 @@ void res_counter_uncharge_locked(struct res_counter=
 *counter, unsigned long val)
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val =3D counter->usage;
>>> >
>>> > =C2=A0 =C2=A0 counter->usage -=3D val;
>>> > + =C2=A0 res_counter_threshold_notify_locked(counter);
>>> > =C2=A0}
>>> >
>>> hmm.. this adds new checks to hot-path of process life cycle.
>>>
>>> Do you have any number on performance impact of these patches(w/o setti=
ng any threshold)?

No, I don't. I did only functional testing on this stage.

>>> IMHO, it might be small enough to be ignored because KAMEZAWA-san's coa=
lesce charge/uncharge
>>> patches have decreased charge/uncharge for res_counter itself, but I wa=
nt to know just to make sure.
>>>
>> Another concern is to support root cgroup, you need another notifier hoo=
k in
>> memcg because root cgroup doesn't use res_counter now.
>>
>> Can't this be implemented in a way like softlimit check ?

I'll investigate it.

>> Filter by the number of event will be good for notifier behavior, for av=
oiding
>> too much wake up, too.

Good idea, thanks.

> I guess the semantics would vary then, they would become activity
> semantics. I think we should avoid threshold notification for root,
> since we have no limits in root anymore.

Threshold notifications for root cgroup is really needed on embedded
systems to avid OOM-killer.

>
> BTW, Kirill, I've been meaning to write this layer on top of
> cgroupstats, is there anything that prevents us from using that today?

I'll investigate it.

> CC'ing Dan Malek and Vladslav Buzov who worked on similar patches
> earlier.
>
> Balbir Singh.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
