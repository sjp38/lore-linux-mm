Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF8E36B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 05:06:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z67so62878410itb.8
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 02:06:54 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m63si19467174ioi.35.2017.04.24.02.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 02:06:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC 1/2] mm: Uncharge poisoned pages
Date: Mon, 24 Apr 2017 09:05:31 +0000
Message-ID: <20170424090530.GA31900@hori1.linux.bs1.fc.nec.co.jp>
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1492680362-24941-2-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1492680362-24941-2-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <47D2D236408D8143BC06CDC612AB9BB9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Thu, Apr 20, 2017 at 11:26:01AM +0200, Laurent Dufour wrote:
> When page are poisoned, they should be uncharged from the root memory
> cgroup.

Could you include some information about what problem this patch tries
to solve?
# I know that you already explain it in patch 0/2, so you can simply
# copy from it.

>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/memory-failure.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 27f7210e7fab..00bd39d3d4cb 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -530,6 +530,7 @@ static const char * const action_page_types[] =3D {
>  static int delete_from_lru_cache(struct page *p)
>  {
>  	if (!isolate_lru_page(p)) {
> +		memcg_kmem_uncharge(p, 0);

This function is supposed to be called with if (memcg_kmem_enabled()) check=
,
so could you do like below?

+		if (memcg_kmem_enabled())
+			memcg_kmem_uncharge(p, 0);


And I feel that we can call this function outside if (!isolate_lru_page(p))
block, because isolate_lru_page could fail and then the error page is left
incompletely isolated. Such error page has PageHWPoison set, so I guess tha=
t
the reported bug still triggers on such case.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
