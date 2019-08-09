Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F65AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 580132166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:05:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ntope72j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 580132166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2CE46B0292; Fri,  9 Aug 2019 14:05:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE386B02A2; Fri,  9 Aug 2019 14:05:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B80A26B02B9; Fri,  9 Aug 2019 14:05:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD226B0292
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:05:56 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a15so8889563oto.14
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:05:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=aXqwFbZXLc0jc6LmbghFnYdfUqr8zle8MxM4PnoEM74=;
        b=KfPHdR5AnsRZ/1fkixv7plN9DyDDjEbCiWHAx6zq0J54l97JAxmD4aJSJY8aYeyS2J
         zyfi6RfSLe8AAYQWOouG/S/MEqcCrUPICz0z+ef8Q6Eohj29vwNHO0Ftu9NqDeK5VLcS
         M7Kxo0qBQl+FESdqR8Aaq9vmKvNNYUZo04mKfZfsYFfjicjy2Q1wYyZlsl9u80+ajZXo
         LhT5Mh7r70t5p+gSeOWXa2eal+feHqI1yiJVEWeFnObWj3whLLknwIDffijsrP33yZtn
         kdBAkzrLBLoqnQrgaxw1IhoBLTo8uvQbv84iHns0lBnSklsiVmWmerVvGP1/99ZmJcfj
         MQ6g==
X-Gm-Message-State: APjAAAV1Is/wor57cTnMjHDb74PJcJe9Cq3buV/NgSDJY09eX1XRX+Ri
	kEQSMcxxNwKgQA734yMq93uZqCYtDu92vSYBpJi/zZW9fNGhqrusrSldI5QvvIS/Sa6fBPKpvP/
	0EOUh01+thwDJ7NcrLvwMyyJc/exeCxMc3kqgiGaU0/ciXcKto2MfoZ1qI64QDEGIfQ==
X-Received: by 2002:a9d:62c4:: with SMTP id z4mr17774003otk.56.1565373956268;
        Fri, 09 Aug 2019 11:05:56 -0700 (PDT)
X-Received: by 2002:a9d:62c4:: with SMTP id z4mr17773951otk.56.1565373955603;
        Fri, 09 Aug 2019 11:05:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373955; cv=none;
        d=google.com; s=arc-20160816;
        b=h/FsvmwTlTGqikh7j/uG/ognqBcNiJ2t8l2sYScQMqulEHa7BIkOSvuKsyPtNoEEwF
         IS+4Wv0KbBtTmF0fvjXSFWqwzcJUTqKr84d4m/K7+ZDp0c6Q1jvQjsov+c0O87mepVgV
         KG8WK6EhGvY+nk+Y/EAtU9VXnnGFEJJgZcwxG+Ek969nV9JEWy2UOFhiGChAZRye1B8p
         Ydsh5hWTnSS/2NXkMAhu+UpU/TEvBTQBSKOVA0WgwWdp0K8dmECZ+M0ba/+F+IXn5EEK
         z6LMqwU9RhIgSSMsCmR9HK5lMDiMg1+a+R1jTYjuJboyDSrMHdMlxbQUo/307oMNXhu0
         7OwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=aXqwFbZXLc0jc6LmbghFnYdfUqr8zle8MxM4PnoEM74=;
        b=gwid1w1K907RPjOwigDYE2BthdBPd7pWkmmIDrD0nE5sQn2KLinSmtsmcFIfvXrewi
         mmRkKE9H5NDpxlG+i/OZKf5iTvedXhmyho+rUIcDo6coVdQljuWXjl1lj81pZMCwonAM
         hOCzi1LTtJ4djxYCC2a3mvBkpTvwprHIoVYhn3lNXto0ITzqoSyBhCDkePaCsXrGnJob
         r4eS5l4RlQo9BV7ANT1+BK6pcVbGrMD05SinDjAjKS4tebYl+jYHLLJ9O/r8R4Poqqg4
         ZslVspN4MaXQDhBNlnMPlVPHQ3QgST1HNfZDJcPJVVRf46MNRM5BCgZEM8VdSUqy1MMa
         +xRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ntope72j;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y27sor45260743ote.102.2019.08.09.11.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 11:05:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ntope72j;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=aXqwFbZXLc0jc6LmbghFnYdfUqr8zle8MxM4PnoEM74=;
        b=Ntope72jwTxtu3Yysu6SNp8tcmL3H+NFI7czF31eOSqr4bal2SL/RrlLvEAayx2Ppj
         Es40PbT9e5+Zgr+Ba1AEytbNAAULO/iK0f1/uJN4haBod2IZjQguq4yHjlQTCQIKReRt
         /lN9A/E3wWfGY6skJCuhbuMvEaHxMHxL9OARpTq4DI8pSoAqPrAAhABRLIBmAX/sUgxv
         0nh3pdV5vI1ptGadMwRdWf27a8ufQdcJ2pMvk7HDwgizlapWvxb8XnU8zYSZQj8ePcuw
         nX0f6it3SQzuzRohHkPFgUjaNJ9ZNvw8PnZj8l9JeRYW+eqQItb5r/MzXgt4Dn7z9X3C
         fZPg==
X-Google-Smtp-Source: APXvYqzBzQeIAM/yjyqWmposhI/WI4/2AmabiVnKsQMoOTrkpJzf/aSrJcKPk7atxAAWEz/+DMmblUGjWOYHlqAxuCA=
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr19888526otp.33.1565373954812;
 Fri, 09 Aug 2019 11:05:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190808194002.226688-1-almasrymina@google.com> <20190809112738.GB13061@blackbody.suse.cz>
In-Reply-To: <20190809112738.GB13061@blackbody.suse.cz>
From: Mina Almasry <almasrymina@google.com>
Date: Fri, 9 Aug 2019 11:05:43 -0700
Message-ID: <CAHS8izNM3jYFWHY5UJ7cmJ402f-RKXzQ=JFHpD7EkvpAdC2_SA@mail.gmail.com>
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>
Cc: mike.kravetz@oracle.com, shuah <shuah@kernel.org>, 
	David Rientjes <rientjes@google.com>, Shakeel Butt <shakeelb@google.com>, 
	Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, khalid.aziz@oracle.com, 
	open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 9, 2019 at 4:27 AM Michal Koutn=C3=BD <mkoutny@suse.com> wrote:
>
> (+CC cgroups@vger.kernel.org)
>
> On Thu, Aug 08, 2019 at 12:40:02PM -0700, Mina Almasry <almasrymina@googl=
e.com> wrote:
> > We have developers interested in using hugetlb_cgroups, and they have e=
xpressed
> > dissatisfaction regarding this behavior.
> I assume you still want to enforce a limit on a particular group and the
> application must be able to handle resource scarcity (but better
> notified than SIGBUS).
>
> > Alternatives considered:
> > [...]
> (I did not try that but) have you considered:
> 3) MAP_POPULATE while you're making the reservation,

I have tried this, and the behaviour is not great. Basically if
userspace mmaps more memory than its cgroup limit allows with
MAP_POPULATE, the kernel will reserve the total amount requested by
the userspace, it will fault in up to the cgroup limit, and then it
will SIGBUS the task when it tries to access the rest of its
'reserved' memory.

So for example:
- if /proc/sys/vm/nr_hugepages =3D=3D 10, and
- your cgroup limit is 5 pages, and
- you mmap(MAP_POPULATE) 7 pages.

Then the kernel will reserve 7 pages, and will fault in 5 of those 7
pages, and will SIGBUS you when you try to access the remaining 2
pages. So the problem persists. Folks would still like to know they
are crossing the limits on mmap time.

> 4) Using multple hugetlbfs mounts with respective limits.
>

I assume you mean the size=3D<value> option on the hugetlbfs mount. This
would only limit hugetlb memory usage via the hugetlbfs mount. Tasks
can still allocate hugetlb memory without any mount via
mmap(MAP_HUGETLB) and shmget/shmat APIs, and all these calls will
deplete the global, shared hugetlb memory pool.

> > Caveats:
> > 1. This support is implemented for cgroups-v1. I have not tried
> >    hugetlb_cgroups with cgroups v2, and AFAICT it's not supported yet.
> >    This is largely because we use cgroups-v1 for now.
> Adding something new into v1 without v2 counterpart, is making migration
> harder, that's one of the reasons why v1 API is rather frozen now. (I'm
> not sure whether current hugetlb controller fits into v2 at all though.)
>

In my estimation it's maybe fine to make this change in v1 because, as
far as I understand, hugetlb_cgroups are a little used feature of the
kernel (although we see it getting requested) and hugetlb_cgroups
aren't supported in v2 yet, and I don't *think* this change makes it
any harder to port hugetlb_cgroups to v2.

But, like I said if there is consensus this must not be checked in
without hugetlb_cgroups v2 supported is added alongside, I can take a
look at that.

> Michal

