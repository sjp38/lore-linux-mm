Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A2FCC6B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 07:51:23 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so5058108wgh.12
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 04:51:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ba6si17145392wib.17.2014.06.27.04.51.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jun 2014 04:51:21 -0700 (PDT)
Date: Fri, 27 Jun 2014 13:51:11 +0200 (CEST)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH] msync: fix incorrect fstart calculation
In-Reply-To: <006a01cf91fc$5d225170$1766f450$@samsung.com>
Message-ID: <alpine.LFD.2.00.1406271348150.2349@localhost.localdomain>
References: <006a01cf91fc$5d225170$1766f450$@samsung.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1417942477-1403869875=:2349"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <namjae.jeon@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, 'Matthew Wilcox' <matthew.r.wilcox@intel.com>, 'Eric Whitney' <enwlinux@gmail.com>, Ashish Sangwan <a.sangwan@samsung.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1417942477-1403869875=:2349
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

On Fri, 27 Jun 2014, Namjae Jeon wrote:

> Date: Fri, 27 Jun 2014 20:38:49 +0900
> From: Namjae Jeon <namjae.jeon@samsung.com>
> To: 'Andrew Morton' <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>,
>     Luka1 Czerner <lczerner@redhat.com>,
>     'Matthew Wilcox' <matthew.r.wilcox@intel.com>,
>     'Eric Whitney' <enwlinux@gmail.com>,
>     Ashish Sangwan <a.sangwan@samsung.com>
> Subject: [PATCH] msync: fix incorrect fstart calculation
> 
> Fix a regression caused by Commit 7fc34a62ca mm/msync.c: sync only
> the requested range in msync().
> xfstests generic/075 fail occured on ext4 data=journal mode because
> the intended range was not syncing due to wrong fstart calculation.

Looks good to me and it fixes the issues with data=journal on ext4.

Reviewed-by: Lukas Czerner <lczerner@redhat.com>
Tested-by: Lukas Czerner <lczerner@redhat.com>

> 
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Luka1 Czerner <lczerner@redhat.com>
> Reported-by: Eric Whitney <enwlinux@gmail.com>
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Signed-off-by: Ashish Sangwan <a.sangwan@samsung.com>
> ---
>  mm/msync.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/msync.c b/mm/msync.c
> index a5c6736..ad97dce 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -78,7 +78,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
>  			goto out_unlock;
>  		}
>  		file = vma->vm_file;
> -		fstart = start + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +		fstart = (start - vma->vm_start) +
> +			 ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>  		fend = fstart + (min(end, vma->vm_end) - start) - 1;
>  		start = vma->vm_end;
>  		if ((flags & MS_SYNC) && file &&
> 
--8323328-1417942477-1403869875=:2349--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
