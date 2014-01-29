Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id A77DE6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 20:19:51 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wn1so1281513obc.34
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:19:51 -0800 (PST)
Received: from g5t0007.atlanta.hp.com (g5t0007.atlanta.hp.com. [15.192.0.44])
        by mx.google.com with ESMTPS id so9si201172oeb.140.2014.01.28.17.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 17:19:50 -0800 (PST)
Message-ID: <1390958378.11839.37.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/8] mm, hugetlb: fix race in region tracking
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 28 Jan 2014 17:19:38 -0800
In-Reply-To: <1390955806-ljm7w9nq-mutt-n-horiguchi@ah.jp.nec.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
	 <1390794746-16755-4-git-send-email-davidlohr@hp.com>
	 <1390856576-ud1qp3fm-mutt-n-horiguchi@ah.jp.nec.com>
	 <1390859042.27421.4.camel@buesod1.americas.hpqcorp.net>
	 <1390874021-48f5mo0m-mutt-n-horiguchi@ah.jp.nec.com>
	 <1390876457.27421.19.camel@buesod1.americas.hpqcorp.net>
	 <1390955806-ljm7w9nq-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-01-28 at 19:36 -0500, Naoya Horiguchi wrote:
> On Mon, Jan 27, 2014 at 06:34:17PM -0800, Davidlohr Bueso wrote:
[...]
> > > If this retry is really essential for the fix, please comment the reason
> > > both in patch description and inline comment. It's very important for
> > > future code maintenance.
> > 
> > So we locate the corresponding region in the reserve map, and if we are
> > below the current region, then we allocate a new one. Since we dropped
> > the lock to allocate memory, we have to make sure that we still need the
> > new region and that we don't race with the new status of the reservation
> > map. This is the whole point of the retry, and I don't see it being
> > suboptimal.
> 
> I'm afraid that you don't explain why you need drop the lock for memory
> allocation. Are you saying that this unlocking comes from the difference
> between rwsem and spin lock?

Because you cannot go to sleep while holding a spinlock, which is
exactly what kmalloc(GFP_KERNEL) can do. We *might* get a way with it
with GFP_ATOMIC, I dunno, but I certainly prefer this approach better.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
