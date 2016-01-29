Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 18C696B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 17:19:46 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id ba1so75131453obb.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:19:46 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id t63si4490545oie.59.2016.01.29.14.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 14:19:45 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id wb13so42141682obb.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:19:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160129144909.GV2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
 <20160127044036.GR2948@linux.intel.com> <CALCETrXJacX8HB3vahu0AaarE98qkx-wW9tRYQ8nVVbHt=FgzQ@mail.gmail.com>
 <20160129144909.GV2948@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 Jan 2016 14:19:25 -0800
Message-ID: <CALCETrXnt56iHuvc6RS_-LGKKpkzYD+O=5zYUNn=Esr5=VmgnA@mail.gmail.com>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and track_pfn_remap()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 29, 2016 at 6:49 AM, Matthew Wilcox <willy@linux.intel.com> wrote:
> On Tue, Jan 26, 2016 at 09:44:24PM -0800, Andy Lutomirski wrote:
>> On Tue, Jan 26, 2016 at 8:40 PM, Matthew Wilcox <willy@linux.intel.com> wrote:
>> > On Mon, Jan 25, 2016 at 09:33:35AM -0800, Andy Lutomirski wrote:
>> >> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
>> >> <matthew.r.wilcox@intel.com> wrote:
>> >> > From: Matthew Wilcox <willy@linux.intel.com>
>> >> >
>> >> > track_pfn_insert() overwrites the pgprot that is passed in with a value
>> >> > based on the VMA's page_prot.  This is a problem for people trying to
>> >> > do clever things with the new vm_insert_pfn_prot() as it will simply
>> >> > overwrite the passed protection flags.  If we use the current value of
>> >> > the pgprot as the base, then it will behave as people are expecting.
>> >> >
>> >> > Also fix track_pfn_remap() in the same way.
>> >>
>> >> Well that's embarrassing.  Presumably it worked for me because I only
>> >> overrode the cacheability bits and lookup_memtype did the right thing.
>> >>
>> >> But shouldn't the PAT code change the memtype if vm_insert_pfn_prot
>> >> requests it?  Or are there no callers that actually need that?  (HPET
>> >> doesn't, because there's a plain old ioremapped mapping.)
>> >
>> > I'm confused.  Here's what I understand:
>> >
>> >  - on x86, the bits in pgprot can be considered as two sets of bits;
>> >    the 'cacheability bits' -- those in _PAGE_CACHE_MASK and the
>> >    'protection bits' -- PRESENT, RW, USER, ACCESSED, NX
>> >  - The purpose of track_pfn_insert() is to ensure that the cacheability bits
>> >    are the same on all mappings of a given page, as strongly advised by the
>> >    Intel manuals [1].  So track_pfn_insert() is really only supposed to
>> >    modify _PAGE_CACHE_MASK of the passed pgprot, but in fact it ends up
>> >    modifying the protection bits as well, due to the bug.
>> >
>> > I don't think you overrode the cacheability bits at all.  It looks to
>> > me like your patch ends up mapping the HPET into userspace writable.
>>
>> I sure hope not.  If vm_page_prot was writable, something was already
>> broken, because this is the vvar mapping, and the vvar mapping is
>> VM_READ (and not even VM_MAYREAD).
>
> I do beg yor pardon.  I thought you were inserting a readonly page
> into the middle of a writable mapping.  Instead you're inserting a
> non-executable page into the middle of a VM_READ | VM_EXEC mapping.
> Sorry for the confusion.  I should have written:
>
> "like your patch ends up mapping the HPET into userspace executable"
>
> which is far less exciting.

I think it's not even that.  That particular mapping is just VM_READ.

Anyway, this patch is:

Acked-by: Andy Lutomirski <luto@kernel.org>

Ingo etc: this patch should probably go in to tip:x86/asm -- the code
currently in there is wrong, even if it has no obvious symptom.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
