Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 36D676B003D
	for <linux-mm@kvack.org>; Sat, 12 Dec 2009 14:46:11 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id l26so478360fgb.8
        for <linux-mm@kvack.org>; Sat, 12 Dec 2009 11:46:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091212233409.60da66fb.d-nishimura@mtf.biglobe.ne.jp>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	 <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	 <20091212125046.14df3134.d-nishimura@mtf.biglobe.ne.jp>
	 <cc557aab0912120506x56b9a707ob556035fdcf40a22@mail.gmail.com>
	 <20091212233409.60da66fb.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 12 Dec 2009 21:46:08 +0200
Message-ID: <cc557aab0912121146y276a8d26v8baee15be1f83a97@mail.gmail.com>
Subject: Re: [PATCH RFC v2 3/4] memcg: rework usage of stats by soft limit
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 12, 2009 at 4:34 PM, Daisuke Nishimura
<d-nishimura@mtf.biglobe.ne.jp> wrote:
> On Sat, 12 Dec 2009 15:06:52 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> On Sat, Dec 12, 2009 at 5:50 AM, Daisuke Nishimura
>> <d-nishimura@mtf.biglobe.ne.jp> wrote:
>> > And IIUC, it's the same for your threshold feature, right ?
>> > I think it would be better:
>> >
>> > - discard this change.
>> > - in 4/4, rename mem_cgroup_soft_limit_check to mem_cgroup_event_check=
,
>> > =C2=A0and instead of adding a new STAT counter, do like:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_event_check(mem)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_upda=
te_tree(mem, page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_thre=
shold(mem);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> I think that mem_cgroup_update_tree() and mem_cgroup_threshold() should =
be
>> run with different frequency. How to share MEM_CGROUP_STAT_EVENTS
>> between soft limits and thresholds in this case?
>>
> hmm, both softlimit and your threshold count events at the same place(cha=
rge and uncharge).
> So, I think those events can be shared.
> Is there any reason they should run in different frequency ?

SOFTLIMIT_EVENTS_THRESH is 1000. If use the same value for thresholds,
a threshold can
be exceed on 1000*nr_cpu_id pages. It's too many. I think, that 100 is
a reasonable value.

mem_cgroup_soft_limit_check() resets MEM_CGROUP_STAT_EVENTS when it reaches
SOFTLIMIT_EVENTS_THRESH. If I will do the same thing for
THRESHOLDS_EVENTS_THRESH
(which is 100) , mem_cgroup_event_check() will never be 'true'. Any
idea how to share
MEM_CGROUP_STAT_EVENTS in this case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
