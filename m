Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A1976B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 14:30:46 -0500 (EST)
Received: by pwj10 with SMTP id 10so1637664pwj.6
        for <linux-mm@kvack.org>; Sun, 17 Jan 2010 11:30:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100106070150.GL3059@balbir.in.ibm.com>
	 <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100107071554.GO3059@balbir.in.ibm.com>
	 <20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100107083440.GS3059@balbir.in.ibm.com>
	 <20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100107092736.GW3059@balbir.in.ibm.com>
	 <20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 18 Jan 2010 01:00:44 +0530
Message-ID: <661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 5:17 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 7 Jan 2010 14:57:36 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-07 18:08:0=
0]:
>>
>> > On Thu, 7 Jan 2010 17:48:14 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > > > "How pages are shared" doesn't show good hints. I don't hear suc=
h parameter
>> > > > > is used in production's resource monitoring software.
>> > > > >
>> > > >
>> > > > You mean "How many pages are shared" are not good hints, please se=
e my
>> > > > justification above. With Virtualization (look at KSM for example)=
,
>> > > > shared pages are going to be increasingly important part of the
>> > > > accounting.
>> > > >
>> > >
>> > > Considering KSM, your cuounting style is tooo bad.
>> > >
>> > > You should add
>> > >
>> > > =A0- MEM_CGROUP_STAT_SHARED_BY_KSM
>> > > =A0- MEM_CGROUP_STAT_FOR_TMPFS/SYSV_IPC_SHMEM
>> > >
>>
>> No.. I am just talking about shared memory being important and shared
>> accounting being useful, no counters for KSM in particular (in the
>> memcg context).
>>
> Think so ? The number of memcg-private pages is in interest in my point o=
f view.
>
> Anyway, I don't change my opinion as "sum of rss" is not necessary to be =
calculated
> in the kernel.
> If you want to provide that in memcg, please add it to global VM as /proc=
/meminfo.
>
> IIUC, KSM/SHMEM has some official method in global VM.
>

Kamezawa-San,

I implemented the same in user space and I get really bad results, here is =
why

1. I need to hold and walk the tasks list in cgroups and extract RSS
through /proc (results in worse hold times for the fork() scenario you
menioned)
2. The data is highly inconsistent due to the higher margin of error
in accumulating data which is changing as we run. By the time we total
and look at the memcg data, the data is stale

Would you be OK with the patch, if I renamed "shared_usage_in_bytes"
to "non_private_usage_in_bytes"?

Given that the stat is user initiated, I don't see your concern w.r.t.
overhead. Many subsystems like KSM do pay the overhead cost if the
user really wants the feature or the data. I would be really
interested in other opinions as well (if people do feel strongly
against or for the feature)

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
