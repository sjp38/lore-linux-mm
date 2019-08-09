Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D6D1C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 20:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E46ED2086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 20:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oaMUzgnk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E46ED2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690626B0008; Fri,  9 Aug 2019 16:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 641AE6B000A; Fri,  9 Aug 2019 16:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 509C36B000C; Fri,  9 Aug 2019 16:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 275A06B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 16:57:54 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id o1so1592818otp.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 13:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=oOFZs7lWd/cRN6ArflLZND+4GUEsB210O2v04GTqqFo=;
        b=iRcIz0Rag5vA+cqu+/0gJ57PrkC+2EwIgdeggRgX7FPEc3avx0yy2ZCT38/psKqw7V
         WlPhidHnfbg5gepc0lZ0NXY5gZaUnsiR87OmExrD3489IFARL4sWiXytwnky/mwO4A1y
         hpCUA9LvaKk7h4cQiKHPxMqToPtODXy8TkD3K/07KvTNa1fMO56FF50tnOqkOBpD+mSo
         9sZ7+0zC7/APohatREl6ApxBKbVCIz7AfwaoPAkANq/Zc3ofwA7zH8UBY/z5o/VgqulE
         aKh2M9TXN/g43VfVXwUaLDsDT3bBGTfnDfAkG6N9+AEiNt1m/3kYDxqSjJ2feYMdGvb+
         ypXQ==
X-Gm-Message-State: APjAAAX9jHABXGul/4+i4yAUW9Kp2EOq5u9SmbnOKVWZLhqlQY3/pp0F
	YxRXtlTxlPs2ClxTrtrcOA9u68dofhHPkkdTL6RlWTovp3ZEc17E0FnsbdomdXaM27e7Qm2SLBK
	nZRsEIBYUrkq4A8LPNocb2rNJHflKrxfWGRWdttmFLh7FzSaFpe/2S9GWt6+3SpXJkg==
X-Received: by 2002:a54:4f09:: with SMTP id e9mr7565973oiy.89.1565384273773;
        Fri, 09 Aug 2019 13:57:53 -0700 (PDT)
X-Received: by 2002:a54:4f09:: with SMTP id e9mr7565948oiy.89.1565384273134;
        Fri, 09 Aug 2019 13:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565384273; cv=none;
        d=google.com; s=arc-20160816;
        b=ARgR3vGOnM+QQfi9DcmP2M/xWEo1TUDP85Oz//VbzoYSN6AXvDS6PiyxlVcGYjofmR
         og61nXPl3TgZ5zUzCqu/vuC04xhL7dtsRNBGVCeTX/CLaIGLry3SWNMJZZvwnXIHDpz7
         kRu9OHa5fyAWPShvx3IrddIqvlhnZMXcWZD9lTXpaTXXORQwxucW6ywNq8S8Qqn5296w
         TxgqfHZFhyIBKhmZyjMRuy11gt0H++7BK9pQVfp/aAG5h3wYU1jHBiTYhaWcpaSzQMmM
         NQVskWkFutekNijwxJp/dNJDgN45qYUQ5kN3wtpFSrQvqlUOQPoP5m9MCgmcxVU7tWs8
         Ss1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=oOFZs7lWd/cRN6ArflLZND+4GUEsB210O2v04GTqqFo=;
        b=Sfa3CynRLj2ZhcbsAZKBnNrBXUVy8NSaZBu7+k4i36wfJ/k0gBfwQEtGsLTY1cGcxk
         HKEbO1R1pcEOIKux3XMffkMSpieO3vHrEXWnlUImp7I8DQZQ0bvLH/D9kMi4Mm1HTYNQ
         83rU6URnPm47y0lfzUYqSOFJJuCllLUHMjYGLuWvxTkh+2nHP63P/MatK/5viMesHgmG
         3CY/PYHvZ+3brEyrK6+3DrnVa9pFEeq0cx/EMzzN96CexKlgd/2qTL+aI+PypLc7qKDp
         P5/momUlbQx0nFWXGsP2/Pq8G3a/+Jgw6Jon1mgbpxlNLjsnHYH/VPUmqgA+2YjEtLUX
         OU3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oaMUzgnk;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor1576155ote.179.2019.08.09.13.57.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 13:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oaMUzgnk;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=oOFZs7lWd/cRN6ArflLZND+4GUEsB210O2v04GTqqFo=;
        b=oaMUzgnkhQr8vDqzN541ro79UdzcKWW6RPUgaYRCoEUrv2bw3hFwhciMuc/FZdo5rD
         vxMv49GFSKxSdt8Guqkl3Ym6D8NQAmj6ZogWqxgFOIOGN12mqRCCvqwrbBbrIFOD37y6
         M8RFhPFm8h2kqEcagvwI1ThRn2pW3BdZ4bWVhjR2aCUZMabFWTTkHEC+DlulLPsBkURQ
         J0N4hEZBmjU0BxVSkNq5NHcKLgXOHBc/TjM+c2Dd9gJEOJcM2D3+BJTM+E7rwtry6ONZ
         dZKKJ/RYUEo65s59sGogF3VXgWK0crDgh1g5Ht0zprHVMqVwqRhhHk2rQfVwWDNTQrMI
         6Lrw==
X-Google-Smtp-Source: APXvYqzJcsa9ICi+fQi0Gyqrx84T4EuV0wmUdDvyiJ6cpsg1nCPtkM6vHL+J8zfsreYU1640rrFmz2rWtDYW2f3D/OU=
X-Received: by 2002:a9d:6216:: with SMTP id g22mr18398597otj.349.1565384272566;
 Fri, 09 Aug 2019 13:57:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190808194002.226688-1-almasrymina@google.com>
 <20190809112738.GB13061@blackbody.suse.cz> <CAHS8izNM3jYFWHY5UJ7cmJ402f-RKXzQ=JFHpD7EkvpAdC2_SA@mail.gmail.com>
 <fc420531-f0fe-8df5-57fe-71a686bf2a71@oracle.com>
In-Reply-To: <fc420531-f0fe-8df5-57fe-71a686bf2a71@oracle.com>
From: Mina Almasry <almasrymina@google.com>
Date: Fri, 9 Aug 2019 13:57:41 -0700
Message-ID: <CAHS8izN9BFASse_pjLEhQzWwofjRv+JQ5Z=ZiR6Wywn2USLELA@mail.gmail.com>
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>, 
	shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 9, 2019 at 1:39 PM Mike Kravetz <mike.kravetz@oracle.com> wrote=
:
>
> On 8/9/19 11:05 AM, Mina Almasry wrote:
> > On Fri, Aug 9, 2019 at 4:27 AM Michal Koutn=C3=BD <mkoutny@suse.com> wr=
ote:
> >>> Alternatives considered:
> >>> [...]
> >> (I did not try that but) have you considered:
> >> 3) MAP_POPULATE while you're making the reservation,
> >
> > I have tried this, and the behaviour is not great. Basically if
> > userspace mmaps more memory than its cgroup limit allows with
> > MAP_POPULATE, the kernel will reserve the total amount requested by
> > the userspace, it will fault in up to the cgroup limit, and then it
> > will SIGBUS the task when it tries to access the rest of its
> > 'reserved' memory.
> >
> > So for example:
> > - if /proc/sys/vm/nr_hugepages =3D=3D 10, and
> > - your cgroup limit is 5 pages, and
> > - you mmap(MAP_POPULATE) 7 pages.
> >
> > Then the kernel will reserve 7 pages, and will fault in 5 of those 7
> > pages, and will SIGBUS you when you try to access the remaining 2
> > pages. So the problem persists. Folks would still like to know they
> > are crossing the limits on mmap time.
>
> If you got the failure at mmap time in the MAP_POPULATE case would this
> be useful?
>
> Just thinking that would be a relatively simple change.

Not quite, unfortunately. A subset of the folks that want to use
hugetlb memory, don't want to use MAP_POPULATE (IIRC, something about
mmaping a huge amount of hugetlb memory at their jobs' startup, and
doing that with MAP_POPULATE adds so much to their startup time that
it is prohibitively expensive - but that's just what I vaguely recall
offhand. I can get you the details if you're interested).

> --
> Mike Kravetz

