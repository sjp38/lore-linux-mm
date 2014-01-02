Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 251236B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 07:44:22 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so14204408pdj.11
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 04:44:21 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id dv5si42433300pbb.13.2014.01.02.04.44.19
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 04:44:20 -0800 (PST)
Message-ID: <52C55F12.4050406@ubuntukylin.com>
Date: Thu, 02 Jan 2014 20:44:02 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
References: <cover.1388409686.git.liwang@ubuntukylin.com> <52C1C6F7.8010809@intel.com> <FFE7C704-791E-4B73-9251-EFB9135AB254@dilger.ca> <52C1E6B1.4010402@intel.com>
In-Reply-To: <52C1E6B1.4010402@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andreas Dilger <adilger@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>

Do we really need clean dcache/icache at the current stage?
That will introduce more code work, so far, iput() will put
those unreferenced inodes into superblock lru list. To free
the inodes inside a specific directory, it seems we do not
have a handy API to use, and need
modify iput() to recognize our situation, and collect those
inodes into our list rather than superblock lru list. Maybe
we stay at current stage now, since it is simple and could
gain the major benefits, leave the dcache/icache cleaning
to do in the future?

On 2013/12/31 5:33, Dave Hansen wrote:
> On 12/30/2013 11:40 AM, Andreas Dilger wrote:
>> On Dec 30, 2013, at 12:18, Dave Hansen <dave.hansen@intel.com> wrote:
>>> Why is this necessary to do in the kernel?  Why not leave it to
>>> userspace to walk the filesystem(s)?
>>
>> I would suspect that trying to do it in userspace would be quite bad. It would require traversing the whole directory tree to issue cache flushed for each subdirectory, but it doesn't know when to stop traversal. That would mean the "cache flush" would turn into "cache pollute" and cause a lot of disk IO for subdirectories not in cache to begin with.
>
> That makes sense for dentries at least and is a pretty good reason.
> Probably good enough to to include some text in the patch description.
> ;)  Perhaps: "We need this interface because we have no way of
> determining what is in the dcache from userspace, and we do not want
> userspace to pollute the dcache going and looking for page cache to evict."
>
> One other thing that bothers me: POSIX_FADV_DONTNEED on a directory
> seems like it should do something with the _directory_.  It should undo
> the kernel's caching that happens as a result of readdir().
>
> Should this also be trying to drop the dentry/inode entries like "echo 2
>> .../drop_caches" does?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
