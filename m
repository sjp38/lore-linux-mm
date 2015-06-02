Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A0CE0900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 15:06:29 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so18414310pab.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 12:06:29 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id m6si27613852pdr.252.2015.06.02.12.06.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 12:06:28 -0700 (PDT)
Message-ID: <1433270808.23540.155.camel@misato.fc.hp.com>
Subject: Re: [PATCH v12 0/10] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 02 Jun 2015 12:46:48 -0600
In-Reply-To: <20150602162103.GL23057@wotan.suse.de>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
	 <20150602162103.GL23057@wotan.suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, hch@lst.de

On Tue, 2015-06-02 at 18:21 +0200, Luis R. Rodriguez wrote:
> On Mon, Jun 01, 2015 at 01:36:23PM -0600, Toshi Kani wrote:
> > This patchset adds support of Write-Through (WT) mapping on x86.
> > The study below shows that using WT mapping may be useful for
> > non-volatile memory.
> > 
> > http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf
> > 
> > The patchset consists of the following changes.
> >  - Patch 1/10 to 6/10 add ioremap_wt()
> >  - Patch 7/10 adds pgprot_writethrough()
> >  - Patch 8/10 to 9/10 add set_memory_wt()
> >  - Patch 10/10 changes the pmem driver to call ioremap_wt()
> > 
> > All new/modified interfaces have been tested.
> > 
> > The patchset is based on:
> > git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#tip-mm-2
> 
> While at it can you also look at:
>
> mcgrof@ergon ~/linux-next (git::master)$ git grep -4 "writethrough" drivers/infiniband/

Thanks for checking this.  The inifiniband driver uses WT mappings on
powerpc without proper WT interfaces defined.  They can be cleaned up by
a separate patch series to support WT on powerpc in the same way after
this patchset (support WT on x86) is settled.

> drivers/infiniband/hw/ipath/ipath_driver.c-
> drivers/infiniband/hw/ipath/ipath_driver.c-     dd->ipath_pcirev = pdev->revision;
> drivers/infiniband/hw/ipath/ipath_driver.c-
> drivers/infiniband/hw/ipath/ipath_driver.c-#if defined(__powerpc__)
> drivers/infiniband/hw/ipath/ipath_driver.c:     /* There isn't a generic way to specify writethrough mappings */
> drivers/infiniband/hw/ipath/ipath_driver.c-     dd->ipath_kregbase = __ioremap(addr, len,
> drivers/infiniband/hw/ipath/ipath_driver.c-             (_PAGE_NO_CACHE|_PAGE_WRITETHRU));
> drivers/infiniband/hw/ipath/ipath_driver.c-#else
> drivers/infiniband/hw/ipath/ipath_driver.c-     dd->ipath_kregbase = ioremap_nocache(addr, len);

Once powerpc defines ioremap_wt(), this driver can simply call
ioremap_wt() without the ifdef.  ioremap_wt() is defined as
ioremap_nocache() on the architectures without WT support.

> drivers/infiniband/hw/ipath/ipath_file_ops.c-
> drivers/infiniband/hw/ipath/ipath_file_ops.c-   phys = dd->ipath_physaddr + piobufs;
> drivers/infiniband/hw/ipath/ipath_file_ops.c-
> drivers/infiniband/hw/ipath/ipath_file_ops.c-#if defined(__powerpc__)
> drivers/infiniband/hw/ipath/ipath_file_ops.c:   /* There isn't a generic way to specify writethrough mappings */
> drivers/infiniband/hw/ipath/ipath_file_ops.c-   pgprot_val(vma->vm_page_prot) |= _PAGE_NO_CACHE;
> drivers/infiniband/hw/ipath/ipath_file_ops.c-   pgprot_val(vma->vm_page_prot) |= _PAGE_WRITETHRU;
> drivers/infiniband/hw/ipath/ipath_file_ops.c-   pgprot_val(vma->vm_page_prot) &= ~_PAGE_GUARDED;
> drivers/infiniband/hw/ipath/ipath_file_ops.c-#endif

Once powerpc defines pgprot_writethrough(), this driver can use it
without the ifdef.  pgprot_writethrough() is defined as
pgprot_noncached() on the architectures without WT support.

> drivers/infiniband/hw/qib/qib_file_ops.c-
> drivers/infiniband/hw/qib/qib_file_ops.c-       phys = dd->physaddr + piobufs;
> drivers/infiniband/hw/qib/qib_file_ops.c-
> drivers/infiniband/hw/qib/qib_file_ops.c-#if defined(__powerpc__)
> drivers/infiniband/hw/qib/qib_file_ops.c:       /* There isn't a generic way to specify writethrough mappings */
> drivers/infiniband/hw/qib/qib_file_ops.c-       pgprot_val(vma->vm_page_prot) |= _PAGE_NO_CACHE;
> drivers/infiniband/hw/qib/qib_file_ops.c-       pgprot_val(vma->vm_page_prot) |= _PAGE_WRITETHRU;
> drivers/infiniband/hw/qib/qib_file_ops.c-       pgprot_val(vma->vm_page_prot) &= ~_PAGE_GUARDED;
> drivers/infiniband/hw/qib/qib_file_ops.c-#endif

Same as above.

> drivers/infiniband/hw/qib/qib_pcie.c-   addr = pci_resource_start(pdev, 0);
> drivers/infiniband/hw/qib/qib_pcie.c-   len = pci_resource_len(pdev, 0);
> drivers/infiniband/hw/qib/qib_pcie.c-
> drivers/infiniband/hw/qib/qib_pcie.c-#if defined(__powerpc__)
> drivers/infiniband/hw/qib/qib_pcie.c:   /* There isn't a generic way to specify writethrough mappings */
> drivers/infiniband/hw/qib/qib_pcie.c-   dd->kregbase = __ioremap(addr, len, _PAGE_NO_CACHE | _PAGE_WRITETHRU);
> drivers/infiniband/hw/qib/qib_pcie.c-#else
> drivers/infiniband/hw/qib/qib_pcie.c-   dd->kregbase = ioremap_nocache(addr, len);
> drivers/infiniband/hw/qib/qib_pcie.c-#endif

Same as ipath_driver.c.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
