Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4273CC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:27:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F23D92173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:27:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F23D92173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 852D46B0003; Mon, 20 May 2019 20:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 802B16B0005; Mon, 20 May 2019 20:27:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 718606B0006; Mon, 20 May 2019 20:27:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C32D6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 20:27:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g38so10810049pgl.22
        for <linux-mm@kvack.org>; Mon, 20 May 2019 17:27:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Bdh4ARbVEy4Dgnb4xkh/7BqCk7LSLNG8IV293eCHH+Y=;
        b=lBmhIOFvxEJwHuw/lrZkuRkQUn5p01JGrWZHMGaHAemHy0V4pbwQHRDFhtpCIxR/vC
         0/JfZrsxcNhBTnNWfPT4iu2y9gbvSaXHX01gCzo4RY/SD+O1Mp9Mi0zWoCHEfh7uROBL
         FpfEsr992onKN4cTEJZvrUK5hmHuuxVwouVr/0Rxm+qTFDMxWNBQc25hwcabO6D4ve3T
         iky7jc9wWgkrebL7GuDmTYkiH3v16/AwOuzNo2NghtdeSOB2cTAfqy++Qt84RfAHW3L0
         +meb/0sy6vOenc9SSaK6Ox/LHNdRnJO3+qt+m1xUNo/F71ZXuM7YFdNNHnNZPKm+fgLp
         QPvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXy+DXq7stuDmNB/cz520Az74gRJzHlt9Nvs42ymvCOrdGtk1NC
	JMXurVJYOY532xBRalKsxwrM038M5QOWI10AP8QlKuwn1JMt2CrpEq5h9sqdovcZlFDI5Od39gy
	SO+3Ip/8SkXWrfO6mijXPH2C10bIzGUbv3HFmmQscQkHMcgKLLvufb14Rxt8LsyNhQw==
X-Received: by 2002:a62:5581:: with SMTP id j123mr84331154pfb.102.1558398459910;
        Mon, 20 May 2019 17:27:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJK+JYBSusRB6NCXZajsqf+BwPbpDODZnj2p8qFDLz+iwEXkLTsTPFmNKxX6oPAkeMjtrB
X-Received: by 2002:a62:5581:: with SMTP id j123mr84331092pfb.102.1558398459075;
        Mon, 20 May 2019 17:27:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558398459; cv=none;
        d=google.com; s=arc-20160816;
        b=TWBakqmS6usmrlsTWy+RWkzOO4H8Ug4/gN4ezjsetzAcdvwLOZX9M0T4ygxM7Assa8
         BDN6Yi9tk35vzfffsk7Kewx+i2KSPJ3m3mjbYuPtDK8HYicRuKMBwTurVj0GATZ9xc14
         dOMhlrv2Ab80IeelTZ7rha7SWlAgVPqOLMV4itO+wneCpOfkz4Toe17nusBfGD2SvTdz
         ER4IKfRtH/EvCC4FJkJ44IRcOjPuuBFu2RZcm/tL+ihUcc92SNKS5vBivNcRCu0yhUYr
         lt0klBGTA+HcyAIZPLWAADBscxm1SFL4sm5rEK5qsCY7DJ5jriLtZUea6hQ80xub2WM8
         xOXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Bdh4ARbVEy4Dgnb4xkh/7BqCk7LSLNG8IV293eCHH+Y=;
        b=QTQqtoiVz8yDZ4HowDh2/IrnUkIiHU8Q6M9NXrqCSVgYHFmZ1iE5F0jJMqK0Ga0DJw
         rS9diU2PpOE3eXd9hGoqXZYNmRCWW/EWgBWEIh8+1ciXON8f3KNxL0tQQwDTVQTO2j25
         sTBYl2+/eF+XCkud6/2NS0KGsMT7zoeQja826kws8EvrhE3lUB1B2AKW4fTE4qM9GPL6
         3PB6iMQ0TOMjL3OJNadoWkc1U11zqtgaVSAkN6waHqtcZcnQO0HxERz6kt3bo+T4Aof2
         JgJebIuqp1U73pF9CX2HN6eEABgTu1qZQkLcD/hqppR6ap588bkl1siSeZpJjAARQB7O
         7IqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c16si20369508pfr.94.2019.05.20.17.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 17:27:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 17:27:38 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 20 May 2019 17:27:37 -0700
Date: Mon, 20 May 2019 17:28:27 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	alexander.h.duyck@linux.intel.com, andreyknvl@google.com,
	arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
	riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
	npiggin@gmail.com, mathieu.desnoyers@efficios.com,
	shakeelb@google.com, guro@fb.com, aarcange@redhat.com,
	hughd@google.com, jglisse@redhat.com, mgorman@techsingularity.net,
	daniel.m.jordan@oracle.com, jannh@google.com, kilobyte@angband.pl,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/7] mm: Add process_vm_mmap() syscall declaration
Message-ID: <20190521002827.GA30518@iweiny-DESK2.sc.intel.com>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <155836080726.2441.11153759042802992469.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155836080726.2441.11153759042802992469.stgit@localhost.localdomain>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 05:00:07PM +0300, Kirill Tkhai wrote:
> Similar to process_vm_readv() and process_vm_writev(),
> add declarations of a new syscall, which will allow
> to map memory from or to another process.

Shouldn't this be the last patch in the series so that the syscall is actually
implemented first?

Ira

> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |    2 ++
>  include/linux/syscalls.h               |    5 +++++
>  include/uapi/asm-generic/unistd.h      |    5 ++++-
>  init/Kconfig                           |    9 +++++----
>  kernel/sys_ni.c                        |    2 ++
>  6 files changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index ad968b7bac72..99d6e0085576 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -438,3 +438,4 @@
>  431	i386	fsconfig		sys_fsconfig			__ia32_sys_fsconfig
>  432	i386	fsmount			sys_fsmount			__ia32_sys_fsmount
>  433	i386	fspick			sys_fspick			__ia32_sys_fspick
> +434	i386	process_vm_mmap		sys_process_vm_mmap		__ia32_compat_sys_process_vm_mmap
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index b4e6f9e6204a..46d7d2898f7a 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -355,6 +355,7 @@
>  431	common	fsconfig		__x64_sys_fsconfig
>  432	common	fsmount			__x64_sys_fsmount
>  433	common	fspick			__x64_sys_fspick
> +434	common	process_vm_mmap		__x64_sys_process_vm_mmap
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> @@ -398,3 +399,4 @@
>  545	x32	execveat		__x32_compat_sys_execveat/ptregs
>  546	x32	preadv2			__x32_compat_sys_preadv64v2
>  547	x32	pwritev2		__x32_compat_sys_pwritev64v2
> +548	x32	process_vm_mmap		__x32_compat_sys_process_vm_mmap
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index e2870fe1be5b..7d8ae36589cf 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -997,6 +997,11 @@ asmlinkage long sys_fspick(int dfd, const char __user *path, unsigned int flags)
>  asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
>  				       siginfo_t __user *info,
>  				       unsigned int flags);
> +asmlinkage long sys_process_vm_mmap(pid_t pid,
> +				    unsigned long src_addr,
> +				    unsigned long len,
> +				    unsigned long dst_addr,
> +				    unsigned long flags);
>  
>  /*
>   * Architecture-specific system calls
> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> index a87904daf103..b7aaa5ae02da 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -844,9 +844,12 @@ __SYSCALL(__NR_fsconfig, sys_fsconfig)
>  __SYSCALL(__NR_fsmount, sys_fsmount)
>  #define __NR_fspick 433
>  __SYSCALL(__NR_fspick, sys_fspick)
> +#define __NR_process_vm_mmap 424
> +__SC_COMP(__NR_process_vm_mmap, sys_process_vm_mmap, \
> +          compat_sys_process_vm_mmap)
>  
>  #undef __NR_syscalls
> -#define __NR_syscalls 434
> +#define __NR_syscalls 435
>  
>  /*
>   * 32 bit systems traditionally used different
> diff --git a/init/Kconfig b/init/Kconfig
> index 8b9ffe236e4f..604db5f14718 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -320,13 +320,14 @@ config POSIX_MQUEUE_SYSCTL
>  	default y
>  
>  config CROSS_MEMORY_ATTACH
> -	bool "Enable process_vm_readv/writev syscalls"
> +	bool "Enable process_vm_readv/writev/mmap syscalls"
>  	depends on MMU
>  	default y
>  	help
> -	  Enabling this option adds the system calls process_vm_readv and
> -	  process_vm_writev which allow a process with the correct privileges
> -	  to directly read from or write to another process' address space.
> +	  Enabling this option adds the system calls process_vm_readv,
> +	  process_vm_writev and process_vm_mmap, which allow a process
> +	  with the correct privileges to directly read from or write to
> +	  or mmap another process' address space.
>  	  See the man page for more details.
>  
>  config USELIB
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 4d9ae5ea6caf..6f51634f4f7e 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -316,6 +316,8 @@ COND_SYSCALL(process_vm_readv);
>  COND_SYSCALL_COMPAT(process_vm_readv);
>  COND_SYSCALL(process_vm_writev);
>  COND_SYSCALL_COMPAT(process_vm_writev);
> +COND_SYSCALL(process_vm_mmap);
> +COND_SYSCALL_COMPAT(process_vm_mmap);
>  
>  /* compare kernel pointers */
>  COND_SYSCALL(kcmp);
> 

