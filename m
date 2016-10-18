Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFFD06B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:30:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so2535100wme.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:30:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x128si730016wmb.76.2016.10.18.11.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 11:30:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id g16so661024wmg.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:30:25 -0700 (PDT)
Date: Tue, 18 Oct 2016 20:30:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161018183023.GC27792@dhcp22.suse.cz>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018143207.GA5833@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 18-10-16 17:32:07, Kirill A. Shutemov wrote:
> On Tue, Oct 18, 2016 at 04:20:07PM +0200, Michal Hocko wrote:
> > On Mon 17-10-16 17:55:40, Kirill A. Shutemov wrote:
> > > On Mon, Oct 17, 2016 at 04:12:46PM +0200, Michal Hocko wrote:
> > > > On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
> > [...]
> > > > > We add two handle to specify minimal file size for huge pages:
> > > > > 
> > > > >   - mount option 'huge_min_size';
> > > > > 
> > > > >   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
> > > > >     in-kernel tmpfs mountpoint;
> > > > 
> > > > Could you explain who might like to change the minimum value (other than
> > > > disable the feautre for the mount point) and for what reason?
> > > 
> > > Depending on how well CPU microarchitecture deals with huge pages, you
> > > might need to set it higher in order to balance out overhead with benefit
> > > of huge pages.
> > 
> > I am not sure this is a good argument. How do a user know and what will
> > help to make that decision? Why we cannot autotune that? In other words,
> > adding new knobs just in case turned out to be a bad idea in the past.
> 
> Well, I don't see a reasonable way to autotune it. We can just let
> arch-specific code to redefine it, but the argument below still stands.
> 
> > > In other case, if it's known in advance that specific mount would be
> > > populated with large files, you might want to set it to zero to get huge
> > > pages allocated from the beginning.

Do you think this is a sufficient reason to provide a tunable with such a
precision? In other words why cannot we simply start by using an
internal only limit at the huge page size for the initial transition
(with a way to disable THP altogether for a mount point) and only add a
more fine grained tunning if there ever is a real need for it with a use
case description. In other words can we be less optimistic about
tunables than we used to be in the past and often found out that those
were mistakes much later?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
