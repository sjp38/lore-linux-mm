Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA6A26B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:35:52 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d6so15200380itc.6
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:35:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b203sor2921728oih.267.2017.09.17.22.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Sep 2017 22:35:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170914131819.26266-14-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz> <20170914131819.26266-14-jack@suse.cz>
From: "Yan, Zheng" <ukernel@gmail.com>
Date: Mon, 18 Sep 2017 13:35:50 +0800
Message-ID: <CAAM7YAnHjkGRhzeUUXOMnux70UKqnQ3kG6x0jRpzasSNeyAVCg@mail.gmail.com>
Subject: Re: [PATCH 13/15] ceph: Use pagevec_lookup_range_nr_tag()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, "Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>

On Thu, Sep 14, 2017 at 9:18 PM, Jan Kara <jack@suse.cz> wrote:
> Use new function for looking up pages since nr_pages argument from
> pagevec_lookup_range_tag() is going away.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/ceph/addr.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index e57e9d37bf2d..87789c477381 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -869,11 +869,9 @@ static int ceph_writepages_start(struct address_space *mapping,
>                 max_pages = wsize >> PAGE_SHIFT;
>
>  get_more_pages:
> -               pvec_pages = min_t(unsigned, PAGEVEC_SIZE,
> -                                  max_pages - locked_pages);
> -               pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
> +               pvec_pages = pagevec_lookup_range_nr_tag(&pvec, mapping, &index,
>                                                 end, PAGECACHE_TAG_DIRTY,
> -                                               pvec_pages);
> +                                               max_pages - locked_pages);
>                 dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
>                 if (!pvec_pages && !locked_pages)
>                         break;
> --
> 2.12.3
>

Reviewed-by: "Yan, Zheng" <zyan@redhat.com>

> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
