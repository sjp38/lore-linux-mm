Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5A76B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 12:25:54 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id q107so9948192qgd.3
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 09:25:54 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 65si12910184qgx.47.2015.01.09.09.25.52
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 09:25:52 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86, mpx: Ensure unused arguments of prctl() MPX requests are 0
References: <54AE5BE8.1050701@gmail.com>
Date: Fri, 09 Jan 2015 09:25:51 -0800
In-Reply-To: <54AE5BE8.1050701@gmail.com> (Michael Kerrisk's message of "Thu,
	08 Jan 2015 11:28:56 +0100")
Message-ID: <87r3v350io.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, lkml <linux-kernel@vger.kernel.org>

"Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:

> From: Michael Kerrisk <mtk.manpages@gmail.com>
>
> commit fe8c7f5cbf91124987106faa3bdf0c8b955c4cf7 added two new prctl()
> operations, PR_MPX_ENABLE_MANAGEMENT and PR_MPX_DISABLE_MANAGEMENT.
> However, no checks were included to ensure that unused arguments
> are zero, as is done in many existing prctl()s and as should be 
> done for all new prctl()s. This patch adds the required checks.

This will break the existing gcc run time, which doesn't zero these
arguments.

-ANdi

>
> Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>
> ---
>  kernel/sys.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index a8c9f5a..ea9c881 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2210,9 +2210,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  		up_write(&me->mm->mmap_sem);
>  		break;
>  	case PR_MPX_ENABLE_MANAGEMENT:
> +		if (arg2 || arg3 || arg4 || arg5)
> +			return -EINVAL;
>  		error = MPX_ENABLE_MANAGEMENT(me);
>  		break;
>  	case PR_MPX_DISABLE_MANAGEMENT:
> +		if (arg2 || arg3 || arg4 || arg5)
> +			return -EINVAL;
>  		error = MPX_DISABLE_MANAGEMENT(me);
>  		break;
>  	default:
> -- 
> 1.9.3

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
