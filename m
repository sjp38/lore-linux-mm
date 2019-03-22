Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38C10C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:45:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E636B218FC
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:45:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E636B218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B0616B0006; Fri, 22 Mar 2019 11:45:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887F76B0007; Fri, 22 Mar 2019 11:45:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750BA6B0008; Fri, 22 Mar 2019 11:45:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25C9E6B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:45:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so1128780edd.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:45:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B7QLAOIspGi+pMZ0NRFiNxSwvLuzqH/UGMA7IIsPF0Q=;
        b=e9tkXA2YgQM3hHutW4Cdfz/IW8AzeXrsZWlZ+KS6UMV8tpzxpxgUCIz5fiZRzzNIuK
         ornmyE5AbS+iD/MGghnWvhRf08A4L3jzQ6bcKW1/L752LO0X912YQBHJFpfnfJg9Q2z5
         ptp64CIbjp+h+FBZZgZeKCFqMC+2fKCFtCDlGFsIE539imICCFZWjkkjz71O1v9ADFnu
         XxVUl9R+cQknL6m1mArV9tvh7elIay4CS7ValYpxnWRb/GvuRbsD8mFum4jaV7dZXxn1
         4DhEPsIPFzKn/YnkZYRouSbO6xqOQziojAmldZd/7afNqunKHh4yNmmnJ0r1lg4+jpiA
         VVHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWUmSNcz29lnrdpI0lOa4OisuEvylDsoFDvJb335vXzSZhCYP6L
	FAyaUIzsD01yQG7RV2QnCnIQTsVuvoZRVZTVz9urLR/zAzO4UaVR41v/Ne7EOVCnD+lSFeQyzQf
	fwgAC8csV3zFSX6fLeq50+aA58Vx9RrhdquHhqwWpaEBM7ZTrPm6aLHerfPGdSFK/OA==
X-Received: by 2002:a17:906:d0cb:: with SMTP id bq11mr5968999ejb.185.1553269526705;
        Fri, 22 Mar 2019 08:45:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6iJ8oOwbN3zVQdWX2YTIvgs3CPmnyAb66xxw7MBZYtoHyn/YpG9C3q5tGQ7avjMDgYgkA
X-Received: by 2002:a17:906:d0cb:: with SMTP id bq11mr5968962ejb.185.1553269525826;
        Fri, 22 Mar 2019 08:45:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269525; cv=none;
        d=google.com; s=arc-20160816;
        b=kvC5AqBtvvu4CbPrnR1os9TgoSo1PQkbUGdATZTfUJnGZQ1b8AkqVPxomEiiZOJUAV
         KJuwRSnd2z8m6JJ/t1+5p4Y2WP/QhdeQls5bofkiuRwap3fF0TrGqZP04ry4Et+jHluu
         qFpZ9adX9dPdcCcxGqCGsJ/FyCwp068UUhB0wBYN7gFukJG+EzcAgEvHkLvgz9Z0QBrk
         vKB6ZG8nyU0TC34mo5eyl+JN0fENFBpcdnLs7wVq8uVnQRGp+KwdmMsVcfQZgwYNa2L2
         yqbNBgvjVNSOxxQSKCjXjsI8tGCxU/yjzBZcvnde4WOTF58/PdqqCBCir/JChSjd+wYM
         ebOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B7QLAOIspGi+pMZ0NRFiNxSwvLuzqH/UGMA7IIsPF0Q=;
        b=v7OTZco0qpe6cJdH8J3n6SWOpNtsuxOBenFB3JHax48JWWAjkqTmwXGziOKJqYAPLo
         3XEVqiAXGanAUsCVP6ZWp65rdShOYOY47+9VqziIRWBTpWUAAx/XejTgY1gyMgKvjsiA
         51EUcWB/8IQdNNEebGSTI/FHFkcKGAXPLRU2qELdkoG8tXVQqo2aFYmHpUGnRQWWa4er
         CAlCKNlLHXZsHrenj1FADwUlXK87ttN9IKKYy7fMW717xAw55FuDsKZl0cXWeQDy6PvE
         43wud/cNvJqsZjHS1OS59Kw8y1pKO8+DXZY+quv68pmWbywhHbdvUFIczBFFn0baeJtU
         jgNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s4si163706edx.79.2019.03.22.08.45.25
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 08:45:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7227BA78;
	Fri, 22 Mar 2019 08:45:24 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 896833F59C;
	Fri, 22 Mar 2019 08:45:16 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:45:14 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 11/20] tracing, arm64: untag user pointers in
 seq_print_user_ip
Message-ID: <20190322154513.GQ13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <c9553c3a4850d43c8af0c00e97850d70428b7de7.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9553c3a4850d43c8af0c00e97850d70428b7de7.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:25PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> seq_print_user_ip() uses provided user pointers for vma lookups, which
> can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  kernel/trace/trace_output.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> index 54373d93e251..6376bee93c84 100644
> --- a/kernel/trace/trace_output.c
> +++ b/kernel/trace/trace_output.c
> @@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  {
>  	struct file *file = NULL;
>  	unsigned long vmstart = 0;
> +	unsigned long untagged_ip = untagged_addr(ip);
>  	int ret = 1;
>  
>  	if (s->full)
> @@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  		const struct vm_area_struct *vma;
>  
>  		down_read(&mm->mmap_sem);
> -		vma = find_vma(mm, ip);
> +		vma = find_vma(mm, untagged_ip);
>  		if (vma) {
>  			file = vma->vm_file;
>  			vmstart = vma->vm_start;
> @@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  			ret = trace_seq_path(s, &file->f_path);
>  			if (ret)
>  				trace_seq_printf(s, "[+0x%lx]",
> -						 ip - vmstart);
> +						 untagged_ip - vmstart);
>  		}
>  		up_read(&mm->mmap_sem);
>  	}

How would we end up with a tagged address here? Does "ip" here imply
instruction pointer, which we wouldn't tag?

-- 
Catalin

