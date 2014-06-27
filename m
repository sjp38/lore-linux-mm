Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 399436B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 12:13:00 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so4682577qcx.8
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 09:13:00 -0700 (PDT)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id y9si14356099qcb.11.2014.06.27.09.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 09:12:59 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id hw13so4161066qab.20
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 09:12:59 -0700 (PDT)
Date: Fri, 27 Jun 2014 12:12:56 -0400
From: Eric Whitney <enwlinux@gmail.com>
Subject: Re: [PATCH] msync: fix incorrect fstart calculation
Message-ID: <20140627161256.GA8164@wallace>
References: <006a01cf91fc$5d225170$1766f450$@samsung.com>
 <100D68C7BA14664A8938383216E40DE0407A787B@FMSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <100D68C7BA14664A8938383216E40DE0407A787B@FMSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: Namjae Jeon <namjae.jeon@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-ext4 <linux-ext4@vger.kernel.org>, =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>, 'Eric Whitney' <enwlinux@gmail.com>, Ashish Sangwan <a.sangwan@samsung.com>

I can confirm that this patch corrects the ext4 regressions I reported on
3.16-rc1 for data_journal.

Additionally, it corrects regressions for two other tests I have not yet
reported.  Those tests include generic/263 when running with the
data=journal mount option, and generic/219 (a quota test that doesn't use
fsx) when running with all xfstests-bld scenarios (4k, ext4, nojournal, 1k,
etc.) with the exception of bigalloc.  The generic/219 failure on bigalloc in
3.16-rc1 is not a regression, and was present in earlier releases.

With this patch, ext4 3.16-rc3 regression results on x64_64 should look much
more like 3.15 final.

Thanks guys!
Eric


* Wilcox, Matthew R <matthew.r.wilcox@intel.com>:
> Acked-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ________________________________________
> From: Namjae Jeon [namjae.jeon@samsung.com]
> Sent: June 27, 2014 4:38 AM
> To: 'Andrew Morton'
> Cc: linux-mm@kvack.org; linux-ext4; LukA!A! Czerner; Wilcox, Matthew R; 'Eric Whitney'; Ashish Sangwan
> Subject: [PATCH] msync: fix incorrect fstart calculation
> 
> Fix a regression caused by Commit 7fc34a62ca mm/msync.c: sync only
> the requested range in msync().
> xfstests generic/075 fail occured on ext4 data=journal mode because
> the intended range was not syncing due to wrong fstart calculation.
> 
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: LukA!A! Czerner <lczerner@redhat.com>
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
>                         goto out_unlock;
>                 }
>                 file = vma->vm_file;
> -               fstart = start + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +               fstart = (start - vma->vm_start) +
> +                        ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>                 fend = fstart + (min(end, vma->vm_end) - start) - 1;
>                 start = vma->vm_end;
>                 if ((flags & MS_SYNC) && file &&
> --
> 1.7.11-rc0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
