Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6E56B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 12:41:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f134so14769614lfg.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:41:36 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id m127si287232lfa.186.2016.10.18.09.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 09:41:34 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id x23so27569163lfi.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:41:34 -0700 (PDT)
Date: Tue, 18 Oct 2016 19:41:31 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [Bug 177821] New: NULL pointer dereference in list_rcu
Message-ID: <20161018164131.GB14704@esperanza>
References: <bug-177821-27@https.bugzilla.kernel.org/>
 <20161017171038.924cbbcfc0a23652d2d2b8b4@linux-foundation.org>
 <FA3391F9-B333-451D-8415-CB5B62030A9D@beget.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FA3391F9-B333-451D-8415-CB5B62030A9D@beget.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

On Tue, Oct 18, 2016 at 10:26:55AM +0300, Alexander Polakov wrote:
> From: Alexander Polakov <apolyakov@beget.ru>
> Subject: mm/list_lru.c: avoid error-path NULL pointer deref
> 
> As described in https://bugzilla.kernel.org/show_bug.cgi?id=177821:
> 
> After some analysis it seems to be that the problem is in alloc_super(). 
> In case list_lru_init_memcg() fails it goes into destroy_super(), which
> calls list_lru_destroy().
> 
> And in list_lru_init() we see that in case memcg_init_list_lru() fails,
> lru->node is freed, but not set NULL, which then leads list_lru_destroy()
> to believe it is initialized and call memcg_destroy_list_lru(). 
> memcg_destroy_list_lru() in turn can access lru->node[i].memcg_lrus, which
> is NULL.
> 
> [akpm@linux-foundation.org: add comment]
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Alexander Polakov <apolyakov@beget.ru>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

FWIW,

The patch is indeed correct. However, failing a mount because of
inability to allocate per memcg data sounds bad. We should probably
fallback on vmalloc in memcg_{init,update}_list_lru_node() or use a
contrived data structure, like flex_array, there. This is also fair for
{init,update}_memcg_params in mm/slab_common.c.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
