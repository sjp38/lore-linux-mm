Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA1F46B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:30:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w14-v6so3873763pfn.13
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 18:30:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w9-v6si22435468pfg.234.2018.07.16.18.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Jul 2018 18:30:35 -0700 (PDT)
Date: Mon, 16 Jul 2018 18:30:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180717013019.GA7934@bombadil.infradead.org>
References: <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
 <20180716124115.GA7072@bombadil.infradead.org>
 <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Chinner <david@fromorbit.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Mon, Jul 16, 2018 at 04:40:32PM -0700, Andrew Morton wrote:
> On Mon, 16 Jul 2018 05:41:15 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Mon, Jul 16, 2018 at 11:09:01AM +0200, Michal Hocko wrote:
> > > On Fri 13-07-18 10:36:14, Dave Chinner wrote:
> > > [...]
> > > > By limiting the number of negative dentries in this case, internal
> > > > slab fragmentation is reduced such that reclaim cost never gets out
> > > > of control. While it appears to "fix" the symptoms, it doesn't
> > > > address the underlying problem. It is a partial solution at best but
> > > > at worst it's another opaque knob that nobody knows how or when to
> > > > tune.
> > > 
> > > Would it help to put all the negative dentries into its own slab cache?
> > 
> > Maybe the dcache should be more sensitive to its own needs.  In __d_alloc,
> > it could check whether there are a high proportion of negative dentries
> > and start recycling some existing negative dentries.
> 
> Well, yes.
> 
> The proposed patchset adds all this background reclaiming.  Problem is
> a) that background reclaiming sometimes can't keep up so a synchronous
> direct-reclaim was added on top and b) reclaiming dentries in the
> background will cause non-dentry-allocating tasks to suffer because of
> activity from the dentry-allocating tasks, which is inappropriate.

... and it's an awful lot of code (almost 600 lines!) to implement
something fairly conceptually simple.

> I expect a better design is something like
> 
> __d_alloc()
> {
> 	...
> 	while (too many dentries)
> 		call the dcache shrinker
> 	...
> }
> 
> and that's it.  This way we have a hard upper limit and only the tasks
> which are creating dentries suffer the cost.

I think the "too many total dentries" is probably handled just fine
by the core MM.  What the dentry cache needs to prevent is adding a
disproportionately large number of useless negative dentries.  

So I'd rather see:

	if (too_many_negative(nr_dentry, nr_dentry_neg))
		reclaim_negative_dentries(16);
	...

16 feels like a fairly natural batch size.  I don't know what
too_many_negative() looks like.  Maybe it's:

bool too_many_negative(unsigned int total, unsigned int neg)
{
	if (neg < 100)
		return false;
	if (neg * 5 < total * 2)
		return false;
	return true;
}

but it could be almost arbitrarily complex.  I do think it needs to
scale with the total number of dentries, not scale with memory size of
the machine or the number of CPUs or anything similar.
