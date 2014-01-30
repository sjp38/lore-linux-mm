Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 201FB6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:50:05 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so3508321pdj.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:50:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id n8si7989839pax.73.2014.01.30.13.50.03
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 13:50:04 -0800 (PST)
Date: Thu, 30 Jan 2014 13:50:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on
 memcg_create_kmem_cache fail path
Message-Id: <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
	<20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org>
	<alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com>
	<20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
	<alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014 13:38:56 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> > > What's funnier is that tmp_name isn't required at all since 
> > > kmem_cache_create_memcg() is just going to do a kstrdup() on it anyway, so 
> > > you could easily just pass in the pointer to memory that has been 
> > > allocated for s->name rather than allocating memory twice.
> > 
> > We need a buffer to sprintf() into.
> > 
> 
> Yeah, it shouldn't be temporary it should be the one and only allocation.  
> We should construct the name in memcg_create_kmem_cache() and be done with 
> it.

Could.  That would require converting memcg_create_kmem_cache() to take 
a va_list and call kasprintf() on it.

The problem is that pesky rcu_read_lock() which is required around
cgroup_name() - we'd have to call memcg_create_kmem_cache() under
rcu_read_lock() so the usual GFP_foo limitations apply.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
