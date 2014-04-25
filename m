Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3CD6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 13:56:28 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id db12so5053683veb.24
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 10:56:27 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id kp14si1878357vcb.2.2014.04.25.10.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 10:56:27 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id im17so5286365vcb.0
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 10:56:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
References: <53558507.9050703@zytor.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	<20140423184145.GH17824@quack.suse.cz>
	<CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
	<20140424065133.GX26782@laptop.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
	<CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
	<alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
	<CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
	<1398389846.8437.6.camel@pasglop>
	<1398393700.8437.22.camel@pasglop>
	<CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
	<5359CD7C.5020604@zytor.com>
	<CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
	<alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
Date: Fri, 25 Apr 2014 10:56:26 -0700
Message-ID: <CA+55aFz=fwpGegGXfyWh9bh_iVM7g4q=0ywugS+sR=L+Od7j5g@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, Apr 25, 2014 at 5:01 AM, Hugh Dickins <hughd@google.com> wrote:
>
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

Hmm. unmap_mapping_range() is just abotu the only thing that _does_
take i_mmap_mutex. unmap_single_vma() does it for
is_vm_hugetlb_page(), which is a bit confusing. And normally we only
take it for the actual final vma link/unlink, not for the actual
traversal. So we'd have to change that all quite radically (or we'd
have to drop and re-take it).

So I'm not quite convinced. Your simple patch looks simple and should
certainly fix DaveH's test-case, but then leaves munmap/exit as a
separate thing to fix. And I don't see how to do that cleanly (it
really looks like "we'll just have to take that semaphore again
separately).

i_mmap_mutex is likely not contended, but we *do* take it for private
mappings too (and for read-only ones), so this lock is actually much
more common than the dirty shared mapping.

So I think I prefer my patch, even if that may be partly due to just
it being mine ;)

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
