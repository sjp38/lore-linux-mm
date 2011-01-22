Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 23F238D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 23:46:28 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p0M4kAjI027340
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 20:46:10 -0800
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by hpaq3.eem.corp.google.com with ESMTP id p0M4jbH5020925
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 20:46:09 -0800
Received: by pvf33 with SMTP id 33so762008pvf.15
        for <linux-mm@kvack.org>; Fri, 21 Jan 2011 20:46:08 -0800 (PST)
Date: Fri, 21 Jan 2011 20:46:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same
 inode
In-Reply-To: <E1PfvGx-00086O-IA@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LSU.2.00.1101212014330.4301@sister.anvils>
References: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu> <20110120124043.GA4347@infradead.org> <E1PfvGx-00086O-IA@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Miklos Szeredi wrote:
> On Thu, 20 Jan 2011, Christoph Hellwig wrote:
> > On Thu, Jan 20, 2011 at 01:30:58PM +0100, Miklos Szeredi wrote:
> > > 
> > > Truncate and hole punching already serialize with i_mutex.  Other
> > > callers of unmap_mapping_range() do not, and it's difficult to get
> > > i_mutex protection for all callers.  In particular ->d_revalidate(),
> > > which calls invalidate_inode_pages2_range() in fuse, may be called
> > > with or without i_mutex.
> > 
> > 
> > Which I think is mostly a fuse problem.  I really hate bloating the
> > generic inode (into which the address_space is embedded) with another
> > mutex for deficits in rather special case filesystems. 
> 
> As Hugh pointed out unmap_mapping_range() has grown a varied set of
> callers, which are difficult to fix up wrt i_mutex.  Fuse was just an
> example.
> 
> I don't like the bloat either, but this is the best I could come up
> with for fixing this problem generally.  If you have a better idea,
> please share it.

If we start from the point that this is mostly a fuse problem (I expect
that a thorough audit will show up a few other filesystems too, but
let's start from this point): you cite ->d_revalidate as a particular
problem, but can we fix up its call sites so that it is always called
either with, or much preferably without, i_mutex held?  Though actually
I couldn't find where ->d_revalidate() is called while holding i_mutex.

Failing that, can fuse down_write i_alloc_sem before calling
invalidate_inode_pages2(_range), to achieve the same exclusion?
The setattr truncation path takes i_alloc_sem as well as i_mutex,
though I'm not certain of its full coverage.

I did already consider holding and dropping i_alloc_sem inside
invalidate_inode_pages2_range(); but direct-io.c very much wants
to take mmap_sem (when get_user_pages_fast goes slow) after taking
i_alloc_sem, whereas fuse_direct_mmap() very much wants to call
invalidate_inode_pages2() while mmap_sem is held.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
