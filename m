Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B059F6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:56:47 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so10604814wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:56:47 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id fy8si33877343wjb.94.2015.05.06.05.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 05:56:46 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 May 2015 13:56:45 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 91E95219004D
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:56:23 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46CufkI5571026
	for <linux-mm@kvack.org>; Wed, 6 May 2015 12:56:41 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46CufIN007333
	for <linux-mm@kvack.org>; Wed, 6 May 2015 08:56:41 -0400
Date: Wed, 6 May 2015 14:56:40 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: TLB flushes on s390
Message-ID: <20150506145640.70ee8686@mschwide>
In-Reply-To: <20150506125000.GB17739@node.dhcp.inet.fi>
References: <20150506112939.GA17739@node.dhcp.inet.fi>
	<20150506140002.6f9e4e5d@mschwide>
	<20150506125000.GB17739@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org

On Wed, 6 May 2015 15:50:00 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Wed, May 06, 2015 at 02:00:02PM +0200, Martin Schwidefsky wrote:
> > On Wed, 6 May 2015 14:29:39 +0300
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > I'm looking though s390 code around page table handling and I found that
> > > in many places s390 does tlb flush before changing page table entry.
> > 
> > Uhh, have fun with that.. it is complicated :-/
> >  
> > > Let's look for instance on pmdp_clear_flush() implementation on s390.
> > > It's implemented with pmdp_get_and_clear() which does pmdp_flush_direct()
> > > *before* pmd_clear(). That's invert order comparing to generic
> > > pmdp_flush_direct().
> > > 
> > > The question is what prevents tlb from being re-fill between flushing tlb
> > > and clearing page table entry?
> >  
> > Look again at pmdp_flush_direct(), either __pmdp_idte_local or __pmdp_idte is
> > called. Both functions use the IDTE instruction but in two different flavors.
> > The mnemonic IDTE stands for invalidate-dat-table-entry, the instruction sets
> > the invalid bit in the PMD and flushes all TLB entries on all CPUs that are
> > affected by the now invalid PMD. The pmd_clear after the pmdp_flush_direct is
> > done to set all the other bits of the PMD to the "empty" state. The invalid
> > bit is already set prior to pmd_clear.
> 
> Okay, it makes some sense.
> 
> One more question: why does __tlb_flush_full()/__tlb_flush_asce() require
> disabling preemption and pmdp_flush_direct() doesn't?
 
Easy: for pmdp_flush_direct you are required to hold the pmd-lock as you
modify the pmd. The spinlock provides the preempt_disable.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
