Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 495CC6B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 00:57:40 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so18982746pab.17
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 21:57:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ce5si1239326pad.58.2014.09.03.21.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 21:57:39 -0700 (PDT)
Message-ID: <5407F124.5070203@oracle.com>
Date: Thu, 04 Sep 2014 12:57:08 +0800
From: Junxiao Bi <junxiao.bi@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>	<20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>	<5407C989.50605@oracle.com> <20140903193058.2bc891a7.akpm@linux-foundation.org>
In-Reply-To: <20140903193058.2bc891a7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: david@fromorbit.com, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 09/04/2014 10:30 AM, Andrew Morton wrote:
> On Thu, 04 Sep 2014 10:08:09 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
> 
>> On 09/04/2014 07:10 AM, Andrew Morton wrote:
>>> On Wed,  3 Sep 2014 13:54:54 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
>>>
>>>> commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
>>>> introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
>>>> when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
>>>> run into I/O, like in superblock shrinker.
>>>
>>> Is there an actual bug which inspired this fix?  If so, please describe
>>> it.
>>>
>> Yes, an ocfs2 deadlock bug is related to this, there is a workqueue in
>> ocfs2 who is for building tcp connections and processing ocfs2 message.
>> Like when an new node is up in ocfs2 cluster, the workqueue will try to
>> build the connections to it, since there are some common code in
>> networking like sock_alloc() using GFP_KERNEL to allocate memory, direct
>> reclaim will be triggered and call into superblock shrinker if available
>> memory is not enough even set PF_MEMALLOC_NOIO for the workqueue. To
>> shrink the inode cache, ocfs2 needs release cluster lock and this
>> depends on workqueue to do it, so cause the deadlock. Not sure whether
>> there are similar issue for other cluster fs, like nfs, it is possible
>> rpciod hung like the ocfs2 workqueue?
> 
> All this info should be in the changelog.
> 
>>
>>> I don't think it's accurate to say that __GFP_FS implies __GFP_IO. 
>>> Where did that info come from?
>> __GFP_FS allowed callback into fs during memory allocation, and fs may
>> do io whatever __GFP_IO is set?
> 
> __GFP_FS and __GFP_IO are (or were) for communicating to vmscan: don't
> enter the fs for writepage, don't write back swapcache.
> 
> I guess those concepts have grown over time without a ton of thought
> going into it.  Yes, I suppose that if a filesystem's writepage is
> called (for example) it expects that it will be able to perform
> writeback and it won't check (or even be passed) the __GFP_IO setting.
> 
> So I guess we could say that !__GFP_FS && GFP_IO is not implemented and
> shouldn't occur.
> 
> That being said, it still seems quite bad to disable VFS cache
> shrinking for PF_MEMALLOC_NOIO allocation attempts.
Even without this ocfs2 deadlock bug, the implement of PF_MEMALLOC_NOIO
is wrong. See the deadlock case described in its log below. Let see the
case "block device runtime resume", since __GFP_FS is not cleared, it
could run into fs writepage and cause deadlock.
