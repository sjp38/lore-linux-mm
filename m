Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB9E06B0287
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:50:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xm6so43431729pab.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:50:25 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id q81si7778839pfa.134.2016.04.20.16.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 16:50:25 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:50:21 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH mmotm 3/5] huge tmpfs recovery: tweak shmem_getpage_gfp
 to fill team fix
Message-ID: <20160421095021.422d54ed@canb.auug.org.au>
In-Reply-To: <alpine.LSU.2.11.1604161629520.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
	<alpine.LSU.2.11.1604161629520.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Mika Penttila <mika.penttila@nextfour.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Sat, 16 Apr 2016 16:33:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>
> Please add this fix after my 27/31, your
> huge-tmpfs-recovery-tweak-shmem_getpage_gfp-to-fill-team.patch
> for later merging into it.  Great catch by Mika Penttila, a bug which
> prevented some unusual cases from being recovered into huge pages as
> intended: an initially sparse head would be set PageTeam only after
> this check.  But the check is guarding against a racing disband, which
> cannot happen before the head is published as PageTeam, plus we have
> an additional reference on the head which keeps it safe throughout:
> so very easily fixed.
> 
> Reported-by: Mika Penttila <mika.penttila@nextfour.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/shmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2938,7 +2938,7 @@ repeat:
>  			page = *pagep;
>  			lock_page(page);
>  			head = page - (index & (HPAGE_PMD_NR-1));
> -			if (!PageTeam(head)) {
> +			if (!PageTeam(head) && page != head) {
>  				error = -ENOENT;
>  				goto decused;
>  			}

Added to linux-next today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
