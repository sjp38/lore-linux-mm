Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8BB06B03FA
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 03:56:48 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id g12so69505915lfe.5
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 00:56:48 -0800 (PST)
Received: from smtp36.i.mail.ru (smtp36.i.mail.ru. [94.100.177.96])
        by mx.google.com with ESMTPS id e124si16780244lfg.84.2016.12.22.00.56.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 00:56:47 -0800 (PST)
Date: Thu, 22 Dec 2016 11:56:37 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 2/2] kasan: add memcg kmem_cache test
Message-ID: <20161222085637.GB3494@esperanza>
References: <1482257462-36948-1-git-send-email-gthelen@google.com>
 <1482257462-36948-2-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482257462-36948-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 20, 2016 at 10:11:02AM -0800, Greg Thelen wrote:
> Make a kasan test which uses a SLAB_ACCOUNT slab cache.  If the test is
> run within a non default memcg, then it uncovers the bug fixed by
> "kasan: drain quarantine of memcg slab objects"[1].
> 
> If run without fix [1] it shows "Slab cache still has objects", and the
> kmem_cache structure is leaked.
> Here's an unpatched kernel test:
> $ dmesg -c > /dev/null
> $ mkdir /sys/fs/cgroup/memory/test
> $ echo $$ > /sys/fs/cgroup/memory/test/tasks
> $ modprobe test_kasan 2> /dev/null
> $ dmesg | grep -B1 still
> [ 123.456789] kasan test: memcg_accounted_kmem_cache allocate memcg accounted object
> [ 124.456789] kmem_cache_destroy test_cache: Slab cache still has objects
> 
> Kernels with fix [1] don't have the "Slab cache still has objects"
> warning or the underlying leak.
> 
> The new test runs and passes in the default (root) memcg, though in the
> root memcg it won't uncover the problem fixed by [1].
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
