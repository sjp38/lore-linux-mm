Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82074C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:55:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D0A2133D
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:55:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D0A2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DC926B0003; Sat, 15 Jun 2019 10:55:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B30F6B0005; Sat, 15 Jun 2019 10:55:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F2178E0001; Sat, 15 Jun 2019 10:55:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 661576B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:55:47 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f11so338458otq.3
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:55:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=gFmJrg9gTcnKcoZCiQypnNRQNxX/k8DGBmBoxNPZno8=;
        b=Vwczyl8rdehnW3/SdKxOeykdeR29VFRvIZk+I4COgM/IJFrmsX+xtuJMLR6u4jgSP0
         kCqZSs/m5bXrHLz6ZJnFLwVu/22kVwqe2VIWi8Ftz/cSWGLRch79v6EjGcYLTtQ77hXp
         jSidceBCuFjc+icIYLf7MowLjxGyvwqB8kClbapirMN3V+cjZQ6/TqCjo2PwcGWqlQOf
         giMlXJR0+gbEpZP0+FQNDHWjUL7RCgirEUQEELlmIJzShr8tE/6EFrhyFb6laPukdS7P
         SygCJeN+G7/p4XFS5CaOOuQEKhusiiu+MHL+h/1JM9WsUmzk/gaJlAvJlukK9uo/Myu/
         Z2Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV3SCAE38YTA+D+pd9fWwZ/EmeXLh2SXsiGCTcYHsJjVSVeg5Qo
	Mp6Fh+sxhVbM5bzntWB6tIXS8Gt3FQkIn1bbkOu7R5/3CjX6tnqmARO+s7bEwnIhfQ27ee+YSSC
	hcsUZDh8iLdD0DrwRVIgPfI7xBOIDZmDqueeJ9GBQPrnDwU+WwyD1Mmob5bVDvKnnfQ==
X-Received: by 2002:a9d:4599:: with SMTP id x25mr10040522ote.219.1560610547091;
        Sat, 15 Jun 2019 07:55:47 -0700 (PDT)
X-Received: by 2002:a9d:4599:: with SMTP id x25mr10040502ote.219.1560610546511;
        Sat, 15 Jun 2019 07:55:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560610546; cv=none;
        d=google.com; s=arc-20160816;
        b=XFJ7xpQEJHvdk9MLueJ70nGJBbcn3C897u8/Xyr07cIMiV2hnjh0MSnppVpHi05G3w
         B/0QhHGR3KCmuNqiFfVMwXkzoEOy5o7WlvfhJZ5AJx9YAKI4P9w5MWCZ1NBC1pG2p+Ew
         04ok1gGCoSqYhlhZZnKCCFY1eptS6E6krmBGhuhqRFcKlL+a6HCeYlB7fU4f5SrC3ADw
         OCgj7DLVQ9wtlkDKUY3JRaxstHw7wcVUvVAbLzPF1juzGvLaY2M4q7JFjILkznOOeX21
         Io+Rj8R4jeSTCxUgANuDaXP8a6qmxPjosM4J5mp+O4QW/Z7FQX7Ct1mLPpuzbfwCU42Z
         kwCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=gFmJrg9gTcnKcoZCiQypnNRQNxX/k8DGBmBoxNPZno8=;
        b=V/Q/pvjeJhNvMSVqttz5GaP+iHEWN1e51rhDfG/TguRibeeWFq5UUfaE4I1JlregGo
         FZFHlGW/nAYLK/+dCV/Aab2OXzNwzse2kbfJmt0QQbCINigrG0z+uV2WRFg3ugrvlxQE
         o0TdiBMPlyHVoVeIwc7pQQfgbt6UQCR4rEADITBXLKUupbbgd/3gWzyLn1YtmjNT3XG7
         8k/0mQuqsQT8/VXBOW2Svt7V4w3EuN7iRBxLWQi7xlh3x0pvqwN8G0aPWtzpIMGTWxGa
         Jo8d+QV33cEqJgEY4jo2i9z7V6P8YIUO6fBZ25KXKz+Cqv3Vi7zl1R4JRpPJsHKmSQQK
         7ygA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor3180381oto.116.2019.06.15.07.55.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 07:55:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jsavitz@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwKBPzqo5TL6rFrnREFUjRgNeUMkK3klySr7NevDMq8P3LAgYuZoUbBHpsMVVHfErjvWphf4b3VQAeDVe90mDI=
X-Received: by 2002:a9d:67d5:: with SMTP id c21mr33729557otn.243.1560610546148;
 Sat, 15 Jun 2019 07:55:46 -0700 (PDT)
MIME-Version: 1.0
References: <1560437690-13919-1-git-send-email-jsavitz@redhat.com> <20190613122956.2fe1e200419c6497159044a0@linux-foundation.org>
In-Reply-To: <20190613122956.2fe1e200419c6497159044a0@linux-foundation.org>
From: Joel Savitz <jsavitz@redhat.com>
Date: Sat, 15 Jun 2019 10:55:31 -0400
Message-ID: <CAL1p7m5_uzOhk6Lj78Pgh6Y6EXPd=+YLk4vwMZd6xyoiJutt5g@mail.gmail.com>
Subject: Re: [PATCH v4] fs/proc: add VmTaskSize field to /proc/$$/status
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, 
	Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ram Pai <linuxram@us.ibm.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, 
	Sandeep Patil <sspatil@android.com>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, 
	linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The most immediate use case is the optimization of an internal test,
but upon closer examination neither this patch nor the test itself
turn out to be worth pursuing.

Thank you for your time and constructive comments.

Best,
Joel Savitz


On Thu, Jun 13, 2019 at 3:30 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 13 Jun 2019 10:54:50 -0400 Joel Savitz <jsavitz@redhat.com> wrote:
>
> > The kernel provides no architecture-independent mechanism to get the
> > size of the virtual address space of a task (userspace process) without
> > brute-force calculation. This patch allows a user to easily retrieve
> > this value via a new VmTaskSize entry in /proc/$$/status.
>
> Why is access to ->task_size required?  Please fully describe the
> use case.
>
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -187,6 +187,7 @@ read the file /proc/PID/status:
> >    VmLib:      1412 kB
> >    VmPTE:        20 kb
> >    VmSwap:        0 kB
> > +  VmTaskSize:        137438953468 kB
> >    HugetlbPages:          0 kB
> >    CoreDumping:    0
> >    THP_enabled:         1
> > @@ -263,6 +264,7 @@ Table 1-2: Contents of the status files (as of 4.19)
> >   VmPTE                       size of page table entries
> >   VmSwap                      amount of swap used by anonymous private data
> >                               (shmem swap usage is not included)
> > + VmTaskSize                  size of task (userspace process) vm space
>
> This is rather vague.  Is it the total amount of physical memory?  The
> sum of all vma sizes, populated or otherwise?  Something else?
>
>

