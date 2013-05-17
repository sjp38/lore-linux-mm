Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3C35A6B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 16:31:52 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id o13so633123qaj.7
        for <linux-mm@kvack.org>; Fri, 17 May 2013 13:31:51 -0700 (PDT)
Message-ID: <519693B8.10600@gmail.com>
Date: Fri, 17 May 2013 16:31:52 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()
References: <20130508143411.GD30955@pd.tnic> <1368029552-dzvitovl-mutt-n-horiguchi@ah.jp.nec.com> <20130508184524.GF30955@pd.tnic> <1368046093-mpzcumyb-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1368046093-mpzcumyb-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@alien8.de>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 8 May 2013 11:48:01 -0400
> Subject: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()
> 
> This patch fixes "warning: unused variable 'hs'" when !CONFIG_HUGETLB_PAGE
> introduced by commit af73e4d9506d "hugetlbfs: fix mmap failure in unaligned
> size request".
> 
> Reported-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  ipc/shm.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index e316cb9..9ff741a 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -491,9 +491,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  
>  	sprintf (name, "SYSV%08x", key);
>  	if (shmflg & SHM_HUGETLB) {
> -		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
> -						& SHM_HUGE_MASK);
> -		size_t hugesize = ALIGN(size, huge_page_size(hs));
> +		size_t hugesize = ALIGN(size, huge_page_size(hstate_sizelog(
> +				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK)));

NAK. This is uglier than before.
You should change !CONFIG_HUGETLB_PAGE specific code instead.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
