Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69840C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:05:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167822082C
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:05:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167822082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6E28E0003; Tue,  5 Mar 2019 21:05:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866F68E0001; Tue,  5 Mar 2019 21:05:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 756448E0003; Tue,  5 Mar 2019 21:05:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47CC38E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 21:05:46 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s65so8616997qke.16
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 18:05:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J0CC6t7furmIfZ0tJkstKRpObNiPXT5mpNBRsWN62vw=;
        b=TAjQQDLF+xIELYCIltfVSrhGXYptb977zh816dHOrtOYMDnAr6JeZLg2cOu5CRgltY
         +HfqlW9YiBsQWNxdbntalOyHjxc7HTNTIHVb0Tl27vdXPrOFayz7nVId7F4j60LJHus9
         l9DQ/MykCSJ5Mu6kaFYsaa8rK5dLq5ClG4eY0LsynwsE4kqRcviB0BqnAbOP4UvGPfx2
         IKEJIdIZpXEGbtUV8KmfXsX0igSoxEPmgtQwvUSKvKdy/1g76cuHuC3lpysO5CxJqXkr
         Ab2QtDRb/WDS+X65bM1odGJuDlJzRb+OeIUiwuvUR6WZk6n/o1h3SD5hESjzVAFY0vRv
         sZOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVrKXPAZ1NXFYYcTPArh0rNWrMu5QcRfK5yT1WcizfOU0RBv029
	yEL8PDPrL6IhA4/8/LZRMsJ+vZxuyGj5sRAkaSsm/woTb/GCmG9FD4ggyIHIMtzNmR0fdDLC/41
	PkG0yljQlZd1osBH9TeMQVpGPP+wqkyYoIXdlnyfT+691v6NSeRHIhG/gB7xIY9WVqA==
X-Received: by 2002:a37:dd41:: with SMTP id n62mr3934240qki.11.1551837946015;
        Tue, 05 Mar 2019 18:05:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqznXbZCrdEOdHFI21pbRovqKdx/9XJKS8gA1FJ3SRJ+YtEaGVgcmUFqPvR5gLScsex5l9BY
X-Received: by 2002:a37:dd41:: with SMTP id n62mr3934202qki.11.1551837945040;
        Tue, 05 Mar 2019 18:05:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551837945; cv=none;
        d=google.com; s=arc-20160816;
        b=R+jfJv4q9XAGi3axJRCmngXJAkLDuv1mSQrU8pXQux7ieWuCt8X+Kht1NB+eGJGZik
         g7uiyYPETdSsFLY2CWY+LQNlo+EJ7puq8KRSXZZqSgTZflZI+JXEXoRaGAMC9skLm6xm
         5ed2PsdWBGp4nhJXxxqJJxToUeeaTuW1CMLeh0GZdZRpfbuNgzvqPlr+F8B4W4/dSgx3
         4jHVNkn+0DKyZBM54ssK+MR2qXplawPLThR+NzK/lW1jfH7bIAlYpx0Z1LwGiaitNRa5
         VNh1o/LLQlPVY1l/vA60E7HMI65bZ8NbIQuyEDZ+n9dgZFGW/mMjAy054BvvBNiW/5R5
         egVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J0CC6t7furmIfZ0tJkstKRpObNiPXT5mpNBRsWN62vw=;
        b=XBY7ibQXJpg8ek3Yue1Totv3oQ+j7GCX7Tf/tSrkSBbs4kFpq6o4CiPNxXWLFdUCKr
         eCvLcUBhdNBQoTV2xdMvvfzIO2pU/lO+OVmbOaClFdsnrMPiXk5ODuGoUL4u3aOcnG9Z
         DhCqDXtk5D1ElkfePFee5aL72jmVA/IumSCteZvLMIAhc+9kMpEgN6tHr2Jwe4hFcr1x
         mtahuP3OIxFDKwNALxe3dZtn17M/tYmPRpIys2XAEsB9lEDJeExwXX/QCDinKPZaZ8eg
         Ol6tsKOkY7vEW9YnrolaNodyahnJOuSRGAdGGGK22xkQlsbnzHHPrX1bEdtjyD9XNlOK
         InlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 198si215150qkj.8.2019.03.05.18.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 18:05:45 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F30F5308222E;
	Wed,  6 Mar 2019 02:05:43 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 14774600D7;
	Wed,  6 Mar 2019 02:05:40 +0000 (UTC)
Date: Tue, 5 Mar 2019 21:05:40 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	David Rientjes <rientjes@google.com>,
	Hugh Dickins <hughd@google.com>,
	Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Peter Xu <peterx@redhat.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190306020540.GA23850@redhat.com>
References: <00000000000006457e057c341ff8@google.com>
 <5C7BFE94.6070500@huawei.com>
 <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
 <5C7D2F82.40907@huawei.com>
 <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C7E1A38.2060906@huawei.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 06 Mar 2019 02:05:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

[ CC'ed Mike and Peter ]

On Tue, Mar 05, 2019 at 02:42:00PM +0800, zhong jiang wrote:
> On 2019/3/5 14:26, Dmitry Vyukov wrote:
> > On Mon, Mar 4, 2019 at 4:32 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >> On 2019/3/4 22:11, Dmitry Vyukov wrote:
> >>> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
> >>>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>> Hi, guys
> >>>>>>
> >>>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
> >>>>>>
> >>>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
> >>>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
> >>>>>>
> >>>>>> Any thoughts?
> >>>>> FWIW syzbot was able to reproduce this with this reproducer.
> >>>>> This looks like a very subtle race (threaded reproducer that runs
> >>>>> repeatedly in multiple processes), so most likely we are looking for
> >>>>> something like few instructions inconsistency window.
> >>>>>
> >>>> I has a little doubtful about the instrustions inconsistency window.
> >>>>
> >>>> I guess that you mean some smb barriers should be taken into account.:-)
> >>>>
> >>>> Because IMO, It should not be the lock case to result in the issue.
> >>> Since the crash was triggered on x86 _most likley_ this is not a
> >>> missed barrier. What I meant is that one thread needs to executed some
> >>> code, while another thread is stopped within few instructions.
> >>>
> >>>
> >> It is weird and I can not find any relationship you had said with the issue.:-(
> >>
> >> Because It is the cause that mm->owner has been freed, whereas we still deference it.
> >>
> >> From the lastest freed task call trace, It fails to create process.
> >>
> >> Am I miss something or I misunderstand your meaning. Please correct me.
> > Your analysis looks correct. I am just saying that the root cause of
> > this use-after-free seems to be a race condition.
> >
> >
> >
> Yep, Indeed,  I can not figure out how the race works. I will dig up further.

Yes it's a race condition.

We were aware about the non-cooperative fork userfaultfd feature
creating userfaultfd file descriptor that gets reported to the parent
uffd, despite they belong to mm created by failed forks.

https://www.spinics.net/lists/linux-mm/msg136357.html

The fork failure in my testcase happened because of signal pending
that interrupted fork after the failed-fork uffd context, was already
pushed to the userfaultfd reader/monitor. CRIU then takes care of
filtering the failed fork cases so we didn't want to make the fork
code more complicated just for userfaultfd.

In reality if MEMCG is enabled at build time, mm->owner maintainance
code now creates a race condition in the above case, with any fork
failure.

I pinged Mike yesterday to ask if my theory could be true for this bug
and one solution he suggested is to do the userfaultfd_dup at a point
where fork cannot fail anymore. That's precisely what we were
wondering to do back then to avoid the failed fork reports to the
non cooperative uffd monitor.

That will solve the false positive deliveries that CRIU manager
currently filters out too. From a theoretical standpoint it's also
quite strange to even allow any uffd ioctl to run on a otherwise long
gone mm created for a process that in the end wasn't even created (the
mm got temporarily fully created, but no child task really ever used
such mm). However that mm is on its way to exit_mmap as soon as the
ioclt returns and this only ever happens during race conditions, so
the way CRIU monitor works there wasn't anything fundamentally
concerning about this detail, despite it's remarkably "strange". Our
priority was to keep the fork code as simple as possible and keep
userfaultfd as non intrusive as possible.

One alternative solution I'm wondering about for this memcg issue is
to free the task struct with RCU also when fork has failed and to add
the mm_update_next_owner before mmput. That will still report failed
forks to the uffd monitor, so it's not the ideal fix, but since it's
probably simpler I'm posting it below. Also I couldn't reproduce the
problem with the testcase here yet.

From 6cbf9d377b705476e5226704422357176f79e32c Mon Sep 17 00:00:00 2001
From: Andrea Arcangeli <aarcange@redhat.com>
Date: Tue, 5 Mar 2019 19:21:37 -0500
Subject: [PATCH 1/1] userfaultfd: use RCU to free the task struct when fork
 fails if MEMCG

MEMCG depends on the task structure not to be freed under
rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
mm->owner.

A better fix would be to avoid registering forked vmas in userfaultfd
contexts reported to the monitor, if case fork ends up failing.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index eb9953c82104..3bcbb361ffbc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -953,6 +953,15 @@ static void mm_init_aio(struct mm_struct *mm)
 #endif
 }
 
+static __always_inline void mm_clear_owner(struct mm_struct *mm,
+					   struct task_struct *p)
+{
+#ifdef CONFIG_MEMCG
+	if (mm->owner == p)
+		mm->owner = NULL;
+#endif
+}
+
 static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 {
 #ifdef CONFIG_MEMCG
@@ -1345,6 +1354,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 free_pt:
 	/* don't put binfmt in mmput, we haven't got module yet */
 	mm->binfmt = NULL;
+	mm_init_owner(mm, NULL);
 	mmput(mm);
 
 fail_nomem:
@@ -1676,6 +1686,24 @@ static inline void rcu_copy_process(struct task_struct *p)
 #endif /* #ifdef CONFIG_TASKS_RCU */
 }
 
+#ifdef CONFIG_MEMCG
+static void __delayed_free_task(struct rcu_head *rhp)
+{
+	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
+
+	free_task(tsk);
+}
+#endif /* CONFIG_MEMCG */
+
+static __always_inline void delayed_free_task(struct task_struct *tsk)
+{
+#ifdef CONFIG_MEMCG
+	call_rcu(&tsk->rcu, __delayed_free_task);
+#else /* CONFIG_MEMCG */
+	free_task(tsk);
+#endif /* CONFIG_MEMCG */
+}
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -2137,8 +2165,10 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
-	if (p->mm)
+	if (p->mm) {
+		mm_clear_owner(p->mm, p);
 		mmput(p->mm);
+	}
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
@@ -2169,7 +2199,7 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_free:
 	p->state = TASK_DEAD;
 	put_task_stack(p);
-	free_task(p);
+	delayed_free_task(p);
 fork_out:
 	spin_lock_irq(&current->sighand->siglock);
 	hlist_del_init(&delayed.node);

