Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f69.google.com (mail-qg0-f69.google.com [209.85.192.69])
	by kanga.kvack.org (Postfix) with ESMTP id 752526B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 19:21:31 -0400 (EDT)
Received: by mail-qg0-f69.google.com with SMTP id d90so145499593qgd.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 16:21:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u63si6056304qku.213.2016.04.28.16.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 16:21:30 -0700 (PDT)
Date: Fri, 29 Apr 2016 01:21:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160428232127.GL11700@redhat.com>
References: <20160428102051.17d1c728@t450s.home>
 <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428125808.29ad59e5@t450s.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello Alex and Kirill,

On Thu, Apr 28, 2016 at 12:58:08PM -0600, Alex Williamson wrote:
> > > specific fix to this code is not applicable.  It also still occurs on
> > > kernels as recent as v4.6-rc5, so the issue hasn't been silently fixed
> > > yet.  I'm able to reproduce this fairly quickly with the above test,
> > > but it's not hard to imagine a test w/o any iommu dependencies which
> > > simply does a user directed get_user_pages_fast() on a set of userspace
> > > addresses, retains the reference, and at some point later rechecks that
> > > a new get_user_pages_fast() results in the same page address.  It

Can you try to "git revert 1f25fe20a76af0d960172fb104d4b13697cafa84"
and then apply the below patch on top of the revert?

Totally untested... if I missed something and it isn't correct, I hope
this brings us in the right direction faster at least.

Overall the problem I think is that we need to restore full accuracy
and we can't deal with false positive COWs (which aren't entirely
cheap either... reading 512 cachelines should be much faster than
copying 2MB and using 4MB of CPU cache). 32k vs 4MB. The problem of
course is when we really need a COW, we'll waste an additional 32k,
but then it doesn't matter that much as we'd be forced to load 4MB of
cache anyway in such case. There's room for optimizations but even the
simple below patch would be ok for now.
