Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BFDFC282CC
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 08:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC7A72080F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 08:53:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="dFRXAToX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC7A72080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690998E007B; Tue,  5 Feb 2019 03:53:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63EB98E001C; Tue,  5 Feb 2019 03:53:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52E0E8E007B; Tue,  5 Feb 2019 03:53:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECED68E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 03:53:27 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id o5so702486wmf.9
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 00:53:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9NPvfNG+JFpDM7sjiNkdW+XpScH5VeiM2qlV0JoY6ZA=;
        b=fX7ETKRxvxJtE4d5S2+ZqKm3M2cC+DrmiVRZiXkuKYVrc9OBGNeBcIWCm1X+3tr4m+
         OYk2XykXVFZmfic9iran3LaB5rS4cIq6r0aQ6gaLqyP2FS1egeZvSh2yp9tk9vM+dvjj
         UQpnwFgl26FVEEC6yBAp5GIfkOUhFBreMtRmnkG5Y8gwGvhBSNp2liMuYTeZ+aY3jqwz
         lMPj00vk3RUur6dr9W/Ahp+OvmvnkKvAARsVASkrnE1zv+4ql72LmCQmwkvn12LDvuw6
         uRhMTlcpDJ8511CtUKD0IJP9eoptGCHZsupC1lDFENrO8peZmgKFo3odE6397gH9A0FW
         XLag==
X-Gm-Message-State: AHQUAubFtpVzYFwStsE4XqggEKKgM4ieam1MmtBop03x18MnfudywlSx
	SRkVVRZGqwcoWE2/CNape6ah42JKSefpySOf4Pie3buwwWKNomyyeRwxuHHPtOJRQ7b4rHVSym/
	D99Dt0LmXJ0dSEw+UR8r/fh9BY4RXonTBhjrMz6iKrYHBKKpBMvwBM0ZGq9z+KlVvkA==
X-Received: by 2002:adf:fd03:: with SMTP id e3mr2566151wrr.280.1549356807410;
        Tue, 05 Feb 2019 00:53:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib/V5JkkUW87pyYRNMP3fsxjLQcuLoxt5B3D2tnev9I7b1pXcOpn1LgVyWdgpsyUAXp3Auy
X-Received: by 2002:adf:fd03:: with SMTP id e3mr2566105wrr.280.1549356806523;
        Tue, 05 Feb 2019 00:53:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549356806; cv=none;
        d=google.com; s=arc-20160816;
        b=u3kfFrvCS52PLnDQWx+2OrPWcttlkR0heAz1pmAGHJKpspHOWHc75oGyFZJt8i4PTD
         pAZgmFK5Q8cS2hA5rPc/BWr28KtsayuB8f2wWqjV5uWW31wVJ0KLnsbs/UFZiP4P/+Y0
         WlfvQtY4HkMl/4EKgLm5Qk8XKe3n0wVh98OUGeCHyPJq7TCxVvYPvJVmjZnxDlZjLvLg
         XrEccnSVf2ogq3B/MZ9qtVL2FjNMzIhVUyrfVULTVMXmf9F41GbmPgGkG+qSxLybg9dY
         47mvKVONjJPDDt51uyNUYFF7aFsb1/warvDR2GWiCWVgaj7uho9jemr5JY9F/HJxdJjs
         hq/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9NPvfNG+JFpDM7sjiNkdW+XpScH5VeiM2qlV0JoY6ZA=;
        b=vuR1D4aJCHh8Y3Mj8XjuCz+xzrdYezx/COhqx8GbgMFCvKddYAPJ/q6XY6YVpuOx/1
         yvt+AS5p8viNhXM/65ZWUMF65zaHNN6uSEMO6T8PUkgbaS53wc/yD7azSw+CNPCdlyAp
         WLPy/PXcSSihybTc3CgFPhWKtFhDKhdcmWLlGC/cm1pMeS0gB682uu0SVOnI3/EHkaGL
         BSA2dOM4zCfdqDNkCO3oM3X7uPRF6X30Z8BoOpJnUFyDhZ7MVsxIqJPpuWqzcox/ojDv
         zJXC9+h7O253At1JSKl2EmEul1Xzl3TAVARNE2oIhIrtZj65+KAsVxLDaHGL3fKvFOxO
         wSQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=dFRXAToX;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id a126si10619654wmc.150.2019.02.05.00.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 00:53:26 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=dFRXAToX;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB6B008896F3D5E1C66173.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:6b00:8896:f3d5:e1c6:6173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 955EB1EC02AE;
	Tue,  5 Feb 2019 09:53:25 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549356805;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=9NPvfNG+JFpDM7sjiNkdW+XpScH5VeiM2qlV0JoY6ZA=;
	b=dFRXAToX5/08SPN0allQ11aILUZsmqf1gG1hG+VKNk9k/KbmUKs/QtkUV1Dckk8k5WEBri
	SbcwLdA6zuqezXnk0dN5d6IYdQlJsKW0k1gguU0W6REBUNatrwKiZt6E8IsZhciVrJH0CU
	WTpRddr5zmzLbrlGnkZkBIBx+ZjWfJ4=
Date: Tue, 5 Feb 2019 09:53:11 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v2 04/20] fork: provide a function for copying init_mm
Message-ID: <20190205085311.GH21801@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-5-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-5-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:06PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> Provide a function for copying init_mm. This function will be later used
> for setting a temporary mm.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
> Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  include/linux/sched/task.h |  1 +
>  kernel/fork.c              | 24 ++++++++++++++++++------
>  2 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
> index 44c6f15800ff..c5a00a7b3beb 100644
> --- a/include/linux/sched/task.h
> +++ b/include/linux/sched/task.h
> @@ -76,6 +76,7 @@ extern void exit_itimers(struct signal_struct *);
>  extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
>  extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
>  struct task_struct *fork_idle(int);
> +struct mm_struct *copy_init_mm(void);
>  extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
>  extern long kernel_wait4(pid_t, int __user *, int, struct rusage *);
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b69248e6f0e0..d7b156c49f29 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1299,13 +1299,20 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>  		complete_vfork_done(tsk);
>  }
>  
> -/*
> - * Allocate a new mm structure and copy contents from the
> - * mm structure of the passed in task structure.
> +/**
> + * dup_mm() - duplicates an existing mm structure
> + * @tsk: the task_struct with which the new mm will be associated.
> + * @oldmm: the mm to duplicate.
> + *
> + * Allocates a new mm structure and copy contents from the provided

s/copy/copies/

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

