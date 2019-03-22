Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA34C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:24:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E58521925
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:24:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IfQqpqlA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E58521925
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 938426B0005; Fri, 22 Mar 2019 17:24:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E8DE6B0006; Fri, 22 Mar 2019 17:24:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 800736B0007; Fri, 22 Mar 2019 17:24:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE646B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:24:53 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id a7so2840793ioq.3
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:24:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cDdtGqydhUlrmwu2LnW0CqWSMjmwrzYRsu4xa54SsdQ=;
        b=Fi8z3HdYMxyjlUDcN0ToxfbetRKiaHHOoABn4+sleHqOVU+9OL6a3dhsXovfuK8pw0
         e+1tbxImsjJh9lwjPOnehGSBZKfgjqwLBT6beAaN/EhYeQ7XlnuckK30x9POoTx9n4aJ
         +UdKNI5H3JG5kCKjEyror0CgaxBRrlOjNgoNZEVhs1gj2PIxcol9PSeNbwsORWM96Q03
         fC9ooyrhwkDnvgLJ7VIHJO9CikVy4qu91a2GssjEEtCdEJ3af6eOM+D1zA8sJnh47oZo
         k3AvyjPZc+QkS/JbvKWB+7y8RB2fBpUDnUnOQ7dJo7UsB0YUvGiZV/evNRgp1RKZ/Ahe
         k6HQ==
X-Gm-Message-State: APjAAAUk3PITJAVGQ/Ji0AXif24k9gNFnUGSGep8H+6Mj+jGMKiGLSYI
	WFbDiNiNYu5QQO7cSVEoPEvOjBAcD0Srg2gtXE816+wvta+dvz3SzidOngfKZQHsCWLkpuTcwQZ
	iJT/mULGsHsRvzBlJ8YoWweWaGRcWNSvwR0FjRV7776k7CEKP1iy5Hx3rOEIP1RI=
X-Received: by 2002:a24:1a91:: with SMTP id 139mr2910531iti.91.1553289893125;
        Fri, 22 Mar 2019 14:24:53 -0700 (PDT)
X-Received: by 2002:a24:1a91:: with SMTP id 139mr2910499iti.91.1553289892328;
        Fri, 22 Mar 2019 14:24:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553289892; cv=none;
        d=google.com; s=arc-20160816;
        b=TSDAbBldLD1BMObFCCEUSAIJtXetnR7FfHev6xocHrY38RpKMJrH5Fu/+gbIork/r7
         7HGc8/Tibu7OQfZiTPDHtqaoHLZWYnyrVHqEjnFTUC67tdQJLwwXaD+ii1NRGzPplRYa
         L5ajjifR+DgNVgLzB6Npd8cHy0Yszp4I1Znvc3XJiY4pA/ZldXD6sYGs7JZDcmOtX+1j
         h4KAKQr0D0T9ZPHP/AWCJSFuwVqryx8ArZeY9LcVEbQxDL4kVvAy25i3vHjjTRUdcTh7
         czJ/y0lhjIRzXdnVLl/uBx/PlpDyNrg/rcaqzKyHna0sNKaWTXxGDMn1yS03booBDTAt
         CENw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cDdtGqydhUlrmwu2LnW0CqWSMjmwrzYRsu4xa54SsdQ=;
        b=KyqvmCAqnRTegP6PaFPJE/7befIinBlCRSdoOfVTgdS/+s46Jma2dRmzTd6JGVMeGO
         9PzsFhWgCazB/bLJ6CwaX/pTwKqfI8RDBraZfkhAtNitcOVi9iVFkme3kQg7Y4/JKty/
         QMCV8XkpJWBfNToK5Hjx5JLTnx2GuoYyGecIkR/IwJ29rha2rgkR4uidBDViW6xpxvhF
         jKRpd33a/+cbEFd3Sn2TFQIJdl5WGQa6Zr5RD6r5lv3N9eXQqHrm0oeA0WX11Sw5FpQM
         EQt64qY6JaKNYhFlr2yrkqGQvba7GAQPmCguDFyKCkqjZvKmZHcElkf4ZgLus2j4cOvS
         RRTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IfQqpqlA;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor23967432jag.7.2019.03.22.14.24.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 14:24:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IfQqpqlA;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cDdtGqydhUlrmwu2LnW0CqWSMjmwrzYRsu4xa54SsdQ=;
        b=IfQqpqlAl9WxMim1njI9ZGtFN2KzkG2RyjbZz1s5kvqAwqNi55+x8Cd3G5PmfiVj+o
         VPJqJh+h6DnDUlbBCcN9ZLM8i9Hi4jnw3DwbpOI9/5iJnLBoo/j6bOc6G9eAt6L4xRWl
         KgWyciN4bk45V/2DOKDEpMF9kivqXX0NYVAUScLHJ4Lx8is/Qn2Qk1EV5Zur6MxptsP4
         91MdAULmbgQdfp8AXGVyzRIwc/ny1JQJiCAm6VjX+Qn9WpYsMDXhu8eIfoIgYCUvfB37
         yY/UMXHX1+BAZWA5N07NcC0HbWiiyoPrKD3to4v3FSUhrD9/1njznA2axS5EIBx4j/TK
         M3pA==
X-Google-Smtp-Source: APXvYqxseixB2ibq/MJ6bxUEBZWqxCwN2iB+ljxfYVPyfRlM5U9gn9G6F1HlfbfdPl5E5YSGfGb2gQ2GoPyTBHvlRRE=
X-Received: by 2002:a02:6d12:: with SMTP id m18mr9143951jac.54.1553289891728;
 Fri, 22 Mar 2019 14:24:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-2-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-2-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 14:24:40 -0700
Message-ID: <CAA9_cmffz1VBOJ0ykBtcj+hiznn-kbbuotu1uUhPiJtXiFjJXg@mail.gmail.com>
Subject: Re: [RESEND 1/7] mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
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
> Rather than have a separate get_user_pages_longterm() call,
> introduce FOLL_LONGTERM and change the longterm callers to use
> it.
>
> This patch does not change any functionality.
>
> FOLL_LONGTERM can only be supported with get_user_pages() as it
> requires vmas to determine if DAX is in use.
>
> CC: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
[..]
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2d483dbdffc0..6831077d126c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
[..]
> @@ -2609,6 +2596,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  #define FOLL_REMOTE    0x2000  /* we are working on non-current tsk/mm */
>  #define FOLL_COW       0x4000  /* internal GUP flag */
>  #define FOLL_ANON      0x8000  /* don't do file mappings */
> +#define FOLL_LONGTERM  0x10000 /* mapping is intended for a long term pin */

Let's change this comment to say something like /* mapping lifetime is
indefinite / at the discretion of userspace */, since "longterm is not
well defined.

I think it should also include a /* FIXME: */ to say something about
the havoc a long term pin might wreak on fs and mm code paths.

>  static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
>  {
> diff --git a/mm/gup.c b/mm/gup.c
> index f84e22685aaa..8cb4cff067bc 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1112,26 +1112,7 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL(get_user_pages_remote);
>
> -/*
> - * This is the same as get_user_pages_remote(), just with a
> - * less-flexible calling convention where we assume that the task
> - * and mm being operated on are the current task's and don't allow
> - * passing of a locked parameter.  We also obviously don't pass
> - * FOLL_REMOTE in here.
> - */
> -long get_user_pages(unsigned long start, unsigned long nr_pages,
> -               unsigned int gup_flags, struct page **pages,
> -               struct vm_area_struct **vmas)
> -{
> -       return __get_user_pages_locked(current, current->mm, start, nr_pages,
> -                                      pages, vmas, NULL,
> -                                      gup_flags | FOLL_TOUCH);
> -}
> -EXPORT_SYMBOL(get_user_pages);
> -
>  #if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
> -
> -#ifdef CONFIG_FS_DAX
>  static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
>  {
>         long i;
> @@ -1150,12 +1131,6 @@ static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
>         }
>         return false;
>  }
> -#else
> -static inline bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
> -{
> -       return false;
> -}
> -#endif
>
>  #ifdef CONFIG_CMA
>  static struct page *new_non_cma_page(struct page *page, unsigned long private)
> @@ -1209,10 +1184,13 @@ static struct page *new_non_cma_page(struct page *page, unsigned long private)
>         return __alloc_pages_node(nid, gfp_mask, 0);
>  }
>
> -static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
> -                                       unsigned int gup_flags,
> +static long check_and_migrate_cma_pages(struct task_struct *tsk,
> +                                       struct mm_struct *mm,
> +                                       unsigned long start,
> +                                       unsigned long nr_pages,
>                                         struct page **pages,
> -                                       struct vm_area_struct **vmas)
> +                                       struct vm_area_struct **vmas,
> +                                       unsigned int gup_flags)
>  {
>         long i;
>         bool drain_allow = true;
> @@ -1268,10 +1246,14 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
>                                 putback_movable_pages(&cma_page_list);
>                 }
>                 /*
> -                * We did migrate all the pages, Try to get the page references again
> -                * migrating any new CMA pages which we failed to isolate earlier.
> +                * We did migrate all the pages, Try to get the page references
> +                * again migrating any new CMA pages which we failed to isolate
> +                * earlier.
>                  */
> -               nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
> +               nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
> +                                                  pages, vmas, NULL,
> +                                                  gup_flags);
> +

Why did this need to change to __get_user_pages_locked?

>                 if ((nr_pages > 0) && migrate_allow) {
>                         drain_allow = true;
>                         goto check_again;
> @@ -1281,66 +1263,115 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
>         return nr_pages;
>  }
>  #else
> -static inline long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
> -                                              unsigned int gup_flags,
> -                                              struct page **pages,
> -                                              struct vm_area_struct **vmas)
> +static long check_and_migrate_cma_pages(struct task_struct *tsk,
> +                                       struct mm_struct *mm,
> +                                       unsigned long start,
> +                                       unsigned long nr_pages,
> +                                       struct page **pages,
> +                                       struct vm_area_struct **vmas,
> +                                       unsigned int gup_flags)
>  {
>         return nr_pages;
>  }
>  #endif
>
>  /*
> - * This is the same as get_user_pages() in that it assumes we are
> - * operating on the current task's mm, but it goes further to validate
> - * that the vmas associated with the address range are suitable for
> - * longterm elevated page reference counts. For example, filesystem-dax
> - * mappings are subject to the lifetime enforced by the filesystem and
> - * we need guarantees that longterm users like RDMA and V4L2 only
> - * establish mappings that have a kernel enforced revocation mechanism.
> + * __gup_longterm_locked() is a wrapper for __get_uer_pages_locked which

s/uer/user/

> + * allows us to process the FOLL_LONGTERM flag if present.
> + *
> + * FOLL_LONGTERM Checks for either DAX VMAs or PPC CMA regions and either fails
> + * the pin or attempts to migrate the page as appropriate.
> + *
> + * In the filesystem-dax case mappings are subject to the lifetime enforced by
> + * the filesystem and we need guarantees that longterm users like RDMA and V4L2
> + * only establish mappings that have a kernel enforced revocation mechanism.
> + *
> + * In the CMA case pages can't be pinned in a CMA region as this would
> + * unnecessarily fragment that region.  So CMA attempts to migrate the page
> + * before pinning.
>   *
>   * "longterm" == userspace controlled elevated page count lifetime.
>   * Contrast this to iov_iter_get_pages() usages which are transient.

Ah, here's the longterm documentation, but if I was a developer
considering whether to use FOLL_LONGTERM or not I would expect to find
the documentation at the flag definition site.

I think it has become more clear since get_user_pages_longterm() was
initially merged that we need to warn people not to use it, or at
least seriously reconsider whether they want an interface to support
indefinite pins.

>   */
> -long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
> -                            unsigned int gup_flags, struct page **pages,
> -                            struct vm_area_struct **vmas_arg)
> +static __always_inline long __gup_longterm_locked(struct task_struct *tsk,

...why the __always_inline?

