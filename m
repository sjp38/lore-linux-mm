Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 273926B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 07:03:32 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o25C3TNP008202
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 04:03:29 -0800
Received: from fxm5 (fxm5.prod.google.com [10.184.13.5])
	by wpaz37.hot.corp.google.com with ESMTP id o25C3RZj023461
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 04:03:28 -0800
Received: by fxm5 with SMTP id 5so4009156fxm.29
        for <linux-mm@kvack.org>; Fri, 05 Mar 2010 04:03:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B8E3F77.6070201@cn.fujitsu.com>
References: <4B8E3F77.6070201@cn.fujitsu.com>
Date: Fri, 5 Mar 2010 04:03:26 -0800
Message-ID: <6599ad831003050403v2e988723k1b6bf38d48707ab1@mail.gmail.com>
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy and
	mems_allowed
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 3, 2010 at 2:52 AM, Miao Xie <miaox@cn.fujitsu.com> wrote:
> if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
> task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
> mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
> use a rwlock to protect them to fix this probelm.

Rather than adding locks, if the intention is just to avoid the
allocator seeing an empty nodemask couldn't we instead do the
equivalent of:

current->mems_allowed |= new_mask;
current->mems_allowed = new_mask;

i.e. effectively set all new bits in the nodemask first, and then
clear all old bits that are no longer in the new mask. The only
downside of this is that a page allocation that races with the update
could potentially allocate from any node in the union of the old and
new nodemasks - but that's the case anyway for an allocation that
races with an update, so I don't see that it's any worse.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
