Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3EC4C41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BC68214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:42:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RJyoyNUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BC68214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9E76B0003; Fri,  9 Aug 2019 15:42:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D580F6B0005; Fri,  9 Aug 2019 15:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF78D6B0010; Fri,  9 Aug 2019 15:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 974786B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 15:42:45 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x5so70782094otb.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 12:42:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qcpdYAxgZIBIFmbMMN32rTklid76j4wSMwVthTygoNA=;
        b=uHfX4XsCKsTwVgppFVTZcXFJiqh9gWPeQlONeSfN0LJUXHj7eBLi0G4feoVmwjtdnz
         ZvfGJu8mXYg5pQDeUJlr5z/wgZcfhS0PnaNCJ2j0B/ryTjuAzgiZkXBslVIhnl7K/x3m
         cYuvfaPtj16VhCzxw6sEqAn6MQLlmsB2vkK8yHFLDXaEXg6OOnt3yvJu7MnfldDZqrJR
         /3/M2ZydBHg61QN606wTDpEvZBF7P/jzsAAwiTDKTSU21MZhfyONuoG1ae/kUk90xLS6
         xI0CTtUAu3RdZ4lk53uxPev1HYVTKchUXakIyVhgZQBFhoO8lm2iioPY3sUNxNWsVn0d
         X42A==
X-Gm-Message-State: APjAAAU/McILprPvkmIUZIugnKGLDIknDCB3bcnLYbYdMre2M9MT0ws5
	aXrLILEqCkW2Q8kKmGTonK7va8wVNcwz1IEGwq8xgNaBSQVVHtmp1mv/lCO7jEvgS/FamKZHqji
	nb9RpiUbS3tcl0bQbiSqlaXfcwMDguGHhgeNrM/kyOaONLECfyNwJ3jWdE7iHI7gHSw==
X-Received: by 2002:a9d:6a4d:: with SMTP id h13mr20530445otn.259.1565379765323;
        Fri, 09 Aug 2019 12:42:45 -0700 (PDT)
X-Received: by 2002:a9d:6a4d:: with SMTP id h13mr20530402otn.259.1565379764440;
        Fri, 09 Aug 2019 12:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565379764; cv=none;
        d=google.com; s=arc-20160816;
        b=tu3Twc6dBuFdftz6OyBCykSyGcEnYF33OaNRfx7nVlMZ2CZkMtygh8fB+BY4pbT4ud
         IHY3xUVvXcn4kV5oK+n4WOtD/aPWT1Vhs/opSq/3EG3v00NZ9ue3SJrd0nw6ag7GYqrv
         YkFEi35n/gQ3VSN8+Vuk3BfV8GLyXExb+WQQVHZv4KtTppHsrpuWPmh6DiUpCvwjVKDl
         1MdfxNR8mdYl0wYgl8+Kqi09HZktDZBD4kWtbnFTDRqN+Nq0MxukMjuuiL8u+PJBFg3D
         PS2pNkPDGEaizLtfWNuVnW3J56BtV7EER6afiM16wEBg0i4JqgFzAqodqL7rd4YWKMsG
         00FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qcpdYAxgZIBIFmbMMN32rTklid76j4wSMwVthTygoNA=;
        b=CUeq9a0Tx4yte/0ASgMXf11e7P+ubZNqANV/GHEPNzKvKDgvBDyVIV/ABAaseqMu2j
         FNaaj2NWBAnmedkeNBQ7Ov2gZGRtJONBBKX4LoOTYiY5Lm7ratKehhXFMzv8ZAWY3y3Q
         kCEzQkR6yo+m0BC/xFucyIiltJELepW7wjQbFfnQPj3f8qPdnnDKYkuxTGNUG89b3yTB
         DQJVMGSJII/AVPB3MCTXJRLpN3ci56ef71R2WdG+tesf6/pcjo9V0o8Rx6n/BNSu1v3d
         UYT67STLSFPR+AkyxPVYaj+IGNKW1IfeG9lMjmp/Rwx4TlbWXYzCsxvN7Imb+3/pSunV
         HlMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RJyoyNUY;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 97sor50853890oth.73.2019.08.09.12.42.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 12:42:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RJyoyNUY;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qcpdYAxgZIBIFmbMMN32rTklid76j4wSMwVthTygoNA=;
        b=RJyoyNUYqKorBafNZSFufOucWTqHlYU6ePm8PWFu+GIE13hP9XfnH6A+kAksmwCdbe
         vzGT4xozV8azvINAKFqxf4rjaADZ8DZM/wWdLxQvPQeBvwWfz7ggehshQVNaej9Zot+i
         Rt0XvJeFEd3rLDrvyYNVd8sa6JGkDdb53e2aNIO3MksGaCcSm1dpCyXndElMclNsoii6
         hNMrsvjpSCG55N6y4J1ijNIfWOSKA/7ZDT3SG5aHVisGHMqTVkQvdSRaScM1mw2AdFU/
         DcgWng57kp6L4Z0ypwuM4wWXGABlTGCB4fbDdeYhyGdkbTRzY6NrRHleQxDUMXSjH7iy
         FqVg==
X-Google-Smtp-Source: APXvYqzeWQV1n/GSsdfXYaqb9RFi8FCT4BwFakpht1LHgGOeLAHZsXnj3/yOPVvlKxSnNUiKVpK80tad3rbeLviNEyw=
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr20222798otp.33.1565379763678;
 Fri, 09 Aug 2019 12:42:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190808231340.53601-1-almasrymina@google.com> <f0a5afe9-2586-38c9-9a6d-8a2b7b288b50@oracle.com>
In-Reply-To: <f0a5afe9-2586-38c9-9a6d-8a2b7b288b50@oracle.com>
From: Mina Almasry <almasrymina@google.com>
Date: Fri, 9 Aug 2019 12:42:32 -0700
Message-ID: <CAHS8izOKmaOETBd_545Zex=KFNjYOvf3dCzcMRUEXnnhYCK5bw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/5] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>, 
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 9, 2019 at 10:54 AM Mike Kravetz <mike.kravetz@oracle.com> wrot=
e:
>
> (+CC  Michal Koutn=C3=BD, cgroups@vger.kernel.org, Aneesh Kumar)
>
> On 8/8/19 4:13 PM, Mina Almasry wrote:
> > Problem:
> > Currently tasks attempting to allocate more hugetlb memory than is avai=
lable get
> > a failure at mmap/shmget time. This is thanks to Hugetlbfs Reservations=
 [1].
> > However, if a task attempts to allocate hugetlb memory only more than i=
ts
> > hugetlb_cgroup limit allows, the kernel will allow the mmap/shmget call=
,
> > but will SIGBUS the task when it attempts to fault the memory in.
> >
> > We have developers interested in using hugetlb_cgroups, and they have e=
xpressed
> > dissatisfaction regarding this behavior. We'd like to improve this
> > behavior such that tasks violating the hugetlb_cgroup limits get an err=
or on
> > mmap/shmget time, rather than getting SIGBUS'd when they try to fault
> > the excess memory in.
> >
> > The underlying problem is that today's hugetlb_cgroup accounting happen=
s
> > at hugetlb memory *fault* time, rather than at *reservation* time.
> > Thus, enforcing the hugetlb_cgroup limit only happens at fault time, an=
d
> > the offending task gets SIGBUS'd.
> >
> > Proposed Solution:
> > A new page counter named hugetlb.xMB.reservation_[limit|usage]_in_bytes=
. This
> > counter has slightly different semantics than
> > hugetlb.xMB.[limit|usage]_in_bytes:
> >
> > - While usage_in_bytes tracks all *faulted* hugetlb memory,
> > reservation_usage_in_bytes tracks all *reserved* hugetlb memory.
> >
> > - If a task attempts to reserve more memory than limit_in_bytes allows,
> > the kernel will allow it to do so. But if a task attempts to reserve
> > more memory than reservation_limit_in_bytes, the kernel will fail this
> > reservation.
> >
> > This proposal is implemented in this patch, with tests to verify
> > functionality and show the usage.
>
> Thanks for taking on this effort Mina.
>
No problem! Thanks for reviewing!

> Before looking at the details of the code, it might be helpful to discuss
> the expected semantics of the proposed reservation limits.
>
> I see you took into account the differences between private and shared
> mappings.  This is good, as the reservation behavior is different for eac=
h
> of these cases.  First let's look at private mappings.
>
> For private mappings, the reservation usage will be the size of the mappi=
ng.
> This should be fairly simple.  As reservations are consumed in the hugetl=
bfs
> code, reservations in the resv_map are removed.  I see you have a hook in=
to
> region_del.  So, the expectation is that as reservations are consumed the
> reservation usage will drop for the cgroup.  Correct?

I assume by 'reservations are consumed' you mean when a reservation
goes from just 'reserved' to actually in use (as in the task is
writing to the hugetlb page or something). If so, then the answer is
no, that is not correct. When reservations are consumed, the
reservation usage stays the same. I.e. the reservation usage tracks
hugetlb memory (reserved + used) you could say. This is 100% the
intention, as we want to know on mmap time if there is enough 'free'
(that is unreserved and unused) memory left over in the cgroup to
satisfy the mmap call.

The hooks in region_add and region_del are to account shared mappings
only. There is a check in those code blocks that makes sure the code
is only engaged in shared mappings. The commit messages of patches 3/5
and 4/5 go into more details regarding this.

> The only tricky thing about private mappings is COW because of fork.  Cur=
rent
> reservation semantics specify that all reservations stay with the parent.
> If child faults and can not get page, SIGBUS.  I assume the new reservati=
on
> limits will work the same.
>

Although I did not explicitly try it, yes. It should work the same.
The additional reservation due to the COW will get charged to whatever
cgroup the fork is in. If the task can't get a page it gets SIGBUS'd.
If there is not enough room to charge the cgroup it's in, then the
charge will fail, which I assume will trigger error path that also
leads to SIGBUS.

> I believe tracking reservations for shared mappings can get quite complic=
ated.
> The hugetlbfs reservation code around shared mappings 'works' on the basi=
s
> that shared mapping reservations are global.  As a result, reservations a=
re
> more associated with the inode than with the task making the reservation.

FWIW, I found it not too bad. And my tests at least don't detect an
anomaly around shared mappings. The key I think is that I'm tracking
cgroup to uncharge on the file_region entry inside the resv_map, so we
know who allocated each file_region entry exactly and we can uncharge
them when the entry is region_del'd.

> For example, consider a file of size 4 hugetlb pages.
> Task A maps the first 2 pages, and 2 reservations are taken.  Task B maps
> all 4 pages, and 2 additional reservations are taken.  I am not really su=
re
> of the desired semantics here for reservation limits if A and B are in se=
parate
> cgroups.  Should B be charged for 4 or 2 reservations?

Task A's cgroup is charged 2 pages to its reservation usage.
Task B's cgroup is charged 2 pages to its reservation usage.

This is analogous to how shared memory accounting is done for things
like tmpfs, and I see no strong reason right now to deviate. I.e. the
task that made the reservation is charged with it, and others use it
without getting charged.

> Also in the example above, after both tasks create their mappings suppose
> Task B faults in the first page.  Does the reservation usage of Task A go
> down as it originally had the reservation?
>

Reservation usage never goes down when pages are consumed. Yes, I
would have this problem if I was planning to decrement reservation
usage when pages are put into use, but, the goal is to find out if
there is 'free' memory (unreserved + unused) in the cgroup at mmap
time, so we want a counter that tracks (reserved + used).

> It should also be noted that when hugetlbfs reservations are 'consumed' f=
or
> shared mappings there are no changes to the resv_map.  Rather the unmap c=
ode
> compares the contents of the page cache to the resv_map to determine how
> many reservations were actually consumed.  I did not look close enough to
> determine the code drops reservation usage counts as pages are added to s=
hared
> mappings.

I think this concern also goes away if reservation usage doesn't go
down when pages are consumed, but let me know if you still have
doubts.

Thanks for taking a look so far!
>
> --
> Mike Kravetz

