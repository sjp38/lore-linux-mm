Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id D52F96B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:30:36 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id t60so7242188wes.18
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 14:30:36 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id d41si21596824eep.176.2014.01.13.14.30.36
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 14:30:36 -0800 (PST)
Date: Tue, 14 Jan 2014 00:30:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] powerpc: thp: Fix crash on mremap
Message-ID: <20140113223028.GA8488@node.dhcp.inet.fi>
References: <1388570027-22933-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1388572145.4373.41.camel@pasglop>
 <20140102021951.GA26369@node.dhcp.inet.fi>
 <20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Jan 13, 2014 at 02:17:48PM -0800, Andrew Morton wrote:
> On Thu, 2 Jan 2014 04:19:51 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Wed, Jan 01, 2014 at 09:29:05PM +1100, Benjamin Herrenschmidt wrote:
> > > On Wed, 2014-01-01 at 15:23 +0530, Aneesh Kumar K.V wrote:
> > > > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > > > 
> > > > This patch fix the below crash
> > > > 
> > > > NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
> > > > LR [c0000000000439ac] .hash_page+0x18c/0x5e0
> > > > ...
> > > > Call Trace:
> > > > [c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
> > > > [437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
> > > > [437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58
> > > > 
> > > > On ppc64 we use the pgtable for storing the hpte slot information and
> > > > store address to the pgtable at a constant offset (PTRS_PER_PMD) from
> > > > pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
> > > > the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
> > > > from new pmd.
> > > > 
> > > > We also want to move the withdraw and deposit before the set_pmd so
> > > > that, when page fault find the pmd as trans huge we can be sure that
> > > > pgtable can be located at the offset.
> > > > 
> 
> Did this get fixed?

New version: http://thread.gmane.org/gmane.linux.kernel.mm/111809

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
