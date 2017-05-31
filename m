Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 069FD6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 18:20:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a77so5962405wma.12
        for <linux-mm@kvack.org>; Wed, 31 May 2017 15:20:32 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id x15si18108242wmf.110.2017.05.31.15.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 15:20:31 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id d127so37391651wmf.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 15:20:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9e610b16-86fc-e5a0-ea6b-19007348a6c3@I-love.SAKURA.ne.jp>
References: <CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com>
 <9e610b16-86fc-e5a0-ea6b-19007348a6c3@I-love.SAKURA.ne.jp>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 31 May 2017 15:20:10 -0700
Message-ID: <CAM_iQpUNq7L-LQS673T-sOHXNMKw8yEzdwdHwkPb6bM32a=U9g@mail.gmail.com>
Subject: Re: Yet another page allocation stall on 4.9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

(Sorry for the delay)

On Thu, May 25, 2017 at 4:17 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Cong Wang wrote:
>> Below is the one we got when running LTP memcg_stress test with 150
>> memcg groups each with 0.5g memory on a 64G memory host. So far, this
>> is not reproducible at all.
>
> Since 150 * 0.5G > 64G, I assume that non-memcg OOM is possible.
>
> Since Node 1 Normal free is below min watermark, I assume that stalling
> threads are trying to allocate from Node 1 Normal. And Node 1 is marked a=
s
> all_unreclaimable =3D=3D yes.
>
> [16212.217051] Node 1 active_anon:32559600kB inactive_anon:13516kB active=
_file:216kB inactive_file:212kB unevictable:0kB isolated(anon):0kB isolated=
(file):0kB mapped:14208kB dirty:0kB writeback:0kB shmem:16628kB shmem_thp: =
0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages=
_scanned:683486 all_unreclaimable? yes
> [16212.217074] Node 1 Normal free:44744kB min:45108kB low:78068kB high:11=
1028kB active_anon:32559600kB inactive_anon:13516kB active_file:216kB inact=
ive_file:212kB unevictable:0kB writepending:0kB present:33554432kB managed:=
32962516kB mlocked:0kB slab_reclaimable:39540kB slab_unreclaimable:144280kB=
 kernel_stack:5208kB pagetables:70388kB bounce:0kB free_pcp:1112kB local_pc=
p:0kB free_cma:0kB
>
> Since "page allocation stalls for" messages are printed for allocation re=
quests
> which can invoke the OOM killer, something is preventing them from callin=
g out_of_memory().
> There are no OOM killer messages around these stalls, aren't there?

I didn't see any OOM message in our (partial) kernel log.


>
> [16216.520770] warn_alloc: 5 callbacks suppressed
> [16216.520775] scribed: page allocation stalls for 35691ms, order:0, mode=
:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
> [16216.631514] memcg_process_s: page allocation stalls for 31710ms, order=
:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
> [16216.854787] scribed: page allocation stalls for 35977ms, order:0, mode=
:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
> [16216.984835] scribed: page allocation stalls for 36056ms, order:0, mode=
:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
> [16217.075797] memcg_process_s: page allocation stalls for 32206ms, order=
:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
>
> One of possibilities that can prevent them from calling out_of_memory() i=
s that
> should_reclaim_retry() continues returning true for some reason. If that =
is the
> case, at least did_some_progress > 0 was true when should_reclaim_retry()=
 is
> called, otherwise should_reclaim_retry() will eventually return false due=
 to
> MAX_RECLAIM_RETRIES check. This means that try_to_free_pages() is returni=
ng
> non-zero value via __alloc_pages_direct_reclaim(). Then, something is set=
ting
> sc->nr_reclaimed to non-zero? mem_cgroup_soft_limit_reclaim() in shrink_z=
ones() ?
> But how? Let's wait for comments from mm experts...
>

Yeah, I am not familiar with that code at all, especially after OOM killer
is written recently.


>
>
>> Please let me know if I can provide any other information you need.
>
> Did these stalls last forever until you take actions like SysRq-i ?


Seem so, machine was rebooted after that.


> I suspect it might not a lockup but slow down due to over-stressing.
>
> I wonder why soft lockup warnings are there.

I guess the kernel watchdog detects the same stall, but I also see
there is cond_resched() in that code but it was never called for some
reason.


>
> [16212.217026] CPU: 4 PID: 3872 Comm: scribed Not tainted 4.9.23.el7.twit=
ter.x86_64 #1
> [16213.505627] NMI watchdog: BUG: soft lockup - CPU#5 stuck for 23s!
> [16213.505713] CPU: 5 PID: 7598 Comm: cleanup Not tainted 4.9.23.el7.twit=
ter.x86_64 #1
> [16214.250659] NMI watchdog: BUG: soft lockup - CPU#17 stuck for 22s!
> [16214.250765] CPU: 17 PID: 3905 Comm: scribed Tainted: G             L 4=
.9.23.el7.twitter.x86_64 #1
> [16215.357554] CPU: 20 PID: 7812 Comm: proxymap Tainted: G             L =
4.9.23.el7.twitter.x86_64 #1
> [16217.047932] CPU: 8 PID: 827 Comm: crond Tainted: G             L 4.9.2=
3.el7.twitter.x86_64 #1
>
> But these stalls and first time of soft lockup ('L' bit set to tainted_ma=
sk variable) seems to
> occurred roughly at the same time. The first time of soft lockup began ar=
ound uptime =3D 16190.
> Assuming "warn_alloc: 5 callbacks suppressed" is due to allocation stalls=
, when was the
> first time page allocation stall began? If it began around uptime =3D 161=
80, these soft lockup
> warnings might be caused by trying to print too much messages via warn_al=
loc() to slow consoles.
>

The log I sent is partial, but that is already all what we captured,
I can't find more in kern.log due to log rotation.

Please let me know if I can provide any other information.

Thanks for looking into it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
