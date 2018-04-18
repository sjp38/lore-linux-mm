Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3D216B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 03:36:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 38-v6so816282wrv.8
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 00:36:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16si1005730edf.188.2018.04.18.00.36.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 00:36:04 -0700 (PDT)
Date: Wed, 18 Apr 2018 09:35:58 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 00/35 v5] PTI support for x32
Message-ID: <20180418073558.mebtl457ss2rzhrm@suse.de>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <CA+55aFwGTOgSonVquab63PZG5z_NfgVF2A08iHaNeeqY5pdfnA@mail.gmail.com>
 <20180416160154.GE15462@8bytes.org>
 <CA+55aFzrYbTMXyZBVqRV875HwQJNxD+822RGeeDb7BLDLU8aWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzrYbTMXyZBVqRV875HwQJNxD+822RGeeDb7BLDLU8aWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Mon, Apr 16, 2018 at 09:13:22AM -0700, Linus Torvalds wrote:
> See for example commit 8c06c7740d19 ("x86/pti: Leave kernel text
> global for !PCID") and in particular the performance numbers (that's
> an Atom microserver, but it was chosen due to lack of PCID).

Okay, I checked this on 32 bit and after some small changes I got
identical mappings with GLB set in all page-tables. The changes were:

	* Don't change permission bits in pti_clone_kernel_text().
	  Changing them does not make a difference on 64 bit as
	  everything cloned in this function is RO anyway. On 32 bit
	  some areas are mapped RW, so it does make a difference there.
	  
	  Having different permissions between kernel and user
	  page-table does also not make sense, because a permission
	  mismatch in the TLB will cause a re-walk, which is as fast as
	  not mapping it at all.

	* Mapping kernel-text to user-space on 32 bit too. Since there
	  is no PCID this should improve performance. I have not
	  measured that yet, but will do so before posting the next
	  version.

I do some more testing and performance measurements and will send
version 6 of my patches beginning of next week when v4.17-rc2 is out.


Regards,

	Joerg
