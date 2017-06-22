Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2EC6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:21:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r103so2923716wrb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:21:35 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id b33si1034330wra.97.2017.06.22.02.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 02:21:34 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id 77so3086015wrb.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:21:34 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:21:29 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 00/14] x86: 5-level paging enabling for v4.13, Part 4
Message-ID: <20170622092129.wsesn34wdpzq7epu@gmail.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
 <20170622085744.wetigtzctyzukbs5@node.shutemov.name>
 <20170622090422.wbbaw6pm457i7cbr@gmail.com>
 <20170622090736.l5xcxazkeicughyt@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622090736.l5xcxazkeicughyt@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Jun 22, 2017 at 11:04:22AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > On Tue, Jun 06, 2017 at 02:31:19PM +0300, Kirill A. Shutemov wrote:
> > > > Please review and consider applying.
> > > 
> > > Hi Ingo,
> > > 
> > > I've noticed you haven't applied last two patches of the patchset.
> > > 
> > > Is there any problem with them? Or what is you plan here?
> > 
> > As they change/extend the Linux ABI I still need to think about them some more.
> 
> Okay, I see.
> 
> Let me know if any action is required from my side.

Yeah, so I had a look, and the ABI principle of using the mmap() address hint to 
trigger 57-bit address space allocations still looks mostly good to me, but please 
split up this patch:

 Subject: [PATCHv7 14/14] x86/mm: Allow to have userspace mappings above 47-bits

 arch/x86/include/asm/elf.h       |  4 ++--
 arch/x86/include/asm/mpx.h       |  9 +++++++++
 arch/x86/include/asm/processor.h | 12 +++++++++---
 arch/x86/kernel/sys_x86_64.c     | 30 ++++++++++++++++++++++++++----
 arch/x86/mm/hugetlbpage.c        | 27 +++++++++++++++++++++++----
 arch/x86/mm/mmap.c               |  6 +++---
 arch/x86/mm/mpx.c                | 33 ++++++++++++++++++++++++++++++++-
 7 files changed, 104 insertions(+), 17 deletions(-)

One patch should add the MPX quirk, another should add all the TASK_SIZE 
variations, without actually changing the logic, etc. - while the final patch adds 
the larger task size. Please try to split it into as many patches as possible - 
I'd say 4-5 look ideal. All of this changes existing code paths and if things 
break we'd like some small patch to be bisected to. The finer grained structure 
also makes review easier.

Also, please rename the tasksize_*() functions to task_size_ (in yet another 
patch) - it's absolutely silly that we have 'TASK_SIZE' in uppercase but 
'tasksize' in lowercase ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
