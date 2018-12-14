Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
Date: Fri, 14 Dec 2018 12:25:50 +0100
Message-ID: <1618433.IpySj692Hd@blindfold>
In-Reply-To: <1544766961-3492-1-git-send-email-openzhangj@gmail.com>
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-kernel-owner@vger.kernel.org
To: zhangjun <openzhangj@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, hch@lst.de, bfoster@redhat.comdarrick.wong@oracle.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-mm.kvack.org>

[CC'ing authors of the code plus mm folks]

Am Freitag, 14. Dezember 2018, 06:56:01 CET schrieb zhangjun:
> IOMAP uses PG_private a little different with buffer_head based
> filesystem.
> It uses it as marker and when set, the page counter is not incremented,
> migrate_page_move_mapping() assumes that PG_private indicates a counter
> of +1.
> so, we have to pass a extra count of -1 to migrate_page_move_mapping()
> if the flag is set.
> 
> Signed-off-by: zhangjun <openzhangj@gmail.com>
> ---
>  fs/iomap.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 64ce240..352e58a 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -544,8 +544,17 @@ iomap_migrate_page(struct address_space *mapping, struct page *newpage,
>  		struct page *page, enum migrate_mode mode)
>  {
>  	int ret;
> +	int extra_count = 0;
>  
> -	ret = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
> +	/*
> +	 * IOMAP uses PG_private as marker and does not raise the page counter.
> +	 * migrate_page_move_mapping() expects a incremented counter if PG_private
> +	 * is set. Therefore pass -1 as extra_count for this case.
> +	 */
> +	if (page_has_private(page))
> +		extra_count = -1;
> +	ret = migrate_page_move_mapping(mapping, newpage, page,
> +		       NULL, mode, extra_count);
>  	if (ret != MIGRATEPAGE_SUCCESS)
>  		return ret;

This is the third place which needs this workaround.
UBIFS, F2FS, and now iomap.

I agree with Dave that nobody can assume that PG_private implies an additional
page reference.
But page migration does that. Including parts of the write back code.

Thanks,
//richard
