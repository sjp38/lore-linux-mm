Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD2466B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 19:26:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hi6so131958672pac.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 16:26:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bd6si559995pad.41.2016.09.08.16.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 16:26:23 -0700 (PDT)
Date: Thu, 8 Sep 2016 16:26:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: warn about empty nodemask
Message-Id: <20160908162621.51ff52413559a7a6bb5a7df5@linux-foundation.org>
In-Reply-To: <1473208886.12692.2.camel@TP420>
References: <1473044391.4250.19.camel@TP420>
	<d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
	<B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
	<3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz>
	<1473208886.12692.2.camel@TP420>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Wed, 07 Sep 2016 08:41:26 +0800 Li Zhong <zhong@linux.vnet.ibm.com> wrote:

> Warn about allocating with an empty nodemask, it would be easier to
> understand than oom messages. The check is added in the slow path.
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> --- 
> mm/page_alloc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a2214c6..d624ff3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3448,6 +3448,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto got_pg;
>  
> +	if (ac->nodemask && nodes_empty(*ac->nodemask)) {
> +		pr_warn("nodemask is empty\n");
> +		gfp_mask &= ~__GFP_NOWARN;
> +		goto nopage;
> +	}
> +

Wouldn't it be better to do

	if (WARN_ON(ac->nodemask && nodes_empty(*ac->nodemask)) {
		...

so we can identify the misbehaving call site?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
