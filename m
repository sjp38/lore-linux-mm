Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 410146B000A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 11:16:53 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id y73-v6so5343910oie.13
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 08:16:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y13-v6sor7692103oie.152.2018.11.12.08.16.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 08:16:51 -0800 (PST)
Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com. [209.85.167.178])
        by smtp.gmail.com with ESMTPSA id e195-v6sm4838734oic.26.2018.11.12.08.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 08:16:48 -0800 (PST)
Received: by mail-oi1-f178.google.com with SMTP id u130-v6so7610762oie.7
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 08:16:48 -0800 (PST)
MIME-Version: 1.0
References: <20181111212610.25213-1-timofey.titovets@synesis.ru> <20181112035838.GF21824@bombadil.infradead.org>
In-Reply-To: <20181112035838.GF21824@bombadil.infradead.org>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Mon, 12 Nov 2018 19:16:11 +0300
Message-ID: <CAGqmi7610QBdEp=xUOgPEbMhfB11ZF6cFCBS-T3BoCb2Sbj1ug@mail.gmail.com>
Subject: Re: [PATCH v2] ksm: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

=D0=BF=D0=BD, 12 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 6:58, Matthe=
w Wilcox <willy@infradead.org>:
>
> On Mon, Nov 12, 2018 at 12:26:10AM +0300, Timofey Titovets wrote:
> > ksm by default working only on memory that added by
> > madvice().
> >
> > And only way get that work on other applications:
> >  - Use LD_PRELOAD and libraries
> >  - Patch kernel
> >
> > Lets use kernel task list in ksm_scan_thread and add logic to allow ksm
> > import VMA from tasks.
> > That behaviour controlled by new attribute: mode
> > I try mimic hugepages attribute, so mode have two states:
> >  - normal       - old default behaviour
> >  - always [new] - allow ksm to get tasks vma and try working on that.
> >
> > To reduce CPU load & tasklist locking time,
> > ksm try import VMAs from one task per loop.
> >
> > So add new attribute "mode"
> > Two passible values:
> >  - normal [default] - ksm use only madvice
> >  - always [new]     - ksm will search vma over all processes memory and
> >                       add it to the dedup list
>
> Do you have any numbers for how much difference this change makes with
> various different workloads?

Yep, i got some non KVM numbers,
Formulas:
 Percentage - (pages_sharing - pages_shared)/pages_unshared
 Memory saved - (pages_sharing - pages_shared)*4/1024 MiB

- My working laptop: 5% - ~100 MiB saved ~2GiB used
  Many different chrome based apps + KDE

- K8s test VM:  40% - ~160 MiB saved ~920MiB used
  With some small running docker images

- Ceph test VM: 20% - ~60MiB saved ~600MiB used
  With ceph mon, osd.

Develop cluster servers:
- K8s server backend: 72%, ~5800 MiB saved ~35.7 GiB used
  (With backend apps: C, java, go & etc server apps)

- K8s server processing: 55%, ~2600 MiB saved ~28 GiB used
  (90% of load many instance of one CPU intensive application)

- Ceph node: 2%, ~190 MiB saved ~11.7 GiB used
  (OSD only)


So numbers, as always depends on the load.

Thanks!
- - -
P.S.
On recent kernels (4.19) i see BUG_ON message, that ksmd scheduled
while in critical section/atomic context,
not sure how to properly fix that.
(If i understood correctly, i can use preempt_disable(); but that
looks more like hack, not a fix).

Any feedback are welcome.
