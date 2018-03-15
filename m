Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2B56B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:58:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id k4-v6so2859773pls.15
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 01:58:23 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0123.outbound.protection.outlook.com. [104.47.2.123])
        by mx.google.com with ESMTPS id x23si3467743pfh.355.2018.03.15.01.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 01:58:22 -0700 (PDT)
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180314220909.GE2943022@devbig577.frc2.facebook.com>
 <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c5c1c98b-9e0c-ec09-36c6-4266ad239ef1@virtuozzo.com>
Date: Thu, 15 Mar 2018 11:58:15 +0300
MIME-Version: 1.0
In-Reply-To: <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15.03.2018 01:22, Andrew Morton wrote:
> On Wed, 14 Mar 2018 15:09:09 -0700 Tejun Heo <tj@kernel.org> wrote:
> 
>> Hello, Andrew.
>>
>> On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
>>> It would benefit from a comment explaining why we're doing this (it's
>>> for the oom-killer).
>>
>> Will add.
>>
>>> My memory is weak and our documentation is awful.  What does
>>> mutex_lock_killable() actually do and how does it differ from
>>> mutex_lock_interruptible()?  Userspace tasks can run pcpu_alloc() and I
>>
>> IIRC, killable listens only to SIGKILL.
>>
>>> wonder if there's any way in which a userspace-delivered signal can
>>> disrupt another userspace task's memory allocation attempt?
>>
>> Hmm... maybe.  Just honoring SIGKILL *should* be fine but the alloc
>> failure paths might be broken, so there are some risks.  Given that
>> the cases where userspace tasks end up allocation percpu memory is
>> pretty limited and/or priviledged (like mount, bpf), I don't think the
>> risks are high tho.
> 
> hm.  spose so.  Maybe.  Are there other ways?  I assume the time is
> being spent in pcpu_create_chunk()?  We could drop the mutex while
> running that stuff and take the appropriate did-we-race-with-someone
> testing after retaking it.  Or similar.

The balance work spends its time in pcpu_populate_chunk(). There are
two stacks of this problem:

[  106.313267] kworker/2:2     D13832   936      2 0x80000000
[  106.313740] Workqueue: events pcpu_balance_workfn
[  106.314109] Call Trace:
[  106.314293]  ? __schedule+0x267/0x750
[  106.314570]  schedule+0x2d/0x90
[  106.314803]  schedule_timeout+0x17f/0x390
[  106.315106]  ? __next_timer_interrupt+0xc0/0xc0
[  106.315429]  __alloc_pages_slowpath+0xb73/0xd90
[  106.315792]  __alloc_pages_nodemask+0x16a/0x210
[  106.316148]  pcpu_populate_chunk+0xce/0x300
[  106.316479]  pcpu_balance_workfn+0x3f3/0x580
[  106.316853]  ? _raw_spin_unlock_irq+0xe/0x30
[  106.317227]  ? finish_task_switch+0x8d/0x250
[  106.317632]  process_one_work+0x1b7/0x410
[  106.317970]  worker_thread+0x26/0x3d0
[  106.318304]  ? process_one_work+0x410/0x410
[  106.318649]  kthread+0x10e/0x130
[  106.318916]  ? __kthread_create_worker+0x120/0x120
[  106.319360]  ret_from_fork+0x35/0x40

[  106.453375] a.out           D13400  3670      1 0x00100004
[  106.453880] Call Trace:
[  106.454114]  ? __schedule+0x267/0x750
[  106.454427]  schedule+0x2d/0x90
[  106.454829]  schedule_preempt_disabled+0xf/0x20
[  106.455422]  __mutex_lock.isra.2+0x181/0x4d0
[  106.455988]  ? pcpu_alloc+0x3c4/0x670
[  106.456465]  pcpu_alloc+0x3c4/0x670
[  106.456973]  ? preempt_count_add+0x63/0x90
[  106.457401]  ? __local_bh_enable_ip+0x2e/0x60
[  106.457882]  ipv6_add_dev+0x121/0x490
[  106.458330]  addrconf_notify+0x27b/0x9a0
[  106.458823]  ? inetdev_init+0xd7/0x150
[  106.459270]  ? inetdev_event+0x339/0x4b0
[  106.459738]  ? preempt_count_add+0x63/0x90
[  106.460243]  ? _raw_spin_lock_irq+0xf/0x30
[  106.460747]  ? notifier_call_chain+0x42/0x60
[  106.461271]  notifier_call_chain+0x42/0x60
[  106.461819]  register_netdevice+0x415/0x530
[  106.462364]  register_netdev+0x11/0x20
[  106.462849]  loopback_net_init+0x43/0x90
[  106.463216]  ops_init+0x3b/0x100
[  106.463516]  setup_net+0x7d/0x150
[  106.463831]  copy_net_ns+0x14b/0x180
[  106.464134]  create_new_namespaces+0x117/0x1b0
[  106.464481]  unshare_nsproxy_namespaces+0x5b/0x90
[  106.464864]  SyS_unshare+0x1b0/0x300

[  106.536845] Kernel panic - not syncing: Out of memory and no killable processes...
