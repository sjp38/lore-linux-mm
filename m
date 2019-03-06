Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B17C4C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:12:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D77D20661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:12:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D77D20661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D212F8E0003; Wed,  6 Mar 2019 03:12:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD0078E0001; Wed,  6 Mar 2019 03:12:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B71828E0003; Wed,  6 Mar 2019 03:12:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88DDA8E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 03:12:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 203so9171364qke.7
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 00:12:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VcbhR6YLJFD1Kdo2uvUoo5+elIYoX2aWecNcw6/O/JU=;
        b=bFt/6gK9O0cVu5GJjo/vU2sdZYCYeToRag7tRxhatnvwjtzr7k/Bx3cd8cMRDili+u
         WGo2xp8AndzH3oRRfdL9okK8bDrk5QMj+p5y9ye/9AV+V2QQD3MgleKzwsfmJuWFYMjA
         DhX4iOfzqy1YbQzoJbF1S86HeaN4Ajg+qzmjvllQyV5NFVxb/xLYvhAM5j2PLpfBdbXc
         nHti2rsdwX3KBmC4EjM7lwmvbw0uA+3dBLgnXeM72DP4S0MK5Fr8S0Q3//YbjAknzqCc
         NIu27Rqt0TUe+8S4YV15Y++srxA9MhDx4nfvyzerlrgHEgF3jhuKcdKvowUxGEkZeAIo
         CIAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXFFJXCIsENvpiOoTEgNsHhKC49I6+cyYsxx3B+CKXe7EE7M60I
	3WWKz6i3r5Pk1WITOtroUM7rbkNjRqhdtFvwwq0OSdXSwcu3glUp82SqppQMVKqB6VkDusH2Hmo
	tlKmaXQBWDBaUB2QpRlrjFAevqxfYS7iaPceH7qyprkGJ4fzlhO3XnxWblKXUL6MUzQ==
X-Received: by 2002:a37:bcc7:: with SMTP id m190mr4849742qkf.300.1551859931164;
        Wed, 06 Mar 2019 00:12:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqw8dmGDMyBcEYsVgV06qvHdDvlG0iP9Vdc6o5Ou2nvzKynndrXIvrFC//oVBs2459kgA+bD
X-Received: by 2002:a37:bcc7:: with SMTP id m190mr4849712qkf.300.1551859930350;
        Wed, 06 Mar 2019 00:12:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551859930; cv=none;
        d=google.com; s=arc-20160816;
        b=YiYOofCiKg9PvyVNpaGwenwN+WTsQ5SSpMh5bYEe2RIayN0p6bBbpnhQGzbB+hshX9
         vYtV4N5mvrCTE0cV89Zb7BEnMVLYsUfrd2JFskcy5+HDPcAZiU0ZGL8f3i9SPYsT3N7h
         Bhlv0RECjvh5pzPt8ybM+Y5bk+XJ7nepYF2qFgf+DbaiOoMU+jxtyqs13ioWhcVwroOq
         GrLe5RRZTTcGVfbosjXpQpHm4ppTpgvcPyKuGbaVJpA0GjDnM8cnh/ujkbpXBtRi7c3c
         7i8GwUf6tOAvbS82tuwoy3zKmPJ+UX2JkRSYvgl+/PHZKfr7IrMF0JFlzuJjoPeIMAI6
         lVjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VcbhR6YLJFD1Kdo2uvUoo5+elIYoX2aWecNcw6/O/JU=;
        b=R4+bPQRCPAjCwLPCYnv7x/Tws9VnS3sqJx/eygO7z5poKA5SBJl9vgl0EBpXbv84N+
         wGgxtf4gLKIVYB4GLj2i0OWgF7iF9iRUXvQnAZQ4IJJTTpto8Fhmipo9g5ZYRKXBdvts
         x05Tu3qUw4bq6967dQcUByEC2cLZ7w/AXPfyt8/CTnUwO/DUCxFR6z9gjZRpAJMnmLGF
         AwpK1XczRXe3nebZk1RJ7s4qwazeIOwJiRgJae4nfMKMQjivFXVV1P3/JJMLMnRWFNug
         P2MN1/Mt/RaLeqkYlRsDgkEV80joNCC5+kLXkUzoNsaCXRTt/CUpgcV5VG2B7U7dk7FQ
         FvEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p5si446367qvm.50.2019.03.06.00.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 00:12:10 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4722C83F51;
	Wed,  6 Mar 2019 08:12:09 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 627E11A267;
	Wed,  6 Mar 2019 08:12:03 +0000 (UTC)
Date: Wed, 6 Mar 2019 16:12:01 +0800
From: Peter Xu <peterx@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>,
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
	Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190306081201.GC11093@xz-x1>
References: <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
 <5C7D2F82.40907@huawei.com>
 <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
 <20190306020540.GA23850@redhat.com>
 <5C7F6048.2050802@huawei.com>
 <20190306062625.GA3549@rapoport-lnx>
 <5C7F7992.7050806@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5C7F7992.7050806@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 06 Mar 2019 08:12:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:41:06PM +0800, zhong jiang wrote:
> On 2019/3/6 14:26, Mike Rapoport wrote:
> > Hi,
> >
> > On Wed, Mar 06, 2019 at 01:53:12PM +0800, zhong jiang wrote:
> >> On 2019/3/6 10:05, Andrea Arcangeli wrote:
> >>> Hello everyone,
> >>>
> >>> [ CC'ed Mike and Peter ]
> >>>
> >>> On Tue, Mar 05, 2019 at 02:42:00PM +0800, zhong jiang wrote:
> >>>> On 2019/3/5 14:26, Dmitry Vyukov wrote:
> >>>>> On Mon, Mar 4, 2019 at 4:32 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>> On 2019/3/4 22:11, Dmitry Vyukov wrote:
> >>>>>>> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>>>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
> >>>>>>>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>>>>>> Hi, guys
> >>>>>>>>>>
> >>>>>>>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
> >>>>>>>>>>
> >>>>>>>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
> >>>>>>>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
> >>>>>>>>>>
> >>>>>>>>>> Any thoughts?
> >>>>>>>>> FWIW syzbot was able to reproduce this with this reproducer.
> >>>>>>>>> This looks like a very subtle race (threaded reproducer that runs
> >>>>>>>>> repeatedly in multiple processes), so most likely we are looking for
> >>>>>>>>> something like few instructions inconsistency window.
> >>>>>>>>>
> >>>>>>>> I has a little doubtful about the instrustions inconsistency window.
> >>>>>>>>
> >>>>>>>> I guess that you mean some smb barriers should be taken into account.:-)
> >>>>>>>>
> >>>>>>>> Because IMO, It should not be the lock case to result in the issue.
> >>>>>>> Since the crash was triggered on x86 _most likley_ this is not a
> >>>>>>> missed barrier. What I meant is that one thread needs to executed some
> >>>>>>> code, while another thread is stopped within few instructions.
> >>>>>>>
> >>>>>>>
> >>>>>> It is weird and I can not find any relationship you had said with the issue.:-(
> >>>>>>
> >>>>>> Because It is the cause that mm->owner has been freed, whereas we still deference it.
> >>>>>>
> >>>>>> From the lastest freed task call trace, It fails to create process.
> >>>>>>
> >>>>>> Am I miss something or I misunderstand your meaning. Please correct me.
> >>>>> Your analysis looks correct. I am just saying that the root cause of
> >>>>> this use-after-free seems to be a race condition.
> >>>>>
> >>>>>
> >>>>>
> >>>> Yep, Indeed,  I can not figure out how the race works. I will dig up further.
> >>> Yes it's a race condition.
> >>>
> >>> We were aware about the non-cooperative fork userfaultfd feature
> >>> creating userfaultfd file descriptor that gets reported to the parent
> >>> uffd, despite they belong to mm created by failed forks.
> >>>
> >>> https://www.spinics.net/lists/linux-mm/msg136357.html
> >>>
> >> Hi, Andrea
> >>
> >> I still not clear why uffd ioctl can use the incomplete process as the mm->owner.
> >> and how to produce the race.
> > There is a C reproducer in  the syzcaller report:
> >
> > https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
> >  
> >> From your above explainations,   My underdtanding is that the process handling do_exexve
> >> will have a temporary mm,  which will be used by the UUFD ioctl.
> > The race is between userfaultfd operation and fork() failure:
> >
> > forking thread                  | userfaultfd monitor thread
> > --------------------------------+-------------------------------
> > fork()                          |
> >   dup_mmap()                    |
> >     dup_userfaultfd()           |
> >     dup_userfaultfd_complete()  |
> >                                 |  read(UFFD_EVENT_FORK)
> >                                 |  uffdio_copy()
> >                                 |    mmget_not_zero()
> >     goto bad_fork_something     |
> >     ...                         |
> > bad_fork_free:                  |
> >       free_task()               |
> >                                 |  mem_cgroup_from_task()
> >                                 |       /* access stale mm->owner */
> >  
> Hi, Mike

Hi, Zhong,

> 
> forking thread fails to create the process ,and then free the allocated task struct.
> Other userfaultfd monitor thread should not access the stale mm->owner.
> 
> The parent process and child process do not share the mm struct.  Userfaultfd monitor thread's
> mm->owner should not point to the freed child task_struct.

IIUC the problem is that above mm (of the mm->owner) is the child
process's mm rather than the uffd monitor's.  When
dup_userfaultfd_complete() is called there will be a new userfaultfd
context sent to the uffd monitor thread which linked to the chlid
process's mm, and if the monitor thread do UFFDIO_COPY upon the newly
received userfaultfd it'll operate on that new mm too.

> 
> and due to the existence of tasklist_lock,  we can not specify the mm->owner to freed task_struct.
> 
> I miss something,=-O
> 
> Thanks,
> zhong jiang
> >> Thanks,
> >> zhong jiang
> 
> 

Regards,

-- 
Peter Xu

