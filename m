Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 329BA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:31:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so9468359edr.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:31:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18si562377edy.84.2019.01.22.07.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:31:03 -0800 (PST)
Date: Tue, 22 Jan 2019 16:31:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: no need to check return value of debugfs_create
 functions
Message-ID: <20190122153102.GJ4087@dhcp22.suse.cz>
References: <20190122152151.16139-14-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122152151.16139-14-gregkh@linuxfoundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org

On Tue 22-01-19 16:21:13, Greg KH wrote:
[...]
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 022d4cbb3618..18ee657fb918 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1998,8 +1998,7 @@ DEFINE_SHOW_ATTRIBUTE(memblock_debug);
>  static int __init memblock_init_debugfs(void)
>  {
>  	struct dentry *root = debugfs_create_dir("memblock", NULL);
> -	if (!root)
> -		return -ENXIO;
> +
>  	debugfs_create_file("memory", 0444, root,
>  			    &memblock.memory, &memblock_debug_fops);
>  	debugfs_create_file("reserved", 0444, root,

I haven't really read the whole patch but this has just hit my eyes. Is
this a correct behavior?

Documentations says:
 * @parent: a pointer to the parent dentry for this file.  This should be a
 *          directory dentry if set.  If this parameter is NULL, then the
 *          file will be created in the root of the debugfs filesystem.

so in case of failure we would get those debugfs files outside of their
intended scope. I believe it is much more correct to simply not create
anything, no?
-- 
Michal Hocko
SUSE Labs
