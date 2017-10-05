Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5E9F6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 19:32:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so21329854pfd.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 16:32:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15sor35654pfm.129.2017.10.05.16.32.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 16:32:12 -0700 (PDT)
Date: Thu, 5 Oct 2017 16:32:07 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 00/20] Speculative page faults
Message-ID: <20171005233206.vpg446q5k2r4g27r@ast-mbp>
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
 <670c9a22-cf5b-3fab-b2f2-a72fbd4451c8@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <670c9a22-cf5b-3fab-b2f2-a72fbd4451c8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On Wed, Oct 04, 2017 at 08:50:49AM +0200, Laurent Dufour wrote:
> On 25/09/2017 18:27, Alexei Starovoitov wrote:
> > On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
> > <ldufour@linux.vnet.ibm.com> wrote:
> >> Despite the unprovable lockdep warning raised by Sergey, I didn't get any
> >> feedback on this series.
> >>
> >> Is there a chance to get it moved upstream ?
> > 
> > what is the status ?
> > We're eagerly looking forward for this set to land,
> > since we have several use cases for tracing that
> > will build on top of this set as discussed at Plumbers.
> 
> Hi Alexei,
> 
> Based on Plumber's note [1], it sounds that the use case is tied to the BPF
> tracing where a call tp find_vma() call will be made on a process's context
> to fetch user space's symbols.
> 
> Am I right ?
> Is the find_vma() call made in the context of the process owning the mm
> struct ?

Hi Laurent,

we're thinking about several use cases on top of your work.
First one is translation of user address to file_handle where
we need to do find_vma() from preempt_disabled context of bpf program.
My understanding that srcu should solve that nicely.
Second is making probe_read() to try harder when address is causing
minor fault. We're thinking that find_vma() followed by some new
light weight filemap_access() that doesn't sleep will do the trick.
In both cases the program will be accessing current->mm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
