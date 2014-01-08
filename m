Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 39CB26B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 21:06:45 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id kx10so1176624pab.8
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 18:06:44 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id sz7si58453496pab.319.2014.01.07.18.06.42
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 18:06:43 -0800 (PST)
Message-ID: <52CCB2A7.2000300@ubuntukylin.com>
Date: Wed, 08 Jan 2014 10:06:31 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] Add shrink_pagecache_parent
References: <cover.1388409686.git.liwang@ubuntukylin.com>	<249cbd3edaa84dd58a0626780fb546ddf7c1dc11.1388409687.git.liwang@ubuntukylin.com> <20140102155534.9b0cd498209d835d0c93837e@linux-foundation.org>
In-Reply-To: <20140102155534.9b0cd498209d835d0c93837e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>, Dave Chinner <david@fromorbit.com>

Hi,

On 01/03/2014 07:55 AM, Andrew Morton wrote:
> On Mon, 30 Dec 2013 21:45:17 +0800 Li Wang <liwang@ubuntukylin.com> wrote:
>
>> Analogous to shrink_dcache_parent except that it collects inodes.
>> It is not very appropriate to be put in dcache.c, but d_walk can only
>> be invoked from here.
>
> Please cc Dave Chinner on future revisions.  He be da man.
>
> The overall intent of the patchset seems reasonable and I agree that it
> can't be efficiently done from userspace with the current kernel API.
> We *could* do it from userspace by providing facilities for userspace to
> query the VFS caches: "is this pathname in the dentry cache" and "is
> this inode in the inode cache".
>
Even we have these available, i am afraid it will still introduce
non-negligible overhead due to frequent system calls for a directory
  walking operation, especially under massive small file situations.

>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -1318,6 +1318,42 @@ void shrink_dcache_parent(struct dentry *parent)
>>   }
>>   EXPORT_SYMBOL(shrink_dcache_parent);
>>
>> +static enum d_walk_ret gather_inode(void *data, struct dentry *dentry)
>> +{
>> +	struct list_head *list = data;
>> +	struct inode *inode = dentry->d_inode;
>> +
>> +	if ((inode == NULL) || ((!inode_owner_or_capable(inode)) &&
>> +				(!capable(CAP_SYS_ADMIN))))
>> +		goto out;
>> +	spin_lock(&inode->i_lock);
>> +	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
>
> It's unclear what rationale lies behind this particular group of tests.
>
>> +		(inode->i_mapping->nrpages == 0) ||
>> +		(!list_empty(&inode->i_lru))) {
>
> arg, the "Inode locking rules" at the top of fs/inode.c needs a
> refresh, I suspect.  It is too vague.
>
> Formally, inode->i_lru is protected by
> i_sb->s_inode_lru->node[nid].lock, not by ->i_lock.  I guess you can
> just do a list_lru_add() and that will atomically add the inode to your
> local list_lru if ->i_lru wasn't being used for anything else.
>
> I *think* that your use of i_lock works OK, because code which fiddles
> with i_lru and s_inode_lru also takes i_lock.  However we need to
> decide which is the preferred and official lock.  ie: what is the
> design here??
>
> However...  most inodes will be on an LRU list, won't they?  Doesn't
> this reuse of i_lru mean that many inodes will fail to be processed?
> If so, we might need to add a new list_head to the inode, which will be
> problematic.
>
As far as I know, fix me if i am wrong, only when inode has zero
reference count, it will be put into superblock lru list. For most
situations, there is at least a dentry refers to it, so it will not
be on any lru list.

>
> Aside: inode_lru_isolate() fiddles directly with inode->i_lru without
> taking i_sb->s_inode_lru->node[nid].lock.  Why doesn't this make a
> concurrent s_inode_lru walker go oops??  Should we be using
> list_lru_del() in there?  (which should have been called
> list_lru_del_init(), sigh).
>
It seems inode_lru_isolate() only called by prune_icache_sb() as
a callback function. Before calling it, the caller has hold
the lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
