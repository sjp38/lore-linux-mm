Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 65F106B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:14:46 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so62655103pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:14:46 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ie4si7786828pbb.168.2015.11.18.16.14.45
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 16:14:45 -0800 (PST)
Date: Thu, 19 Nov 2015 02:14:40 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: fixup_userfault returns VM_FAULT_RETRY if asked
Message-ID: <20151119001440.GA7206@black.fi.intel.com>
References: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1447890598-56860-2-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447890598-56860-2-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Thu, Nov 19, 2015 at 12:49:57AM +0100, Dominik Dingel wrote:
> When calling fixup_userfault with FAULT_FLAG_ALLOW_RETRY, fixup_userfault
> didn't care about VM_FAULT_RETRY and returned 0. If the VM_FAULT_RETRY flag is
> set we will return the complete result of handle_mm_fault.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  mm/gup.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index deafa2c..2af3b31 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -609,6 +609,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  			return -EFAULT;
>  		BUG();
>  	}
> +	if (ret & VM_FAULT_RETRY)
> +		return ret;

Nope. fixup_user_fault() return errno, not VM_FAULT_* mask.

I guess it should be
		return -EBUSY;

>  	if (tsk) {
>  		if (ret & VM_FAULT_MAJOR)
>  			tsk->maj_flt++;
> -- 
> 2.3.9
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
