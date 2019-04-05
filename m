Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99A4FC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 09:41:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9F621738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 09:41:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="ULSi0ax/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9F621738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 090E36B000C; Fri,  5 Apr 2019 05:41:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A846B000D; Fri,  5 Apr 2019 05:41:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFCE26B000E; Fri,  5 Apr 2019 05:41:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9CB6B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 05:41:20 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m85so1555100lje.19
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 02:41:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=4JkRSSMRagE7EI9xDgYp7Ni6fHBNDtj9wUVk7uBeoJQ=;
        b=evgnF/Zd4nvvJG45ydQ1RTKEISYfVL9nQsbTM60uYwN6Ljp3jHtP8hBA+osUduN6Lw
         gEonWnOkZDN8Scolyo1npOwO3AqRfYHNs8IvZ3RQHbeHKXKpunkjipsBPasG+0XJ8fEw
         +9ADqAYKyfW4TiHugQQQG8whMGcqiKE+M0rjt0v8hCsmnEt45GGEiR0kt94thYlgd0bA
         9Is5A5cI3Wg4hlsVKQUxq+iHj7NcdUNUwM7fCPKvaEQwlBtkLNJE+DBNkLHo80TLRchZ
         DFHH8KP5GPNMneKzfjHsGC9bY9MYEqzWeqSrnR7Q3a2/jjVE3YBzPBRuDreo4R5u4Qo2
         Qjew==
X-Gm-Message-State: APjAAAUQhCSbnoVEjBZU2QsaIB2q6Yv89eTqWBXwYa6TZv9PvHAFHShe
	RWsMlI4a8AIuN30sD8EnkJoyU6qRFpZkc8CMUXzHquhxYhShrdFmb7jWBljt+PaZwE4Mw48Wyhs
	ZdkbXi8K0ZOl8GuxOk/12lU6F8Ejw026/pRofRAye34MDHPXJa1GANJmmgUZ7pMEQCw==
X-Received: by 2002:a2e:808e:: with SMTP id i14mr6742474ljg.103.1554457279510;
        Fri, 05 Apr 2019 02:41:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoTF4/PNdjzNgnnxMaUf0FzqaW5oa0yHbWvA4urQeXNMR436DH9DkzKEstQKGOcdjDo+Wk
X-Received: by 2002:a2e:808e:: with SMTP id i14mr6742389ljg.103.1554457277958;
        Fri, 05 Apr 2019 02:41:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554457277; cv=none;
        d=google.com; s=arc-20160816;
        b=cJyyJUsvZ4+Nja9ZmQGykBBl8CTk4vumvBNpJj3g8by/kupUe/sxVHo26IhpRarytY
         2qC6nA5i2mucLuPKOfavEf3RLF4j20/UCLKiKGOGpM8tgjOFP95MZVVCXzuoYLsJ+L9k
         7FReiOoUAxrRMERpmA+2WwUVVGQV0CEYiu21yscFXxlyZAvoR/ohZYO5oGLN+h1VK49b
         Uud1cuh4onUJvk3vEPRe9h4qbFcW++Gvyvl2AYfz2zBVO+PT7RDa0P/5U0Rw3r1WzxTv
         V4uQpVcOxbqmaM9el89la1B1xTk4p2ed4NNGTLDtgVG8AT6kwk0dDjW8LFX0ziyF5zP+
         Lv0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject:dkim-signature;
        bh=4JkRSSMRagE7EI9xDgYp7Ni6fHBNDtj9wUVk7uBeoJQ=;
        b=PDqvxIY/Or77fCeZ/ODsu8fb525qsHV2Ze+ZVocnGiUukFkJVV3tdWEVRTogO6WF3V
         xMU7gpLMOBqQBLUNaxfRfafPJqnzd7i5L3CYPMftDQaYX6iq270ThHAngZ1en8H2edDF
         0tMswKGjtn2RHZPtHaMqb1ZUVjNL7frUVshkf2uS1PIxAcGwN0jtZ+W33hwyEA1yxqpB
         d8pLDGVmLALELzeHYmmDe67JO65HOU/7/2KcnUNX2B1LAphbxZ5+YAuClFbO0a53cu7K
         8lPHnAA5opmcGpRjGVJ1V9moQDsTpRqCnapAR0anF+iZeAn1TDb2wKqig8Z/c2h/sb/j
         MtzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="ULSi0ax/";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id p8si15324470ljh.161.2019.04.05.02.41.17
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 02:41:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="ULSi0ax/";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 5DBF42E14F7;
	Fri,  5 Apr 2019 12:41:17 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id Mlp1kDB17y-fG3iUcZk;
	Fri, 05 Apr 2019 12:41:17 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554457277; bh=4JkRSSMRagE7EI9xDgYp7Ni6fHBNDtj9wUVk7uBeoJQ=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=ULSi0ax/dCeNU7EGjofynI+HlFPazH1JX3x6wfLdVXa5S4sn7D7VJnG9Ih0D4huGo
	 hLwvj4e9sp0nhJKkYj1SUpMaf6u1oXtj+sWe58dbyHEgZjhnjfysQfxo/vjEfzQ+ZC
	 C97mk9Nh2UhRcseRxuaP0WP6PgUrVZ/0snOp1ipg=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d4bb:795:9728:5f59])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id eiM1ZR1XFp-fGBe4E39;
	Fri, 05 Apr 2019 12:41:16 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
To: Hugh Dickins <hughd@google.com>, "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Cc: Vineeth Pillai <vpillai@digitalocean.com>,
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
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <56deb587-8cd6-317a-520f-209207468c55@yandex-team.ru>
Date: Fri, 5 Apr 2019 12:41:15 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1904041836030.25100@eggly.anvils>
Content-Type: multipart/mixed;
 boundary="------------CB2AA163A547B315483B2E2F"
Content-Language: en-CA
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------CB2AA163A547B315483B2E2F
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 05.04.2019 5:12, Hugh Dickins wrote:
> On Tue, 2 Apr 2019, Hugh Dickins wrote:
>> On Sun, 31 Mar 2019, Hugh Dickins wrote:
>>> On Sun, 31 Mar 2019, Alex Xu (Hello71) wrote:
>>>> Excerpts from Vineeth Pillai's message of March 25, 2019 6:08 pm:
>>>>> On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
>>>>>>
>>>>>> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
>>>>>> suspect my setup erroneously executes two swapoff+cryptsetup close
>>>>>> operations simultaneously, so a race condition is triggered.
>>>>>>
>>>>>> I am using a single swap on a plain dm-crypt device on a MBR partition
>>>>>> on a SATA drive.
>>>>>>
>>>>>> I think the problem is probably related to
>>>>>> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
>>>>>>
>>>>> Could you please provide more information on this - stack trace, dmesg etc?
>>>>> Is it easily reproducible? If yes, please detail the steps so that I
>>>>> can try it inhouse.
>>>>>
>>>>> Thanks,
>>>>> Vineeth
>>>>>
>>>>
>>>> Some info from the BUG entry (I didn't bother to type it all,
>>>> low-quality image available upon request):
>>>>
>>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
>>>> #PF error: [normal kernel read fault]
>>>> PGD 0 P4D 0
>>>> Oops: 0000 [#1] SMP
>>>> CPU: 0 Comm: swapoff Not tainted 5.1.0-rc1+ #2
>>>> RIP: 0010:shmem_recalc_inode+0x41/0x90
>>>>
>>>> Call Trace:
>>>> ? shmem_undo_range
>>>> ? rb_erase_cached
>>>> ? set_next_entity
>>>> ? __inode_wait_for_writeback
>>>> ? shmem_truncate_range
>>>> ? shmem_evict_inode
>>>> ? evict
>>>> ? shmem_unuse
>>>> ? try_to_unuse
>>>> ? swapcache_free_entries
>>>> ? _cond_resched
>>>> ? __se_sys_swapoff
>>>> ? do_syscall_64
>>>> ? entry_SYSCALL_64_after_hwframe
>>>>
>>>> As I said, it only occurs occasionally on shutdown. I think it is a safe
>>>> guess that it can only occur when the swap is not empty, but possibly
>>>> other conditions are necessary, so I will test further.
>>>
>>> Thanks for the update, Alex. I'm looking into a couple of bugs with the
>>> 5.1-rc swapoff, but this one doesn't look like anything I know so far.
>>> shmem_recalc_inode() is a surprising place to crash: it's as if the
>>> igrab() in shmem_unuse() were not working.
>>>
>>> Yes, please do send Vineeth and me (or the lists) your low-quality image,
>>> in case we can extract any more info from it; and also please the
>>> disassembly of your kernel's shmem_recalc_inode(), so we can be sure of
>>> exactly what it's crashing on (though I expect that will leave me as
>>> puzzled as before).
>>>
>>> If you want to experiment with one of my fixes, not yet written up and
>>> posted, just try changing SWAP_UNUSE_MAX_TRIES in mm/swapfile.c from
>>> 3 to INT_MAX: I don't see how that issue could manifest as crashing in
>>> shmem_recalc_inode(), but I may just be too stupid to see it.
>>
>> Thanks for the image and disassembly you sent: which showed that the
>> ffffffff81117351:       48 83 3f 00             cmpq   $0x0,(%rdi)
>> you are crashing on, is the "if (sbinfo->max_blocks)" in the inlined
>> shmem_inode_unacct_blocks(): inode->i_sb->s_fs_info is NULL, which is
>> something that shmem_put_super() does.
>>
>> Eight-year-old memories stirred: I knew when looking at Vineeth's patch,
>> that I ought to look back through the history of mm/shmem.c, to check
>> some points that Konstantin Khlebnikov had made years ago, that
>> surprised me then and were in danger of surprising us again with this
>> rework. But I failed to do so: thank you Alex, for reporting this bug
>> and pointing us back there.
>>
>> igrab() protects from eviction but does not protect from unmounting.
>> I bet that is what you are hitting, though I've not even read through
>> 2.6.39's 778dd893ae785 ("tmpfs: fix race between umount and swapoff")
>> again yet, and not begun to think of the fix for it this time around;
>> but wanted to let you know that this bug is now (probably) identified.
> 
> Hi Alex, could you please give the patch below a try? It fixes a
> problem, but I'm not sure that it's your problem - please let us know.
> 
> I've not yet written up the commit description, and this should end up
> as 4/4 in a series fixing several new swapoff issues: I'll wait to post
> the finished series until heard back from you.
> 
> I did first try following the suggestion Konstantin had made back then,
> for a similar shmem_writepage() case: atomic_inc_not_zero(&sb->s_active).
> 
> But it turned out to be difficult to get right in shmem_unuse(), because
> of the way that relies on the inode as a cursor in the list - problem
> when you've acquired an s_active reference, but fail to acquire inode
> reference, and cannot safely release the s_active reference while still
> holding the swaplist mutex.
> 
> If VFS offered an isgrab(inode), like igrab() but acquiring s_active
> reference while holding i_lock, that would drop very easily into the
> current shmem_unuse() as a replacement there for igrab(). But the rest
> of the world has managed without that for years, so I'm disinclined to
> add it just for this. And the patch below seems good enough without it.
> 
> Thanks,
> Hugh
> 
> ---
> 
>   include/linux/shmem_fs.h |    1 +
>   mm/shmem.c               |   39 ++++++++++++++++++---------------------
>   2 files changed, 19 insertions(+), 21 deletions(-)
> 
> --- 5.1-rc3/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
> +++ linux/include/linux/shmem_fs.h	2019-04-04 16:18:08.193512968 -0700
> @@ -21,6 +21,7 @@ struct shmem_inode_info {
>   	struct list_head	swaplist;	/* chain of maybes on swap */
>   	struct shared_policy	policy;		/* NUMA memory alloc policy */
>   	struct simple_xattrs	xattrs;		/* list of xattrs */
> +	atomic_t		stop_eviction;	/* hold when working on inode */
>   	struct inode		vfs_inode;
>   };
>   
> --- 5.1-rc3/mm/shmem.c	2019-03-17 16:18:15.701823872 -0700
> +++ linux/mm/shmem.c	2019-04-04 16:18:08.193512968 -0700
> @@ -1081,9 +1081,15 @@ static void shmem_evict_inode(struct ino
>   			}
>   			spin_unlock(&sbinfo->shrinklist_lock);
>   		}
> -		if (!list_empty(&info->swaplist)) {
> +		while (!list_empty(&info->swaplist)) {
> +			/* Wait while shmem_unuse() is scanning this inode... */
> +			wait_var_event(&info->stop_eviction,
> +				       !atomic_read(&info->stop_eviction));
>   			mutex_lock(&shmem_swaplist_mutex);
>   			list_del_init(&info->swaplist);
> +			/* ...but beware of the race if we peeked too early */
> +			if (!atomic_read(&info->stop_eviction))
> +				list_del_init(&info->swaplist);
>   			mutex_unlock(&shmem_swaplist_mutex);
>   		}
>   	}
> @@ -1227,36 +1233,27 @@ int shmem_unuse(unsigned int type, bool
>   		unsigned long *fs_pages_to_unuse)
>   {
>   	struct shmem_inode_info *info, *next;
> -	struct inode *inode;
> -	struct inode *prev_inode = NULL;
>   	int error = 0;
>   
>   	if (list_empty(&shmem_swaplist))
>   		return 0;
>   
>   	mutex_lock(&shmem_swaplist_mutex);
> -
> -	/*
> -	 * The extra refcount on the inode is necessary to safely dereference
> -	 * p->next after re-acquiring the lock. New shmem inodes with swap
> -	 * get added to the end of the list and we will scan them all.
> -	 */
>   	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
>   		if (!info->swapped) {
>   			list_del_init(&info->swaplist);
>   			continue;
>   		}
> -
> -		inode = igrab(&info->vfs_inode);
> -		if (!inode)
> -			continue;
> -
> +		/*
> +		 * Drop the swaplist mutex while searching the inode for swap;
> +		 * but before doing so, make sure shmem_evict_inode() will not
> +		 * remove placeholder inode from swaplist, nor let it be freed
> +		 * (igrab() would protect from unlink, but not from unmount).
> +		 */
> +		atomic_inc(&info->stop_eviction);
>   		mutex_unlock(&shmem_swaplist_mutex);
> -		if (prev_inode)
> -			iput(prev_inode);
> -		prev_inode = inode;
This seems too ad hoc solution.

Superblock could be protected with s_umount,
in same way as writeback pins it in __writeback_inodes_wb()

Please see (completely untested) patch in attachment.

>   
> -		error = shmem_unuse_inode(inode, type, frontswap,
> +		error = shmem_unuse_inode(&info->vfs_inode, type, frontswap,
>   					  fs_pages_to_unuse);
>   		cond_resched();
>   
> @@ -1264,14 +1261,13 @@ int shmem_unuse(unsigned int type, bool
>   		next = list_next_entry(info, swaplist);
>   		if (!info->swapped)
>   			list_del_init(&info->swaplist);
> +		if (atomic_dec_and_test(&info->stop_eviction))
> +			wake_up_var(&info->stop_eviction);
>   		if (error)
>   			break;
>   	}
>   	mutex_unlock(&shmem_swaplist_mutex);
>   
> -	if (prev_inode)
> -		iput(prev_inode);
> -
>   	return error;
>   }
>   
> @@ -2238,6 +2234,7 @@ static struct inode *shmem_get_inode(str
>   		info = SHMEM_I(inode);
>   		memset(info, 0, (char *)inode - (char *)info);
>   		spin_lock_init(&info->lock);
> +		atomic_set(&info->stop_eviction, 0);
>   		info->seals = F_SEAL_SEAL;
>   		info->flags = flags & VM_NORESERVE;
>   		INIT_LIST_HEAD(&info->shrinklist);
> 

--------------CB2AA163A547B315483B2E2F
Content-Type: text/plain; charset=UTF-8;
 name="shmem-fix-race-between-shmem_unuse-and-umount"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="shmem-fix-race-between-shmem_unuse-and-umount"

c2htZW06IGZpeCByYWNlIGJldHdlZW4gc2htZW1fdW51c2UgYW5kIHVtb3VudAoKRnJvbTog
S29uc3RhbnRpbiBLaGxlYm5pa292IDxraGxlYm5pa292QHlhbmRleC10ZWFtLnJ1PgoKRnVu
Y3Rpb24gc2htZW1fdW51c2UgY291bGQgcmFjZSB3aXRoIGdlbmVyaWNfc2h1dGRvd25fc3Vw
ZXIuCklub2RlIHJlZmVyZW5jZSBpcyBub3QgZW5vdWdoIGZvciBwcmV2ZW50aW5nIHVtb3Vu
dCBhbmQgZnJlZWluZyBzdXBlcmJsb2NrLgoKU2lnbmVkLW9mZi1ieTogS29uc3RhbnRpbiBL
aGxlYm5pa292IDxraGxlYm5pa292QHlhbmRleC10ZWFtLnJ1PgotLS0KIG1tL3NobWVtLmMg
fCAgIDI0ICsrKysrKysrKysrKysrKysrKysrKysrLQogMSBmaWxlIGNoYW5nZWQsIDIzIGlu
c2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9tbS9zaG1lbS5jIGIv
bW0vc2htZW0uYwppbmRleCBiM2RiMzc3OWEzMGEuLjIwMThhOWE5NmJiNyAxMDA2NDQKLS0t
IGEvbW0vc2htZW0uYworKysgYi9tbS9zaG1lbS5jCkBAIC0xMjE4LDYgKzEyMTgsMTAgQEAg
c3RhdGljIGludCBzaG1lbV91bnVzZV9pbm9kZShzdHJ1Y3QgaW5vZGUgKmlub2RlLCB1bnNp
Z25lZCBpbnQgdHlwZSwKIAlyZXR1cm4gcmV0OwogfQogCitzdGF0aWMgdm9pZCBzaG1lbV9z
eW5jaHJvbml6ZV91bW91bnQoc3RydWN0IHN1cGVyX2Jsb2NrICpzYiwgdm9pZCAqYXJnKQor
eworfQorCiAvKgogICogUmVhZCBhbGwgdGhlIHNoYXJlZCBtZW1vcnkgZGF0YSB0aGF0IHJl
c2lkZXMgaW4gdGhlIHN3YXAKICAqIGRldmljZSAndHlwZScgYmFjayBpbnRvIG1lbW9yeSwg
c28gdGhlIHN3YXAgZGV2aWNlIGNhbiBiZQpAQCAtMTIyOSw2ICsxMjMzLDcgQEAgaW50IHNo
bWVtX3VudXNlKHVuc2lnbmVkIGludCB0eXBlLCBib29sIGZyb250c3dhcCwKIAlzdHJ1Y3Qg
c2htZW1faW5vZGVfaW5mbyAqaW5mbywgKm5leHQ7CiAJc3RydWN0IGlub2RlICppbm9kZTsK
IAlzdHJ1Y3QgaW5vZGUgKnByZXZfaW5vZGUgPSBOVUxMOworCXN0cnVjdCBzdXBlcl9ibG9j
ayAqc2I7CiAJaW50IGVycm9yID0gMDsKIAogCWlmIChsaXN0X2VtcHR5KCZzaG1lbV9zd2Fw
bGlzdCkpCkBAIC0xMjQ3LDkgKzEyNTIsMjIgQEAgaW50IHNobWVtX3VudXNlKHVuc2lnbmVk
IGludCB0eXBlLCBib29sIGZyb250c3dhcCwKIAkJCWNvbnRpbnVlOwogCQl9CiAKKwkJLyoK
KwkJICogTG9jayBzdXBlcmJsb2NrIHRvIHByZXZlbnQgdW1vdW50IGFuZCBmcmVlaW5nIGl0
IHVuZGVyIHVzLgorCQkgKiBJZiB1bW91bnQgaW4gcHJvZ3Jlc3MgaXQgd2lsbCBmcmVlIHN3
YXAgZW50aWVzLgorCQkgKgorCQkgKiBNdXN0IGJlIGRvbmUgYmVmb3JlIGdyYWJiaW5nIGlu
b2RlIHJlZmVyZW5jZSwgb3RoZXJ3aXNlCisJCSAqIGdlbmVyaWNfc2h1dGRvd25fc3VwZXIo
KSB3aWxsIGNvbXBsYWluIGFib3V0IGJ1c3kgaW5vZGVzLgorCQkgKi8KKwkJc2IgPSBpbmZv
LT52ZnNfaW5vZGUuaV9zYjsKKwkJaWYgKCF0cnlsb2NrX3N1cGVyKHNiKSkKKwkJCWNvbnRp
bnVlOworCiAJCWlub2RlID0gaWdyYWIoJmluZm8tPnZmc19pbm9kZSk7Ci0JCWlmICghaW5v
ZGUpCisJCWlmICghaW5vZGUpIHsKKwkJCXVwX3JlYWQoJnNiLT5zX3Vtb3VudCk7CiAJCQlj
b250aW51ZTsKKwkJfQogCiAJCW11dGV4X3VubG9jaygmc2htZW1fc3dhcGxpc3RfbXV0ZXgp
OwogCQlpZiAocHJldl9pbm9kZSkKQEAgLTEyNTgsNiArMTI3Niw3IEBAIGludCBzaG1lbV91
bnVzZSh1bnNpZ25lZCBpbnQgdHlwZSwgYm9vbCBmcm9udHN3YXAsCiAKIAkJZXJyb3IgPSBz
aG1lbV91bnVzZV9pbm9kZShpbm9kZSwgdHlwZSwgZnJvbnRzd2FwLAogCQkJCQkgIGZzX3Bh
Z2VzX3RvX3VudXNlKTsKKwkJdXBfcmVhZCgmc2ItPnNfdW1vdW50KTsKIAkJY29uZF9yZXNj
aGVkKCk7CiAKIAkJbXV0ZXhfbG9jaygmc2htZW1fc3dhcGxpc3RfbXV0ZXgpOwpAQCAtMTI3
Miw2ICsxMjkxLDkgQEAgaW50IHNobWVtX3VudXNlKHVuc2lnbmVkIGludCB0eXBlLCBib29s
IGZyb250c3dhcCwKIAlpZiAocHJldl9pbm9kZSkKIAkJaXB1dChwcmV2X2lub2RlKTsKIAor
CS8qIFdhaXQgZm9yIHVtb3VudHMsIHRoaXMgZ3JhYnMgc191bW91bnQgZm9yIGVhY2ggc3Vw
ZXJibG9jay4gKi8KKwlpdGVyYXRlX3N1cGVyc190eXBlKCZzaG1lbV9mc190eXBlLCBzaG1l
bV9zeW5jaHJvbml6ZV91bW91bnQsIE5VTEwpOworCiAJcmV0dXJuIGVycm9yOwogfQogCg==
--------------CB2AA163A547B315483B2E2F--

