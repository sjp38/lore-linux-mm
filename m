Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DF7266B0036
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 20:00:59 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so3148957wgg.9
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 17:00:59 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (7.3.c.8.2.a.e.f.f.f.8.1.0.3.2.0.9.6.0.7.2.3.f.b.0.b.8.0.1.0.0.2.ip6.arpa. [2001:8b0:bf32:7069:230:18ff:fea2:8c37])
        by mx.google.com with ESMTPS id cu7si16563720wjc.70.2014.09.14.17.00.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Sep 2014 17:00:58 -0700 (PDT)
Date: Mon, 15 Sep 2014 01:00:25 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Message-ID: <20140915010025.5940c946@alan.etchedpixels.co.uk>
In-Reply-To: <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
	<1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> The base of the bounds directory is set into mm_struct during
> PR_MPX_REGISTER command execution. This member can be used to
> check whether one application is mpx enabled.

Not really because by the time you ask the question another thread might
have decided to unregister it.


> +int mpx_register(struct task_struct *tsk)
> +{
> +	struct mm_struct *mm = tsk->mm;
> +
> +	if (!cpu_has_mpx)
> +		return -EINVAL;
> +
> +	/*
> +	 * runtime in the userspace will be responsible for allocation of
> +	 * the bounds directory. Then, it will save the base of the bounds
> +	 * directory into XSAVE/XRSTOR Save Area and enable MPX through
> +	 * XRSTOR instruction.
> +	 *
> +	 * fpu_xsave() is expected to be very expensive. In order to do
> +	 * performance optimization, here we get the base of the bounds
> +	 * directory and then save it into mm_struct to be used in future.
> +	 */
> +	mm->bd_addr = task_get_bounds_dir(tsk);
> +	if (!mm->bd_addr)
> +		return -EINVAL;

What stops two threads calling this in parallel ?
> +
> +	return 0;
> +}
> +
> +int mpx_unregister(struct task_struct *tsk)
> +{
> +	struct mm_struct *mm = current->mm;
> +
> +	if (!cpu_has_mpx)
> +		return -EINVAL;
> +
> +	mm->bd_addr = NULL;

or indeed calling this in parallel

What are the semantics across execve() ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
