Date: Tue, 22 Oct 2002 14:21:18 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <188940000.1035314478@baldur.austin.ibm.com>
In-Reply-To: <407130000.1035313347@flay>
References: <Pine.LNX.3.96.1021022135649.7820C-100000@gatekeeper.tmr.com>
 <407130000.1035313347@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, October 22, 2002 12:02:27 -0700 "Martin J. Bligh"
<mbligh@aracnet.com> wrote:


>> I'm just trying to decide what this might do for a news server with
>> hundreds of readers mmap()ing a GB history file. Benchmarks show the 2.5
>> has more latency the 2.4, and this is likely to make that more obvious.
> 
> On the other hand, I don't think shared pagetables have an mmap hook,
> though that'd be easy enough to add. And if you're not reading the whole 
> history file, presumably the PTEs will only be sparsely instantiated
> anyway.

Actually shared page tables work on any shared memory area, no matter how
it was created.  When a page fault occurs and there's no pte page already
allocated (the common case for any newly mapped region) it checks the vma
to see if it's shared.  If it's shared, it gets the address_space for that
vma, then walks through all the shared vmas looking for one that's mapped
at the same address and offset and already has a pte page that can be
shared.

So if your history file is mapped at the same address for all your
processes then it will use shared page tables.  While it might be a nice
add-on to allow sharing if they're mapped on the same pte page boundary,
that doesn't seem likely enough to justify the extra work.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
