Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 386BD6B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:56:31 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id u188so78231150wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:56:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id df6si30133498wjc.222.2016.01.25.10.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:56:30 -0800 (PST)
Date: Mon, 25 Jan 2016 13:55:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/memcontrol: avoid a spurious gcc warning
Message-ID: <20160125185538.GF29291@cmpxchg.org>
References: <1453736756-1959377-3-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1453736756-1959377-3-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-arm-kernel@lists.infradead.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Hi Arnd,

On Mon, Jan 25, 2016 at 04:45:50PM +0100, Arnd Bergmann wrote:
> When CONFIG_DEBUG_VM is set, the various VM_BUG_ON() confuse gcc to
> the point where it cannot remember that 'memcg' is known to be initialized:
> 
> mm/memcontrol.c: In function 'mem_cgroup_can_attach':
> mm/memcontrol.c:4791:9: warning: 'memcg' may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> On ARM gcc-5.1, the above happens when any two or more of the VM_BUG_ON()
> are active, but not when I remove most or all of them. This is clearly
> random behavior and the only way I've found to shut up the warning is
> to add an explicit initialization.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks Arnd.

This has been fixed upstream already:

commit eed67d75b66748a498a0592d9704081a98509444
Author: Ross Zwisler <ross.zwisler@linux.intel.com>
Date:   Wed Dec 23 14:53:27 2015 -0700

    cgroup: Fix uninitialized variable warning
    
    Commit 1f7dd3e5a6e4 ("cgroup: fix handling of multi-destination migration
    from subtree_control enabling") introduced the following compiler warning:
    
    mm/memcontrol.c: In function a??mem_cgroup_can_attacha??:
    mm/memcontrol.c:4790:9: warning: a??memcga?? may be used uninitialized in this function [-Wmaybe-uninitialized]
       mc.to = memcg;
             ^
    
    Fix this by initializing 'memcg' to NULL.
    
    This was found using gcc (GCC) 4.9.2 20150212 (Red Hat 4.9.2-6).
    
    Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
    Signed-off-by: Tejun Heo <tj@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
