Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B45756B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 19:30:07 -0500 (EST)
Received: by mail-ia0-f176.google.com with SMTP id y26so14100541iab.7
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 16:30:07 -0800 (PST)
Message-ID: <1357345807.5273.6.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
From: Simon Jeons <simon.jeons@gmail.com>
Date: Fri, 04 Jan 2013 18:30:07 -0600
In-Reply-To: <alpine.LNX.2.00.1301041446340.4863@eggly.anvils>
References: <20121224050817.GA25749@kroah.com>
	 <1356658337-12540-1-git-send-email-pholasek@redhat.com>
	 <1357030004.1379.4.camel@kernel.cn.ibm.com>
	 <alpine.LNX.2.00.1301022050450.979@eggly.anvils>
	 <1357259044.4930.4.camel@kernel.cn.ibm.com>
	 <alpine.LNX.2.00.1301041446340.4863@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 2013-01-04 at 15:03 -0800, Hugh Dickins wrote:
> On Thu, 3 Jan 2013, Simon Jeons wrote:
> > On Wed, 2013-01-02 at 21:10 -0800, Hugh Dickins wrote:
> > > 
> > > As you can see, remove_rmap_item_from_tree uses it to decide whether
> > > or not it should rb_erase the rmap_item from the unstable_tree.
> > > 
> > > Every full scan of all the rmap_items, we increment ksm_scan.seqnr,
> > > forget the old unstable_tree (it would just be a waste of processing
> > > to remove every node one by one), and build up the unstable_tree afresh.
> > > 
> > 
> > When the rmap_items left over from the previous scan will be removed?
> 
> Removed from the unstable rbtree?  Not at all, it's simply restarted
> afresh, and the old rblinkages ignored.  Freed back to slab?  When the
> scan passes that mm+address and realizes that rmap_item is not wanted
> any more.  (Or when ksm is shut down with KSM_RUN_UNMERGE.)
> 

Make sense. Thanks Hugh. :)

> > 
> > > That works fine until we need to remove an rmap_item: then we have to be
> > > very sure to remove it from the unstable_tree if it's already been linked
> > > there during this scan, but ignore its rblinkage if that's just left over
> > > from the previous scan.
> > > 
> > > A single bit would be enough to decide this; but we got it troublesomely
> > > wrong in the early days of KSM (didn't always visit every rmap_item each
> > > scan), so it's convenient to use 8 bits (the low unsigned char, stored
> > 
> > When the scenario didn't always visit every rmap_item each scan can
> > occur? 
> 
> You're asking me about a stage of KSM development 3.5 years ago:
> I don't remember the details.
> 
> > 
> > > below the FLAGs and below the page-aligned address in the rmap_item -
> > > there's lots of them, best keep them as small as we can) and do a
> > > BUG_ON(age > 1) if we made a mistake.
> > > 
> > > We haven't hit that BUG_ON in over three years: if we need some more
> > > bits for something, we can cut the age down to one or two bits.
> > > 
> > > Hugh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
