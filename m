Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAEA6B00A5
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:59:19 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so10655881pdj.30
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 07:59:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gm1si2310522pbd.47.2014.09.11.07.59.16
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 07:59:17 -0700 (PDT)
Message-ID: <5411B8C3.7080205@intel.com>
Date: Thu, 11 Sep 2014 07:59:15 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> + * This function will be called by do_munmap(), and the VMAs covering
> + * the virtual address region start...end have already been split if
> + * necessary and remvoed from the VMA list.

"remvoed" -> "removed"

> +void mpx_unmap(struct mm_struct *mm,
> +		unsigned long start, unsigned long end)
> +{
> +	int ret;
> +
> +	ret = mpx_try_unmap(mm, start, end);
> +	if (ret == -EINVAL)
> +		force_sig(SIGSEGV, current);
> +}

In the case of a fault during an unmap, this just ignores the situation
and returns silently.  Where is the code to retry the freeing operation
outside of mmap_sem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
