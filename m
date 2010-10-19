Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A59C6B00D8
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:23:41 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2201744iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:23:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019115952.d922763b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101018021126.GB8654@localhost>
	<1287389631.1997.9.camel@myhost>
	<20101018180919.3AF8.A69D9226@jp.fujitsu.com>
	<1287454058.2078.12.camel@myhost>
	<20101019115952.d922763b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 14:23:29 +0900
Message-ID: <AANLkTikw6NizBStoXVz8Br_LYvoLoofsOB+d6-FX2=Be@mail.gmail.com>
Subject: Re: oom_killer crash linux system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Figo.zhang" <zhangtianfei@leadcoretech.com>, lKOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 11:59 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 19 Oct 2010 10:07:38 +0800
> "Figo.zhang" <zhangtianfei@leadcoretech.com> wrote:
>
>>
>> >
>> > very lots of change ;)
>> > can you please send us your crash log?
>>
>> i add some prink in select_bad_process() and oom_badness() to see
>> pid/totalpages/points/memoryuseage/and finally process to selet to kill.
>>
>> i found it the oom-killer select: syslog-ng,mysqld,nautilus,VirtualBox
>> to kill, so my question is:
>>
>> 1. the syslog-ng,mysqld,nautilus is the system foundamental process, so
>> if oom-killer kill those process, the system will be damaged, such as
>> lose some important data.
>>
>> 2. the new oom-killer just use percentage of used memory as score to
>> select the candidate to kill, but how to know this process to very
>> important for system?
>>
>
> The kernel can never know it. Just an admin (a man or management software=
) knows.
> Old kernel tries to guess it, but it tend to be wrong and many many repor=
t comes
> "why my ....is killed..." All guesswork the kernel does is not enough, I =
think.
>
>> oom_score_adj, it is anyone commercial linux distributions to use this
>> to protect the critical process.
>>
> oom_adj may be used in some system. All my customers select panic_at_oom=
=3D1
> and cause cluster fail over rather than half-broken.
>
> <Off topic>
> Your another choice is memory cgroup, I think.
> please see documentation/cgroup/memory.txt or libcgroup.
> http://sourceforge.net/projects/libcg/
> You can use some fancy controls with it.
> </Off topic>
>
>
> BTW, there seems to be some strange things.
> (CC'ed to linux-mm)
> Brief Summary:
> =A0 an oom-killer happens on swapless environment with 2.6.36-rc8.
> =A0 It has 2G memory.
> a reporter says
> =3D=3D
>> i want to test the oom-killer. My desktop (Dell optiplex 780, i686
>> kernel)have 2GB ram, i turn off the swap partition, and open a huge pdf
>> files and applications, and let the system eat huge ram.
>>
>> in 2.6.35, i can use ram up to 1.75GB,
>>
>> but in 2.6.36-rc8, i just use to 1.53GB ram , the system come very slow
>> and crashed after some minutes , the DiskIO is very busy. i see the
>> DiskIO read is up to 8MB/s, write just only 400KB/s, (see by conky).
> =3D=3D
>
> The trigger of oom-kill is order=3D0 allocation. (see original mail for f=
ull log)
>
>
> Oct 19 09:44:08 myhost kernel: [ =A0618.441470] httpd invoked oom-killer:
> gfp_mask=3D0x201da, order=3D0, oom_adj=3D0, oom_score_adj=3D0
>
> Zone's stat is.
>
> Oct 19 09:44:08 myhost kernel: [ =A0618.441551]
> DMA free:7968kB min:64kB low:80kB high:96kB active_anon:3700kB inactive_a=
non:3752kB
> =A0 =A0active_file:12kB inactive_file:252kB unevictable:0kB isolated(anon=
):0kB
> =A0 =A0isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback=
:4kB
> =A0 =A0mapped:52kB shmem:348kB slab_reclaimable:0kB slab_unreclaimable:16=
kB
> =A0 =A0kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
> =A0 =A0writeback_tmp:0kB pages_scanned:421 all_unreclaimable? yes
> =A0 =A0lowmem_reserve[]: 0 865 1980 1980
>
> Oct 19 09:44:08 myhost kernel: [ =A0618.441560]
> Normal free:39348kB min:3728kB low:4660kB high:5592kB active_anon:176740k=
B
> =A0 =A0 =A0 inactive_anon:25640kB active_file:84kB inactive_file:308kB
> =A0 =A0 =A0 unevictable:0kB isolated(anon):0kB isolated(file):0kB present=
:885944kB
> =A0 =A0 =A0 mlocked:0kB dirty:0kB writeback:4kB mapped:576992kB shmem:502=
4kB
> =A0 =A0 =A0 slab_reclaimable:7612kB slab_unreclaimable:15512kB kernel_sta=
ck:2792kB
> =A0 =A0 =A0 pagetables:6884kB unstable:0kB bounce:0kB writeback_tmp:0kB
> =A0 =A0 =A0 pages_scanned:741 all_unreclaimable? yes
> =A0 =A0 =A0 lowmem_reserve[]: 0 0 8921 8921
>
> Oct 19 09:44:08 myhost kernel: [ =A0618.441569]
> HighMem free:392kB min:512kB low:1712kB high:2912kB active_anon:492208kB
> =A0 =A0 =A0 =A0inactive_anon:166404kB active_file:180kB inactive_file:840=
kB
> =A0 =A0 =A0 =A0unevictable:40kB isolated(anon):0kB isolated(file):0kB pre=
sent:1141984kB
> =A0 =A0 =A0 =A0mlocked:40kB dirty:0kB writeback:12kB mapped:493648kB shme=
m:72216kB
> =A0 =A0 =A0 =A0slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0=
kB
> =A0 =A0 =A0 =A0pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
> =A0 =A0 =A0 =A0pages_scanned:1552 all_unreclaimable? yes
>
> Highmem seems a bit strange.
> =A0present(1141984) - active_anon - inactive_anon - inactive_file - activ=
e_file
> =A0=3D 482352kB but free is 392kB.
>
> =A0Highmem is used for some other purpose than usual user's page.(pagetab=
le is 0.)
> =A0And, Hmm, mapped:493648kB seems too large for me.
> =A0(active/inactive-file + shmem is not enough.)
> =A0And "mapped" in NORMAL zone is large, too.
>
> =A0Does anyone have idea about file-mapped-but-not-on-LRU pages ?

Isn't it possible some file pages are much sharable?
Please see the page_add_file_rmap.

>
> Thanks,
> -Kame
>
>
>
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
