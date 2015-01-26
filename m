Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F21FC6B007B
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 05:45:47 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so11083629pab.5
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 02:45:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e15si11667517pdl.240.2015.01.26.02.45.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 02:45:47 -0800 (PST)
Date: Mon, 26 Jan 2015 13:45:34 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] slab: update_memcg_params: explicitly check that old
 array != NULL
Message-ID: <20150126104534.GA28978@esperanza>
References: <20150126085638.GA6507@mwanda>
 <1422266479-29098-1-git-send-email-vdavydov@parallels.com>
 <20150126101902.GC6507@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150126101902.GC6507@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 01:23:05PM +0300, Dan Carpenter wrote:
> On Mon, Jan 26, 2015 at 01:01:19PM +0300, Vladimir Davydov wrote:
> > This warning is false-positive, because @old equals NULL iff
> > @memcg_nr_cache_ids equals 0.
> 
> I don't see how it could be a false positive.  The "old" pointer is
> dereferenced inside the call to memset() so unless memset is a macro the
> compiler isn't going to optimize the dereference away.

old->entries is not dereferenced: memcg_cache_array->entries is not a
pointer - it is embedded to the memcg_cache_array struct.

> 
> 
> //----- test code
> 
> void frob(void *p){}
> 
> struct foo {
> 	int *x, *y, *z;
> };
> 
> int main(void)
> {
> 	struct foo *x = NULL;
> 
> 	frob(x->y);
> 
> 	return 0;
> }
> 
> //---- end
> 
> 
> If we compile with gcc test.c then it segfaults.  With -02 the compiler
> is able to tell that frob() is an empty function and it doesn't
> segfault.  In the kernel code, there is no way for the compiler to
> optimize the memset() away so it will Oops.

Just change

- 	int *x, *y, *z;
+	int *x, *z;
+	int *y[0];

and it won't.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
