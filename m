Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE5C6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 18:11:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so6939943plh.7
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 15:11:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u6-v6si6848963plm.239.2018.04.05.15.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 15:11:25 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:11:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-Id: <20180405151123.df20d12168d8a38f7a6b02b5@linux-foundation.org>
In-Reply-To: <20180313004532.GU30522@ZenIV.linux.org.uk>
References: <20180305133743.12746-1-guro@fb.com>
	<20180305133743.12746-5-guro@fb.com>
	<20180312211742.GR30522@ZenIV.linux.org.uk>
	<20180312223632.GA6124@castle>
	<20180313004532.GU30522@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 13 Mar 2018 00:45:32 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Mar 12, 2018 at 10:36:38PM +0000, Roman Gushchin wrote:
> 
> > Ah, I see...
> > 
> > I think, it's better to account them when we're actually freeing,
> > otherwise we will have strange path:
> > (indirectly) reclaimable -> unreclaimable -> free
> > 
> > Do you agree?
> 
> > +static void __d_free_external_name(struct rcu_head *head)
> > +{
> > +	struct external_name *name;
> > +
> > +	name = container_of(head, struct external_name, u.head);
> > +
> > +	mod_node_page_state(page_pgdat(virt_to_page(name)),
> > +			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
> > +			    -ksize(name));
> > +
> > +	kfree(name);
> > +}
> 
> Maybe, but then you want to call that from __d_free_external() and from
> failure path in __d_alloc() as well.  Duplicating something that convoluted
> and easy to get out of sync is just asking for trouble.

So.. where are we at with this issue?
