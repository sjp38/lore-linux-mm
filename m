Received: from [10.10.97.164]([10.10.97.164]) (2361 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1Izwae-00005ZC@megami.veritas.com>
	for <linux-mm@kvack.org>; Wed, 5 Dec 2007 07:55:12 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Wed, 5 Dec 2007 15:54:46 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_referenced() and VM_LOCKED
In-Reply-To: <4755F041.4000605@google.com>
Message-ID: <Pine.LNX.4.64.0712051538390.10505@blonde.wat.veritas.com>
References: <473D1BC9.8050904@google.com> <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com> <4755F041.4000605@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Dec 2007, Ethan Solomita wrote:
> Hugh Dickins wrote:
> > On Fri, 16 Nov 2007, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 15 Nov 2007 20:25:45 -0800
> > > Ethan Solomita <solo@google.com> wrote:
> > >
> > > > page_referenced_file() checks for the vma to be VM_LOCKED|VM_MAYSHARE
> > > > and adds returns 1.
> > 
> > That's a case where it can deduce that the page is present and should
> > be treated as referenced, without even examining the page tables.
> > 
> > > > We don't do the same in page_referenced_anon().
> > 
> > It cannot make that same deduction in the page_referenced_anon() case
> > (different vmas may well contain different COWs of some original page).
> 
> Sorry to come back in with this so late --
> if the vma is VM_MAYSHARE, would there be COWs of the original page?

99.999% correct answer: No, that's why we're testing VM_MAYSHARE,
because we know it has to be that original page which is present
and locked there (it might be readwrite, or it might be readonly,
but it won't be a COWed copy in a VM_MAYSHARE vma; the same would
be true if we tested VM_SHARED, but that would miss readonly cases).

00.001% adjustment: Actually, there's an aberrant case in which
do_wp_page() can put a COW into a VM_MAYSHARE area, supposedly to
suit ptrace().  I overlooked that case when I put the VM_MAYSHARE
test into page_referenced_file(); later when I learnt about it
(and found Linus unwilling to change it), I did an audit of such
oversights, but concluded this test wasn't worth changing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
