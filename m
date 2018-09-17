Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA42A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 02:16:30 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id h81-v6so2283768vke.13
        for <linux-mm@kvack.org>; Sun, 16 Sep 2018 23:16:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11-v6sor3691314vsc.25.2018.09.16.23.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Sep 2018 23:16:29 -0700 (PDT)
MIME-Version: 1.0
References: <CAOuPNLj1wx4sznrtLdKjcvuTf0dECPWzPaR946FoYRXB6YAGCw@mail.gmail.com>
 <20180916153237.GC15699@rapoport-lnx> <CAOuPNLj0HyC+yzwTpN-EWpzHTJ58u7pBfOja1MyweF4pbct1eQ@mail.gmail.com>
 <20180917043724.GA12866@rapoport-lnx>
In-Reply-To: <20180917043724.GA12866@rapoport-lnx>
From: Pintu Kumar <pintu.ping@gmail.com>
Date: Mon, 17 Sep 2018 11:46:17 +0530
Message-ID: <CAOuPNLidXFHgkBmwOPj_xFkU_OpLaXbpJg04Le7MPxu8cYg_RQ@mail.gmail.com>
Subject: Re: KSM not working in 4.9 Kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: open list <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Mon, Sep 17, 2018 at 10:07 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> On Sun, Sep 16, 2018 at 10:35:17PM +0530, Pintu Kumar wrote:
> > On Sun, Sep 16, 2018 at 9:02 PM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > >
> > > On Fri, Sep 14, 2018 at 07:58:01PM +0530, Pintu Kumar wrote:
> > > > Hi All,
> > > >
> > > > Board: Hikey620 ARM64
> > > > Kernel: 4.9.20
> > > >
> > > > I am trying to verify KSM (Kernel Same Page Merging) functionality on
> > > > 4.9 Kernel using "mmap" and madvise user space test utility.
> > > > But to my observation, it seems KSM is not working for me.
> > > > CONFIG_KSM=y is enabled in kernel.
> > > > ksm_init is also called during boot up.
> > > >   443 ?        SN     0:00 [ksmd]
> > > >
> > > > ksmd thread is also running.
> > > >
> > > > However, when I see the sysfs, no values are written.
> > > > ~ # grep -H '' /sys/kernel/mm/ksm/*
> > > > /sys/kernel/mm/ksm/pages_hashed:0
> > > > /sys/kernel/mm/ksm/pages_scanned:0
> > > > /sys/kernel/mm/ksm/pages_shared:0
> > > > /sys/kernel/mm/ksm/pages_sharing:0
> > > > /sys/kernel/mm/ksm/pages_to_scan:200
> > > > /sys/kernel/mm/ksm/pages_unshared:0
> > > > /sys/kernel/mm/ksm/pages_volatile:0
> > > > /sys/kernel/mm/ksm/run:1
> > > > /sys/kernel/mm/ksm/sleep_millisecs:1000
> > > >
> > > > So, please let me know if I am doing any thing wrong.
> > > >
> > > > This is the test utility:
> > > > int main(int argc, char *argv[])
> > > > {
> > > >         int i, n, size;
> > > >         char *buffer;
> > > >         void *addr;
> > > >
> > > >         n = 100;
> > > >         size = 100 * getpagesize();
> > > >         for (i = 0; i < n; i++) {
> > > >                 buffer = (char *)malloc(size);
> > > >                 memset(buffer, 0xff, size);
> > > >                 addr =  mmap(NULL, size,
> > > >                            PROT_READ | PROT_EXEC | PROT_WRITE,
> > > > MAP_PRIVATE | MAP_ANONYMOUS,
> > > >                            -1, 0);
> > > >                 madvise(addr, size, MADV_MERGEABLE);
> > >
> > > Just mmap'ing an area does not allocate any physical pages, so KSM has
> > > nothing to merge.
> > >
> > > You need to memset(addr,...) after mmap().
> > >
> >
> > Yes, I am doing memset also.
> > memset(addr, 0xff, size);
> >
> > But still no effect.
> > And I checked LTP test cases. It almost doing the same thing.
> >
> > I observed that [ksmd] thread is not waking up at all.
> > I gave some print inside it, but I could never saw that prints coming.
> > I could not find it running either in top command during the operation.
> > Is there anything needs to be done, to wakw up ksmd?
> > I already set: echo 1 > /sys/kernel/mm/ksm.
>
> It should be echo 1 > /sys/kernel/mm/ksm/run
>

Oh yes, sorry for the typo.
I tried the same, but still ksm is not getting invoked.
Could someone confirm if KSM was working in 4.9 kernel?


> >
> >
> > > >                 sleep(1);
> > > >         }
> > > >         printf("Done....press ^C\n");
> > > >
> > > >         pause();
> > > >
> > > >         return 0;
> > > > }
> > > >
> > > >
> > > >
> > > > Thanks,
> > > > Pintu
> > > >
> > >
> > > --
> > > Sincerely yours,
> > > Mike.
> > >
> >
>
> --
> Sincerely yours,
> Mike.
>
