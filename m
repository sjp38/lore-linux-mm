Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 688AA6B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 14:43:10 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so3503876pbb.39
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:43:10 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id ps1si5405533pbc.121.2014.04.25.11.43.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 11:43:09 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so3494259pbc.24
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:43:09 -0700 (PDT)
Date: Fri, 25 Apr 2014 11:41:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <535A9356.8060608@intel.com>
Message-ID: <alpine.LSU.2.11.1404251138050.5909@eggly.anvils>
References: <53558507.9050703@zytor.com> <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com> <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz>
 <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com> <20140424065133.GX26782@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404241110160.2443@eggly.anvils> <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
 <alpine.LSU.2.11.1404241252520.3455@eggly.anvils> <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com> <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop> <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com> <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com> <alpine.LSU.2.11.1404250414590.5198@eggly.anvils> <535A9356.8060608@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, 25 Apr 2014, Dave Hansen wrote:
> On 04/25/2014 05:01 AM, Hugh Dickins wrote:
> > Er, i_mmap_mutex.
> > 
> > That's what unmap_mapping_range(), and page_mkclean()'s rmap_walk,
> > take to iterate over the file vmas.  So perhaps there's no race at all
> > in the unmap_mapping_range() case.  And easy (I imagine) to fix the
> > race in Dave's racewrite.c use of MADV_DONTNEED: untested patch below.
> > 
> > But exit and munmap() don't take i_mmap_mutex: perhaps they should
> > when encountering a VM_SHARED vma (I believe VM_SHARED should be
> > peculiar to having vm_file set, but test both below because I don't
> > want to oops in some odd corner where a special vma is set up).
> 
> Hey Hugh,
> 
> Do you want some testing on this?

Yes, please do: I just haven't gotten around to cloning the git
tree and trying it.  It's quite likely that we shall go Linus's
way rather than this, but still useful to have the information
as to whether this way really is viable.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
