Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 516C28E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 00:37:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v4-v6so17078349oix.2
        for <linux-mm@kvack.org>; Sun, 16 Sep 2018 21:37:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 7-v6si6819096oik.113.2018.09.16.21.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Sep 2018 21:37:32 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8H4YenF122538
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 00:37:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mhx1wbtgt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 00:37:32 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 17 Sep 2018 05:37:30 +0100
Date: Mon, 17 Sep 2018 07:37:24 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: KSM not working in 4.9 Kernel
References: <CAOuPNLj1wx4sznrtLdKjcvuTf0dECPWzPaR946FoYRXB6YAGCw@mail.gmail.com>
 <20180916153237.GC15699@rapoport-lnx>
 <CAOuPNLj0HyC+yzwTpN-EWpzHTJ58u7pBfOja1MyweF4pbct1eQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOuPNLj0HyC+yzwTpN-EWpzHTJ58u7pBfOja1MyweF4pbct1eQ@mail.gmail.com>
Message-Id: <20180917043724.GA12866@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.ping@gmail.com>
Cc: open list <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Sun, Sep 16, 2018 at 10:35:17PM +0530, Pintu Kumar wrote:
> On Sun, Sep 16, 2018 at 9:02 PM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >
> > On Fri, Sep 14, 2018 at 07:58:01PM +0530, Pintu Kumar wrote:
> > > Hi All,
> > >
> > > Board: Hikey620 ARM64
> > > Kernel: 4.9.20
> > >
> > > I am trying to verify KSM (Kernel Same Page Merging) functionality on
> > > 4.9 Kernel using "mmap" and madvise user space test utility.
> > > But to my observation, it seems KSM is not working for me.
> > > CONFIG_KSM=y is enabled in kernel.
> > > ksm_init is also called during boot up.
> > >   443 ?        SN     0:00 [ksmd]
> > >
> > > ksmd thread is also running.
> > >
> > > However, when I see the sysfs, no values are written.
> > > ~ # grep -H '' /sys/kernel/mm/ksm/*
> > > /sys/kernel/mm/ksm/pages_hashed:0
> > > /sys/kernel/mm/ksm/pages_scanned:0
> > > /sys/kernel/mm/ksm/pages_shared:0
> > > /sys/kernel/mm/ksm/pages_sharing:0
> > > /sys/kernel/mm/ksm/pages_to_scan:200
> > > /sys/kernel/mm/ksm/pages_unshared:0
> > > /sys/kernel/mm/ksm/pages_volatile:0
> > > /sys/kernel/mm/ksm/run:1
> > > /sys/kernel/mm/ksm/sleep_millisecs:1000
> > >
> > > So, please let me know if I am doing any thing wrong.
> > >
> > > This is the test utility:
> > > int main(int argc, char *argv[])
> > > {
> > >         int i, n, size;
> > >         char *buffer;
> > >         void *addr;
> > >
> > >         n = 100;
> > >         size = 100 * getpagesize();
> > >         for (i = 0; i < n; i++) {
> > >                 buffer = (char *)malloc(size);
> > >                 memset(buffer, 0xff, size);
> > >                 addr =  mmap(NULL, size,
> > >                            PROT_READ | PROT_EXEC | PROT_WRITE,
> > > MAP_PRIVATE | MAP_ANONYMOUS,
> > >                            -1, 0);
> > >                 madvise(addr, size, MADV_MERGEABLE);
> >
> > Just mmap'ing an area does not allocate any physical pages, so KSM has
> > nothing to merge.
> >
> > You need to memset(addr,...) after mmap().
> >
> 
> Yes, I am doing memset also.
> memset(addr, 0xff, size);
> 
> But still no effect.
> And I checked LTP test cases. It almost doing the same thing.
> 
> I observed that [ksmd] thread is not waking up at all.
> I gave some print inside it, but I could never saw that prints coming.
> I could not find it running either in top command during the operation.
> Is there anything needs to be done, to wakw up ksmd?
> I already set: echo 1 > /sys/kernel/mm/ksm.

It should be echo 1 > /sys/kernel/mm/ksm/run
 
> 
> 
> > >                 sleep(1);
> > >         }
> > >         printf("Done....press ^C\n");
> > >
> > >         pause();
> > >
> > >         return 0;
> > > }
> > >
> > >
> > >
> > > Thanks,
> > > Pintu
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.
