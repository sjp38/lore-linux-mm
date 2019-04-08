Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BDE6C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 640D320857
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:19:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Qsbv9FVu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 640D320857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD3C56B0291; Mon,  8 Apr 2019 03:19:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5B3A6B0292; Mon,  8 Apr 2019 03:19:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5EA6B0293; Mon,  8 Apr 2019 03:19:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A72D6B0291
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 03:19:29 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h6so3661290ljj.10
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 00:19:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gSlaW2S1GnOiFkldJxqZMxuprNIHjJiDHduvTL2+kAs=;
        b=Upco/fZfx+AfQzj1nw8i6x37oNaZ67lMPTTN8ZSG6t1UwR5XeA+doVvqTdDoGCo1e/
         kinP4MU40/gOS8rO854sdzbDN7QSp6AL7AG+RoT05h9DXJPIH8w55GOPCAWZaV3mz8F8
         uFBK9z9dsbxk08uRTP4GtnbFKGxoyXasmrlLgITSaJEyjLK0rbPVa/jPBLubdUNxM7e1
         u6YsPvZcpXVKHGwu0w4PCTif2TW+s304pc3vjqiFuCQn1l8+r2Y3DPxjUdfda5vVrubK
         1oFaQQFv7hCFVMdsIdnCKFUv4d8VyHVElodG1EQ1Zp4MlGgwaqf7sOT+oEjExMCqMrhm
         uKTQ==
X-Gm-Message-State: APjAAAW72Bo9wTDxMQ5SXhUEQKZbU0FREOItn7C3YI4zl1VD2wFiiMFw
	fmLgVZDaj3lxJ75BKz33U+AhDuMrFaGYEhoK6+SqGH50HuTkQ/UtzNXJaC7NktbJ4Cc2KT5/Y8O
	og4rTGe6gG6gBTDq6DCSYDQPY7ZMX2lk6s6kcsoyuh8tgsqy+21MCVwydMMYs8o9bUA==
X-Received: by 2002:a2e:6507:: with SMTP id z7mr14893820ljb.147.1554707968185;
        Mon, 08 Apr 2019 00:19:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWw4dlahW3UKyA58xhpuP+wjHV5IwI6N7xF7yX6MIbHNQ92OfG6lUbFZ4diiQyjZ7vZ9Up
X-Received: by 2002:a2e:6507:: with SMTP id z7mr14893767ljb.147.1554707966970;
        Mon, 08 Apr 2019 00:19:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554707966; cv=none;
        d=google.com; s=arc-20160816;
        b=Pz0PML9+D5Pvf6DYcUl7xLA6I5ovHKXVlloddfsY/5aNX8tW0NKhnm3XgOQC4vY1Od
         ubSTM2Apouzy1ufVn74N/iKEGPJEALruPe3WRgkGQfJuB0Tj5aGaJxhVmifqfBG/JJkK
         ywJ+Hr0+NlKT5lsSOFERMhElTFx6+vNpqF/mPeq/eLJ3JxDwtHtsNeJ/iZct9WkTlvdO
         cxUtxoRQhSh8mc0u5jgYAIP9pIB7TmNho8w0SSafjora5XFpEYj2M9dDPYOCU4BosLlJ
         YjgBemFlWS8yHQLAYMhk/ZPo/37jtRlEqeBQoB7EADB7uuhr6KtLm8YxyxbB9O5QvzZT
         PHvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=gSlaW2S1GnOiFkldJxqZMxuprNIHjJiDHduvTL2+kAs=;
        b=oprcclVeHflRFBqZvGrpFkzF2cH8b1KQaRH2ThcmGBp6jtduIENSKevLiy7AcqhIJE
         GoSm/3J2j7SKlLPZQn1xzNXVgKW03+4qhBwCiGFAc6ZWmGV7OtHytHHYrcDEP323d2/n
         9tgxGV+3s4qz0vNjHvcn7+BcGRPxzxtaX4tVHDdf9UO0CyAYj3PWVM9ZGCkMxXxHo9vF
         OhtlYGN8BjiOLWdTZDUTb46SH2Tp+vubQhclCABvg649aRPqXiyOPZDZcqInBv3mHsyt
         cLfOls4lqIDqVUyHVA6CZb7Bs+nfGOh2vxYAmXE0B2OR7vG4KxaPHHSMrQs6cmLKUTML
         ocNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Qsbv9FVu;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTP id d186si503119lfg.139.2019.04.08.00.19.26
        for <linux-mm@kvack.org>;
        Mon, 08 Apr 2019 00:19:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Qsbv9FVu;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 781052E1499;
	Mon,  8 Apr 2019 10:19:26 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id MYareibynx-JPLWSl6j;
	Mon, 08 Apr 2019 10:19:26 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554707966; bh=gSlaW2S1GnOiFkldJxqZMxuprNIHjJiDHduvTL2+kAs=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=Qsbv9FVuQ5T84p4a7cGDThb4cvXPLbxq/0R0aiRRvU9UGJI6Hmy2JnFKGg1UrgmgP
	 yUlefQvKvBO4j42UyVb7bDeBDWDAQEE+o9flpTqblGo3N/5C8rDLwxWVFRzZW8LRNH
	 Qv1wFykvmsEHqyxIcCvo8Ijq2wUzPfrGob8lCnEU=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f5ec:9361:ed45:768f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 9JxVp63SfO-JPLOgjrA;
	Mon, 08 Apr 2019 10:19:25 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
To: Hugh Dickins <hughd@google.com>
Cc: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>,
 Vineeth Pillai <vpillai@digitalocean.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Rik van Riel <riel@surriel.com>,
 Huang Ying <ying.huang@intel.com>, Al Viro <viro@zeniv.linux.org.uk>
References: <1553440122.7s759munpm.astroid@alex-desktop.none>
 <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com>
 <1554048843.jjmwlalntd.astroid@alex-desktop.none>
 <alpine.LSU.2.11.1903311146040.2667@eggly.anvils>
 <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
 <alpine.LSU.2.11.1904041836030.25100@eggly.anvils>
 <56deb587-8cd6-317a-520f-209207468c55@yandex-team.ru>
 <alpine.LSU.2.11.1904072206030.1769@eggly.anvils>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <1b0bc97a-8162-d4df-7187-7636e5934b23@yandex-team.ru>
Date: Mon, 8 Apr 2019 10:19:24 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1904072206030.1769@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.2019 9:05, Hugh Dickins wrote:
> On Fri, 5 Apr 2019, Konstantin Khlebnikov wrote:
>> On 05.04.2019 5:12, Hugh Dickins wrote:
>>> Hi Alex, could you please give the patch below a try? It fixes a
>>> problem, but I'm not sure that it's your problem - please let us know.
>>>
>>> I've not yet written up the commit description, and this should end up
>>> as 4/4 in a series fixing several new swapoff issues: I'll wait to post
>>> the finished series until heard back from you.
>>>
>>> I did first try following the suggestion Konstantin had made back then,
>>> for a similar shmem_writepage() case: atomic_inc_not_zero(&sb->s_active).
>>>
>>> But it turned out to be difficult to get right in shmem_unuse(), because
>>> of the way that relies on the inode as a cursor in the list - problem
>>> when you've acquired an s_active reference, but fail to acquire inode
>>> reference, and cannot safely release the s_active reference while still
>>> holding the swaplist mutex.
>>>
>>> If VFS offered an isgrab(inode), like igrab() but acquiring s_active
>>> reference while holding i_lock, that would drop very easily into the
>>> current shmem_unuse() as a replacement there for igrab(). But the rest
>>> of the world has managed without that for years, so I'm disinclined to
>>> add it just for this. And the patch below seems good enough without it.
>>>
>>> Thanks,
>>> Hugh
>>>
>>> ---
>>>
>>>    include/linux/shmem_fs.h |    1 +
>>>    mm/shmem.c               |   39 ++++++++++++++++++---------------------
>>>    2 files changed, 19 insertions(+), 21 deletions(-)
>>>
>>> --- 5.1-rc3/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
>>> +++ linux/include/linux/shmem_fs.h	2019-04-04 16:18:08.193512968 -0700
>>> @@ -21,6 +21,7 @@ struct shmem_inode_info {
>>>    	struct list_head	swaplist;	/* chain of maybes on swap */
>>>    	struct shared_policy	policy;		/* NUMA memory alloc policy
>>> */
>>>    	struct simple_xattrs	xattrs;		/* list of xattrs */
>>> +	atomic_t		stop_eviction;	/* hold when working on inode
>>> */
>>>    	struct inode		vfs_inode;
>>>    };
>>>    --- 5.1-rc3/mm/shmem.c	2019-03-17 16:18:15.701823872 -0700
>>> +++ linux/mm/shmem.c	2019-04-04 16:18:08.193512968 -0700
>>> @@ -1081,9 +1081,15 @@ static void shmem_evict_inode(struct ino
>>>    			}
>>>    			spin_unlock(&sbinfo->shrinklist_lock);
>>>    		}
>>> -		if (!list_empty(&info->swaplist)) {
>>> +		while (!list_empty(&info->swaplist)) {
>>> +			/* Wait while shmem_unuse() is scanning this inode...
>>> */
>>> +			wait_var_event(&info->stop_eviction,
>>> +				       !atomic_read(&info->stop_eviction));
>>>    			mutex_lock(&shmem_swaplist_mutex);
>>>    			list_del_init(&info->swaplist);
>>> +			/* ...but beware of the race if we peeked too early
>>> */
>>> +			if (!atomic_read(&info->stop_eviction))
>>> +				list_del_init(&info->swaplist);
>>>    			mutex_unlock(&shmem_swaplist_mutex);
>>>    		}
>>>    	}
>>> @@ -1227,36 +1233,27 @@ int shmem_unuse(unsigned int type, bool
>>>    		unsigned long *fs_pages_to_unuse)
>>>    {
>>>    	struct shmem_inode_info *info, *next;
>>> -	struct inode *inode;
>>> -	struct inode *prev_inode = NULL;
>>>    	int error = 0;
>>>      	if (list_empty(&shmem_swaplist))
>>>    		return 0;
>>>      	mutex_lock(&shmem_swaplist_mutex);
>>> -
>>> -	/*
>>> -	 * The extra refcount on the inode is necessary to safely dereference
>>> -	 * p->next after re-acquiring the lock. New shmem inodes with swap
>>> -	 * get added to the end of the list and we will scan them all.
>>> -	 */
>>>    	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
>>>    		if (!info->swapped) {
>>>    			list_del_init(&info->swaplist);
>>>    			continue;
>>>    		}
>>> -
>>> -		inode = igrab(&info->vfs_inode);
>>> -		if (!inode)
>>> -			continue;
>>> -
>>> +		/*
>>> +		 * Drop the swaplist mutex while searching the inode for
>>> swap;
>>> +		 * but before doing so, make sure shmem_evict_inode() will
>>> not
>>> +		 * remove placeholder inode from swaplist, nor let it be
>>> freed
>>> +		 * (igrab() would protect from unlink, but not from unmount).
>>> +		 */
>>> +		atomic_inc(&info->stop_eviction);
>>>    		mutex_unlock(&shmem_swaplist_mutex);
>>> -		if (prev_inode)
>>> -			iput(prev_inode);
>>> -		prev_inode = inode;
>> This seems too ad hoc solution.
> 
> I see what you mean by "ad hoc", but disagree with "too" ad hoc:
> it's an appropriate solution, and a general one - I didn't invent it
> for this, but for the huge tmpfs recoveries work items four years ago;
> just changed the name from "info->recoveries" to "info->stop_eviction"
> to let it be generalized to this swapoff case.
> 
> I prefer mine, since it simplifies shmem_unuse() (no igrab!), and has
> the nice (but admittedly not essential) property of letting swapoff
> proceed without delay and without unnecessary locking on unmounting
> filesystems and evicting inodes.  (Would I prefer to use the s_umount
> technique for my recoveries case? I think not.) >
> But yours should work too, with a slight change - see comments below,
> where I've inlined yours. I'd better get on and post my four fixes
> tomorrow, whether or not they fix Alex's case; then if people prefer
> yours to my 4/4, yours can be swapped in instead.
> 

Ok. But both swapoff and tmpfs umount does not look like
operations that should be concurrent by any cost.

>> shmem: fix race between shmem_unuse and umount
>>
>> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> Function shmem_unuse could race with generic_shutdown_super.
>> Inode reference is not enough for preventing umount and freeing superblock.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> ---
>>   mm/shmem.c |   24 +++++++++++++++++++++++-
>>   1 file changed, 23 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index b3db3779a30a..2018a9a96bb7 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -1218,6 +1218,10 @@ static int shmem_unuse_inode(struct inode *inode, unsigned int type,
>>   	return ret;
>>   }
>>   
>> +static void shmem_synchronize_umount(struct super_block *sb, void *arg)
>> +{
>> +}
>> +
> 
> I think this can go away, see below.
> 
>>   /*
>>    * Read all the shared memory data that resides in the swap
>>    * device 'type' back into memory, so the swap device can be
>> @@ -1229,6 +1233,7 @@ int shmem_unuse(unsigned int type, bool frontswap,
>>   	struct shmem_inode_info *info, *next;
>>   	struct inode *inode;
>>   	struct inode *prev_inode = NULL;
>> +	struct super_block *sb;
>>   	int error = 0;
>>   
>>   	if (list_empty(&shmem_swaplist))
>> @@ -1247,9 +1252,22 @@ int shmem_unuse(unsigned int type, bool frontswap,
>>   			continue;
>>   		}
>>   
>> +		/*
>> +		 * Lock superblock to prevent umount and freeing it under us.
>> +		 * If umount in progress it will free swap enties.
>> +		 *
>> +		 * Must be done before grabbing inode reference, otherwise
>> +		 * generic_shutdown_super() will complain about busy inodes.
>> +		 */
>> +		sb = info->vfs_inode.i_sb;
>> +		if (!trylock_super(sb))
> 
> Right, trylock important there.
> 
>> +			continue;
>> +
>>   		inode = igrab(&info->vfs_inode);
>> -		if (!inode)
>> +		if (!inode) {
>> +			up_read(&sb->s_umount);
> 
> Yes, that indeed avoids the difficulty I had with when to call
> deactivate_super(), that put me off trying to use s_active.
> 
>>   			continue;
>> +		}
>>   
>>   		mutex_unlock(&shmem_swaplist_mutex);
>>   		if (prev_inode)
>> @@ -1258,6 +1276,7 @@ int shmem_unuse(unsigned int type, bool frontswap,
>>   
>>   		error = shmem_unuse_inode(inode, type, frontswap,
>>   					  fs_pages_to_unuse);
>> +		up_read(&sb->s_umount);
> 
> No, not here. I think you have to note prev_sb, and then only
> up_read(&prev_sb->s_umount) after each iput(prev_inode): otherwise
> there's still a risk of "Self-destruct in 5 seconds", isn't there?

Oh yes. So, this code have to swap sb locks above with this monster

if (sb != info->vfs_inode.i_sb) {
     if (sb)
         up_read(&sb->s_umount);
     sb = NULL;
     if (!trylock_super(info->vfs_inode.i_sb))
	continue;
     sb = info->vfs_inode.i_sb
}

Locking shmem_swaplist_mutex under s_umount should be fine.


Also I looking into idea of treating swapoff like reverse-writeback:
-> iterate over superblocks
-> lock s_umount with normal down_read
-> iterate over inodes
-> iterate over inode tags
-> ...

Whole code will be more natural in this way.

> 
>>   		cond_resched();
>>   
>>   		mutex_lock(&shmem_swaplist_mutex);
>> @@ -1272,6 +1291,9 @@ int shmem_unuse(unsigned int type, bool frontswap,
>>   	if (prev_inode)
>>   		iput(prev_inode);
>>   
>> +	/* Wait for umounts, this grabs s_umount for each superblock. */
>> +	iterate_supers_type(&shmem_fs_type, shmem_synchronize_umount, NULL);
>> +
> 
> I guess that's an attempt to compensate for the somewhat unsatisfactory
> trylock above (bearing in mind the SWAP_UNUSE_MAX_TRIES 3, but I remove
> that in my 2/4). Nice idea, and if it had the effect of never needing to
> retry shmem_unuse(), I'd say yes; but since you're still passing over
> un-igrab()-able inodes without an equivalent synchronization, I think
> this odd iterate_supers_type() just delays swapoff without buying any
> guarantee: better just deleted to keep your patch simpler.

Yep, robust algorithm is better than try-3-times-and-give-up =)
(could hide bugs for ages)

I suppose your solution will wait for wakeup from shmem_evict_inode()?
That should work. In more general design this could be something like
__wait_on_freeing_inode(), but with killable wait.

> 
>>   	return error;
>>   }
>>   
> 
> Thanks,
> Hugh
> 

