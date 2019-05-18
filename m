Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7625EC04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2834B218B6
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:12:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Fq1j7oUt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2834B218B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C783A6B0006; Fri, 17 May 2019 20:12:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C01AB6B0008; Fri, 17 May 2019 20:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA1916B000A; Fri, 17 May 2019 20:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2D66B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 20:12:58 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id d64so3199242vkg.7
        for <linux-mm@kvack.org>; Fri, 17 May 2019 17:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=jqgp/AAKfQLeMa+FXIn1qxTEO8Ap0fwZ5EF6f7NI8mA=;
        b=bYeyaP3vC5ooWvNYME1IzcI+PditVdZyWP5d97RjhWt64qp/TISbW/wgmU77s8BgsX
         BuwdDujt1BzB8+EzOTK0kAFgRsVtMCHF2MPmR7Dsx2eFkKjzIMuohheNI94aiwMjjNOO
         kBMX18Ia2QRa8v67IsFF7vq1YQuzrbO8MieIjjVJSpdCCqjimdMV7nWkBwTKdDidCz2V
         x5Ow4gW6eteMtcpvDwsuNXK98nRNta72BLAfRqb+OVE5Fw2aa4zXUldM2r8gCqRVqKS5
         DJTxbIXovaMBOL6L291uTHrBISDaJfuqFDuMYFUdrB3/BxnyJ2Ij3r30hd3v5sjTcMAA
         rbkQ==
X-Gm-Message-State: APjAAAXGvM+/ADX9LyKJHhfexOYclcLskU3kFjyhOsn1azVLVhFha1dA
	DJKA2144349cJ0LnR4dx4/4ZQyh2STTdHj3QCrxgqSSI7wPN8Rt8uOIaDmOuA3d+dx3pEmvRmv4
	Cco7Lwzo8TJcThTt3YbibBpkITBzYFeprcbTxH4qc69OF+EYn+cfmc4qCgXOlArqCdw==
X-Received: by 2002:a67:d99a:: with SMTP id u26mr3442808vsj.2.1558138378113;
        Fri, 17 May 2019 17:12:58 -0700 (PDT)
X-Received: by 2002:a67:d99a:: with SMTP id u26mr3442785vsj.2.1558138377291;
        Fri, 17 May 2019 17:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558138377; cv=none;
        d=google.com; s=arc-20160816;
        b=nUcRPvKLww+KVeeE4L07ROQLV2tDGleEO2LWphKd9E+STMPWLNCajLPeoc3RHIwkdF
         F6gKVEN8CK74d/3BrhauY0AaMPtQJXCQAXeztZZkViP9e56YbKFnYGZpJeT33b0NzeQw
         RRUBQJG29jU5flsRQoyWJzQlRONEcf2dXN8pz8nPHbLriLrnD18aGExMNmXmm1wWfQ7B
         wSgWHdEtt7m3w2pVXZ3lypDFedhVF2a9eeW7gtjXG/sExyqM7mDiDCVktBRdN1zI17FS
         l4nox8bgX3DPkVPtXsk7m9vqwn8TQESt9dnoh/FKiSALJMZnSF3tJVmshyncMtjM6feT
         cAGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=jqgp/AAKfQLeMa+FXIn1qxTEO8Ap0fwZ5EF6f7NI8mA=;
        b=iuYTbvNCALO3EW4RcQVsyJZ22GuflnVt00pGyFvazs68y0Vq8yRIveWY5tyRkUM07I
         Va5F5t8VbeGEn1CzFxOLKd2j20wes8ob0X1WCYyftJHLfpLcmVaKWLL7RPUT7XEqsMdd
         RDlr/iT4r8Fa1WEdsvi5k/rm9uRurwvbTuROQoA3hj9B5lsfFIXLuh4UcjZWdKfJqXyN
         kEO8OeQLa1zOCpiZkEemnGafXr+Xm5WchDUJPWb/Ro3s8AMKUZwQnVERL/MAx/pQbjQX
         iKJT4td6G1C04gh3k7o80SXsOO6Xfc9lciWkLA+g7Yz3OC/9OJU2nmdSHExyA1VU+pfF
         5dhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fq1j7oUt;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor6902448uar.30.2019.05.17.17.12.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 17:12:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fq1j7oUt;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=jqgp/AAKfQLeMa+FXIn1qxTEO8Ap0fwZ5EF6f7NI8mA=;
        b=Fq1j7oUtiICi06u8iNXtEC7qmvh4syEHGr5Mq4/Lew78h6OigQR5ARlU7EvYQ1kZ1b
         pL3kxt3eZ7UdOQuTUE+p4ve4ydMeS6hXBKWqEwdqNnIkd1Rr3wyYoLcTvpmplMokWB28
         OPELO3mssUQpXGpzu3kunZn8XVNJpzRozv82BWhR0vf3erhTd6VTSbSlMLLXtI+S13qZ
         yUDWpfCmfM24aM8VIfyL7fxRJdB5lyVGAvFv3sgMQfQ0JN9lbYL2F2RelgkazWm2zF+/
         0saqM2rW5m5k25nZBX3FvdwFAc9BV1qF9ZtkOFM0ukKomQbAlTPw5T4WDVv6qGn/ABTI
         64cA==
X-Google-Smtp-Source: APXvYqw6wAGTgIFK7xCUwoa4xEUAb53JdQRVmL0FhMGxX1gn9XVKTZuOFfV0bylHnx+sB3bG0oj/Kvochg+FbdGoYNk=
X-Received: by 2002:a9f:2246:: with SMTP id 64mr30748332uad.47.1558138376557;
 Fri, 17 May 2019 17:12:56 -0700 (PDT)
MIME-Version: 1.0
References: <1558073209-79549-1-git-send-email-chenjianhong2@huawei.com>
In-Reply-To: <1558073209-79549-1-git-send-email-chenjianhong2@huawei.com>
From: Michel Lespinasse <walken@google.com>
Date: Fri, 17 May 2019 17:12:43 -0700
Message-ID: <CANN689G6mGLSOkyj31ympGgnqxnJosPVc4EakW5gYGtA_45L7g@mail.gmail.com>
Subject: Re: [PATCH] mm/mmap: fix the adjusted length error
To: jianhong chen <chenjianhong2@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	mhocko@suse.com, Vlastimil Babka <vbabka@suse.cz>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, 
	jannh@google.com, steve.capper@arm.com, tiny.windzz@gmail.com, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I worry that the proposed change turns the search from an O(log N)
worst case into a O(N) one.

To see why the current search is O(log N), it is easiest to start by
imagining a simplified search algorithm that wouldn't include the low
and high address limits. In that algorithm, backtracking through the
vma tree is never necessary - the tree walk can always know, prior to
going left or right, if a suitable gap will be found in the
corresponding subtree.

The code we have today does have to respect the low and high address
limits, so it does need to implement backtracking - but this
backtracking only occurs to back out of subtrees that include the low
address limit (the search went 'left' into a subtree that has a large
enough gap, but the gap turns out to be below the limit so it can't be
used and the search needs to go 'right' instead). Because of this, the
amount of backtracking that can occur is very limited, and the search
is still O(log N) in the worst case.

With your proposed change, backtracking could occur not only around
the low address limit, but also at any node within the search tree,
when it turns out that a gap that seemed large enough actually isn't
due to alignment constraints. So, the code should still work, but it
could backtrack more in the worst case, turning the worst case search
into an O(N) thing.

I am not sure what to do about this. First I would want to understand
more about your test case; is this something that you stumbled upon
without expecting it or was it an artificially constructed case to
show the limitations of the current search algorithm ? Also, if your
process does something unusual and expects to be able to map (close
to) the entirety of its address space, would it be reasonable for it
to manually manage the address space and pass explicit addresses to
mmap / shmat ?

On Thu, May 16, 2019 at 11:02 PM jianhong chen <chenjianhong2@huawei.com> w=
rote:
> In linux version 4.4, a 32-bit process may fail to allocate 64M hugepage
> memory by function shmat even though there is a 64M memory gap in
> the process.
>
> It is the adjusted length that causes the problem, introduced from
> commit db4fbfb9523c935 ("mm: vm_unmapped_area() lookup function").
> Accounting for the worst case alignment overhead, function unmapped_area
> and unmapped_area_topdown adjust the search length before searching
> for available vma gap. This is an estimated length, sum of the desired
> length and the longest alignment offset, which can cause misjudgement
> if the system has very few virtual memory left. For example, if the
> longest memory gap available is 64M, we can=E2=80=99t get it from the sys=
tem
> by allocating 64M hugepage memory via shmat function. The reason is
> that it requires a longger length, the sum of the desired length(64M)
> and the longest alignment offset.
>
> To fix this error ,we can calculate the alignment offset of
> gap_start or gap_end to get a desired gap_start or gap_end value,
> before searching for the available gap. In this way, we don't
> need to adjust the search length.
>
> Problem reproduces procedure:
> 1. allocate a lot of virtual memory segments via shmat and malloc
> 2. release one of the biggest memory segment via shmdt
> 3. attach the biggest memory segment via shmat
>
> e.g.
> process maps:
> 00008000-00009000 r-xp 00000000 00:12 3385    /tmp/memory_mmap
> 00011000-00012000 rw-p 00001000 00:12 3385    /tmp/memory_mmap
> 27536000-f756a000 rw-p 00000000 00:00 0
> f756a000-f7691000 r-xp 00000000 01:00 560     /lib/libc-2.11.1.so
> f7691000-f7699000 ---p 00127000 01:00 560     /lib/libc-2.11.1.so
> f7699000-f769b000 r--p 00127000 01:00 560     /lib/libc-2.11.1.so
> f769b000-f769c000 rw-p 00129000 01:00 560     /lib/libc-2.11.1.so
> f769c000-f769f000 rw-p 00000000 00:00 0
> f769f000-f76c0000 r-xp 00000000 01:00 583     /lib/libgcc_s.so.1
> f76c0000-f76c7000 ---p 00021000 01:00 583     /lib/libgcc_s.so.1
> f76c7000-f76c8000 rw-p 00020000 01:00 583     /lib/libgcc_s.so.1
> f76c8000-f76e5000 r-xp 00000000 01:00 543     /lib/ld-2.11.1.so
> f76e9000-f76ea000 rw-p 00000000 00:00 0
> f76ea000-f76ec000 rw-p 00000000 00:00 0
> f76ec000-f76ed000 r--p 0001c000 01:00 543     /lib/ld-2.11.1.so
> f76ed000-f76ee000 rw-p 0001d000 01:00 543     /lib/ld-2.11.1.so
> f7800000-f7a00000 rw-s 00000000 00:0e 0       /SYSV000000ea (deleted)
> fba00000-fca00000 rw-s 00000000 00:0e 65538   /SYSV000000ec (deleted)
> fca00000-fce00000 rw-s 00000000 00:0e 98307   /SYSV000000ed (deleted)
> fce00000-fd800000 rw-s 00000000 00:0e 131076  /SYSV000000ee (deleted)
> ff913000-ff934000 rw-p 00000000 00:00 0       [stack]
> ffff0000-ffff1000 r-xp 00000000 00:00 0       [vectors]
>
> from 0xf7a00000 to fba00000, it has 64M memory gap, but we can't get
> it from kernel.

