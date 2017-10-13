Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C66136B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 00:03:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 131so4828500wmk.16
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 21:03:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o3sor116602edi.0.2017.10.12.21.03.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 21:03:56 -0700 (PDT)
Date: Fri, 13 Oct 2017 07:03:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC] x86/boot/compressed/64: Handle 5-level paging boot
 if kernel is above 4G
Message-ID: <20171013040354.yscl4gif5vt3tzgv@node.shutemov.name>
References: <20171009160924.68032-1-kirill.shutemov@linux.intel.com>
 <af75f8aa-471d-34c5-8009-4009a8273989@intel.com>
 <20171009170900.gyl5sizwnd54ridc@node.shutemov.name>
 <87k200vubr.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k200vubr.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 12, 2017 at 06:07:36PM -0500, Eric W. Biederman wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > On Mon, Oct 09, 2017 at 09:54:53AM -0700, Dave Hansen wrote:
> >> On 10/09/2017 09:09 AM, Kirill A. Shutemov wrote:
> >> > Apart from trampoline itself we also need place to store top level page
> >> > table in lower memory as we don't have a way to load 64-bit value into
> >> > CR3 from 32-bit mode. We only really need 8-bytes there as we only use
> >> > the very first entry of the page table.
> >> 
> >> Oh, and this is why you have to move "lvl5_pgtable" out of the kernel image?
> >
> > Right. I initialize the new location of top level page table directly.
> 
> So just a quick note.  I have a fuzzy memory of people loading their
> kernels above 4G physical because they did not have any memory below
> 4G.
> 
> That might be a very specialized case if my memory is correct because
> cpu startup has to have a trampoline below 1MB.  So I don't know how
> that works.  But I do seem to remember someone mentioning it.
> 
> Is there really no way to switch to 5 level paging other than to drop to
> 32bit mode and disable paging?    The x86 architecture does some very
> bizarre things so I can believe it but that seems like a lot of work to
> get somewhere.

The spec[1] is pretty clear on this, see section 2.2.2:

	The processor allows software to modify CR4.LA57 only outside of
	IA-32e mode. In IA-32e mode, an attempt to modify CR4.LA57 using
	the MOV CR instruction causes a general-protection exception
	(#GP).

[1] https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
