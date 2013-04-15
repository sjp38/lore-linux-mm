Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 249C46B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 17:46:22 -0400 (EDT)
Date: Mon, 15 Apr 2013 14:46:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] mm: Soft-dirty bits for user memory changes
 tracking
Message-Id: <20130415144619.645394d8ecdb180d7757a735@linux-foundation.org>
In-Reply-To: <5168089B.7060305@parallels.com>
References: <51669E5F.4000801@parallels.com>
	<51669EB8.2020102@parallels.com>
	<20130411142417.bb58d519b860d06ab84333c2@linux-foundation.org>
	<5168089B.7060305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 12 Apr 2013 17:14:03 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:

> On 04/12/2013 01:24 AM, Andrew Morton wrote:
> > On Thu, 11 Apr 2013 15:30:00 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:
> > 
> >> The soft-dirty is a bit on a PTE which helps to track which pages a task
> >> writes to. In order to do this tracking one should
> >>
> >>   1. Clear soft-dirty bits from PTEs ("echo 4 > /proc/PID/clear_refs)
> >>   2. Wait some time.
> >>   3. Read soft-dirty bits (55'th in /proc/PID/pagemap2 entries)
> >>
> >> To do this tracking, the writable bit is cleared from PTEs when the
> >> soft-dirty bit is. Thus, after this, when the task tries to modify a page
> >> at some virtual address the #PF occurs and the kernel sets the soft-dirty
> >> bit on the respective PTE.
> >>
> >> Note, that although all the task's address space is marked as r/o after the
> >> soft-dirty bits clear, the #PF-s that occur after that are processed fast.
> >> This is so, since the pages are still mapped to physical memory, and thus
> >> all the kernel does is finds this fact out and puts back writable, dirty
> >> and soft-dirty bits on the PTE.
> >>
> >> Another thing to note, is that when mremap moves PTEs they are marked with
> >> soft-dirty as well, since from the user perspective mremap modifies the
> >> virtual memory at mremap's new address.
> >>
> >> ...
> >>
> >> +config MEM_SOFT_DIRTY
> >> +	bool "Track memory changes"
> >> +	depends on CHECKPOINT_RESTORE && X86
> > 
> > I guess we can add the CHECKPOINT_RESTORE dependency for now, but it is
> > a general facility and I expect others will want to get their hands on
> > it for unrelated things.
> 
> OK. Just tell me when you need the dependency removing patch.
> 
> >>From that perspective, the dependency on X86 is awful.  What's the
> > problem here and what do other architectures need to do to be able to
> > support the feature?
> 
> The problem here is that I don't know what free bits are available on
> page table entries on other architectures. I was about to resolve this
> for ARM very soon, but for the rest of them I need help from other people.

Well, this is also a thing arch maintainers can do when they feel a
need to support the feature on their architecture.  To support them at
that time we should provide them with a) adequate information in an
easy-to-find place (eg, a nice comment at the site of the reference x86
implementation) and b) a userspace test app.

> > You have a test application, I assume.  It would be helpful if we could
> > get that into tools/testing/selftests.
> 
> If a very stupid 10-lines test is OK, then I can cook a patch with it.

I think that would be good.  As a low-priority thing, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
