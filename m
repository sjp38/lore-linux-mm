Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 725136B0003
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 21:47:09 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p187so46553060wmp.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 18:47:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hb7si22163898wjc.71.2015.12.17.18.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Dec 2015 18:47:07 -0800 (PST)
Date: Thu, 17 Dec 2015 18:46:44 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 1/8] hugetlb: make mm and fs code explicitly non-modular
Message-ID: <20151218024644.GA17386@linux-uzut.site>
References: <1450379466-23115-1-git-send-email-paul.gortmaker@windriver.com>
 <1450379466-23115-2-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1450379466-23115-2-git-send-email-paul.gortmaker@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 17 Dec 2015, Paul Gortmaker wrote:

>The Kconfig currently controlling compilation of this code is:
>
>config HUGETLBFS
>        bool "HugeTLB file system support"
>
>...meaning that it currently is not being built as a module by anyone.
>
>Lets remove the modular code that is essentially orphaned, so that
>when reading the driver there is no doubt it is builtin-only.
>
>Since module_init translates to device_initcall in the non-modular
>case, the init ordering gets moved to earlier levels when we use the
>more appropriate initcalls here.
>
>Originally I had the fs part and the mm part as separate commits,
>just by happenstance of the nature of how I detected these
>non-modular use cases.  But that can possibly introduce regressions
>if the patch merge ordering puts the fs part 1st -- as the 0-day
>testing reported a splat at mount time.
>
>Investigating with "initcall_debug" showed that the delta was
>init_hugetlbfs_fs being called _before_ hugetlb_init instead of
>after.  So both the fs change and the mm change are here together.
>
>In addition, it worked before due to luck of link order, since they
>were both in the same initcall category.  So we now have the fs
>part using fs_initcall, and the mm part using subsys_initcall,
>which puts it one bucket earlier.  It now passes the basic sanity
>test that failed in earlier 0-day testing.
>
>We delete the MODULE_LICENSE tag and capture that information at the
>top of the file alongside author comments, etc.
>
>We don't replace module.h with init.h since the file already has that.
>Also note that MODULE_ALIAS is a no-op for non-modular code.
>
>Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
>Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Cc: Mike Kravetz <mike.kravetz@oracle.com>
>Cc: David Rientjes <rientjes@google.com>
>Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
>Cc: Davidlohr Bueso <dave@stgolabs.net>
>Cc: linux-mm@kvack.org
>Cc: linux-fsdevel@vger.kernel.org
>Reported-by: kernel test robot <ying.huang@linux.intel.com>
>Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: Davidlohr Bueso <dave@stgolabs.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
