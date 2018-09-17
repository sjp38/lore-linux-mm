Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA558E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 07:55:40 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id l22-v6so5425761uak.2
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 04:55:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i18-v6sor7412869uap.30.2018.09.17.04.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 04:55:39 -0700 (PDT)
MIME-Version: 1.0
References: <CAOuPNLj1wx4sznrtLdKjcvuTf0dECPWzPaR946FoYRXB6YAGCw@mail.gmail.com>
 <20180916153237.GC15699@rapoport-lnx> <CAOuPNLj0HyC+yzwTpN-EWpzHTJ58u7pBfOja1MyweF4pbct1eQ@mail.gmail.com>
 <20180917043724.GA12866@rapoport-lnx> <CAOuPNLidXFHgkBmwOPj_xFkU_OpLaXbpJg04Le7MPxu8cYg_RQ@mail.gmail.com>
In-Reply-To: <CAOuPNLidXFHgkBmwOPj_xFkU_OpLaXbpJg04Le7MPxu8cYg_RQ@mail.gmail.com>
From: Pintu Kumar <pintu.ping@gmail.com>
Date: Mon, 17 Sep 2018 17:25:27 +0530
Message-ID: <CAOuPNLj+4pMnEy5EyZmzDWszqMb_PQb3q7t_hvG_50BTz1He2Q@mail.gmail.com>
Subject: Re: KSM not working in 4.9 Kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: open list <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Mon, Sep 17, 2018 at 11:46 AM Pintu Kumar <pintu.ping@gmail.com> wrote:
> > > But still no effect.
> > > And I checked LTP test cases. It almost doing the same thing.
> > >
> > > I observed that [ksmd] thread is not waking up at all.
> > > I gave some print inside it, but I could never saw that prints coming.
> > > I could not find it running either in top command during the operation.
> > > Is there anything needs to be done, to wakw up ksmd?
> > > I already set: echo 1 > /sys/kernel/mm/ksm.
> >
> > It should be echo 1 > /sys/kernel/mm/ksm/run
> >
>
> Oh yes, sorry for the typo.
> I tried the same, but still ksm is not getting invoked.
> Could someone confirm if KSM was working in 4.9 kernel?
>

Ok, it's working now. I have to explicitly stop the ksm thread to see
the statistics.
Also there was some internal patch that was setting vm_flags to
VM_MERGABLE thus causing ksm_advise call to return.

# echo 1 > /sys/kernel/mm/ksm/run
# ./malloc-test.out &
# echo 0 > /sys/kernel/mm/ksm/run

~ # grep -H '' /sys/kernel/mm/ksm/*
/sys/kernel/mm/ksm/full_scans:105
/sys/kernel/mm/ksm/pages_shared:1
/sys/kernel/mm/ksm/pages_sharing:999
/sys/kernel/mm/ksm/pages_to_scan:100
/sys/kernel/mm/ksm/pages_unshared:0
/sys/kernel/mm/ksm/pages_volatile:0
/sys/kernel/mm/ksm/run:0
/sys/kernel/mm/ksm/sleep_millisecs:20


However, I have one doubt.
Is the above data correct, for the below program?

int main(int argc, char *argv[])
{
        int i, n, size, ret;
        char *buffer;
        void *addr;

        n = 10;
        size = 100 * getpagesize();
        for (i = 0; i < n; i++) {
                buffer = (char *)malloc(size);
                memset(buffer, 0xff, size);
                madvise(buffer, size, MADV_MERGEABLE);
                addr =  mmap(NULL, size,
                           PROT_READ | PROT_EXEC | PROT_WRITE,
MAP_PRIVATE | MAP_ANONYMOUS,
                           -1, 0);
                memset(addr, 0xff, size);
                ret = madvise(addr, size, MADV_MERGEABLE);
                if (ret < 0) {
                        fprintf(stderr, "madvise failed: ret: %d,
reason: %s\n", ret, strerror(errno));
                }
                usleep(500);
        }
        printf("Done....press ^C\n");

        pause();

        return 0;
}


Thanks,
Pintu
