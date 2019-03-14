Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D962EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 17:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B32C21872
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 17:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="iylZzi+8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B32C21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 130FB6B0003; Thu, 14 Mar 2019 13:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0E56B0005; Thu, 14 Mar 2019 13:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3FF6B0006; Thu, 14 Mar 2019 13:47:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE366B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:47:39 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id u13so1774327ljj.13
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:47:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gQYMLIgVmxQldUr4kxOlYx1VLacMHWwXJZip9LpPVrk=;
        b=AbmYNLOSOJHbFqtTPT9kk92oEgva7GGw89C0PIV5TRVqSRCD5oj9ZW6PtjJdYZCC9l
         oyZ7Mf5yAIIbNi7PeXfXRd8sb4+P9CYOLMoWWVKn3F5/ykoT/UicfbblGKASfo9AT9a7
         oTlA7aOzt95aB1dK10YmnoIZpkxnjFgdedeGPd3bPi4CpvVkY6jUEs4ONb6/8nCEpcmw
         ZUulYxbEZK6rEp0BWSTyVn+rrxh1IF7tDfrQlcBMyk82I3l60Dql8g+Rs/k3UWkxG3Ug
         GCSsSETPJSZVXJ8N4il6g5ffjrMV0pJQaMyN5lvnw+tYu3zBWz91sK2CJfu20/C25h0o
         ZRJQ==
X-Gm-Message-State: APjAAAUPmRBfjIVPtAfOpsIfigZ331MVQcm2flBexzqAPBXpxh251cIh
	G66Gf83uW9Oij2BagOi66IrBl84NgG5KbaeDikC8nSHrjt9NZl7cJz+GfxaDyxWitrYci7/ExWs
	qmS4HMf7KfKKfepgbv09jxHc+hZUSyfOk3zqWiQWBNuLKeyzdJITznnsgM7zgzwLQJT8Med1LCY
	7YlOFCRKG4S/5vFjdveyq5LC/dRZE8SKql7iMINp17KxHQwaZizNiTPusRLZwtAFClKj/WRGoxe
	lwuecLfFc+CfvtbvBScNA0wuNmyxK/lZiCKSoQ8JWoRQlQ1nER3dzkwNkqQ9kI7qh0OWDn8GP4n
	oKeWA/V4VKVES/1IVs0+oV51eB4jW6Ndvle4pl0L5uj9s3coeUL5yZywIZ0UOv7mARSkPXrphjJ
	Z
X-Received: by 2002:a19:9e0d:: with SMTP id h13mr12498631lfe.51.1552585658708;
        Thu, 14 Mar 2019 10:47:38 -0700 (PDT)
X-Received: by 2002:a19:9e0d:: with SMTP id h13mr12498558lfe.51.1552585657215;
        Thu, 14 Mar 2019 10:47:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552585657; cv=none;
        d=google.com; s=arc-20160816;
        b=YkWJ1OXuIyexzzxabJluQq80ZgfFhaZtULHoAVoPEpCXmTyJSkfdGE/GdAk6+fcmGh
         aRRIJs/UX8IVFSh19nrfL9phpUcMgF1vpCzhDfGUyaxslTo4c+YVdmu1t/r5I6o8o57c
         IBG+sL9mueAuUm2Mdj+6CprnkojEIT6Myq7+8U2D/hW0qGQuxodyPx1fpFn2/PThrheZ
         awj5LoH7ayPYAraSBNTDGgsNWh1QS3NI+AxZt/8P3ZRk8Cki6uj6LaYBmSaGylsqbPsz
         flPNsFxLdVrckaHm3rt5BHoryBHi6ASIdXrqGZG2JfcEXcPwHg25GLBRP5+fd+GdpFQL
         74TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gQYMLIgVmxQldUr4kxOlYx1VLacMHWwXJZip9LpPVrk=;
        b=lpGYODsBMlLubP9jHNVycAj4qNNa3vE1r4hK3WNS3NPPmtLHlLtjpOOXqjXooIH1VX
         xqAPFPAgP2Z1RU/e02gLPXYHQfvLeMfLBBKpfA1qanxwr/HuDpmvbadEhb3gZSOc5hts
         60dcqnbbxmPJXAdLNWyDG1EwtuEFmn50r07xyafF0KeX8/U1xN/BfqPVa9UwmNDr6jzO
         mw26+Ymw1t2fH1Af+pcM8YTNO7eeXNAHfskAplyd4Ngdm3S5QXa8I0LdQYr7wcwkfP25
         RYE2tFy0P3tA2WOsOvi/h8fWQ7wuukBlzaxq1yUevKNHFPej8hqP37KYAjpS8trulapa
         djLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=iylZzi+8;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a20sor4147094lfl.60.2019.03.14.10.47.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 10:47:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=iylZzi+8;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gQYMLIgVmxQldUr4kxOlYx1VLacMHWwXJZip9LpPVrk=;
        b=iylZzi+8eAfMi1yoAx76QVqhI6nJFaPp2w8RW26JEUv0mYEAZA8Q/n8R9390ofLy8J
         680tRWJk5W0QGtfi2Or/5ZT9PNwA1ZdJNVb/fMXRuuPSknaxs/GKH5YwedvdmQXma0Ah
         JcMsr3W1yBeVgwz6nYubzDMN9n7gebqxzJdEQ=
X-Google-Smtp-Source: APXvYqzj3H5LXBJMFL3NSv0Ut/9sVgD2+BPFP2JSpI5TDzO8vVnOdbvXIP0EDmouupRx9rtS7LeMK8zJ040fzJKp0L0=
X-Received: by 2002:a19:8c1e:: with SMTP id o30mr17748637lfd.137.1552585656532;
 Thu, 14 Mar 2019 10:47:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
In-Reply-To: <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Thu, 14 Mar 2019 10:47:17 -0700
Message-ID: <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Tim Murray <timmurray@google.com>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Michal Hocko <mhocko@kernel.org>, 
	Suren Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Christian Brauner <christian@brauner.io>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tim,
Thanks for the detailed and excellent write-up. It will serve as a
good future reference for low memory killer requirements. I made some
comments below on the "how to kill" part.

On Tue, Mar 12, 2019 at 10:17 AM Tim Murray <timmurray@google.com> wrote:
>
> On Tue, Mar 12, 2019 at 9:37 AM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> >
> > On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> > > The only way to control the OOM behavior pro-actively is to throttle
> > > allocation speed. We have memcg high limit for that purpose. Along with
> > > PSI, I can imagine a reasonably working user space early oom
> > > notifications and reasonable acting upon that.
> >
> > The issue with pro-active memory management that prompted me to create this was
> > poor memory utilization. All of the alternative means of reclaiming pages in the
> > page allocator's slow path turn out to be very useful for maximizing memory
> > utilization, which is something that we would have to forgo by relying on a
> > purely pro-active solution. I have not had a chance to look at PSI yet, but
> > unless a PSI-enabled solution allows allocations to reach the same point as when
> > the OOM killer is invoked (which is contradictory to what it sets out to do),
> > then it cannot take advantage of all of the alternative memory-reclaim means
> > employed in the slowpath, and will result in killing a process before it is
> > _really_ necessary.
>
> There are two essential parts of a lowmemorykiller implementation:
> when to kill and how to kill.
>
> There are a million possible approaches to decide when to kill an
> unimportant process. They usually trade off between the same two
> failure modes depending on the workload.
>
> If you kill too aggressively, a transient spike that could be
> imperceptibly absorbed by evicting some file pages or moving some
> pages to ZRAM will result in killing processes, which then get started
> up later and have a performance/battery cost.
>
> If you don't kill aggressively enough, you will encounter a workload
> that thrashes the page cache, constantly evicting and reloading file
> pages and moving things in and out of ZRAM, which makes the system
> unusable when a process should have been killed instead.
>
> As far as I've seen, any methodology that uses single points in time
> to decide when to kill without completely biasing toward one or the
> other is susceptible to both. The minfree approach used by
> lowmemorykiller/lmkd certainly is; it is both too aggressive for some
> workloads and not aggressive enough for other workloads. My guess is
> that simple LMK won't kill on transient spikes but will be extremely
> susceptible to page cache thrashing. This is not an improvement; page
> cache thrashing manifests as the entire system running very slowly.
>
> What you actually want from lowmemorykiller/lmkd on Android is to only
> kill once it becomes clear that the system will continue to try to
> reclaim memory to the extent that it could impact what the user
> actually cares about. That means tracking how much time is spent in
> reclaim/paging operations and the like, and that's exactly what PSI
> does. lmkd has had support for using PSI as a replacement for
> vmpressure for use as a wakeup trigger (to check current memory levels
> against the minfree thresholds) since early February. It works fine;
> unsurprisingly it's better than vmpressure at avoiding false wakeups.
>
> Longer term, there's a lot of work to be done in lmkd to turn PSI into
> a kill trigger and remove minfree entirely. It's tricky (mainly
> because of the "when to kill another process" problem discussed
> later), but I believe it's feasible.
>
> How to kill is similarly messy. The latency of reclaiming memory post
> SIGKILL can be severe (usually tens of milliseconds, occasionally
> >100ms). The latency we see on Android usually isn't because those
> threads are blocked in uninterruptible sleep, it's because times of
> memory pressure are also usually times of significant CPU contention
> and these are overwhelmingly CFS threads, some of which may be
> assigned a very low priority. lmkd now sets priorities and resets
> cpusets upon killing a process, and we have seen improved reclaim
> latency because of this. oom reaper might be a good approach to avoid
> this latency (I think some in-kernel lowmemorykiller implementations
> rely on it), but we can't use it from userspace. Something for future
> consideration.
>

This makes sense. If the process receiving the SIGKILL does not get CPU
time, then the kernel may not be able to execute the unconditional
signal handling paths in the context of the victim process to free the memory.

I don't see how proc-fds approach will solve this though. Say you have
process L (which is LMKd) which sends a SIGKILL to process V(which is
a victim). Now L sends SIGKILL to V. Unless V executes the
signal-handling code in kernel context and is scheduled at high enough
priority to get CPU time, I don't think the SIGKILL will be processed.

The exact path that the process being killed executes to free its
memory is: do_signal-> get_signal-> do_group_exit-> do_exit-> mmput.
And this needs to execute in the context of V which needs to get
CPU-time to do such execution.

So my point is to be notified of process death, you still need SIGKILL
to be processed. So you may still need to make sure the task is at a
high enough priority and scheduler puts it on the CPU. Only *after
that* can he proc-fds notification mechanism (or whichever)
notification mechanism can kick in.

Speaking of which I wonder if the scheduler should special case
SIGKILLed threads as higher priority automatically so that they get
CPU time, but don't know if this can cause denial of service kind of
attacks. I don't know if it does something like this already. Peter
should know this right off the bat and he is on CC so he can comment
more.

About the 100ms latency, I wonder whether it is that high because of
the way Android's lmkd is observing that a process has died. There is
a gap between when a process memory is freed and when it disappears
from the process-table.  Once a process is SIGKILLed, it becomes a
zombie. Its memory is freed instantly during the SIGKILL delivery (I
traced this so that's how I know), but until it is reaped by its
parent thread, it will still exist in /proc/<pid> . So if testing the
existence of /proc/<pid> is how Android is observing that the process
died, then there can be a large latency where it takes a very long
time for the parent to actually reap the child way after its memory
was long freed. A quicker way to know if a process's memory is freed
before it is reaped could be to read back /proc/<pid>/maps in
userspace of the victim <pid>, and that file will be empty for zombie
processes. So then one does not need wait for the parent to reap it. I
wonder how much of that 100ms you mentioned is actually the "Waiting
while Parent is reaping the child", than "memory freeing time". So
yeah for this second problem, the procfds work will help.

By the way another approach that can provide a quick and asynchronous
notification of when the process memory is freed, is to monitor
sched_process_exit trace event using eBPF. You can tell eBPF the PID
that you want to monitor before the SIGKILL. As soon as the process
dies and its memory is freed, the eBPF program can send a notification
to user space (using the perf_events polling infra). The
sched_process_exit fires just after the mmput() happens so it is quite
close to when the memory is reclaimed. This also doesn't need any
kernel changes. I could come up with a prototype for this and
benchmark it on Android, if you want. Just let me know.

thanks,

 - Joel










> A non-obvious consequence of both of these concerns is that when to
> kill a second process is a distinct and more difficult problem than
> when to kill the first. A second process should be killed if reclaim
> from the first process has finished and there has been insufficient
> memory reclaimed to avoid perceptible impact. Identifying whether
> memory pressure continues at the same level can probably be handled
> through multiple PSI monitors with different thresholds and window
> lengths, but this is an area of future work.
>
> Knowing whether a SIGKILL'd process has finished reclaiming is as far
> as I know not possible without something like procfds. That's where
> the 100ms timeout in lmkd comes in. lowmemorykiller and lmkd both
> attempt to wait up to 100ms for reclaim to finish by checking for the
> continued existence of the thread that received the SIGKILL, but this
> really means that they wait up to 100ms for the _thread_ to finish,
> which doesn't tell you anything about the memory used by that process.
> If those threads terminate early and lowmemorykiller/lmkd get a signal
> to kill again, then there may be two processes competing for CPU time
> to reclaim memory. That doesn't reclaim any faster and may be an
> unnecessary kill.
>
> So, in summary, the impactful LMK improvements seem like
>
> - get lmkd and PSI to the point that lmkd can use PSI signals as a
> kill trigger and remove all static memory thresholds from lmkd
> completely. I think this is mostly on the lmkd side, but there may be
> some PSI or PSI monitor changes that would help
> - give userspace some path to start reclaiming memory without waiting
> for every thread in a process to be scheduled--could be oom reaper,
> could be something else
> - offer a way to wait for process termination so lmkd can tell when
> reclaim has finished and know when killing another process is
> appropriate

