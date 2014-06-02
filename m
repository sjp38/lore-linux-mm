Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 631D36B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:49:36 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id m15so5416294wgh.32
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:49:35 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id gg4si26215568wjd.15.2014.06.02.08.49.34
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:49:34 -0700 (PDT)
Date: Mon, 2 Jun 2014 18:49:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
Message-ID: <20140602154925.GB8160@node.dhcp.inet.fi>
References: <538CAA520200007800016E87@mail.emea.novell.com>
 <20140602151629.GA8160@node.dhcp.inet.fi>
 <538CB4180200007800016F7F@mail.emea.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <538CB4180200007800016F7F@mail.emea.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: David Vrabel <david.vrabel@citrix.com>, mingo@elte.hu, linux-mm@kvack.org, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

On Mon, Jun 02, 2014 at 04:27:52PM +0100, Jan Beulich wrote:
> >>> On 02.06.14 at 17:16, <kirill@shutemov.name> wrote:
> > On Mon, Jun 02, 2014 at 03:46:10PM +0100, Jan Beulich wrote:
> >> For cold page allocations using the normal clear_highpage() mechanism
> >> may be inefficient on certain architectures, namely due to needlessly
> >> replacing a good part of the data cache contents. Introduce an arch-
> >> overridable clear_cold_highpage() (using streaming non-temporal stores
> >> on x86, where an override gets implemented right away) to make use of
> >> in this specific case.
> >> 
> >> Leverage the impovement in the Xen balloon driver, eliminating the
> >> explicit scrub_page() function.
> > 
> > Any benchmark data?
> > 
> > I've tried non-temporal stores to clear huge pages, but it didn't helped
> > much. I believe it can vary between micro-architectures, but we need
> > numbers. I've played with Westmere that time.
> 
> It's not at all clear to me what to measure here - after all this isn't
> about improving the page clearing latency or throughput, but about
> avoiding to disturb other operations.

It would be nice to find a workload which benefits from not trashing cache
from page allocator.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
