Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82A48C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FEFB20815
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FEFB20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9BE66B0005; Thu, 16 May 2019 09:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4D2B6B0006; Thu, 16 May 2019 09:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D246B0007; Thu, 16 May 2019 09:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 648706B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:30:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e21so5378636edr.18
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zHQ039qY1F+Z+OQ3CtCeOzW33RtkcjUGdqX+BDVEYos=;
        b=abcSijhFAJWyBc3cGjCvWJhM4MdpxylfV/T9FMUei7nBWYB5gCk3DKCa3p5dNK+ip1
         +w+0oyuYp9xz/muDp2CnRspScVemMt25sq6Rc80eRNaq6jMTSn9sFNKLlIyzbtNppAEt
         YSSmZx68SkEeBk/AP7cGL+OaRHUWD8xKJ6pDKqKkCdqg40XGBi8upPPKG7Yj4/WJr3s1
         083JSqyAEEy4FBInpM4DB/IGAgEv660FYDgEZT5bXnlNorVABDokXScdSBprDjK240Kq
         jTrDU3GG9uWyXqvVN41nuVwBPeTEfbEUn7p88J/FmyDoWUqcyOn9WrNlvG8zbW9MjfEt
         drGw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVtyMGXxZXSN52jWjZFm6vlMzA2x50aFlNLYrzlJs8pl+vOV85y
	1ncZx3bPUat+/xf0Px6KY84YtPeK9jy39t1W/I2A7itKTI1eTmiDODTYkJfBO630WuCC37uGC3c
	wv1krmjuVjQFcpxtCwVVWc34rUyyrzIkGB8bP+pGa6NffAFx2qyOLIaUrgQv5QRw=
X-Received: by 2002:a17:906:5d12:: with SMTP id g18mr26389117ejt.286.1558013443930;
        Thu, 16 May 2019 06:30:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbP39Yf0tukE1iG0fhDg1unVjUBUnxqrkJbkaAQt+6z34Y3D47kfdztgSjlr8QV41lDKVm
X-Received: by 2002:a17:906:5d12:: with SMTP id g18mr26389020ejt.286.1558013442912;
        Thu, 16 May 2019 06:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558013442; cv=none;
        d=google.com; s=arc-20160816;
        b=znYbLaq/EBv3TVJ/yMiNATcFtwNUVZAAs7z6z/9S6zU9u1X/oUZq+yyMRvpL5naYx5
         MDaCPZTBx2aQOQXyafQ+AwSe5u1g/yvdmKlEUx5SJWpnwxNKadpTlEz9S8b8moInO8js
         agcek0rApPpLAj6yMizzTYrSUN456j6GFObmxGe49aNYOwmcP8jbWICKKG1tDSTbLKCr
         5DqrpSLi+TM1ZIn4ZjXPV0ZNEUomdVJAMqx7907WMd/cMp3omKTta45krLYh7j2BnXLL
         yNCeM7BrSKUAVZ8WvjG2baIRzXrol1E95Nhxyo3MJobffsAzHCeuJc5JctVvL2Q6KpUO
         lGTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zHQ039qY1F+Z+OQ3CtCeOzW33RtkcjUGdqX+BDVEYos=;
        b=e5+saO8ZumJrJyqnYs1w5YI1Bqxr6Pu3yX2UI5i/prUptmRM4FiH1LwUns+uYVR5bc
         b17vesoHGJe8r8JDzZQ9I2sphp5JDH7BEXwi31J0NF17mKK5RHmJ21oYVJ48C+u+JqWz
         Ibo6B5cNqp2hOCAClzmgv8xWRT1wATxZdySwNC9aDWneePJS/MaxlujYhIlPdM2JsOyT
         ahV6g3Y7DpFDvsJm25xFu4nK/lUIn7NUK8sEXGtW/5V6NCxstDYPfu1Exib6OPT+jqyv
         occV6keFiKKn7lGlGUNghvqjZDL4Nt4i0BnWxkwuE/nOIRBTR+pPhS8tzWc/9PYBTxVC
         qp2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3si697902ejb.94.2019.05.16.06.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:30:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B1F27AD7B;
	Thu, 16 May 2019 13:30:41 +0000 (UTC)
Date: Thu, 16 May 2019 15:30:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
	ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
	vbabka@suse.cz, cl@linux.com, riel@surriel.com,
	keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190516133034.GT16651@dhcp22.suse.cz>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[You are defining a new user visible API, please always add linux-api
 mailing list - now done]

On Wed 15-05-19 18:11:15, Kirill Tkhai wrote:
> This patchset adds a new syscall, which makes possible
> to clone a mapping from a process to another process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.
> 
> For example, it allows to make a zero copy of data,
> when process_vm_writev() was previously used:
> 
> 	struct iovec local_iov, remote_iov;
> 	void *buf;
> 
> 	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
> 		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
> 	recv(sock, buf, n * PAGE_SIZE, 0);
> 
> 	local_iov->iov_base = buf;
> 	local_iov->iov_len = n * PAGE_SIZE;
> 	remove_iov = ...;
> 
> 	process_vm_writev(pid, &local_iov, 1, &remote_iov, 1 0);
> 	munmap(buf, n * PAGE_SIZE);
> 
> 	(Note, that above completely ignores error handling)
> 
> There are several problems with process_vm_writev() in this example:
> 
> 1)it causes pagefault on remote process memory, and it forces
>   allocation of a new page (if was not preallocated);
> 
> 2)amount of memory for this example is doubled in a moment --
>   n pages in current and n pages in remote tasks are occupied
>   at the same time;
> 
> 3)received data has no a chance to be properly swapped for
>   a long time.
> 
> The third is the most critical in case of remote process touches
> the data pages some time after process_vm_writev() was made.
> Imagine, node is under memory pressure:
> 
> a)kernel moves @buf pages into swap right after recv();
> b)process_vm_writev() reads the data back from swap to pages;
> c)process_vm_writev() allocates duplicate pages in remote
>   process and populates them;
> d)munmap() unmaps @buf;
> e)5 minutes later remote task touches data.
> 
> In stages "a" and "b" kernel submits unneeded IO and makes
> system IO throughput worse. To make "b" and "c", kernel
> reclaims memory, and moves pages of some other processes
> to swap, so they have to read pages from swap back. Also,
> unneeded copying of pages is occured, while zero-copy is
> more preferred.
> 
> We observe similar problem during online migration of big enough
> containers, when after doubling of container's size, the time
> increases 100 times. The system resides under high IO and
> throwing out of useful cashes.
> 
> The proposed syscall aims to introduce an interface, which
> supplements currently existing process_vm_writev() and
> process_vm_readv(), and allows to solve the problem with
> anonymous memory transfer. The above example may be rewritten as:
> 
> 	void *buf;
> 
> 	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
> 		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
> 	recv(sock, buf, n * PAGE_SIZE, 0);
> 
> 	/* Sign of @pid is direction: "from @pid task to current" or vice versa. */
> 	process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
> 	munmap(buf, n * PAGE_SIZE);
> 
> It is swap-friendly: in case of memory is swapped right after recv(),
> the syscall just copies pagetable entries like we do on fork(),
> so real access to pages does not occurs, and no IO is needed.
> No excess pages are reclaimed, and number of pages is not doubled.
> Also, zero-copy takes a place, and this also reduces overhead.
> 
> The patchset does not introduce much new code, since we simply
> reuse existing copy_page_range() and copy_vma() functions.
> We extend copy_vma() to be able merge VMAs in remote task [2/5],
> and teach copy_page_range() to work with different local and
> remote addresses [3/5]. Patch [5/5] introduces the syscall logic,
> which mostly consists of sanity checks. The rest of patches
> are preparations.
> 
> This syscall may be used for page servers like in example
> above, for migration (I assume, even virtual machines may
> want something like this), for zero-copy desiring users
> of process_vm_writev() and process_vm_readv(), for debug
> purposes, etc. It requires the same permittions like
> existing proc_vm_xxx() syscalls have.
> 
> The tests I used may be obtained here:
> 
> [1]https://gist.github.com/tkhai/198d32fdc001ec7812a5e1ccf091f275
> [2]https://gist.github.com/tkhai/f52dbaeedad5a699f3fb386fda676562
> 
> ---
> 
> Kirill Tkhai (5):
>       mm: Add process_vm_mmap() syscall declaration
>       mm: Extend copy_vma()
>       mm: Extend copy_page_range()
>       mm: Export round_hint_to_min()
>       mm: Add process_vm_mmap()
> 
> 
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 
>  arch/x86/entry/syscalls/syscall_64.tbl |    2 
>  include/linux/huge_mm.h                |    6 +
>  include/linux/mm.h                     |   11 ++
>  include/linux/mm_types.h               |    2 
>  include/linux/mman.h                   |   14 +++
>  include/linux/syscalls.h               |    5 +
>  include/uapi/asm-generic/mman-common.h |    5 +
>  include/uapi/asm-generic/unistd.h      |    5 +
>  init/Kconfig                           |    9 +-
>  kernel/fork.c                          |    5 +
>  kernel/sys_ni.c                        |    2 
>  mm/huge_memory.c                       |   30 ++++--
>  mm/memory.c                            |  165 +++++++++++++++++++++-----------
>  mm/mmap.c                              |  154 ++++++++++++++++++++++++++----
>  mm/mremap.c                            |    4 -
>  mm/process_vm_access.c                 |   71 ++++++++++++++
>  17 files changed, 392 insertions(+), 99 deletions(-)
> 
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

-- 
Michal Hocko
SUSE Labs

