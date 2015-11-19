Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9DED56B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 03:18:17 -0500 (EST)
Received: by wmww144 with SMTP id w144so105331767wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 00:18:16 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id y84si10555233wmg.105.2015.11.19.00.18.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 00:18:16 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 19 Nov 2015 08:18:15 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7BC752190046
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:18:06 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAJ8IB2R46006416
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:18:12 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAJ8I9D8016577
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 01:18:11 -0700
Date: Thu, 19 Nov 2015 09:18:08 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 2/2] s390/mm: allow gmap code to retry on faulting in
 guest memory
Message-ID: <20151119091808.5d84c8ba@mschwide>
In-Reply-To: <1447890598-56860-3-git-send-email-dingel@linux.vnet.ibm.com>
References: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1447890598-56860-3-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J.
 Herne" <jjherne@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Thu, 19 Nov 2015 00:49:58 +0100
Dominik Dingel <dingel@linux.vnet.ibm.com> wrote:

> The userfaultfd does need FAULT_FLAG_ALLOW_RETRY to not return
> VM_FAULT_SIGBUS.  So we improve the gmap code to handle one
> VM_FAULT_RETRY.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  arch/s390/mm/pgtable.c | 28 ++++++++++++++++++++++++----
>  1 file changed, 24 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index 54ef3bc..8a0025d 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -577,15 +577,22 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
>  	       unsigned int fault_flags)
>  {
>  	unsigned long vmaddr;
> -	int rc;
> +	int rc, fault;
> 
> +	fault_flags |= FAULT_FLAG_ALLOW_RETRY;
> +retry:
>  	down_read(&gmap->mm->mmap_sem);
>  	vmaddr = __gmap_translate(gmap, gaddr);
>  	if (IS_ERR_VALUE(vmaddr)) {
>  		rc = vmaddr;
>  		goto out_up;
>  	}
> -	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags)) {
> +	fault = fixup_user_fault(current, gmap->mm, vmaddr, fault_flags);
> +	if (fault & VM_FAULT_RETRY) {
> +		fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
> +		fault_flags |= FAULT_FLAG_TRIED;
> +		goto retry;
> +	} else if (fault) {
>  		rc = -EFAULT;
>  		goto out_up;
>  	}

Me thinks that you want to add the retry code into fixup_user_fault itself.
You basically have the same code around the three calls to fixup_user_fault.
Yes, it will be a common code patch but I guess that it will be acceptable
given userfaultfd as a reason.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
