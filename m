Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 37905600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 05:15:05 -0500 (EST)
Received: by ewy24 with SMTP id 24so20115914ewy.6
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 02:15:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100104003612.GF16187@balbir.in.ibm.com>
References: <cover.1262186097.git.kirill@shutemov.name>
	 <20100104003612.GF16187@balbir.in.ibm.com>
Date: Mon, 4 Jan 2010 12:15:02 +0200
Message-ID: <cc557aab1001040215r1bdaaed0n2fe461e5ff396cdb@mail.gmail.com>
Subject: Re: [PATCH v5 0/4] cgroup notifications API and memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 4, 2010 at 2:36 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * Kirill A. Shutemov <kirill@shutemov.name> [2009-12-30 17:57:55]:
>
>> This patchset introduces eventfd-based API for notifications in cgroups =
and
>> implements memory notifications on top of it.
>>
>> It uses statistics in memory controler to track memory usage.
>>
>> Output of time(1) on building kernel on tmpfs:
>>
>> Root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.37 user 60.93s system 193% cpu 4=
:52.77 total
>> Non-root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.14 user 62.66s system 193% cpu 4=
:54.74 total
>> Root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.13 user 62.20s system 193% cpu 4=
:53.55 total
>> Non-root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.70 user 64.20s system 193% cpu 4=
:55.70 total
>> Root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.97 user 62.20s system 193% cpu 4=
:53.90 total
>> Non-root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.55 user 64.08s system 193% cpu 4=
:55.63 total
>>
>> Any comments?
>
> Hi,
>
> I just saw that the notification work for me using the tool you
> supplied. One strange thing was that I got notified even though
> the amount of data I was using was reducing, so I hit the notification
> two ways
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0+------------+-----------
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01G
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0----> (got notifie=
d on increase)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<---- (got notifie=
d on decrease)
>
> I am not against the behaviour, but it can be confusing unless
> clarified with the event.

IIUC, you've got two events. One on crossing the threshold up and
one on crossing it down. It's Ok.

By design, notification means that the threshold probably crossed
(it can be crossed twice -- up and down) or the cgroup was removed.
To understand what really happen you need to check if the cgroup
exists and read current usage of the resource.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
