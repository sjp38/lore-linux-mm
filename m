Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31AEAC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA8EE229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:38:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nyY+obe/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA8EE229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719178E0068; Thu, 25 Jul 2019 07:38:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A33C8E0059; Thu, 25 Jul 2019 07:38:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A388E0068; Thu, 25 Jul 2019 07:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2A98E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:38:57 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f11so27261352otq.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:38:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=G6MpZgr7i8B1FkEDPScz8e/wH7xnLSjpvv/jUeXDToM=;
        b=dCLmsEov0qorFwUsUP4Ww5MZQdMretvct8SWto0bvk9Y/roqb9G4PuPKGQ7VN2TtpL
         jO1m7gCHBduYtA0/bRYQTH21IpSrk5o21gcjIb+qs2G9BXCpClVYfRe2ctPSVZIqwcU7
         BUuNjSHVXrWQf7vxE9AKYkvVV0nc+nIiIznQOP5DBO/xDHu2MfAERQmTCZeJxk82gVFe
         9Db3KIRi5+clL0LopFADW6XpZhDrGEq9gTpBAdttft5ZvqackkWwsL8SONGyUd0KOJwc
         k2rftRp680KSDIAxuzSC3MTXp4gV+Whe/iBpsefrjGQCvOJfvs0LlPutxd1UgSevPIm0
         s2mg==
X-Gm-Message-State: APjAAAV3JOLXtYAfaAHPTWuj+eRS//E+N0BYSIW+iFF1gYNSJjxeGy/q
	3u4u7R+m5XY+8OzIm+HQmhxUeOjbNcLcOhOxb7jKGgeg83fh5tF5xGe1vGVLSFtptX16SzkEFYU
	3jnRPcrWciIDkBX3B+BNeFSeeMtnImurRMpTVnb0zrkWK0xwx0lNvDN2+6dsjMGd8zg==
X-Received: by 2002:aca:dd55:: with SMTP id u82mr41551516oig.68.1564054736666;
        Thu, 25 Jul 2019 04:38:56 -0700 (PDT)
X-Received: by 2002:aca:dd55:: with SMTP id u82mr41551489oig.68.1564054735836;
        Thu, 25 Jul 2019 04:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564054735; cv=none;
        d=google.com; s=arc-20160816;
        b=QE19N70DQUGDMxdtA5iRO/T3vs2t68ARI9sACdvRW3p8fIi3WnLdfcSOjvDSv+vKad
         HlMPi7+/QpdacpseEL5xtjuvZMbUFBRFbYmMkkJstTZytDisH05xLn+u0GAM4MYFCMIO
         bg8aMGG/3uoML2hNXtvVcLC6KIPOE7jTt4yWWVxz+VE1vrklsf/4ma97gVaKr4Xs7jly
         zlpIBKPvNRz/YYngmpZWCR/0o27kVIgx6g0L7cyeAzw5H7kckLgAS3i2I3guOnMcdLyB
         NzRW0+sBkdee7HqHSFSvBCD+U/X86j511i74wRgF+ukiCZHhJmksZBc+iaFdLrH4rYaW
         xqWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=G6MpZgr7i8B1FkEDPScz8e/wH7xnLSjpvv/jUeXDToM=;
        b=pFQwmqAuD7kbU9ojx3necCq/BQLYuWnp5OyeMyq++YukvpKD18o36dWTqG22L7fXvD
         QKo+5CyTq7Ore6SDnyltXNxblguDUZWJ1lDZY+QHh4lJ9WxS1AqKnaFQRRd+jr9pZugo
         gEogChDrYcTUmf9CWHJ0kxvoTyPYCd8f51TtSm0JCzqtGKFPZ7BuR9oFaLBIR1oTUfWy
         ohV09+sUL6wBkTGr6LZ4mgyjlr+3UB41h07MdCdFfzrQaMm5zn8B38jfFhaUWUw1zuwJ
         HAC8Qx/AWb8R/bBU9qw6wDPVKG9ygV2gEY9WwaLdBm1ios3eAhZqapY7PMXgQVrnINRG
         5JuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="nyY+obe/";
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c22sor26114909otn.18.2019.07.25.04.38.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 04:38:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="nyY+obe/";
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G6MpZgr7i8B1FkEDPScz8e/wH7xnLSjpvv/jUeXDToM=;
        b=nyY+obe/i8BPsQ9tV6oR/SYTh1cwBpWPdZUHEi6zHL537VM4jVHEMNu6f42gzIG3C4
         php4D9liMyMj06VelMTSpFNOVGLpq2boQmu0KiUu0OJ67ffsZZ8sGDPa4n8hVBTmNrvM
         5wPhO2o0DdouG6Adnn9CD5pzYp+K4/RsN4AQGhA70tinYurvHdYPKFXs+S7uD4ZRcWPw
         hXEx+uUlAQnpd5evyq3CDlJZ3X41kn60/TPU2RXcw7WLCC3XUXoqCwUA9oPd6Z+FzugM
         ChmYOdr4Y2LDAtWYInBfJppWUAt4gByvI0F9eIhsJqDhY4Pv1TXdQatjEJ894w5q81T2
         ThcA==
X-Google-Smtp-Source: APXvYqwlvxtpErK7SyKEUbs9S2xkGf4bF1/no0g7n+Qlk9vOJFBk7RzPSH/NR75ptf/4VJpWmRSPirwNtTIk03j9LdM=
X-Received: by 2002:a05:6830:1688:: with SMTP id k8mr24913637otr.233.1564054735077;
 Thu, 25 Jul 2019 04:38:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
 <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
 <CANpmjNNhwcYo-3tMkYPGrvSew633FQW7fCUiTgYUp7iKYY7fpw@mail.gmail.com> <20190725101114.GB14347@lakrids.cambridge.arm.com>
In-Reply-To: <20190725101114.GB14347@lakrids.cambridge.arm.com>
From: Marco Elver <elver@google.com>
Date: Thu, 25 Jul 2019 13:38:43 +0200
Message-ID: <CANpmjNOQSqtpEWNbk6Ed+GmZ8ZBY-LBn4ojt8_yrUM+qmdGttw@mail.gmail.com>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2019 at 12:11, Mark Rutland <mark.rutland@arm.com> wrote:
>
> On Thu, Jul 25, 2019 at 12:06:46PM +0200, Marco Elver wrote:
> > On Thu, 25 Jul 2019 at 09:51, Dmitry Vyukov <dvyukov@google.com> wrote:
> > >
> > > On Thu, Jul 25, 2019 at 9:35 AM Dmitry Vyukov <dvyukov@google.com> wrote:
> > > >
> > > > ,On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
> > > > >
> > > > > Hook into vmalloc and vmap, and dynamically allocate real shadow
> > > > > memory to back the mappings.
> > > > >
> > > > > Most mappings in vmalloc space are small, requiring less than a full
> > > > > page of shadow space. Allocating a full shadow page per mapping would
> > > > > therefore be wasteful. Furthermore, to ensure that different mappings
> > > > > use different shadow pages, mappings would have to be aligned to
> > > > > KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> > > > >
> > > > > Instead, share backing space across multiple mappings. Allocate
> > > > > a backing page the first time a mapping in vmalloc space uses a
> > > > > particular page of the shadow region. Keep this page around
> > > > > regardless of whether the mapping is later freed - in the mean time
> > > > > the page could have become shared by another vmalloc mapping.
> > > > >
> > > > > This can in theory lead to unbounded memory growth, but the vmalloc
> > > > > allocator is pretty good at reusing addresses, so the practical memory
> > > > > usage grows at first but then stays fairly stable.
> > > > >
> > > > > This requires architecture support to actually use: arches must stop
> > > > > mapping the read-only zero page over portion of the shadow region that
> > > > > covers the vmalloc space and instead leave it unmapped.
> > > > >
> > > > > This allows KASAN with VMAP_STACK, and will be needed for architectures
> > > > > that do not have a separate module space (e.g. powerpc64, which I am
> > > > > currently working on).
> > > > >
> > > > > Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> > > > > Signed-off-by: Daniel Axtens <dja@axtens.net>
> > > >
> > > > Hi Daniel,
> > > >
> > > > This is awesome! Thanks so much for taking over this!
> > > > I agree with memory/simplicity tradeoffs. Provided that virtual
> > > > addresses are reused, this should be fine (I hope). If we will ever
> > > > need to optimize memory consumption, I would even consider something
> > > > like aligning all vmalloc allocations to PAGE_SIZE*KASAN_SHADOW_SCALE
> > > > to make things simpler.
> > > >
> > > > Some comments below.
> > >
> > > Marco, please test this with your stack overflow test and with
> > > syzkaller (to estimate the amount of new OOBs :)). Also are there any
> > > concerns with performance/memory consumption for us?
> >
> > It appears that stack overflows are *not* detected when KASAN_VMALLOC
> > and VMAP_STACK are enabled.
> >
> > Tested with:
> > insmod drivers/misc/lkdtm/lkdtm.ko cpoint_name=DIRECT cpoint_type=EXHAUST_STACK
>
> Could you elaborate on what exactly happens?
>
> i.e. does the test fail entirely, or is it detected as a fault (but not
> reported as a stack overflow)?
>
> If you could post a log, that would be ideal!

No fault, system just appears to freeze.

Log:

[   18.408553] lkdtm: Calling function with 1024 frame size to depth 64 ...
[   18.409546] lkdtm: loop 64/64 ...
[   18.410030] lkdtm: loop 63/64 ...
[   18.410497] lkdtm: loop 62/64 ...
[   18.410972] lkdtm: loop 61/64 ...
[   18.411470] lkdtm: loop 60/64 ...
[   18.411946] lkdtm: loop 59/64 ...
[   18.412415] lkdtm: loop 58/64 ...
[   18.412890] lkdtm: loop 57/64 ...
[   18.413356] lkdtm: loop 56/64 ...
[   18.413830] lkdtm: loop 55/64 ...
[   18.414297] lkdtm: loop 54/64 ...
[   18.414801] lkdtm: loop 53/64 ...
[   18.415269] lkdtm: loop 52/64 ...
[   18.415751] lkdtm: loop 51/64 ...
[   18.416219] lkdtm: loop 50/64 ...
[   18.416698] lkdtm: loop 49/64 ...
[   18.417201] lkdtm: loop 48/64 ...
[   18.417712] lkdtm: loop 47/64 ...
[   18.418216] lkdtm: loop 46/64 ...
[   18.418728] lkdtm: loop 45/64 ...
[   18.419232] lkdtm: loop 44/64 ...
[   18.419747] lkdtm: loop 43/64 ...
[   18.420262] lkdtm: loop 42/64 ...
< no further output, system appears unresponsive at this point >

Thanks,
-- Marco

