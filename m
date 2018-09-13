Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 422218E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:37:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 1-v6so4090005qtp.10
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 00:37:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m36-v6si2456242qtd.251.2018.09.13.00.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 00:37:33 -0700 (PDT)
Date: Thu, 13 Sep 2018 15:37:22 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH v2] mm: mprotect: check page dirty when change ptes
Message-ID: <20180913073722.GF10763@xz-x1>
References: <20180912064921.31015-1-peterx@redhat.com>
 <20180912130355.GA4009@redhat.com>
 <20180912132438.GB4009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180912132438.GB4009@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Khalid Aziz <khalid.aziz@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <ak@linux.intel.com>, Henry Willard <henry.willard@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org

On Wed, Sep 12, 2018 at 09:24:39AM -0400, Jerome Glisse wrote:
> On Wed, Sep 12, 2018 at 09:03:55AM -0400, Jerome Glisse wrote:
> > On Wed, Sep 12, 2018 at 02:49:21PM +0800, Peter Xu wrote:
> > > Add an extra check on page dirty bit in change_pte_range() since there
> > > might be case where PTE dirty bit is unset but it's actually dirtied.
> > > One example is when a huge PMD is splitted after written: the dirty bit
> > > will be set on the compound page however we won't have the dirty bit set
> > > on each of the small page PTEs.
> > > 
> > > I noticed this when debugging with a customized kernel that implemented
> > > userfaultfd write-protect.  In that case, the dirty bit will be critical
> > > since that's required for userspace to handle the write protect page
> > > fault (otherwise it'll get a SIGBUS with a loop of page faults).
> > > However it should still be good even for upstream Linux to cover more
> > > scenarios where we shouldn't need to do extra page faults on the small
> > > pages if the previous huge page is already written, so the dirty bit
> > > optimization path underneath can cover more.
> > > 
> > 
> > So as said by Kirill NAK you are not looking at the right place for
> > your bug please first apply the below patch and read my analysis in
> > my last reply.
> 
> Just to be clear you are trying to fix a userspace bug that is hidden
> for non THP pages by a kernel space bug inside userfaultfd by making
> the kernel space bug of userfaultfd buggy for THP too.
> 
> 
> > 
> > Below patch fix userfaultfd bug. I am not posting it as it is on a
> > branch and i am not sure when Andrea plan to post. Andrea feel free
> > to squash that fix.
> > 
> > 
> > From 35cdb30afa86424c2b9f23c0982afa6731be961c Mon Sep 17 00:00:00 2001
> > From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> > Date: Wed, 12 Sep 2018 08:58:33 -0400
> > Subject: [PATCH] userfaultfd: do not set dirty accountable when changing
> >  protection
> > MIME-Version: 1.0
> > Content-Type: text/plain; charset=UTF-8
> > Content-Transfer-Encoding: 8bit
> > 
> > mwriteprotect_range() has nothing to do with the dirty accountable
> > optimization so do not set it as it opens a door for userspace to
> > unwrite protect pages in a range that is write protected ie the vma
> > !(vm_flags & VM_WRITE).
> > 
> > Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> > ---
> >  mm/userfaultfd.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index a0379c5ffa7c..59db1ce48fa0 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -632,7 +632,7 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> >  		newprot = vm_get_page_prot(dst_vma->vm_flags);
> >  
> >  	change_protection(dst_vma, start, start + len, newprot,
> > -				!enable_wp, 0);
> > +				false, 0);
> >  
> >  	err = 0;
> >  out_unlock:

Hi, Jerome,

I tried your patch, unluckily it didn't work just like when not
applied:

Sep 13 15:16:52 px-ws kernel: FAULT_FLAG_ALLOW_RETRY missing 71
Sep 13 15:16:52 px-ws kernel: CPU: 5 PID: 1625 Comm: qemu-system-x86 Not tainted 4.19.0-rc2+ #31                                                                            
Sep 13 15:16:52 px-ws kernel: Hardware name: LENOVO ThinkCentre M8500t-N000/SHARKBAY, BIOS FBKTC6AUS 06/22/2016                                                             
Sep 13 15:16:52 px-ws kernel: Call Trace:
Sep 13 15:16:52 px-ws kernel:  dump_stack+0x5c/0x7b
Sep 13 15:16:52 px-ws kernel:  handle_userfault+0x4b5/0x780
Sep 13 15:16:52 px-ws kernel:  ? userfaultfd_ctx_put+0xb0/0xb0
Sep 13 15:16:52 px-ws kernel:  do_wp_page+0x1bd/0x5a0
Sep 13 15:16:52 px-ws kernel:  __handle_mm_fault+0x7f9/0x1250
Sep 13 15:16:52 px-ws kernel:  handle_mm_fault+0xfc/0x1f0
Sep 13 15:16:52 px-ws kernel:  __do_page_fault+0x255/0x520
Sep 13 15:16:52 px-ws kernel:  do_page_fault+0x32/0x110
Sep 13 15:16:52 px-ws kernel:  ? page_fault+0x8/0x30
Sep 13 15:16:52 px-ws kernel:  page_fault+0x1e/0x30
Sep 13 15:16:52 px-ws kernel: RIP: 0033:0x7f2a9d3254e0
Sep 13 15:16:52 px-ws kernel: Code: 73 01 c1 ef 07 48 81 e6 00 f0 ff ff 81 e7 e0 1f 00 00 49 8d bc 3e 40 57 00 00 48 3b 37 48 8b f3 0f 85 a4 01 00 00 48 03 77 10 <66> 89 06f
Sep 13 15:16:52 px-ws kernel: RSP: 002b:00007f2ab1aae390 EFLAGS: 00010202
Sep 13 15:16:52 px-ws kernel: RAX: 0000000000000246 RBX: 0000000000001ff2 RCX: 0000000000000031                                                                             
Sep 13 15:16:52 px-ws kernel: RDX: ffffffffffac9604 RSI: 00007f2a53e01ff2 RDI: 000055a98fa049c0                                                                             
Sep 13 15:16:52 px-ws kernel: RBP: 0000000000001ff4 R08: 0000000000000000 R09: 0000000000000002                                                                             
Sep 13 15:16:52 px-ws kernel: R10: 0000000000000000 R11: 00007f2a98201030 R12: 0000000000001ff2                                                                             
Sep 13 15:16:52 px-ws kernel: R13: 0000000000000000 R14: 000055a98f9ff260 R15: 00007f2ab1aaf700                                                                             

In case you'd like to try, here's the QEMU binary I'm testing:

https://github.com/xzpeter/qemu/tree/peter-userfault-wp-test

It write protects the whole system when received HMP command "info
status" (I hacked that command for simplicity; it's of course not used
for that...).

Would you please help me understand how your patch could resolve the
wp page fault from userspace if not with dirty_accountable set in the
uffd-wp world (sorry for asking a question that is related to a custom
tree, but finally it'll be targeted at upstream after all)? I asked
this question in my previous reply to you in v1 but you didn't
respond.  I'd be glad to test any of your further patches if you can
help solve the problem, but I'd also appreciate if you could explain
it a bit on how it work since again I didn't see why it could work:
again, if without that dirty_accountable set then IMO we will never
setup _PAGE_WRITE for page entries and IMHO that's needed for
resolving the page fault for uffd-wp tree.

Also I'm trying to chew on Kirill's NAK to understand how to protect
the dirty flag.  I'd say I really have no quick idea on how I should
protect the dirty bit from being cleared concurrently.  Should I take
the lock_page() around that?  I am not sure since I saw callers of
ClearPageDirty() even without lock_page() called (e.g., in
cancel_dirty_page()).  Maybe it's just not working just like you said
- but I need some more time to figure that out due to my unfamiliarity
of mm code.  So if any of you could explain a bit more would be
appreciated too.

Thanks,

-- 
Peter Xu
