Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9D98B6B0254
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 00:12:11 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so114920255wml.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 21:12:11 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 8si2086020wmi.102.2016.03.07.21.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 21:12:10 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id 1so1986393wmg.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 21:12:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 8 Mar 2016 08:12:09 +0300
Message-ID: <CALYGNiPgBRuZoi8nA-JQCxx-RGiXE9g-dfeeysvH0Rp2VAYz2A@mail.gmail.com>
Subject: Re: [PATCH v1] tools/vm/page-types.c: remove memset() in walk_pfn()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Mar 8, 2016 at 4:47 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> I found that page-types is very slow and my testing shows many timeout errors.
> Here's an example with a simple program allocating 1000 thps.
>
>   $ time ./page-types -p $(pgrep -f test_alloc)
>   ...
>   real    0m17.201s
>   user    0m16.889s
>   sys     0m0.312s
>
>   $ time ./page-types.patched -p $(pgrep -f test_alloc)
>   ...
>   real    0m0.182s
>   user    0m0.046s
>   sys     0m0.135s
>
> Most of time is spent in memset(), which isn't necessary because we check
> that the return of kpagecgroup_read() is equal to pages and uninitialized
> memory is never used. So we can drop this memset().

These zeros are used in show_page_range() - for merging pages into ranges.

You could add fast-path for count=1

@@ -633,7 +633,10 @@ static void walk_pfn(unsigned long voffset,
        unsigned long pages;
        unsigned long i;

-       memset(cgi, 0, sizeof cgi);
+       if (count == 1)
+               cgi[0] = 0;
+       else
+               memset(cgi, 0, sizeof cgi);

        while (count) {
                batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);


>
> Fixes: 954e95584579 ("tools/vm/page-types.c: add memory cgroup dumping and filtering")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  tools/vm/page-types.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/tools/vm/page-types.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/tools/vm/page-types.c
> index dab61c3..c192baf 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/tools/vm/page-types.c
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/tools/vm/page-types.c
> @@ -633,8 +633,6 @@ static void walk_pfn(unsigned long voffset,
>         unsigned long pages;
>         unsigned long i;
>
> -       memset(cgi, 0, sizeof cgi);
> -
>         while (count) {
>                 batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);
>                 pages = kpageflags_read(buf, index, batch);
> --
> 2.7.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
