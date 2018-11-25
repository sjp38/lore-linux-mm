Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8481C6B3B10
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 03:08:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so7792790ede.19
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 00:08:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si1836753edn.332.2018.11.25.00.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 00:08:36 -0800 (PST)
Date: Sun, 25 Nov 2018 09:08:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: debug: Fix a width vs precision bug in printk
Message-ID: <20181125080834.GB12455@dhcp22.suse.cz>
References: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
 <20181123090125.GC8625@dhcp22.suse.cz>
 <20181123143605.GB2970@unbuntlaptop>
 <ddbf19fb-1d73-40ca-b421-4c171466833b@I-love.SAKURA.ne.jp>
 <20181123160846.1160ba23c2514ed9c316be9d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123160846.1160ba23c2514ed9c316be9d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dan Carpenter <dan.carpenter@oracle.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri 23-11-18 16:08:46, Andrew Morton wrote:
> On Fri, 23 Nov 2018 23:48:06 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > On 2018/11/23 23:36, Dan Carpenter wrote:
> > > On Fri, Nov 23, 2018 at 10:01:25AM +0100, Michal Hocko wrote:
> > >> On Fri 23-11-18 10:21:35, Dan Carpenter wrote:
> > >>> We had intended to only print dentry->d_name.len characters but there is
> > >>> a width vs precision typo so if the name isn't NUL terminated it will
> > >>> read past the end of the buffer.
> > >>
> > >> OK, it took me quite some time to grasp what you mean here. The code
> > >> works as expected because d_name.len and dname.name are in sync so there
> > >> no spacing going to happen. Anyway what you propose is formally more
> > >> correct I guess.
> > >>  
> > > 
> > > Yeah.  If we are sure that the name has a NUL terminator then this
> > > change has no effect.
> > 
> > There seems to be %pd which is designed for printing "struct dentry".
> 
> ooh, who knew.  Can we use that please?

I wasn't aware of it either. I do not mind using it instead of the
opencoded variant of mine.

This should do it, right?
diff --git a/mm/debug.c b/mm/debug.c
index d18c5cea3320..68e9a9f2df16 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -80,7 +80,7 @@ void __dump_page(struct page *page, const char *reason)
 		if (mapping->host->i_dentry.first) {
 			struct dentry *dentry;
 			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
-			pr_warn("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
+			pr_warn("name:\"%pd\" ", dentry);
 		}
 	}
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);

-- 
Michal Hocko
SUSE Labs
