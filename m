Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id ABF8F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:02:41 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id jt11so1403213pbb.40
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 05:02:41 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id rj9si2185090pbc.504.2014.04.25.05.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 05:02:40 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2725136pdj.4
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 05:02:40 -0700 (PDT)
Date: Fri, 25 Apr 2014 05:01:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
References: <53558507.9050703@zytor.com> <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com> <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
 <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz> <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com> <20140424065133.GX26782@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
 <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com> <alpine.LSU.2.11.1404241252520.3455@eggly.anvils> <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com> <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop>
 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com> <5359CD7C.5020604@zytor.com> <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Thu, 24 Apr 2014, Linus Torvalds wrote:
> On Thu, Apr 24, 2014 at 7:50 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> >
> > The cases where they occur the mappings tend to be highly stable, i.e.
> > map once *specifically* to be able to do a whole bunch of things without
> > system calls, and then unmap when done.
> 
> Yes. But even that tends to be unusual. mmap() really is bad at
> writing, since you inevitably get read-modify-write patterns etc. So
> it's only useful for fixing up things after-the-fact, which in itself
> is a horrible pattern.
> 
> Don't get me wrong - it exists, but it's really quite rare because it
> has so many problems. Even people who do "fixup" kind of stuff tend to
> map things privately, change things, and then write out the end
> result. That way you can get atomicity by then doing a single
> "rename()" at the end, for example.
> 
> The traditional case for it used to be the nntp index, and these days
> I know some imap indexer (dovecot?) uses it. Every other example of it
> I have ever seen has been a VM stress tester..

Your patch looks good to me (nice use of force_flush), and runs fine
here in normal usage; but I've not actually tried Dave's racewrite.c.

However, I have had a couple of contrarian half-thoughts, that
ordinarily I'd prefer to mull over more before blurting out,
but in the circumstances better say sooner than later.

One, regarding dirty shared mappings: you're thinking above of
mmap()'ing proper filesystem files, but this case also includes
shared memory - I expect there are uses of giant amounts of shared
memory, for which we really would prefer not to slow the teardown.

And confusingly, those are not subject to the special page_mkclean()
constraints, but still need to be handled in a correct manner: your
patch is fine, but might be overkill for them - I'm not yet sure.

Two, Ben said earlier that he's more worried about users of
unmap_mapping_range() than concurrent munmap(); and you said
earlier that you would almost prefer to have some special lock
to serialize with page_mkclean().

Er, i_mmap_mutex.

That's what unmap_mapping_range(), and page_mkclean()'s rmap_walk,
take to iterate over the file vmas.  So perhaps there's no race at all
in the unmap_mapping_range() case.  And easy (I imagine) to fix the
race in Dave's racewrite.c use of MADV_DONTNEED: untested patch below.

But exit and munmap() don't take i_mmap_mutex: perhaps they should
when encountering a VM_SHARED vma (I believe VM_SHARED should be
peculiar to having vm_file set, but test both below because I don't
want to oops in some odd corner where a special vma is set up).

Hugh

--- 3.15-rc2/mm/madvise.c	2013-11-03 15:41:51.000000000 -0800
+++ linux/mm/madvise.c	2014-04-25 04:10:40.124514427 -0700
@@ -274,10 +274,16 @@ static long madvise_dontneed(struct vm_a
 			     struct vm_area_struct **prev,
 			     unsigned long start, unsigned long end)
 {
+	struct address_space *mapping = NULL;
+
 	*prev = vma;
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
+	if (vma->vm_file && (vma->vm_flags & VM_SHARED)) {
+		mapping = vma->vm_file->f_mapping;
+		mutex_lock(&mapping->i_mmap_mutex);
+	}
 	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
 		struct zap_details details = {
 			.nonlinear_vma = vma,
@@ -286,6 +292,8 @@ static long madvise_dontneed(struct vm_a
 		zap_page_range(vma, start, end - start, &details);
 	} else
 		zap_page_range(vma, start, end - start, NULL);
+	if (mapping)
+		mutex_unlock(&mapping->i_mmap_mutex);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
