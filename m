Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5496B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 16:33:44 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so11990090pbb.37
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 13:33:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ty3si34702496pbc.197.2013.12.30.13.33.42
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 13:33:43 -0800 (PST)
Message-ID: <52C1E6B1.4010402@intel.com>
Date: Mon, 30 Dec 2013 13:33:37 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
References: <cover.1388409686.git.liwang@ubuntukylin.com> <52C1C6F7.8010809@intel.com> <FFE7C704-791E-4B73-9251-EFB9135AB254@dilger.ca>
In-Reply-To: <FFE7C704-791E-4B73-9251-EFB9135AB254@dilger.ca>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Li Wang <liwang@ubuntukylin.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>

On 12/30/2013 11:40 AM, Andreas Dilger wrote:
> On Dec 30, 2013, at 12:18, Dave Hansen <dave.hansen@intel.com> wrote:
>> Why is this necessary to do in the kernel?  Why not leave it to
>> userspace to walk the filesystem(s)?
> 
> I would suspect that trying to do it in userspace would be quite bad. It would require traversing the whole directory tree to issue cache flushed for each subdirectory, but it doesn't know when to stop traversal. That would mean the "cache flush" would turn into "cache pollute" and cause a lot of disk IO for subdirectories not in cache to begin with. 

That makes sense for dentries at least and is a pretty good reason.
Probably good enough to to include some text in the patch description.
;)  Perhaps: "We need this interface because we have no way of
determining what is in the dcache from userspace, and we do not want
userspace to pollute the dcache going and looking for page cache to evict."

One other thing that bothers me: POSIX_FADV_DONTNEED on a directory
seems like it should do something with the _directory_.  It should undo
the kernel's caching that happens as a result of readdir().

Should this also be trying to drop the dentry/inode entries like "echo 2
> .../drop_caches" does?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
