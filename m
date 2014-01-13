Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 972466B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:17:51 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so413154pab.40
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 14:17:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nu5si16882625pbc.58.2014.01.13.14.17.49
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 14:17:50 -0800 (PST)
Date: Mon, 13 Jan 2014 14:17:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] powerpc: thp: Fix crash on mremap
Message-Id: <20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
In-Reply-To: <20140102021951.GA26369@node.dhcp.inet.fi>
References: <1388570027-22933-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1388572145.4373.41.camel@pasglop>
	<20140102021951.GA26369@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 2 Jan 2014 04:19:51 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Wed, Jan 01, 2014 at 09:29:05PM +1100, Benjamin Herrenschmidt wrote:
> > On Wed, 2014-01-01 at 15:23 +0530, Aneesh Kumar K.V wrote:
> > > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > > 
> > > This patch fix the below crash
> > > 
> > > NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
> > > LR [c0000000000439ac] .hash_page+0x18c/0x5e0
> > > ...
> > > Call Trace:
> > > [c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
> > > [437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
> > > [437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58
> > > 
> > > On ppc64 we use the pgtable for storing the hpte slot information and
> > > store address to the pgtable at a constant offset (PTRS_PER_PMD) from
> > > pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
> > > the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
> > > from new pmd.
> > > 
> > > We also want to move the withdraw and deposit before the set_pmd so
> > > that, when page fault find the pmd as trans huge we can be sure that
> > > pgtable can be located at the offset.
> > > 

Did this get fixed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
