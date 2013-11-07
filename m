Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0AA6B0171
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 14:35:08 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1075018pad.2
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 11:35:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id r4si4020942pan.159.2013.11.07.11.35.05
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 11:35:06 -0800 (PST)
Received: by mail-we0-f175.google.com with SMTP id t61so994224wes.6
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 11:35:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1311061631280.22318@chino.kir.corp.google.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
 <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
 <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
 <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
 <CANMivWZrefY1bbgpJgABqcUwKfqOR9HQtGNY6cWdutcMASeo2A@mail.gmail.com>
 <CAA25o9QG2BOmV5MoXCH73sadKoRD6wPivKq6TLvEem8GhZeXGg@mail.gmail.com>
 <CAA25o9Q-HvjQ_5pFJgYNeutaCoYgPu=e=k7EHq=6-+jeEuhzoA@mail.gmail.com>
 <CANMivWZhNRGW6DPcqpYiUBjOX23LRZ_kJ9DzzfS7VdRpm075ZA@mail.gmail.com> <alpine.DEB.2.02.1311061631280.22318@chino.kir.corp.google.com>
From: Sameer Nanda <snanda@chromium.org>
Date: Thu, 7 Nov 2013 11:34:43 -0800
Message-ID: <CANMivWYzp_Eqw3BjeUz5ycQLftBuHjcZ7ZoFEwazekJNY2cJXA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luigi Semenzato <semenzato@google.com>, msb@facebook.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 6, 2013 at 4:35 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 6 Nov 2013, Sameer Nanda wrote:
>
>> David -- I think we can make the duration that the tasklist_lock is
>> held smaller by consolidating the process selection logic that is
>> currently split across select_bad_process and oom_kill_process into
>> one place in select_bad_process.  The tasklist_lock would then need to
>> be held only when the thread lists are being traversed.  Would you be
>> ok with that?  I can re-spin the patch if that sounds like a workable
>> option.
>>
>
> No, this caused hundreds of machines to hit soft lockups for Google
> because there's no synchronization that prevents dozens of cpus to take
> tasklist_lock in the oom killer during parallel memcg oom conditions and
> never allow the write_lock_irq() on fork() or exit() to make progress.  We
> absolutely must hold tasklist_lock for as little time as possible in the
> oom killer.
>
> That said, I've never actually seen your reported bug manifest in our
> production environment so let's see if Oleg has any ideas.

Is the path you are referring to mem_cgroup_out_of_memory calling
oom_kill_process?  If so, then that path doesn't appear to suffer from
the two step select_bad_process, oom_kill_process race since
mem_cgroup_out_of_memory directly calls oom_kill_process without going
through select_bad_process.  This also means that the patch I sent is
incorrect since it removes the existing tasklist_lock protection in
oom_kill_process.

Respinning patch to take care of this case.

-- 
Sameer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
