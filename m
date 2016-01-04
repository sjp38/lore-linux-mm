Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD4C6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 04:26:03 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so174796001pac.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 01:26:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f69si61029069pfd.20.2016.01.04.01.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 01:26:02 -0800 (PST)
Date: Mon, 4 Jan 2016 17:25:45 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v2 14/16] x86,nvdimm,kexec: Use walk_iomem_res_desc() for
 iomem search
Message-ID: <20160104092545.GA7033@dhcp-128-65.nay.redhat.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, x86@kernel.org, linux-nvdimm@ml01.01.org, kexec@lists.infradead.org

Hi, Toshi,

On 12/25/15 at 03:09pm, Toshi Kani wrote:
> Change to call walk_iomem_res_desc() for searching resource entries
> with the following names:
>  "ACPI Tables"
>  "ACPI Non-volatile Storage"
>  "Persistent Memory (legacy)"
>  "Crash kernel"
> 
> Note, the caller of walk_iomem_res() with "GART" is left unchanged
> because this entry may be initialized by out-of-tree drivers, which
> do not have 'desc' set to IORES_DESC_GART.

Found below commit which initialize the GART entry:
commit 56dd669a138c40ea6cdae487f233430d12372767
Author: Aaron Durbin <adurbin@google.com>
Date:   Tue Sep 26 10:52:40 2006 +0200

    [PATCH] Insert GART region into resource map
    
    Patch inserts the GART region into the iomem resource map. The GART will then
    be visible within /proc/iomem. It will also allow for other users
    utilizing the GART to subreserve the region (agp or IOMMU).
    
    Signed-off-by: Aaron Durbin <adurbin@google.com>

But later it was reverted:
commit 707d4eefbdb31f8e588277157056b0ce637d6c68
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Tue Mar 18 14:26:12 2014 -0600

    Revert "[PATCH] Insert GART region into resource map"
    
    This reverts commit 56dd669a138c, which makes the GART visible in
    /proc/iomem.  This fixes a regression: e501b3d87f00 ("agp: Support 64-bit
    APBASE") exposed an existing problem with a conflict between the GART
    region and a PCI BAR region.
    
    The GART addresses are bus addresses, not CPU addresses, and therefore
    should not be inserted in iomem_resource.
    
    On many machines, the GART region is addressable by the CPU as well as by
    an AGP master, but CPU addressability is not required by the spec.  On some
    of these machines, the GART is mapped by a PCI BAR, and in that case, the
    PCI core automatically inserts it into iomem_resource, just as it does for
    all BARs.
    
    Inserting it here means we'll have a conflict if the PCI core later tries
    to claim the GART region, so let's drop the insertion here.
    
    The conflict indirectly causes X failures, as reported by Jouni in the
    bugzilla below.  We detected the conflict even before e501b3d87f00, but
    after it the AGP code (fix_northbridge()) uses the PCI resource (which is
    zeroed because of the conflict) instead of reading the BAR again.
    
    Conflicts:
        arch/x86_64/kernel/aperture.c
    
    Fixes: e501b3d87f00 agp: Support 64-bit APBASE
    Link: https://bugzilla.kernel.org/show_bug.cgi?id=72201
    Reported-and-tested-by: Jouni Mettala <jtmettala@gmail.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>


For amd64 agp, currently the region name is "aperture" instead:
drivers/char/agp/amd64-agp.c: agp_aperture_valid()

This may not be the only case, but I doubt that anyone is testing this since
long time ago kexec-tools excluding the 'GART' region. Kexec-tools and kexec_file
may need update to use "aperture" if someone can test it.

I think adding an enum value for compatibility is reasonable, we do not care
about third party drivers in mainline.

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
