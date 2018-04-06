Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E79F6B0011
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 06:33:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so585817plf.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 03:33:26 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w22-v6si7699943plq.115.2018.04.06.03.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 03:33:25 -0700 (PDT)
Date: Fri, 6 Apr 2018 11:32:56 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180406103250.GA3717@castle>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180312211742.GR30522@ZenIV.linux.org.uk>
 <20180312223632.GA6124@castle>
 <20180313004532.GU30522@ZenIV.linux.org.uk>
 <20180405151123.df20d12168d8a38f7a6b02b5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180405151123.df20d12168d8a38f7a6b02b5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Apr 05, 2018 at 03:11:23PM -0700, Andrew Morton wrote:
> On Tue, 13 Mar 2018 00:45:32 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > On Mon, Mar 12, 2018 at 10:36:38PM +0000, Roman Gushchin wrote:
> > 
> > > Ah, I see...
> > > 
> > > I think, it's better to account them when we're actually freeing,
> > > otherwise we will have strange path:
> > > (indirectly) reclaimable -> unreclaimable -> free
> > > 
> > > Do you agree?
> > 
> > > +static void __d_free_external_name(struct rcu_head *head)
> > > +{
> > > +	struct external_name *name;
> > > +
> > > +	name = container_of(head, struct external_name, u.head);
> > > +
> > > +	mod_node_page_state(page_pgdat(virt_to_page(name)),
> > > +			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
> > > +			    -ksize(name));
> > > +
> > > +	kfree(name);
> > > +}
> > 
> > Maybe, but then you want to call that from __d_free_external() and from
> > failure path in __d_alloc() as well.  Duplicating something that convoluted
> > and easy to get out of sync is just asking for trouble.
> 
> So.. where are we at with this issue?

I assume that commit 0babe6fe1da3 ("dcache: fix indirectly reclaimable memory accounting")
address the issue.

__d_free_external_name() is now called from all release paths (including __d_free_external())
and is the only place where NR_INDIRECTLY_RECLAIMABLE_BYTES is decremented.

__d_alloc()'s error path is slightly different, because I bump NR_INDIRECTLY_RECLAIMABLE_BYTES
in a very last moment, when it's already clear, that no errors did occur.
So we don't need to increase and decrease the counter back and forth.

Thank you!
