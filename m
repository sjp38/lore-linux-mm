Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D847C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 22:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD28F20B7C
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 22:01:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NUcrHdVO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD28F20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 425B76B0003; Sat, 10 Aug 2019 18:01:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D55A6B0005; Sat, 10 Aug 2019 18:01:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29F896B0006; Sat, 10 Aug 2019 18:01:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 022516B0003
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 18:01:15 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a17so76740198otd.19
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 15:01:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CKSBDb3n2Zw/j8kWgy95XapjnDr9kx+5JJx/IJIa8C8=;
        b=JUDTYvODZSkNyz5BRjIWHJmRJs36AF6oQovoCFmBxZbBUiDB/Z+XJwAIrlTnBf7V3O
         B5kH9ozTYgrODlAnPn5GCoj6MzIuHt7crYjqPhQwl7JW+Uq3DkVlcnXrFyGkIwdPQLkX
         cmVlMx+lMdUt0sW3iD85rciBaKt/D6jMtWfgTwVwTaTO+cLv05pFKuYOLbUrtENw0h29
         IceeJ5ddGnnHtTmnR6Vg6q3P6xrg95YgyuFBtVOEwTjFibxfQCx7vNE7dXv73/fLCsy4
         f4MfZdOUhhTRAg0YL5KD4Zdg4EElE6Yg8zHiqoSo1EH1KjGF/0hebg+/xbiDh8S52HbK
         0Mow==
X-Gm-Message-State: APjAAAVhnxPRL6WfGaNjeeZ9GJrb/n7TUvl0KXGVKzm0NlZ4yqa02Psr
	03gcVkKBRNZVmNLtECHzy1Zif1LsxAMkdZr1Y1Yq/pvhp/HSjhdKV/LFmS88tfvQf3XTexQK4Jb
	s6o2NiTV7JbtmMuDO5JrA6qnD5WJtZk2Phf6obJIvJkbMF3Q9zYBjLBRZiw/q34mFDQ==
X-Received: by 2002:a9d:7383:: with SMTP id j3mr12336631otk.74.1565474474623;
        Sat, 10 Aug 2019 15:01:14 -0700 (PDT)
X-Received: by 2002:a9d:7383:: with SMTP id j3mr12336559otk.74.1565474473656;
        Sat, 10 Aug 2019 15:01:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565474473; cv=none;
        d=google.com; s=arc-20160816;
        b=n//9n41BmCLxrEREvnBGAopPYkKgy/r7HMBG5AnW2KaVG1cjVfoP6BNzAK828VR60D
         fHN5GAJop+xjS7pnkaLkN+DUisV0btj90wCDR6sfDv7H8u220oJdLNUDC+DwPcIMh4fl
         f5w9IiQYsQbKpcdhTOeK6JpSAh89WmUfpVuZrQ+AhX1o1X3E0idUHwxjLsHudfRr1NUb
         xtWgW23ZqBUSeLpVlmf66F+pbLr9d3YrJiUjsDNHrzbiBYnhWdlrzodkrKhU7AEPNLIk
         DivolQ1Qpj3298bg1X4AZsi8VNq2tTfw3cDKyr0cxm2d+qWs47LJFZ5e5qTAjxFO8L+L
         xsyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CKSBDb3n2Zw/j8kWgy95XapjnDr9kx+5JJx/IJIa8C8=;
        b=DyUYKDElG+Ygs2IDZKUn6ta+QnEv6zxCLFxXfWt8OxLv8hAkcyRSpgym0TQe0YCdam
         Bj0tSgbGFXDfSdQvD+d6yOdNrkaP0GmQw0yfStQiIvHIPwNohYA/THn4QiEs6KLAJfWm
         EfafiCBL5JGR4glikMYxyCSPBLAOvCVWI61T1F5Ps1vDkIKl0bY9dqbdHdQkary34T0P
         ApF+0YWyzBAUboFL7eFHNCTViqH9vV1BIvTyKWbrUtiQCzpUx1WqIr9o1jrFxNAWGHGw
         8O3jZ8xo0kLBxWEDNZFaZQ4hx0OJD8VqktvDqYCRu+iCIcpfFNv+vUxBRpRgq1Emgazf
         LKNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NUcrHdVO;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u71sor46108797oif.93.2019.08.10.15.01.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 15:01:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NUcrHdVO;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CKSBDb3n2Zw/j8kWgy95XapjnDr9kx+5JJx/IJIa8C8=;
        b=NUcrHdVOutsZBY/9WFTG0qmyK4Pv+ynw61exCRXGPu4QidGG4QRnMuzfvhUu4CTm5+
         LBz0d2+yyKpuXU/u8m58dPJXV2KpiikkKgNrk8yy5Kmgq+wXhz9UU7aU3uPtKXzrFPl4
         Uu49ni8D5+tQwgLiVAZ7tIN2GsoxkxtYVSDWeGaim9N80nxj3cpnVNFWTUINaec9HC2w
         sZIG+ZnSKDOwLQ44s4Fx7hqoFAOqHPCHKUSGuypcc88/J9Cuh0bOK5RjjClR4OYtXXX1
         XNTB//O3ZxXOb8ugK43J+tV03Ay3CYIoqDeLg2wTgRn14F/4Mrz1bSvxeIKsvExmUbXQ
         rvyw==
X-Google-Smtp-Source: APXvYqz0uGRd+OhDQQzhvps5/ie3QYUxGJ4pkAuGl0z6CDhEr4NK2GSI4SjZWju6OEg2EGL2jIXdS1whMQ9aB6RYVjA=
X-Received: by 2002:aca:190b:: with SMTP id l11mr11116656oii.67.1565474472697;
 Sat, 10 Aug 2019 15:01:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190808231340.53601-1-almasrymina@google.com>
 <f0a5afe9-2586-38c9-9a6d-8a2b7b288b50@oracle.com> <CAHS8izOKmaOETBd_545Zex=KFNjYOvf3dCzcMRUEXnnhYCK5bw@mail.gmail.com>
 <71a29844-7367-44c4-23be-eff26ac80467@oracle.com>
In-Reply-To: <71a29844-7367-44c4-23be-eff26ac80467@oracle.com>
From: Mina Almasry <almasrymina@google.com>
Date: Sat, 10 Aug 2019 15:01:01 -0700
Message-ID: <CAHS8izPGhHS+=qnf7Vy=C8kXQ=7v7XH3uEVitrW6ARRYU6iDdg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/5] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>, 
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 11:58 AM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> On 8/9/19 12:42 PM, Mina Almasry wrote:
> > On Fri, Aug 9, 2019 at 10:54 AM Mike Kravetz <mike.kravetz@oracle.com> wrote:
> >> On 8/8/19 4:13 PM, Mina Almasry wrote:
> >>> Problem:
> >>> Currently tasks attempting to allocate more hugetlb memory than is available get
> >>> a failure at mmap/shmget time. This is thanks to Hugetlbfs Reservations [1].
> >>> However, if a task attempts to allocate hugetlb memory only more than its
> >>> hugetlb_cgroup limit allows, the kernel will allow the mmap/shmget call,
> >>> but will SIGBUS the task when it attempts to fault the memory in.
> <snip>
> >> I believe tracking reservations for shared mappings can get quite complicated.
> >> The hugetlbfs reservation code around shared mappings 'works' on the basis
> >> that shared mapping reservations are global.  As a result, reservations are
> >> more associated with the inode than with the task making the reservation.
> >
> > FWIW, I found it not too bad. And my tests at least don't detect an
> > anomaly around shared mappings. The key I think is that I'm tracking
> > cgroup to uncharge on the file_region entry inside the resv_map, so we
> > know who allocated each file_region entry exactly and we can uncharge
> > them when the entry is region_del'd.
> >
> >> For example, consider a file of size 4 hugetlb pages.
> >> Task A maps the first 2 pages, and 2 reservations are taken.  Task B maps
> >> all 4 pages, and 2 additional reservations are taken.  I am not really sure
> >> of the desired semantics here for reservation limits if A and B are in separate
> >> cgroups.  Should B be charged for 4 or 2 reservations?
> >
> > Task A's cgroup is charged 2 pages to its reservation usage.
> > Task B's cgroup is charged 2 pages to its reservation usage.
>
> OK,
> Suppose Task B's cgroup allowed 2 huge pages reservation and 2 huge pages
> allocation.  The mmap would succeed, but Task B could potentially need to
> allocate more than 2 huge pages.  So, when faulting in more than 2 huge
> pages B would get a SIGBUS.  Correct?  Or, am I missing something?
>
> Perhaps reservation charge should always be the same as map size/maximum
> allocation size?

I'm thinking this would work similar to how other shared memory like
tmpfs is accounted for right now. I.e. if a task conducts an operation
that causes memory to be allocated then that task is charged for that
memory, and if another task uses memory that has already been
allocated and charged by another task, then it can use the memory
without being charged.

So in case of hugetlb memory, if a task is mmaping memory that causes
a new reservation to be made, and new entries to be created in the
resv_map for the shared mapping, then that task gets charged. If the
task is mmaping memory that is already reserved or faulted, then it
reserves or faults it without getting charged.

In the example above, in chronological order:
- Task A mmaps 2 hugetlb pages, gets charged 2 hugetlb reservations.
- Task B mmaps 4 hugetlb pages, gets charged only 2 hugetlb
reservations because the first 2 are charged already and can be used
without incurring a charge.
- Task B accesses 4 hugetlb pages, gets charged *4* hugetlb faults,
since none of the 4 pages are faulted in yet. If the task is only
allowed 2 hugetlb page faults then it will actually get a SIGBUS.
- Task A accesses 4 hugetlb pages, gets charged no faults, since all
the hugetlb faults is charged to Task B.

So, yes, I can see a scenario where userspace still gets SIGBUS'd, but
I think that's fine because:
1. Notice that the SIGBUS is due to the faulting limit, and not the
reservation limit, so we're not regressing the status quo per say.
Folks using the fault limit today understand the SIGBUS risk.
2. the way I expect folks to use this is to use 'reservation limits'
to partition the available hugetlb memory on the machine using it and
forgo using the existing fault limits. Using both at the same time I
think would be a superuser feature for folks that really know what
they are doing, and understand the risk of SIGBUS that comes with
using the existing fault limits.
3. I expect userspace to in general handle this correctly because
there are similar challenges with all shared memory and accounting of
it, even in tmpfs, I think.

I would not like to charge the full reservation to every process that
does the mmap. Think of this, much more common scenario: Task A and B
are supposed to collaborate on a 10 hugetlb pages of data. Task B
should not access any hugetlb memory other than the memory it is
working on with Task A, so:

1. Task A is put in a cgroup with 10 hugetlb pages reservation limit.
2. Task B is put in a cgroup with 0 hugetlb pages of reservation limit.
3. Task A mmaps 10 hugetlb pages of hugetlb memory, and notifies Task
B that it is done.
4. Task B, due to programmer error, tries to mmap hugetlb memory
beyond what Task A set up for it, it gets denied at mmap time by the
cgroup reservation limit.
5. Task B mmaps the same 10 hugetlb pages of memory and starts working
on them. The mmap succeeds because Task B is not charged anything.

If we were charging the full reservation to both Tasks A and B, then
both A and B would have be in cgroups that allow 10 pages of hugetlb
reservations, and the mmap in step 4 would succeed, and we
accidentally overcommitted the amount of hugetlb memory available.

> --
> Mike Kravetz

