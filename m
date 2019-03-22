Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01DFDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:06:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A69632190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:06:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ETh0Q+H5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A69632190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54E806B0005; Fri, 22 Mar 2019 18:06:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D63B6B0006; Fri, 22 Mar 2019 18:06:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3772D6B0007; Fri, 22 Mar 2019 18:06:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1425A6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:06:07 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id p143so2881549iod.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:06:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zPnyPNGnsO/md2Fj5yEAI9x91Hz7J9uO8l7Sk2KMvIo=;
        b=fDcwzi9SgzPKrnwQ1p932LOlA8N9rwBr8jX0oXubcNi8bY9IJPNUYpHdbQLSR00ZWB
         TFwFgBQlblRRvvhxyIK4RvLm4pSZT255eXKjlG4PRZtdVjKSxPzKM6lVfwwUKvItTzQE
         54e+TOF7YUqmv1o9HwOQvNPHGBzQHOI0rpkWhIQCHwk9K8e8EReuZq6EWyg7dkcHL4Mp
         xbYENeTInJcIg4yOavHjXCy6s8BWYI1rmVSWt/rOzr/3OX1rtJ0iU6gXzDkq2pEQKoss
         bQpyLPeJSJsEbW62Uonp+VF3dVC5+gwsxCqk6wNqMSuIOuUjyXq9wJzfVkJuyR8NCgwE
         cvFA==
X-Gm-Message-State: APjAAAVMKh7dCD1RF85PdgjVoSjY0jbi0bPO836JY9FfDzj7zmkWaJRi
	4w3U/4ZXOcdxnW2ZGofwiAiFEcNwEyb1nYcIws6ivmC2DNV9iwEPNaylrcQw9sIouc6E8qXxjZ/
	XqjUvkbxMUngIYIvzQMC0GJKyFvBSehYQ2FdhXFlCx6hUT3rEUUylb+xsJB1uYHo=
X-Received: by 2002:a02:6a2c:: with SMTP id l44mr6717882jac.63.1553292366828;
        Fri, 22 Mar 2019 15:06:06 -0700 (PDT)
X-Received: by 2002:a02:6a2c:: with SMTP id l44mr6717834jac.63.1553292365840;
        Fri, 22 Mar 2019 15:06:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553292365; cv=none;
        d=google.com; s=arc-20160816;
        b=0K/DmOaiDOGv7BCL3Xjn7wHs8VyO+i9vi81RUtkKHX/v9mFfZwEJ7QM8TVRi+dV8Ut
         J5GGGfcKAu478G7LHk3dEoaJen9dlnTAAHRXscr1AaWN8mZuHMk4cFmyLcYpwC0UZ9au
         1ALvaiFmU37xEb56uD/QdKxgy+DT7Ym80XTwrh+JXF9utU7myHvk0MbIB8tEt7n1eyRZ
         aogo+MKK5NAXv0+ttTgs8FyTdCjqBPZK3zmRltp+1s3/K9U+QixTbw7xZ2syDjmdv28k
         65qGnUTACY0RumPCZ+wWiQ5bhKWMe9L75N2tp3IcGxyXyCj2loXVzg2dBFY5TEdr4Vat
         HGhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zPnyPNGnsO/md2Fj5yEAI9x91Hz7J9uO8l7Sk2KMvIo=;
        b=hLfEDVy0/RTLr5x8y7GJVwcwOBFnReaWz4Ur6esxukQITb+9iBvUdHdlYEzwoNzEtG
         BAEGVCK3f32zw4eK3tl66bSij0rZqXl/UuYi831AIDhPIeiIi4HP3BUBJn/ISj1ZIDUb
         YpiQlcx/9bjj5YGKENupIIQxzGdz5bVeNrFHr2189p9vJmMB4vuxMNXzztQqX8JccRGt
         +fqr+JusTJ9wgm+klGjDhlGMg8aiYcOhPfvjJY9I0Be7D/eq0uOV5wZoDGh4pcVhFRec
         QnTs+zrO0A9fSW95s9+Y8q4clwNlnvD1QAzFTkEBc3D4APMwAz/2GRMKuXTr155N+3qE
         QHig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ETh0Q+H5;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor17816422itm.18.2019.03.22.15.06.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:06:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ETh0Q+H5;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zPnyPNGnsO/md2Fj5yEAI9x91Hz7J9uO8l7Sk2KMvIo=;
        b=ETh0Q+H5NErnf+anAIeNX89EpJjpuFOFrGA549zU6YNjyodAclghZqMAQhCYHmsdpr
         VBr/q0cU6fGUQZpceBNwr0M+bLWwnpat9RsFa50fk6EH+Ej3wT3fiVBe0lVTwTugrloo
         iFU6UFQ36JWbIMUYlh8YNEcsGoj838Wu1icdiWs1qphTBfThMQQSRXpaXXYbY3iRIz+R
         okhh/FvQVRXB/Q8a7q6XyZrBKwLnS/7Qc7BIuqBvFeFzP4QdI3IylwYJd+W54gfYHbbY
         V3ldQH0uIH3yxe3qtmId36/CRAoD48vcD7efQl3U/JsBsrDrQh+HlYfRz2uDtxUe2MaL
         raAg==
X-Google-Smtp-Source: APXvYqzvkOUTluGSKTjETBKJlQ9d9U0bafaXjVPDo287WeJSv03XpVRn3tgZfH8AGEVriQsCe7Tjp8XH5gu+GSmr/AQ=
X-Received: by 2002:a24:298b:: with SMTP id p133mr3554913itp.43.1553292365179;
 Fri, 22 Mar 2019 15:06:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-4-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-4-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 15:05:53 -0700
Message-ID: <CAA9_cmd9gUWMbpkP_AuxZ08iqvZdxjbtDoR-FpSjAyhZJisRZA@mail.gmail.com>
Subject: Re: [RESEND 3/7] mm/gup: Change GUP fast to use flags rather than a
 write 'bool'
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> To facilitate additional options to get_user_pages_fast() change the
> singular write parameter to be gup_flags.
>
> This patch does not change any functionality.  New functionality will
> follow in subsequent patches.
>
> Some of the get_user_pages_fast() call sites were unchanged because they
> already passed FOLL_WRITE or 0 for the write parameter.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
>
> ---
> Changes from V1:
>         Rebase to current merge tree
>         arch/powerpc/mm/mmu_context_iommu.c no longer calls gup_fast
>                 The gup_longterm was converted in patch 1
>
>  arch/mips/mm/gup.c                         | 11 ++++++-----
>  arch/powerpc/kvm/book3s_64_mmu_hv.c        |  4 ++--
>  arch/powerpc/kvm/e500_mmu.c                |  2 +-
>  arch/s390/kvm/interrupt.c                  |  2 +-
>  arch/s390/mm/gup.c                         | 12 ++++++------
>  arch/sh/mm/gup.c                           | 11 ++++++-----
>  arch/sparc/mm/gup.c                        |  9 +++++----
>  arch/x86/kvm/paging_tmpl.h                 |  2 +-
>  arch/x86/kvm/svm.c                         |  2 +-
>  drivers/fpga/dfl-afu-dma-region.c          |  2 +-
>  drivers/gpu/drm/via/via_dmablit.c          |  3 ++-
>  drivers/infiniband/hw/hfi1/user_pages.c    |  3 ++-
>  drivers/misc/genwqe/card_utils.c           |  2 +-
>  drivers/misc/vmw_vmci/vmci_host.c          |  2 +-
>  drivers/misc/vmw_vmci/vmci_queue_pair.c    |  6 ++++--
>  drivers/platform/goldfish/goldfish_pipe.c  |  3 ++-
>  drivers/rapidio/devices/rio_mport_cdev.c   |  4 +++-
>  drivers/sbus/char/oradax.c                 |  2 +-
>  drivers/scsi/st.c                          |  3 ++-
>  drivers/staging/gasket/gasket_page_table.c |  4 ++--
>  drivers/tee/tee_shm.c                      |  2 +-
>  drivers/vfio/vfio_iommu_spapr_tce.c        |  3 ++-
>  drivers/vhost/vhost.c                      |  2 +-
>  drivers/video/fbdev/pvr2fb.c               |  2 +-
>  drivers/virt/fsl_hypervisor.c              |  2 +-
>  drivers/xen/gntdev.c                       |  2 +-
>  fs/orangefs/orangefs-bufmap.c              |  2 +-
>  include/linux/mm.h                         |  4 ++--
>  kernel/futex.c                             |  2 +-
>  lib/iov_iter.c                             |  7 +++++--
>  mm/gup.c                                   | 10 +++++-----
>  mm/util.c                                  |  8 ++++----
>  net/ceph/pagevec.c                         |  2 +-
>  net/rds/info.c                             |  2 +-
>  net/rds/rdma.c                             |  3 ++-
>  35 files changed, 79 insertions(+), 63 deletions(-)


>
> diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
> index 0d14e0d8eacf..4c2b4483683c 100644
> --- a/arch/mips/mm/gup.c
> +++ b/arch/mips/mm/gup.c
> @@ -235,7 +235,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
>   * @nr_pages:  number of pages from start to pin
> - * @write:     whether pages will be written to
> + * @gup_flags: flags modifying pin behaviour
>   * @pages:     array that receives pointers to the pages pinned.
>   *             Should be at least nr_pages long.
>   *
> @@ -247,8 +247,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
>   */
> -int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> -                       struct page **pages)
> +int get_user_pages_fast(unsigned long start, int nr_pages,
> +                       unsigned int gup_flags, struct page **pages)

This looks a tad scary given all related thrash especially when it's
only 1 user that wants to do get_user_page_fast_longterm, right? Maybe
something like the following. Note I explicitly moved the flags to the
end so that someone half paying attention that calls
__get_user_pages_fast will get a compile error if they specify the
args in the same order.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76ba638ceda8..c6c743bc2c68 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1505,8 +1505,15 @@ static inline long
get_user_pages_longterm(unsigned long start,
 }
 #endif /* CONFIG_FS_DAX */

-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-                       struct page **pages);
+
+int __get_user_pages_fast(unsigned long start, int nr_pages,
+               struct page **pages, unsigned int gup_flags);
+
+static inline int get_user_pages_fast(unsigned long start, int
nr_pages, int write,
+                       struct page **pages)
+{
+       return __get_user_pages_fast(start, nr_pages, pages, write ?
FOLL_WRITE);
+}

 /* Container for pinned pfns / pages */
 struct frame_vector {

