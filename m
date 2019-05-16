Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C970C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:32:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F086E2082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:32:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SYjE/ozB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F086E2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CA706B0005; Thu, 16 May 2019 09:32:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87C136B0006; Thu, 16 May 2019 09:32:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71B226B0007; Thu, 16 May 2019 09:32:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0226B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:32:34 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id g80so1647981otg.12
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:32:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=X+8Dc+8NQkNb3/Q1ARB2w0BPiehxHFy6DByP8EfeHyE=;
        b=q8pLNbNF8CSyX9gTLQ0BCpfSqM1IhUsXkvnXmWRGqopUYJJumUiivK/FfWWsa0NBh5
         UH2LiccvhstuZbJqPTiWoC3IxZdfnoM+OQgz2pGyRZ9D3le4ZMbQwddaWXcHjo28N8nW
         5O4mjUprKv2zNoUlw7ZoD5oP0sQg1Ljs7zvNe3GPIjyrehkB4MuolpDlgums9njT6G5r
         j+HepVqM9bqXm9zP1w/aC1aPNprazWvDFk9BJ2vehBFKm3S0KcZntAYCuRaPsB9a/DcS
         Fe2l76qZL3xlzsoTeIIVDog2cYIphY/EEu0kNP8tNYC6obnH1KQSezqrqd8PD5Hx5C9h
         qcmg==
X-Gm-Message-State: APjAAAWLPOckQsnGyOgRJOBF6iP2snMPR1QWZDJPUm8jplhdkU/4GQIe
	AHeEJob/5LdS5e1USS5QmbJ5U89c70vBaSySAA/XQdk3RY4n4w9q3huL/zirke54+39lIkuTh/H
	qtHPFyE8kkPQ6wJ47i8Bsym2Cnl5QmjalVxP3KGP7pwhMP1mw/pM5n/mnsBOs6zT7BQ==
X-Received: by 2002:a05:6830:16d2:: with SMTP id l18mr21585406otr.303.1558013553900;
        Thu, 16 May 2019 06:32:33 -0700 (PDT)
X-Received: by 2002:a05:6830:16d2:: with SMTP id l18mr21585370otr.303.1558013553352;
        Thu, 16 May 2019 06:32:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558013553; cv=none;
        d=google.com; s=arc-20160816;
        b=epXRluZS63aOOPVXLf2lmVdcabsIUJIwtMESHmB6NpJ5b5bnyhZGMNhUAfZCL+tLwa
         Jx+JIacf2dxdUsfBE38Xhqn5caUqQ3yLrsfKfI6s66PHtc2CW+qfPGlHwbl+nxsM2V8f
         HZ16qULHbcdESmxtph0r2Lmt5t8m1aivvLeeh0rwMUQGD8Eu6ba94LBRunX2DkzsSYB9
         tdXmxN0AfBzv2d/8BXa+mgujVvzGon7ZWeCnQcHZS28pTsVAwuATw+CkXU7wB/zQDM2B
         dsO6mt74TiFonVs7IBSbslKOS1k2YS5XfifsDnci8GBEt0uuNl6H2umZUNSm8KxxhK+8
         t29A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=X+8Dc+8NQkNb3/Q1ARB2w0BPiehxHFy6DByP8EfeHyE=;
        b=dLW05jfW9SNevBcRuhxFKubYArBkhbVVI7bPG5gOpqYim8eUCbqpJanEnsMyqtc5m6
         qXI1IuZpkLhgk3MczdT1bqKhtPp1sOwDHWsIZJhR2ySlnwDHUCmMXj9fG1+jZaBzVlz0
         gcMkc+uLTqB59JDmCi95YD7rhdSehkkB7Es0y2A6R+8b3Hneftecji9pIwRW+RMozWrh
         eWshQtL4loyHjH3m5UEbrcsbeleHb8r6+Pm8N4XVezFoO/2M7yD/dGdO+WV4Iz25FtHT
         DGH2cGpN7Y6D4Xz9EqHQDYxdM2kKj+uGpluTzH+UaiSjd0dkbMo0pUa/VGTVzpdvfjDz
         N83Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SYjE/ozB";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v199sor2445787oif.11.2019.05.16.06.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 06:32:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SYjE/ozB";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=X+8Dc+8NQkNb3/Q1ARB2w0BPiehxHFy6DByP8EfeHyE=;
        b=SYjE/ozBIlk8Fx5sGYi6WTZimcARTlAHPPEaELxcs6u17YAQfVwz99WhY0CA7x7cml
         b4Cbzvdp8D4NHP23ztKo/w3yjKTb6vite0InwNqCh9vwMas7ZY5DZACFYyoKryN+jMoV
         NyjJVH4U+KBZh2WxuP67pee+2CWg+DVK+qrBguGtLysuan0h4KqHqlWLuJXrjYjddiTS
         urPSTTaLVGMYc8qvdvqRVf/kNHorlEc45l0DrLwMjryCebhvK2KjtGwCcLCUUeSttn4X
         CZIbEe5ZiInHuQP0yaoUgNKXgkMbz8IOp3sMzWpkjg/O0QLy/mCw2/ZKl8KC6OVEqqUx
         fA9A==
X-Google-Smtp-Source: APXvYqyWTgxVAAT8JN7ctKRABfXdndp8feo5VLLNabYJZjH3z3RmiG0/e3+2ydfvO0aV6qZBGpe1mgmkhH0lQKZq3HI=
X-Received: by 2002:aca:180d:: with SMTP id h13mr10065721oih.39.1558013552764;
 Thu, 16 May 2019 06:32:32 -0700 (PDT)
MIME-Version: 1.0
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
From: Jann Horn <jannh@google.com>
Date: Thu, 16 May 2019 15:32:06 +0200
Message-ID: <CAG48ez3EOwLd8A6Ku53vKLdofmZAh1ZYfkK4rVgSgM8ZfcR4zg@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Michal Hocko <mhocko@suse.com>, keith.busch@intel.com, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, ira.weiny@intel.com, 
	Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, hannes@cmpxchg.org, npiggin@gmail.com, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Shakeel Butt <shakeelb@google.com>, 
	Roman Gushchin <guro@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, kernel list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 5:11 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> This patchset adds a new syscall, which makes possible
> to clone a mapping from a process to another process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.
[...]
> The proposed syscall aims to introduce an interface, which
> supplements currently existing process_vm_writev() and
> process_vm_readv(), and allows to solve the problem with
> anonymous memory transfer. The above example may be rewritten as:
>
>         void *buf;
>
>         buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>                    MAP_PRIVATE|MAP_ANONYMOUS, ...);
>         recv(sock, buf, n * PAGE_SIZE, 0);
>
>         /* Sign of @pid is direction: "from @pid task to current" or vice versa. */
>         process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
>         munmap(buf, n * PAGE_SIZE);

In this specific example, an alternative would be to splice() from the
socket into /proc/$pid/mem, or something like that, right?
proc_mem_operations has no ->splice_read() at the moment, and it'd
need that to be more efficient, but that could be built without
creating new UAPI, right?

But I guess maybe your workload is not that simple? What do you
actually do with the received data between receiving it and shoving it
over into the other process?

