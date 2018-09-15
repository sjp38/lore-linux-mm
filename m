Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76D8E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 20:42:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c22-v6so8713069qkb.18
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 17:42:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x36-v6si3790863qtd.317.2018.09.14.17.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 17:42:05 -0700 (PDT)
Date: Fri, 14 Sep 2018 20:41:57 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] mm: mprotect: check page dirty when change ptes
Message-ID: <20180915004157.GA15678@redhat.com>
References: <20180912064921.31015-1-peterx@redhat.com>
 <20180912130355.GA4009@redhat.com>
 <20180912132438.GB4009@redhat.com>
 <20180913073722.GF10763@xz-x1>
 <20180913142328.GA3576@redhat.com>
 <20180914004239.GA31077@redhat.com>
 <20180914071610.GL10763@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180914071610.GL10763@xz-x1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Khalid Aziz <khalid.aziz@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <ak@linux.intel.com>, Henry Willard <henry.willard@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org

On Fri, Sep 14, 2018 at 03:16:11PM +0800, Peter Xu wrote:
> On Thu, Sep 13, 2018 at 08:42:39PM -0400, Jerome Glisse wrote:
> > On Thu, Sep 13, 2018 at 10:23:28AM -0400, Jerome Glisse wrote:
> > > On Thu, Sep 13, 2018 at 03:37:22PM +0800, Peter Xu wrote:
> > > > On Wed, Sep 12, 2018 at 09:24:39AM -0400, Jerome Glisse wrote:
> > > > > On Wed, Sep 12, 2018 at 09:03:55AM -0400, Jerome Glisse wrote:
> > > > > > On Wed, Sep 12, 2018 at 02:49:21PM +0800, Peter Xu wrote:
> > > > > > > Add an extra check on page dirty bit in change_pte_range() since there
> > > > > > > might be case where PTE dirty bit is unset but it's actually dirtied.
> > > > > > > One example is when a huge PMD is splitted after written: the dirty bit
> > > > > > > will be set on the compound page however we won't have the dirty bit set
> > > > > > > on each of the small page PTEs.
> > > > > > > 
> > > > > > > I noticed this when debugging with a customized kernel that implemented
> > > > > > > userfaultfd write-protect.  In that case, the dirty bit will be critical
> > > > > > > since that's required for userspace to handle the write protect page
> > > > > > > fault (otherwise it'll get a SIGBUS with a loop of page faults).
> > > > > > > However it should still be good even for upstream Linux to cover more
> > > > > > > scenarios where we shouldn't need to do extra page faults on the small
> > > > > > > pages if the previous huge page is already written, so the dirty bit
> > > > > > > optimization path underneath can cover more.
> > > > > > > 
> > > > > > 
> > > > > > So as said by Kirill NAK you are not looking at the right place for
> > > > > > your bug please first apply the below patch and read my analysis in
> > > > > > my last reply.
> > > > > 
> > > > > Just to be clear you are trying to fix a userspace bug that is hidden
> > > > > for non THP pages by a kernel space bug inside userfaultfd by making
> > > > > the kernel space bug of userfaultfd buggy for THP too.
> > > > > 
> > > > > 
> > > > > > 
> > > > > > Below patch fix userfaultfd bug. I am not posting it as it is on a
> > > > > > branch and i am not sure when Andrea plan to post. Andrea feel free
> > > > > > to squash that fix.
> > > > > > 
> > > > > > 
> > > > > > From 35cdb30afa86424c2b9f23c0982afa6731be961c Mon Sep 17 00:00:00 2001
> > > > > > From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> > > > > > Date: Wed, 12 Sep 2018 08:58:33 -0400
> > > > > > Subject: [PATCH] userfaultfd: do not set dirty accountable when changing
> > > > > >  protection
> > > > > > MIME-Version: 1.0
> > > > > > Content-Type: text/plain; charset=UTF-8
> > > > > > Content-Transfer-Encoding: 8bit
> > > > > > 
> > > > > > mwriteprotect_range() has nothing to do with the dirty accountable
> > > > > > optimization so do not set it as it opens a door for userspace to
> > > > > > unwrite protect pages in a range that is write protected ie the vma
> > > > > > !(vm_flags & VM_WRITE).
> > > > > > 
> > > > > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > > > > ---
> > > > > >  mm/userfaultfd.c | 2 +-
> > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > 
> > > > > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > > > > index a0379c5ffa7c..59db1ce48fa0 100644
> > > > > > --- a/mm/userfaultfd.c
> > > > > > +++ b/mm/userfaultfd.c
> > > > > > @@ -632,7 +632,7 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > > > >  		newprot = vm_get_page_prot(dst_vma->vm_flags);
> > > > > >  
> > > > > >  	change_protection(dst_vma, start, start + len, newprot,
> > > > > > -				!enable_wp, 0);
> > > > > > +				false, 0);
> > > > > >  
> > > > > >  	err = 0;
> > > > > >  out_unlock:
> > > > 
> > > > Hi, Jerome,
> > > > 
> > > > I tried your patch, unluckily it didn't work just like when not
> > > > applied:
> > > > 
> > > > Sep 13 15:16:52 px-ws kernel: FAULT_FLAG_ALLOW_RETRY missing 71
> > > > Sep 13 15:16:52 px-ws kernel: CPU: 5 PID: 1625 Comm: qemu-system-x86 Not tainted 4.19.0-rc2+ #31                                                                            
> > > > Sep 13 15:16:52 px-ws kernel: Hardware name: LENOVO ThinkCentre M8500t-N000/SHARKBAY, BIOS FBKTC6AUS 06/22/2016                                                             
> > > > Sep 13 15:16:52 px-ws kernel: Call Trace:
> > > > Sep 13 15:16:52 px-ws kernel:  dump_stack+0x5c/0x7b
> > > > Sep 13 15:16:52 px-ws kernel:  handle_userfault+0x4b5/0x780
> > > > Sep 13 15:16:52 px-ws kernel:  ? userfaultfd_ctx_put+0xb0/0xb0
> > > > Sep 13 15:16:52 px-ws kernel:  do_wp_page+0x1bd/0x5a0
> > > > Sep 13 15:16:52 px-ws kernel:  __handle_mm_fault+0x7f9/0x1250
> > > > Sep 13 15:16:52 px-ws kernel:  handle_mm_fault+0xfc/0x1f0
> > > > Sep 13 15:16:52 px-ws kernel:  __do_page_fault+0x255/0x520
> > > > Sep 13 15:16:52 px-ws kernel:  do_page_fault+0x32/0x110
> > > > Sep 13 15:16:52 px-ws kernel:  ? page_fault+0x8/0x30
> > > > Sep 13 15:16:52 px-ws kernel:  page_fault+0x1e/0x30
> > > > Sep 13 15:16:52 px-ws kernel: RIP: 0033:0x7f2a9d3254e0
> > > > Sep 13 15:16:52 px-ws kernel: Code: 73 01 c1 ef 07 48 81 e6 00 f0 ff ff 81 e7 e0 1f 00 00 49 8d bc 3e 40 57 00 00 48 3b 37 48 8b f3 0f 85 a4 01 00 00 48 03 77 10 <66> 89 06f
> > > > Sep 13 15:16:52 px-ws kernel: RSP: 002b:00007f2ab1aae390 EFLAGS: 00010202
> > > > Sep 13 15:16:52 px-ws kernel: RAX: 0000000000000246 RBX: 0000000000001ff2 RCX: 0000000000000031                                                                             
> > > > Sep 13 15:16:52 px-ws kernel: RDX: ffffffffffac9604 RSI: 00007f2a53e01ff2 RDI: 000055a98fa049c0                                                                             
> > > > Sep 13 15:16:52 px-ws kernel: RBP: 0000000000001ff4 R08: 0000000000000000 R09: 0000000000000002                                                                             
> > > > Sep 13 15:16:52 px-ws kernel: R10: 0000000000000000 R11: 00007f2a98201030 R12: 0000000000001ff2                                                                             
> > > > Sep 13 15:16:52 px-ws kernel: R13: 0000000000000000 R14: 000055a98f9ff260 R15: 00007f2ab1aaf700                                                                             
> > > > 
> > > > In case you'd like to try, here's the QEMU binary I'm testing:
> > > > 
> > > > https://github.com/xzpeter/qemu/tree/peter-userfault-wp-test
> > > > 
> > > > It write protects the whole system when received HMP command "info
> > > > status" (I hacked that command for simplicity; it's of course not used
> > > > for that...).
> > > > 
> > > > Would you please help me understand how your patch could resolve the
> > > > wp page fault from userspace if not with dirty_accountable set in the
> > > > uffd-wp world (sorry for asking a question that is related to a custom
> > > > tree, but finally it'll be targeted at upstream after all)? I asked
> > > > this question in my previous reply to you in v1 but you didn't
> > > > respond.  I'd be glad to test any of your further patches if you can
> > > > help solve the problem, but I'd also appreciate if you could explain
> > > > it a bit on how it work since again I didn't see why it could work:
> > > > again, if without that dirty_accountable set then IMO we will never
> > > > setup _PAGE_WRITE for page entries and IMHO that's needed for
> > > > resolving the page fault for uffd-wp tree.
> > > 
> > > I missed that reply and forgot about PAGE_COPY ... So below is
> > > what i believe a proper fix for your issue:
> > > 
> > 
> > Below is a slightly better one to avoid mkwrite on COW page but it is
> > still kind of ugly to do that in those function maybe adding a new helper
> > would be a better way dunno. Anyway untested but it is better than trying
> > to set pte dirty.
> > 
> > 

[...]

> 
> Hi, Jerome,
> 
> The first version worked for me but the 2nd didn't.  Both will need to
> be fixed up by myself to at least pass the compilation so I'm not sure
> whether the 2nd patch didn't work because of my changes or your patch
> is broken.  Didn't spend more time to dig.
> 
> Anyway, thanks for these attempts and your help.  Let me know if you
> want me to test a 3rd version, or I'll just keep the 1st patch here in
> my local tree together with the rest of the work (I'd say that's far
> easier to understand than the previous oneliner) since it at least
> fixes the thing up.
> 
> Regards,

I fixed the build issue below just in case but it is untested.

If the second version do not work then page are likely real COW page ie
mapcount is elevated because of a fork() (thought maybe userfaultfd do
something there too).

I am not familiar with how userfault works to determine if it is expected
we should not allow write to anonymous page that have page mapping
elevated, maybe you check the mapcount on the page.


Cheers,
Jerome
