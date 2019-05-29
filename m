Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B46C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:04:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0792402A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:04:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0792402A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 779246B0266; Wed, 29 May 2019 14:04:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 703346B026A; Wed, 29 May 2019 14:04:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57C5A6B026B; Wed, 29 May 2019 14:04:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB856B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:04:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c3so2059630plr.16
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:04:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6pwKEIjHhhdYh2aV+QDVDoOKT+9lEeGbCVsj5xLoLt8=;
        b=GjWznzEb7yGOiboBHEutFmHjzC+Ww2RAyARkW3EyYvbTi3Rn3d340VackomnNYzhqL
         cSKqUMoiv46z0mB/TlU5A4zUh/E7GjFC+yZf5q5lTS7Q/U1k1BbCa7ZxKu04RdgVR8M6
         XxzPAFnSDc7i7x05yyBN61M2CJTecHmqlCPYHEkTKjyFFHcgZPmmCzyPrmpQsQYEOI7Z
         LHMrtLKrPh3RkpNfnJ8ymwMOD6okaV2BWlMbKusPOyxsym6mzcliX5M0LEopqyNvHY0t
         5EQ/Iq188t2UC3ShRgfXl2xGC3mS//3oPu9K6he8IhKDql+peVE8rWbc4EM8YILbUKJW
         U10Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV5/lpFfXrbi5+bpXJzIzVprxUsyGrSlooHTyIwh3czBZasxgIL
	ljRZr7QCgO/4yT8W1qjoUbSywhvaPH85Xc0x5vHmqwEUGCGKF4Zu19N408epPGLKaktmrI6CXiM
	dvieQlW9+sTFlAquRhppCcLLLqEdhufcJFoBKvSCgoTE/VOcwYFHb1/WpIZJiu4rr/w==
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr14011948pjr.106.1559153090621;
        Wed, 29 May 2019 11:04:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZuQiw3yc12rGLnycRAx2GzY4IxBdofIiB7oZW0KjCu7qBgMpfS+9msk6IE/O17SQUCFIM
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr14011773pjr.106.1559153089179;
        Wed, 29 May 2019 11:04:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559153089; cv=none;
        d=google.com; s=arc-20160816;
        b=v3FUQ3YA0OvyYTmN2QjusOd9f1xn9H8njsUIfQJm/0/HDligeDJBqGeb1C5WdZxFyN
         7oTi6tX5NW/ABu6MnG+4Wb6S6ezyJDf+YjPukFHinnieWwi2rA+NZctcVh1z6D1izHhq
         c5aeQGFf8WpCUiU4Eo6NJSZ/Bf7gW80LvIKnnGTTgMaJcILIDXedYvPjx2PJZWiYP3RA
         axxU4uf1zU+Gd9PMfIOvmq/h4+8yaLX9DxAGZiRh6GmGKD60Xzzv4jH913+wZzxlnK/t
         WqcXjRyG3hOqT8ZsDspL+klKmEvftE/vjd8OE+8pHsM4rIJlMG9OyzLCC/nyJHPKINII
         TK+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6pwKEIjHhhdYh2aV+QDVDoOKT+9lEeGbCVsj5xLoLt8=;
        b=hEvTDtrVL76A8zQwUCm3GnaYjJU0uo3a9+RFug7IuqMx3ZKq02nwRvqc761eT1eJK7
         1qQN8cB+epI2FmEamaPwaaVO7kWKRU5kZ5TmSHgRL3MV8yHWS7hnMsgBQw9PaCBqtNQl
         jocLomRRRCx0NboCc4wjQStdvys/ji3WbShpsX2CUiggZevb+In0wIs1ahF+Zr+9amy+
         eeYfQ5I6lfnYsg5zBkhTGMyBpNMPQRs2NjKg/IrGx+F3CFfYU22MiwRxSNNwsGXf0G6Z
         XG9uyPrUrFhfuJyQqgFUJ6ezO6FyFZLq22onlu1nQ3u+EjCmvTBnKEOY1I9Zez8xvNMH
         pTog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a13si414319pgl.508.2019.05.29.11.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:04:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 11:04:48 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 29 May 2019 11:04:46 -0700
Date: Wed, 29 May 2019 11:05:48 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>,
	Alan Tull <atull@kernel.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Lameter <cl@linux.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Moritz Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>,
	Steve Sistare <steven.sistare@oracle.com>,
	Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: add account_locked_vm utility function
Message-ID: <20190529180547.GA16182@iweiny-DESK2.sc.intel.com>
References: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
 <20190524175045.26897-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524175045.26897-1-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 01:50:45PM -0400, Daniel Jordan wrote:

[snip]

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..72c1034d2ec7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1564,6 +1564,25 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  int get_user_pages_fast(unsigned long start, int nr_pages,
>  			unsigned int gup_flags, struct page **pages);
>  
> +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> +			struct task_struct *task, bool bypass_rlim);
> +
> +static inline int account_locked_vm(struct mm_struct *mm, unsigned long pages,
> +				    bool inc)
> +{
> +	int ret;
> +
> +	if (pages == 0 || !mm)
> +		return 0;
> +
> +	down_write(&mm->mmap_sem);
> +	ret = __account_locked_vm(mm, pages, inc, current,
> +				  capable(CAP_IPC_LOCK));
> +	up_write(&mm->mmap_sem);
> +
> +	return ret;
> +}
> +
>  /* Container for pinned pfns / pages */
>  struct frame_vector {
>  	unsigned int nr_allocated;	/* Number of frames we have space for */
> diff --git a/mm/util.c b/mm/util.c
> index e2e4f8c3fa12..bd3bdf16a084 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -6,6 +6,7 @@
>  #include <linux/err.h>
>  #include <linux/sched.h>
>  #include <linux/sched/mm.h>
> +#include <linux/sched/signal.h>
>  #include <linux/sched/task_stack.h>
>  #include <linux/security.h>
>  #include <linux/swap.h>
> @@ -346,6 +347,51 @@ int __weak get_user_pages_fast(unsigned long start,
>  }
>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
>  
> +/**
> + * __account_locked_vm - account locked pages to an mm's locked_vm
> + * @mm:          mm to account against, may be NULL

This kernel doc is wrong.  You dereference mm straight away...

> + * @pages:       number of pages to account
> + * @inc:         %true if @pages should be considered positive, %false if not
> + * @task:        task used to check RLIMIT_MEMLOCK
> + * @bypass_rlim: %true if checking RLIMIT_MEMLOCK should be skipped
> + *
> + * Assumes @task and @mm are valid (i.e. at least one reference on each), and
> + * that mmap_sem is held as writer.
> + *
> + * Return:
> + * * 0       on success
> + * * 0       if @mm is NULL (can happen for example if the task is exiting)
> + * * -ENOMEM if RLIMIT_MEMLOCK would be exceeded.
> + */
> +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> +			struct task_struct *task, bool bypass_rlim)
> +{
> +	unsigned long locked_vm, limit;
> +	int ret = 0;
> +
> +	locked_vm = mm->locked_vm;

here...

Perhaps the comment was meant to document account_locked_vm()?  Or should the
parameter checks be moved here?

Ira

> +	if (inc) {
> +		if (!bypass_rlim) {
> +			limit = task_rlimit(task, RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> +			if (locked_vm + pages > limit)
> +				ret = -ENOMEM;
> +		}
> +		if (!ret)
> +			mm->locked_vm = locked_vm + pages;
> +	} else {
> +		WARN_ON_ONCE(pages > locked_vm);
> +		mm->locked_vm = locked_vm - pages;
> +	}
> +
> +	pr_debug("%s: [%d] caller %ps %c%lu %lu/%lu%s\n", __func__, task->pid,
> +		 (void *)_RET_IP_, (inc) ? '+' : '-', pages << PAGE_SHIFT,
> +		 locked_vm << PAGE_SHIFT, task_rlimit(task, RLIMIT_MEMLOCK),
> +		 ret ? " - exceeded" : "");
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(__account_locked_vm);
>

> +
>  unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long prot,
>  	unsigned long flag, unsigned long pgoff)
> 
> base-commit: a188339ca5a396acc588e5851ed7e19f66b0ebd9
> -- 
> 2.21.0
> 

