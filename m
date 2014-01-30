Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0076B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:09:55 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so3469141pdj.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:09:55 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id yh9si7890793pab.63.2014.01.30.13.09.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:09:54 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id w10so3463569pde.21
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:09:54 -0800 (PST)
Date: Thu, 30 Jan 2014 13:09:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
In-Reply-To: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1401301301000.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014, Vladimir Davydov wrote:

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Some changelog would be helpful since this fixes an issue already in 
Linus's tree.

Commit 842e2873697e ("memcg: get rid of kmem_cache_dup()") introduced a 
mutex for memcg_create_kmem_cache() to protect the tmp_name buffer that 
holds the memcg name.  It failed to unlock the mutex if this buffer could 
not be allocated.

This patch fixes the issue by appropriately unlocking the mutex if the 
allocation fails.

Acked-by: David Rientjes <rientjes@google.com>


That said, this tmp_name stuff seems totally unnecessary.  
kmem_cache_create_memcg() already does the kstrdup() so why not just pass 
in a pointer to already allocated memory for s->name rather than having 
this mutex or global buffer at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
