Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 00BAD6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:09:04 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so3681523pab.32
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:09:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id q6si7969061pbf.184.2014.01.30.14.09.03
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 14:09:04 -0800 (PST)
Date: Thu, 30 Jan 2014 14:09:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on
 memcg_create_kmem_cache fail path
Message-Id: <20140130140902.93d35d866f9ea1c697811f6e@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
	<20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org>
	<alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com>
	<20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
	<alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com>
	<20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org>
	<alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014 14:04:12 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Thu, 30 Jan 2014, Andrew Morton wrote:
> 
> > > Yeah, it shouldn't be temporary it should be the one and only allocation.  
> > > We should construct the name in memcg_create_kmem_cache() and be done with 
> > > it.
> > 
> > Could.  That would require converting memcg_create_kmem_cache() to take 
> > a va_list and call kasprintf() on it.
> > 
> 
> Why?  We already construct the name in memcg_create_kmem_cache() 
> appropriately, we just want to avoid the kstrdup() in 
> kmem_cache_create_memcg() since it's pointless like my patch does.

oh, OK, missed that.

The problem now is that the string at kmem_cache.name is PATH_MAX
bytes, and PATH_MAX is huuuuuuuge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
