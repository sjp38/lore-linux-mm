Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 493976B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 09:51:10 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id m5so2387101qaj.25
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 06:51:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id k5si3865783qgf.166.2014.04.25.06.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Apr 2014 06:51:09 -0700 (PDT)
Date: Fri, 25 Apr 2014 15:51:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140425135101.GE11096@twins.programming.kicks-ass.net>
References: <alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
 <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
 <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
 <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
 <1398389846.8437.6.camel@pasglop>
 <1398393700.8437.22.camel@pasglop>
 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, Apr 25, 2014 at 05:01:23AM -0700, Hugh Dickins wrote:
> One, regarding dirty shared mappings: you're thinking above of
> mmap()'ing proper filesystem files, but this case also includes
> shared memory - I expect there are uses of giant amounts of shared
> memory, for which we really would prefer not to slow the teardown.
> 
> And confusingly, those are not subject to the special page_mkclean()
> constraints, but still need to be handled in a correct manner: your
> patch is fine, but might be overkill for them - I'm not yet sure.

I think we could look at mapping_cap_account_dirty(page->mapping) while
holding the ptelock, the mapping can't go away while we hold that lock.

And afaict that's the exact differentiator between these two cases.

> Two, Ben said earlier that he's more worried about users of
> unmap_mapping_range() than concurrent munmap(); and you said
> earlier that you would almost prefer to have some special lock
> to serialize with page_mkclean().
> 
> Er, i_mmap_mutex.
> 
> That's what unmap_mapping_range(), and page_mkclean()'s rmap_walk,
> take to iterate over the file vmas.  So perhaps there's no race at all
> in the unmap_mapping_range() case.  And easy (I imagine) to fix the
> race in Dave's racewrite.c use of MADV_DONTNEED: untested patch below.

Ooh shiney.. yes that might work! 

> But exit and munmap() don't take i_mmap_mutex: perhaps they should
> when encountering a VM_SHARED vma 

Well, they will of course take it in order to detach the vma from the
rmap address_space::i_mmap tree.

> (I believe VM_SHARED should be
> peculiar to having vm_file seta, but test both below because I don't
> want to oops in some odd corner where a special vma is set up).

I think you might be on to something there...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
