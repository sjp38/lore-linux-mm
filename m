Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6470B6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:49:20 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id o185so38581927pfb.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:49:20 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 15si24690842pfp.195.2016.01.29.06.49.19
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 06:49:19 -0800 (PST)
Date: Fri, 29 Jan 2016 09:49:09 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and
 track_pfn_remap()
Message-ID: <20160129144909.GV2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
 <20160127044036.GR2948@linux.intel.com>
 <CALCETrXJacX8HB3vahu0AaarE98qkx-wW9tRYQ8nVVbHt=FgzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXJacX8HB3vahu0AaarE98qkx-wW9tRYQ8nVVbHt=FgzQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 26, 2016 at 09:44:24PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 26, 2016 at 8:40 PM, Matthew Wilcox <willy@linux.intel.com> wrote:
> > On Mon, Jan 25, 2016 at 09:33:35AM -0800, Andy Lutomirski wrote:
> >> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
> >> <matthew.r.wilcox@intel.com> wrote:
> >> > From: Matthew Wilcox <willy@linux.intel.com>
> >> >
> >> > track_pfn_insert() overwrites the pgprot that is passed in with a value
> >> > based on the VMA's page_prot.  This is a problem for people trying to
> >> > do clever things with the new vm_insert_pfn_prot() as it will simply
> >> > overwrite the passed protection flags.  If we use the current value of
> >> > the pgprot as the base, then it will behave as people are expecting.
> >> >
> >> > Also fix track_pfn_remap() in the same way.
> >>
> >> Well that's embarrassing.  Presumably it worked for me because I only
> >> overrode the cacheability bits and lookup_memtype did the right thing.
> >>
> >> But shouldn't the PAT code change the memtype if vm_insert_pfn_prot
> >> requests it?  Or are there no callers that actually need that?  (HPET
> >> doesn't, because there's a plain old ioremapped mapping.)
> >
> > I'm confused.  Here's what I understand:
> >
> >  - on x86, the bits in pgprot can be considered as two sets of bits;
> >    the 'cacheability bits' -- those in _PAGE_CACHE_MASK and the
> >    'protection bits' -- PRESENT, RW, USER, ACCESSED, NX
> >  - The purpose of track_pfn_insert() is to ensure that the cacheability bits
> >    are the same on all mappings of a given page, as strongly advised by the
> >    Intel manuals [1].  So track_pfn_insert() is really only supposed to
> >    modify _PAGE_CACHE_MASK of the passed pgprot, but in fact it ends up
> >    modifying the protection bits as well, due to the bug.
> >
> > I don't think you overrode the cacheability bits at all.  It looks to
> > me like your patch ends up mapping the HPET into userspace writable.
> 
> I sure hope not.  If vm_page_prot was writable, something was already
> broken, because this is the vvar mapping, and the vvar mapping is
> VM_READ (and not even VM_MAYREAD).

I do beg yor pardon.  I thought you were inserting a readonly page
into the middle of a writable mapping.  Instead you're inserting a
non-executable page into the middle of a VM_READ | VM_EXEC mapping.
Sorry for the confusion.  I should have written:

"like your patch ends up mapping the HPET into userspace executable"

which is far less exciting.

> > I don't think the vm_insert_pfn_prot() call gets to change the memtype.
> > For one, that page may already be mapped into a differet userspace using
> > the pre-existing memtype, and [1] continues to bite you.  Then there
> > may be outstanding kernel users of the page that's being mapped in.
> 
> So why was remap_pfn_range different?  I'm sure there was a reason.

Yeah, doesn't make sense to me either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
