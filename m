Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id F31796B0075
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 05:23:17 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id vb8so6921292obc.10
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 02:23:17 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tj9si4697980obc.59.2015.01.26.02.23.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 02:23:17 -0800 (PST)
Date: Mon, 26 Jan 2015 13:23:05 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH -mm] slab: update_memcg_params: explicitly check that old
 array != NULL
Message-ID: <20150126101902.GC6507@mwanda>
References: <20150126085638.GA6507@mwanda>
 <1422266479-29098-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422266479-29098-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 01:01:19PM +0300, Vladimir Davydov wrote:
> This warning is false-positive, because @old equals NULL iff
> @memcg_nr_cache_ids equals 0.

I don't see how it could be a false positive.  The "old" pointer is
dereferenced inside the call to memset() so unless memset is a macro the
compiler isn't going to optimize the dereference away.


//----- test code

void frob(void *p){}

struct foo {
	int *x, *y, *z;
};

int main(void)
{
	struct foo *x = NULL;

	frob(x->y);

	return 0;
}

//---- end


If we compile with gcc test.c then it segfaults.  With -02 the compiler
is able to tell that frob() is an empty function and it doesn't
segfault.  In the kernel code, there is no way for the compiler to
optimize the memset() away so it will Oops.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
