Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51861C48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CC2B2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:29:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bWZIWH1K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CC2B2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85FF06B0005; Thu, 20 Jun 2019 10:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 810818E0003; Thu, 20 Jun 2019 10:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FFE28E0001; Thu, 20 Jun 2019 10:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39C816B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:29:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q14so421643pff.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:29:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/aZGDRAVyAV6lIE0ILnXOjAyIfIPtC0RGIBK6ejA8qE=;
        b=Mi6sFOzFZDR2GOTv7vBffcdIcEYGSWWLG4/3nfSjwC2U9gbKGMjLxDcrHD5e+GPDrE
         Rk/w6yzE8cxRRNtrXxZlapD43GFX/zA+VyZnFYlOWRkFkb4uQqQkLQtmKftBTeiDdDsT
         PmIlsoUVVvRPkMX62wgAwPwlX1EaLNJM/ubbbP7sdk5KlJlGHfudl+FlekP8V5BKVBgD
         WSvR67XrTJKvH+g3NxL/0Crz5Yf04OdvR3LEx/wMJkCPYWg3JMX0AOU4ukRqnbitTWE4
         lo+tr/0gd19ZdBpu3dNf9WG8raoVBC1rMfrvDwKkBBl1QrlfdDB6v8dGnCVd8QjsMgdG
         seVA==
X-Gm-Message-State: APjAAAUZPoEN0UEUTdyu8+lDuw2Lqyv/rEoOpYy9eOHv90xgIIJJriIG
	Nk663TctqcWQlCPyh/PwF8Jgt4jEPrnPqGA265Q5U23KurEmwygGV9kVswDBmO9/zK+feNZhLIM
	cfcKMkeAprO3jjkqAAlI9+ZI5Wx7MM3SKK3ARedaBgGAEU9VQbDP1GfceXGoGlyl8BQ==
X-Received: by 2002:a17:90a:7107:: with SMTP id h7mr3370034pjk.38.1561040961847;
        Thu, 20 Jun 2019 07:29:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjAGpztK2XNhNtmD6On9/NqJolJ5ngh7+V0Tjz0es7RLjlvt8q7sLnXRJUNsExxL6hhp9x
X-Received: by 2002:a17:90a:7107:: with SMTP id h7mr3369962pjk.38.1561040960857;
        Thu, 20 Jun 2019 07:29:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561040960; cv=none;
        d=google.com; s=arc-20160816;
        b=Zpx9teptGsxubR0X2vTlRoFpBPPqE+/8D3XTCZ/zL29kkIgNqu0KlR+nYU9y7FMx9Y
         vBIbWJtQlJAIzDpueDUC3vFjGbD5qJrWwUYbrSklWAMY1I/zd0iKTRJvBOUcx9G48Tjy
         vugtBsag3aJEkQvSBw0vldJjCYMwQ6qdFD5QWZ5KeY6vFfT+4N/wccyWnc1tnVflkdz7
         xYwDG9z0D5DFGf/fZeh2xYUNoPPxyb2xHDbrIEAAtz5PQxhhROTY+8gtv6IA8k+sEjlG
         ucxHCKimRTUE4wkYotW+Sc/3rt2OQ1DNtsom5sCPecxLuZxcAn/HZTQmR20E+vk1BB0x
         +LBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/aZGDRAVyAV6lIE0ILnXOjAyIfIPtC0RGIBK6ejA8qE=;
        b=tbj51G+X6CdVCFMOgs5F9/MV1KhxxelhTkQ8QhRCGPXrwjjztA8AahTcaCo+t8l8ck
         tA6W8BZv14AE56uP4W0AvAdJHIrKGMhRSKa8fMIAgjCsW8qtE1B2sfkmGG2zN0lBmvDx
         YIIU0viRr23XVRZw3DQ5tmnXodO2ASFlCti71WWAjxvVszSc3yvpazHPjb4HjqadCR6j
         RV6GnYp/pTE4VH+1iNnpqI9CilNs4IN36cDQbcRtC7GOijYCASKv3TpmlUkfKQNqB0ba
         T/OimJsbGLIQyOv9A1mDs//ot2UJe39tIOCKw7LCBG2iiEit1TCKHv/xkpdkGd6yII87
         /+sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bWZIWH1K;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w17si20737725pfj.69.2019.06.20.07.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:29:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bWZIWH1K;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 017FD206E0;
	Thu, 20 Jun 2019 14:29:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561040960;
	bh=jGmcXFeW7D8HKNyL/7thTeEj0zTlF5U4/cIcsDDUCcE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=bWZIWH1KS7f4YtgkdDQ1w1wqZnbknVtlEjsKM3/0EvS2BVM9DQEtY3E8AbvcgmQ5j
	 +9V/tRmfj/fFD1RtgIAerM3bvwacNNtvsKzpzC+csNmLj2Oy1HYI3wIAn8J0Eddrl6
	 qA8Hk0xtO2X6F75FZY+zij/t168hRiOm0RZ10QK0=
Date: Thu, 20 Jun 2019 16:29:18 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH stable-4.4 v3] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Message-ID: <20190620142918.GE9832@kroah.com>
References: <20190610074635.2319-1-mhocko@kernel.org>
 <20190617065824.28305-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617065824.28305-1-mhocko@kernel.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 08:58:24AM +0200, Michal Hocko wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Upstream 04f5866e41fb70690e28397487d8bd8eea7d712a commit.
> 
> The core dumping code has always run without holding the mmap_sem for
> writing, despite that is the only way to ensure that the entire vma
> layout will not change from under it.  Only using some signal
> serialization on the processes belonging to the mm is not nearly enough.
> This was pointed out earlier.  For example in Hugh's post from Jul 2017:
> 
>   https://lkml.kernel.org/r/alpine.LSU.2.11.1707191716030.2055@eggly.anvils
> 
>   "Not strictly relevant here, but a related note: I was very surprised
>    to discover, only quite recently, how handle_mm_fault() may be called
>    without down_read(mmap_sem) - when core dumping. That seems a
>    misguided optimization to me, which would also be nice to correct"
> 
> In particular because the growsdown and growsup can move the
> vm_start/vm_end the various loops the core dump does around the vma will
> not be consistent if page faults can happen concurrently.
> 
> Pretty much all users calling mmget_not_zero()/get_task_mm() and then
> taking the mmap_sem had the potential to introduce unexpected side
> effects in the core dumping code.
> 
> Adding mmap_sem for writing around the ->core_dump invocation is a
> viable long term fix, but it requires removing all copy user and page
> faults and to replace them with get_dump_page() for all binary formats
> which is not suitable as a short term fix.
> 
> For the time being this solution manually covers the places that can
> confuse the core dump either by altering the vma layout or the vma flags
> while it runs.  Once ->core_dump runs under mmap_sem for writing the
> function mmget_still_valid() can be dropped.
> 
> Allowing mmap_sem protected sections to run in parallel with the
> coredump provides some minor parallelism advantage to the swapoff code
> (which seems to be safe enough by never mangling any vma field and can
> keep doing swapins in parallel to the core dumping) and to some other
> corner case.
> 
> In order to facilitate the backporting I added "Fixes: 86039bd3b4e6"
> however the side effect of this same race condition in /proc/pid/mem
> should be reproducible since before 2.6.12-rc2 so I couldn't add any
> other "Fixes:" because there's no hash beyond the git genesis commit.
> 
> Because find_extend_vma() is the only location outside of the process
> context that could modify the "mm" structures under mmap_sem for
> reading, by adding the mmget_still_valid() check to it, all other cases
> that take the mmap_sem for reading don't need the new check after
> mmget_not_zero()/get_task_mm().  The expand_stack() in page fault
> context also doesn't need the new check, because all tasks under core
> dumping are frozen.
> 
> Link: http://lkml.kernel.org/r/20190325224949.11068-1-aarcange@redhat.com
> Fixes: 86039bd3b4e6 ("userfaultfd: add new syscall to provide memory externalization")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Jann Horn <jannh@google.com>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: Peter Xu <peterx@redhat.com>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> Reviewed-by: Oleg Nesterov <oleg@redhat.com>
> Reviewed-by: Jann Horn <jannh@google.com>
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Joel Fernandes (Google) <joel@joelfernandes.org>
> [mhocko@suse.com: stable 4.4 backport
>  - drop infiniband part because of missing 5f9794dc94f59
>  - drop userfaultfd_event_wait_completion hunk because of
>    missing 9cd75c3cd4c3d]
>  - handle binder_update_page_range because of missing 720c241924046
>  - handle mlx5_ib_disassociate_ucontext - akaher@vmware.com
> ]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/android/binder.c          |  6 ++++++
>  drivers/infiniband/hw/mlx4/main.c |  3 +++
>  fs/proc/task_mmu.c                | 18 ++++++++++++++++++
>  fs/userfaultfd.c                  | 10 ++++++++--
>  include/linux/mm.h                | 21 +++++++++++++++++++++
>  mm/mmap.c                         |  7 ++++++-
>  6 files changed, 62 insertions(+), 3 deletions(-)

I've queued this up now, as it looks like everyone agrees with it.  What
about a 4.9.y backport?

thanks,

greg k-h

