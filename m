Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69E8EC31E40
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18E8220C01
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:09:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="bpL5Ee4v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18E8220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A276B0005; Fri,  9 Aug 2019 20:09:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90A956B0006; Fri,  9 Aug 2019 20:09:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D3086B0007; Fri,  9 Aug 2019 20:09:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42D436B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 20:09:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w5so60649845pgs.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 17:09:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=6gNuzZAjPm1drI86ijnE4uQ1M9Dnne0kRHnh1Jmmh9I=;
        b=Tosy4o/+rSQrpUx4tQmXNxBRtUIqI47YMHT92RnPfeQPq51ACu/grKBUSAjhli43zP
         wJ/iadMNkJ80Ko+Xk6wlEr+734Fdto522LvXEjGF4Zo1vrD6uxZRe9lYoVKtCeV1NBJX
         3Ugx6pnlZJ3ryp+Xw6CULM/YARcx7jRrAdUwozg0FZUYEmYcNX1Z6NaAl8AAdzIyCUFd
         7gXhnvEAireCYDJoAR8jctKUsFMb1d2n9NVfd2dwqovFxD7ttok9Yr4LqvdztE0zR+s9
         vDjMMNM4/Hz2G9Xi4Phi1mVnfDmn60InKGkMpl0qlsppApXG7dwrah2B5drrJ8dfZKFs
         y+Dw==
X-Gm-Message-State: APjAAAXT9P9JvjIAtcT5OPZEFzMyhfTtD10mmYA5uKfM0OW1dY6Kbwse
	X6mYm0c4TCr0+Yqp7/308Xp4CP/b+8ubsRZnlXrZ3LqvLpkA0PmKIKQIrlsYhhNWhh9zq1BYhbA
	IpEEa6hacUApRHAYXNbFkOhyJPAaeNJ2mmqWCTlFoQtpzSu7oYTyD00P3Zt2Q9J3Txg==
X-Received: by 2002:aa7:9dcd:: with SMTP id g13mr24795782pfq.204.1565395796923;
        Fri, 09 Aug 2019 17:09:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9NnAh2xE+3KoJV6h60TzWUX8eqBrjDwUD1CRRd2q3L/r8deWd8Ee1TqYPj5Ui+C7CrOjr
X-Received: by 2002:aa7:9dcd:: with SMTP id g13mr24795715pfq.204.1565395796069;
        Fri, 09 Aug 2019 17:09:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565395796; cv=none;
        d=google.com; s=arc-20160816;
        b=Ug2eAJmlBgZU09ADHlPz1F8I0Oqe04D5EUtxFJjUvDYuhbIJ2FvfpnPiypqENytOkv
         NRFoTkoZygHiCk6cjHaEG+ZoEkOKZ+YBM3UBvpGDhOI9/l4Cxk9Wxi7gNbHge3UgYzDv
         uNtQ/YwQ5m6bxM3/AGzl+ldcPRS1gJB5jg6lxxAsGjzAh7Rwm/aDekenVxPKLvxwaMgo
         BvZBvY5ZfvuVwIhunQJt+vhnC4dccYTmoDfkk3+TeGj/6EwsS/aMoOGx+esagMx2TAKc
         IBXrc+ooTI+IHQ4os0SGWkKeu/tszJiMpp4CsC4PkskEzgJ97+lCPNvjfZTzAXTTbYLB
         zO+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=6gNuzZAjPm1drI86ijnE4uQ1M9Dnne0kRHnh1Jmmh9I=;
        b=hL+Q9sbhW7E0Ik3WGlh/RomgjoOnYvMQbVZ4KZjhHr+OlNTEMJhSiVaJ1QeBD2SCQP
         ceZCPcBN1XCxrhSFJbeG8t6rI5G/ju6KX++C6RGG+sRRkEBrsKEaPVBV7Fh8I82Sq1wt
         tYOj4RPWCW/9FwFTW6mLqkAPhD97VTOEFcwfrZsBE16+NlZhXfoOtXi8unTHNRfuLL5d
         p3Ddp/IpHyIwUwBtg0lhA1s6BAVTx7yNXImc6XGbyZodmnOTshBqB8eXkaY9gQRfT7JX
         0stMkInY5Jt3PtnCOrgn80njIbWiVOEs6h9JugjwQp1X2NWarsjGkWZeTyafZ47AR9B2
         0ogQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bpL5Ee4v;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s66si60386042pfs.120.2019.08.09.17.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 17:09:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bpL5Ee4v;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4e0b5d0000>; Fri, 09 Aug 2019 17:10:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 17:09:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 09 Aug 2019 17:09:55 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 10 Aug
 2019 00:09:55 +0000
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o
	<tytso@mit.edu>, Michal Hocko <mhocko@suse.com>, Dave Chinner
	<david@fromorbit.com>, <linux-xfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6ed26a08-4371-9dc1-09eb-7b8a4689d93b@nvidia.com>
Date: Fri, 9 Aug 2019 17:09:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809225833.6657-16-ira.weiny@intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565395806; bh=6gNuzZAjPm1drI86ijnE4uQ1M9Dnne0kRHnh1Jmmh9I=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=bpL5Ee4vSwNJx48EaIgEa1vW54C9BYxOuHJZXR2g0DimV8Jbzh9FRHk15PHeXZMt7
	 3/XIvkM/NZxoMCLKXrSswHltiMKCAoppMwLtn2BNcmUd0Lw2sUJvyJyIaxd/yXSjd3
	 LaYgfDzJsY3KevnitA9y+5kH//XcswK9sOikrJXKW9xfdNJxmtenjCD/AWehvcHIik
	 y5CZMfyYhk4QKlqgr+QjwyqQWwWhf7J8xk1xm0vY75awN4I9ewl+//BoHKekZfNLOK
	 ZxUnp+fBKdqhMrKGLYc8mXDRC+MO6XRKOuvv/2u6Q8pmbWfnTuoDHXlQnv60eq+LZw
	 O5Ypby3VqT9Wg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> The addition of FOLL_LONGTERM has taken on additional meaning for CMA
> pages.
> 
> In addition subsystems such as RDMA require new information to be passed
> to the GUP interface to track file owning information.  As such a simple
> FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.
> 
> Introduce a new GUP like call which takes the newly introduced vaddr_pin
> information.  Failure to pass the vaddr_pin object back to a vaddr_put*
> call will result in a failure if pins were created on files during the
> pin operation.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> 
> ---
> Changes from list:
> 	Change to vaddr_put_pages_dirty_lock
> 	Change to vaddr_unpin_pages_dirty_lock
> 
>  include/linux/mm.h |  5 ++++
>  mm/gup.c           | 59 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 64 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 657c947bda49..90c5802866df 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1603,6 +1603,11 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
>  int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
>  			struct task_struct *task, bool bypass_rlim);
>  
> +long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
> +		     unsigned int gup_flags, struct page **pages,
> +		     struct vaddr_pin *vaddr_pin);
> +void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> +				  struct vaddr_pin *vaddr_pin, bool make_dirty);

Hi Ira,

OK, the API seems fine to me, anyway. :)

A bit more below...

>  bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page);
>  
>  /* Container for pinned pfns / pages */
> diff --git a/mm/gup.c b/mm/gup.c
> index eeaa0ddd08a6..6d23f70d7847 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2536,3 +2536,62 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
> +
> +/**
> + * vaddr_pin_pages pin pages by virtual address and return the pages to the
> + * user.
> + *
> + * @addr, start address

What's with the commas? I thought kernel-doc wants colons, like this, right?

@addr: start address


> + * @nr_pages, number of pages to pin
> + * @gup_flags, flags to use for the pin
> + * @pages, array of pages returned
> + * @vaddr_pin, initalized meta information this pin is to be associated
> + * with.
> + *
> + * NOTE regarding vaddr_pin:
> + *
> + * Some callers can share pins via file descriptors to other processes.
> + * Callers such as this should use the f_owner field of vaddr_pin to indicate
> + * the file the fd points to.  All other callers should use the mm this pin is
> + * being made against.  Usually "current->mm".
> + *
> + * Expects mmap_sem to be read locked.
> + */
> +long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
> +		     unsigned int gup_flags, struct page **pages,
> +		     struct vaddr_pin *vaddr_pin)
> +{
> +	long ret;
> +
> +	gup_flags |= FOLL_LONGTERM;


Is now the right time to introduce and use FOLL_PIN? If not, then I can always
add it on top of this later, as part of gup-tracking patches. But you did point
out that FOLL_LONGTERM is taking on additional meaning, and so maybe it's better
to split that meaning up right from the start.


> +
> +	if (!vaddr_pin || (!vaddr_pin->mm && !vaddr_pin->f_owner))
> +		return -EINVAL;
> +
> +	ret = __gup_longterm_locked(current,
> +				    vaddr_pin->mm,
> +				    addr, nr_pages,
> +				    pages, NULL, gup_flags,
> +				    vaddr_pin);
> +	return ret;
> +}
> +EXPORT_SYMBOL(vaddr_pin_pages);
> +
> +/**
> + * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
> + *
> + * @pages, array of pages returned
> + * @nr_pages, number of pages in pages
> + * @vaddr_pin, same information passed to vaddr_pin_pages
> + * @make_dirty: whether to mark the pages dirty
> + *
> + * The semantics are similar to put_user_pages_dirty_lock but a vaddr_pin used
> + * in vaddr_pin_pages should be passed back into this call for propper

Typo:
                                                                  proper

> + * tracking.
> + */
> +void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> +				  struct vaddr_pin *vaddr_pin, bool make_dirty)
> +{
> +	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
> +}
> +EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
> 

OK, whew, I'm glad to see the updated _dirty_lock() API used here. :)

thanks,
-- 
John Hubbard
NVIDIA

