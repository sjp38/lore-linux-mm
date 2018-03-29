Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7B216B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:33:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id e15so2886032wrj.14
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:33:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor3372159edl.11.2018.03.29.07.33.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 07:33:53 -0700 (PDT)
Date: Thu, 29 Mar 2018 17:33:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180329143316.2qreoaw6dng2kvct@node.shutemov.name>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
 <20180329112034.GE31039@dhcp22.suse.cz>
 <20180329123712.zlo6qmstj3zm5v27@node.shutemov.name>
 <20180329125227.GF31039@dhcp22.suse.cz>
 <20180329131308.cq64n3dvnre2wcz5@node.shutemov.name>
 <20180329133700.GG31039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329133700.GG31039@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 29, 2018 at 03:37:00PM +0200, Michal Hocko wrote:
> On Thu 29-03-18 16:13:08, Kirill A. Shutemov wrote:
> > On Thu, Mar 29, 2018 at 02:52:27PM +0200, Michal Hocko wrote:
> > > On Thu 29-03-18 15:37:12, Kirill A. Shutemov wrote:
> > > > On Thu, Mar 29, 2018 at 01:20:34PM +0200, Michal Hocko wrote:
> > > > > On Wed 28-03-18 19:55:32, Kirill A. Shutemov wrote:
> > > > > > Modify several page allocation routines to pass down encryption KeyID to
> > > > > > be used for the allocated page.
> > > > > > 
> > > > > > There are two basic use cases:
> > > > > > 
> > > > > >  - alloc_page_vma() use VMA's KeyID to allocate the page.
> > > > > > 
> > > > > >  - Page migration and NUMA balancing path use KeyID of original page as
> > > > > >    KeyID for newly allocated page.
> > > > > 
> > > > > I am sorry but I am out of time to look closer but this just raised my
> > > > > eyebrows. This looks like a no-go. The basic allocator has no business
> > > > > in fancy stuff like a encryption key. If you need something like that
> > > > > then just build a special allocator API on top. This looks like a no-go
> > > > > to me.
> > > > 
> > > > The goal is to make memory encryption first class citizen in memory
> > > > management and not to invent parallel subsysustem (as we did with hugetlb).
> > > 
> > > How do you get a page_keyid for random kernel allocation?
> > 
> > Initial feature enabling only targets userspace anonymous memory, but we
> > can definately use the same technology in the future for kernel hardening
> > if we would choose so.
> 
> So what kind of key are you going to use for those allocations.

KeyID zero is default. You can think about this as do-not-encrypt.

In MKTME case it means that this memory is encrypted with TME key (random
generated at boot).

> Moreover why cannot you simply wrap those few places which are actually
> using the encryption now?

We can wrap these few places. And I tried this approach. It proved to be
slow.

Hardware doesn't enforce coherency between mappings of the same physical
page with different KeyIDs. OS is responsible for cache management: the
cache has flushed before switching the page to other KeyID.

As we allocate encrypted and unencrypted pages from the same pool, the
approach with wrapper forces us to flush cache on allocation (to switch it
non-zero KeyID) *and* freeing (to switch it back to KeyID-0) encrypted page.
We don't know if the page will be allocated next time using wrapper or
not, so we have to play safe.

This way it's about 4-6 times slower to allocate-free encrypted page
comparing to unencrypted one. On macrobenchmark, I see about 15% slowdown.

With approach I propose we can often avoid cache flushing: we can only
flush the cache on allocation and only if the page had different KeyID
last time it was allocated. It brings slowdown on macrobenchmark to 3.6%
which is more reasonable (more optimizations possible).

Other way to keep separate pool of encrypted pages within page allocator.
I think it would cause more troubles...

I would be glad to find less intrusive way to get reasonable performance.
Any suggestions?

> > For anonymous memory, we can get KeyID from VMA or from other page
> > (migration case).
> > 
> > > > Making memory encryption integral part of Linux VM would involve handing
> > > > encrypted page everywhere we expect anonymous page to appear.
> > > 
> > > How many architectures will implement this feature?
> > 
> > I can't read the future.
> 
> Fair enough, only few of us can, but you are proposing a generic code
> changes based on a single architecture design so we should better make
> sure other architectures can work with that approach without a major
> refactoring.

I tried to keep the implementation as generic as possible: VMA may be
encrypted, you can point to deseried key with an integer (KeyID),
allocation of encrypted page *may* require special handling.

Ther only assumption I made is that KeyID 0 is special, meaning
no-encryption. I think it's reasonable assumption, but easily
fixable if proved to be wrong.

If you see other places I made the abstaction too tied to specific HW
implementation, let me know.

-- 
 Kirill A. Shutemov
