Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B09006B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:42:53 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so63334834wgy.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:42:53 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id fh5si928399wic.14.2015.04.24.14.42.48
        for <linux-mm@kvack.org>;
        Fri, 24 Apr 2015 14:42:49 -0700 (PDT)
Date: Sat, 25 Apr 2015 00:42:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150424214225.GA18804@node.dhcp.inet.fi>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
 <20150422131219.GD6897@pd.tnic>
 <20150422183309.GA4351@node.dhcp.inet.fi>
 <CA+55aFx5NXDUsyd2qjQ+Uu3mt9Fw4HrsonzREs9V0PhHwWmGPQ@mail.gmail.com>
 <20150423162311.GB19709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150423162311.GB19709@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Thu, Apr 23, 2015 at 06:23:11PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 22, 2015 at 12:26:55PM -0700, Linus Torvalds wrote:
> > On Wed, Apr 22, 2015 at 11:33 AM, Kirill A. Shutemov
> > <kirill@shutemov.name> wrote:
> > >
> > > Could you try patch below instead? This can give a clue what's going on.
> > 
> > Just FYI, I've done the revert in my tree.
> > 
> > Trying to figure out what is going on despite that is obviously a good
> > idea, but I'm hoping that my merge window is winding down, so I am
> > trying to make sure it's all "good to go"..
> 
> Sounds safer to defer it, agreed.
> 
> Unfortunately I also can only reproduce it only on a workstation where
> it wasn't very handy to debug it as it'd disrupt my workflow and it
> isn't equipped with reliable logging either (and the KMS mode didn't
> switch to console to show me the oops either). It just got it logged
> once in syslog before freezing.
> 
> The problem has to be that there's some get_page/put_page activity
> before and after a PageAnon transition and it looks like a tail page
> got mapped by hand in userland by some driver using 4k ptes which
> isn't normal

Compound pages mapped with PTEs predates THP. See f3d48f0373c1.

> but apparently safe before the patch was applied. Before
> the patch, the tail page accounting would be symmetric regardless of
> the PageAnon transition.
> 
> page:ffffea0010226040 count:0 mapcount:1 mapping:          (null) index:0x0
> flags: 0x8000000000008010(dirty|tail)
> page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
> ------------[ cut here ]------------
> kernel BUG at mm/swap.c:134!

I looked into code a bit more. And the VM_BUG_ON_PAGE() is bogus. See
explanation in commit message below.

Tail page refcounting is mess. Please consider reviewing my patchset which
drops it [1]. ;)

Linus, how should we proceed with reverted patch? Should I re-submit it to
Andrew? Or you'll re-revert it?

[1] lkml.kernel.org/g/1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com
