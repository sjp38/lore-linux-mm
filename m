Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72F9E6B4D6D
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 15:58:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s1-v6so5647430qte.19
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:58:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s49-v6si4689122qtb.17.2018.08.29.12.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 12:58:54 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180829075129.GU10223@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Message-ID: <374c2c5c-cc9b-af03-a800-32f2cf8a3055@redhat.com>
Date: Wed, 29 Aug 2018 15:58:52 -0400
MIME-Version: 1.0
In-Reply-To: <20180829075129.GU10223@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 08/29/2018 03:51 AM, Michal Hocko wrote:
> On Tue 28-08-18 13:19:40, Waiman Long wrote:
>> For negative dentries that are accessed once and never used again, the=
y
>> should be removed first before other dentries when shrinker is running=
=2E
>> This is done by putting negative dentries at the head of the LRU list
>> instead at the tail.
>>
>> A new DCACHE_NEW_NEGATIVE flag is now added to a negative dentry when =
it
>> is initially created. When such a dentry is added to the LRU, it will =
be
>> added to the head so that it will be the first to go when a shrinker i=
s
>> running if it is never accessed again (DCACHE_REFERENCED bit not set).=

>> The flag is cleared after the LRU list addition.
> Placing object to the head of the LRU list can be really tricky as Dave=

> pointed out. I am not familiar with the dentry cache reclaim so my
> comparison below might not apply. Let me try anyway.
>
> Negative dentries sound very similar to MADV_FREE pages from the reclai=
m
> POV. They are primary candidate for reclaim, yet you want to preserve
> aging to other easily reclaimable objects (including other MADV_FREE
> pages). What we do for those pages is to move them from the anonymous
> LRU list to the inactive file LRU list. Now you obviously do not have
> anon/file LRUs but something similar to active/inactive LRU lists might=

> be a reasonably good match. Have easily reclaimable dentries on the
> inactive list including negative dentries. If negative entries are
> heavily used then they can promote to the active list because there is
> no reason to reclaim them soon.
>
> Just my 2c

As mentioned in my reply to Dave, I did considered using a 2 LRU list
solution. However, that will add more complexity to the dcache LRU
management code than my current approach and probably more potential for
slowdown.

One point that I forgot to mention is that the current dcache LRU list
will only update the order of the dentries when the list is being
shrinked. If a dentry was referenced again before (the DCACHE_REFERENCED
bit set), it will rotated to the tail of the list via LRU rotation
instead of being removed. This is not strictly LRU anyway. The way that
my patch work will just make it move further away from true LRU behavior.=


Cheers,
Longman
