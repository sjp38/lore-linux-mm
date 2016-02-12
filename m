Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 87E7F6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:24:22 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so34323892wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:24:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vx5si21529368wjc.219.2016.02.12.12.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 12:24:21 -0800 (PST)
Date: Fri, 12 Feb 2016 15:24:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160212202405.GA32367@cmpxchg.org>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211153404.42055b27@cuia.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andres Freund <andres@anarazel.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Thu, Feb 11, 2016 at 03:34:04PM -0500, Rik van Riel wrote:
> On Tue, 9 Feb 2016 17:42:56 -0500
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Feb 09, 2016 at 05:52:40PM +0100, Andres Freund wrote:
> 
> > > Rik asked me about active/inactive sizing in /proc/meminfo:
> > > Active:          7860556 kB
> > > Inactive:        5395644 kB
> > > Active(anon):    2874936 kB
> > > Inactive(anon):   432308 kB
> > > Active(file):    4985620 kB
> > > Inactive(file):  4963336 kB
> 
> > Yes, a generous minimum size of the inactive list made sense when it
> > was the exclusive staging area to tell use-once pages from use-many
> > pages. Now that we have refault information to detect use-many with
> > arbitrary inactive list size, this minimum is no longer reasonable.
> > 
> > The new minimum should be smaller, but big enough for applications to
> > actually use the data in their pages between fault and eviction
> > (i.e. it needs to take the aggregate readahead window into account),
> > and big enough for active pages that are speculatively challenged
> > during workingset changes to get re-activated without incurring IO.
> > 
> > However, I don't think it makes sense to dynamically adjust the
> > balance between the active and the inactive cache during refaults.
> 
> Johannes, does this patch look ok to you?

Yes, the anon ratio we use looks like a good fit for file as well.

I've updated the patch to work with cgroups.
