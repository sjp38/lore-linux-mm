Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E44E76B0022
	for <linux-mm@kvack.org>; Mon, 23 May 2011 20:26:32 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4O0QTS5003497
	for <linux-mm@kvack.org>; Mon, 23 May 2011 17:26:29 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq6.eem.corp.google.com with ESMTP id p4O0OLOm029254
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 17:26:28 -0700
Received: by qwf7 with SMTP id 7so4110680qwf.24
        for <linux-mm@kvack.org>; Mon, 23 May 2011 17:26:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110524091114.02fb183d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124636.45c26cfa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520144935.3bfdb2e2.akpm@linux-foundation.org>
	<BANLkTi=Ap=NdZ+05UjjEsC5f5wdjo9yvew@mail.gmail.com>
	<BANLkTinEcbQoV6n0+S9W4s4+AFJKKCiwsA@mail.gmail.com>
	<20110524091114.02fb183d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 May 2011 17:26:28 -0700
Message-ID: <BANLkTinX-qe2vRApxBQbvEdsoAcvCQtB4A@mail.gmail.com>
Subject: Re: [PATCH 6/8] memcg asynchronous memory reclaim interface
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Mon, May 23, 2011 at 5:11 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 23 May 2011 16:36:20 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Fri, May 20, 2011 at 4:56 PM, Hiroyuki Kamezawa
>> <kamezawa.hiroyuki@gmail.com> wrote:
>> > 2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
>> >> On Fri, 20 May 2011 12:46:36 +0900
>> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >>
>> >>> This patch adds a logic to keep usage margin to the limit in asynchr=
onous way.
>> >>> When the usage over some threshould (determined automatically), asyn=
chronous
>> >>> memory reclaim runs and shrink memory to limit - MEMCG_ASYNC_STOP_MA=
RGIN.
>> >>>
>> >>> By this, there will be no difference in total amount of usage of cpu=
 to
>> >>> scan the LRU
>> >>
>> >> This is not true if "don't writepage at all (revisit this when
>> >> dirty_ratio comes.)" is true. =A0Skipping over dirty pages can cause
>> >> larger amounts of CPU consumption.
>> >>
>> >>> but we'll have a chance to make use of wait time of applications
>> >>> for freeing memory. For example, when an application read a file or =
socket,
>> >>> to fill the newly alloated memory, it needs wait. Async reclaim can =
make use
>> >>> of that time and give a chance to reduce latency by background works=
.
>> >>>
>> >>> This patch only includes required hooks to trigger async reclaim and=
 user interfaces.
>> >>> Core logics will be in the following patches.
>> >>>
>> >>>
>> >>> ...
>> >>>
>> >>> =A0/*
>> >>> + * For example, with transparent hugepages, memory reclaim scan at =
hitting
>> >>> + * limit can very long as to reclaim HPAGE_SIZE of memory. This inc=
reases
>> >>> + * latency of page fault and may cause fallback. At usual page allo=
cation,
>> >>> + * we'll see some (shorter) latency, too. To reduce latency, it's a=
ppreciated
>> >>> + * to free memory in background to make margin to the limit. This c=
onsumes
>> >>> + * cpu but we'll have a chance to make use of wait time of applicat=
ions
>> >>> + * (read disk etc..) by asynchronous reclaim.
>> >>> + *
>> >>> + * This async reclaim tries to reclaim HPAGE_SIZE * 2 of pages when=
 margin
>> >>> + * to the limit is smaller than HPAGE_SIZE * 2. This will be enable=
d
>> >>> + * automatically when the limit is set and it's greater than the th=
reshold.
>> >>> + */
>> >>> +#if HPAGE_SIZE !=3D PAGE_SIZE
>> >>> +#define MEMCG_ASYNC_LIMIT_THRESH =A0 =A0 =A0(HPAGE_SIZE * 64)
>> >>> +#define MEMCG_ASYNC_MARGIN =A0 =A0 =A0 =A0 (HPAGE_SIZE * 4)
>> >>> +#else /* make the margin as 4M bytes */
>> >>> +#define MEMCG_ASYNC_LIMIT_THRESH =A0 =A0 =A0(128 * 1024 * 1024)
>> >>> +#define MEMCG_ASYNC_MARGIN =A0 =A0 =A0 =A0 =A0 =A0(8 * 1024 * 1024)
>> >>> +#endif
>> >>
>> >> Document them, please. =A0How are they used, what are their units.
>> >>
>> >
>> > will do.
>> >
>> >
>> >>> +static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
>> >>> +
>> >>> +/*
>> >>> =A0 * The memory controller data structure. The memory controller co=
ntrols both
>> >>> =A0 * page cache and RSS per cgroup. We would eventually like to pro=
vide
>> >>> =A0 * statistics based on the statistics developed by Rik Van Riel f=
or clock-pro,
>> >>> @@ -278,6 +303,12 @@ struct mem_cgroup {
>> >>> =A0 =A0 =A0 =A0*/
>> >>> =A0 =A0 =A0 unsigned long =A0 move_charge_at_immigrate;
>> >>> =A0 =A0 =A0 /*
>> >>> + =A0 =A0 =A0* Checks for async reclaim.
>> >>> + =A0 =A0 =A0*/
>> >>> + =A0 =A0 unsigned long =A0 async_flags;
>> >>> +#define AUTO_ASYNC_ENABLED =A0 (0)
>> >>> +#define USE_AUTO_ASYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1)
>> >>
>> >> These are really confusing. =A0I looked at the implementation and at =
the
>> >> documentation file and I'm still scratching my head. =A0I can't work =
out
>> >> why they exist. =A0With the amount of effort I put into it ;)
>> >>
>> >> Also, AUTO_ASYNC_ENABLED and USE_AUTO_ASYNC have practically the same
>> >> meaning, which doesn't help things.
>> >>
>> > Ah, yes it's confusing.
>>
>> Sorry I was confused by the memory.async_control interface. I assume
>> that is the knob to turn on/off the bg reclaim on per-memcg basis. But
>> when I tried to turn it off, it seems not working well:
>>
>> $ cat /proc/7248/cgroup
>> 3:memory:/A
>>
>> $ cat /dev/cgroup/memory/A/memory.async_control
>> 0
>>
>
> If enabled and kworker runs, this shows "3", for now.
> I'll make this simpler in the next post.
>
>> Then i can see the kworkers start running when the memcg A under
>> memory pressure. There was no other memcgs configured under root.
>
>
> What kworkers ? For example, many kworkers runs on ext4? on my host.
> If kworker/u:x works, it may be for memcg (for my host)

I am kind of sure they are kworkers from memcg. They start running
right after my test and then stop when i kill that test.

$ cat /dev/cgroup/memory/A/memory.limit_in_bytes
2147483648
$ cat /dev/cgroup/memory/A/memory.async_control
0


  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
  393 root      20   0     0    0    0 S   54  0.0   1:30.36
kworker/7:1
  391 root      20   0     0    0    0 S   51  0.0   1:42.35
kworker/5:1
  390 root      20   0     0    0    0 S   43  0.0   1:45.55
kworker/4:1
   11 root      20   0     0    0    0 S   40  0.0   1:36.98
kworker/1:0
   14 root      20   0     0    0    0 S   36  0.0   1:47.04
kworker/0:1
  389 root      20   0     0    0    0 S   24  0.0   0:47.35
kworker/3:1
20071 root      20   0 20.0g 497m 497m D   12  1.5   0:04.99 memtoy
  392 root      20   0     0    0    0 S   10  0.0   1:26.43
kworker/6:1

--Ying

>
> Ok, I'll add statistics in v3.
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
