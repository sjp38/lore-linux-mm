Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B39BF6B0074
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 21:17:55 -0400 (EDT)
Date: Fri, 26 Oct 2012 12:17:33 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/3] KVM: PPC: Book3S HV: More flexible allocator for
 linear memory
Message-ID: <20121026011733.GA31394@drongo>
References: <20120912003427.GH32642@bloggs.ozlabs.ibm.com>
 <9650229C-2512-4684-98EC-6E252E47C4A9@suse.de>
 <20120914081140.GC15028@bloggs.ozlabs.ibm.com>
 <F7ED8384-5B23-478C-B2B7-927A3A755E98@suse.de>
 <20120914124504.GF15028@bloggs.ozlabs.ibm.com>
 <C8AA7FDF-A559-46CF-8A6E-8D8B8163D38E@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C8AA7FDF-A559-46CF-8A6E-8D8B8163D38E@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: kvm-ppc@vger.kernel.org, KVM list <kvm@vger.kernel.org>, linux-mm@kvack.org, mina86@mina86.com

On Fri, Sep 14, 2012 at 03:15:32PM +0200, Alexander Graf wrote:
> 
> On 14.09.2012, at 14:45, Paul Mackerras wrote:
> 
> > On Fri, Sep 14, 2012 at 02:13:37PM +0200, Alexander Graf wrote:
> > 
> >> So do you think it makes more sense to reimplement a large page allocator in KVM, as this patch set does, or improve CMA to get us really big chunks of linear memory?
> >> 
> >> Let's ask the Linux mm guys too :). Maybe they have an idea.
> > 
> > I asked the authors of CMA, and apparently it's not limited to
> > MAX_ORDER as I feared.  It has the advantage that the memory can be
> > used for other things such as page cache when it's not needed, but not
> > for immovable allocations such as kmalloc.  I'm going to try it out.
> > It will need a patch to increase the maximum alignment it allows.
> 
> Awesome. Thanks a lot. I'd really prefer if we can stick to generic Linux solutions rather than invent our own :).

Turns out there is a difficulty with this.  When we have a guest page
that we want to pin in memory, and that page happens to have been
allocated within the CMA region, we would need to migrate it out of
the CMA region before pinning it, since otherwise it would reduce the
amount of contiguous memory available.  But it appears that there
isn't any way to do that.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
