Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 208856B02BE
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 03:41:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rf5so19290688pab.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 00:41:33 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id j82si8184746pfe.42.2016.11.03.00.41.30
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 00:41:32 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-12-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 11/33] userfaultfd: non-cooperative: Add mremap() event
Date: Thu, 03 Nov 2016 15:41:15 +0800
Message-ID: <072901d235a5$a8826700$f9873500$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Michael Rapoport' <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote:
> @@ -576,7 +581,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  			goto out;
>  		}
> 
> -		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
> +		ret = move_vma(vma, addr, old_len, new_len, new_addr,
> +			       &locked, &uf);
>  	}
>  out:
>  	if (offset_in_page(ret)) {
> @@ -586,5 +592,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	up_write(&current->mm->mmap_sem);
>  	if (locked && new_len > old_len)
>  		mm_populate(new_addr + old_len, new_len - old_len);
> +	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);

nit: s/uf/&uf/

>  	return ret;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
