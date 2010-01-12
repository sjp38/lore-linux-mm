Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D1A66B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 22:12:28 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C3CP0e027167
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Tue, 12 Jan 2010 12:12:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BDFD45DE65
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:12:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 696B045DE62
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:12:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 399281DB803A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:12:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B97781DB8040
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:12:24 +0900 (JST)
Date: Tue, 12 Jan 2010 12:12:32 +0900 (JST)
Message-Id: <20100112.121232.189721840.d.hatayama@jp.fujitsu.com>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
From: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
In-Reply-To: <20100107162928.1d6eba76.akpm@linux-foundation.org>
References: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
	<20100107162928.1d6eba76.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended numbering support
Date: Thu, 7 Jan 2010 16:29:28 -0800

> On Mon, 04 Jan 2010 10:06:07 +0900 (JST)
> Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:
> 
> > The current ELF dumper can produce broken corefiles if program headers
> > exceed 65535. In particular, the program in 64-bit environment often
> > demands more than 65535 mmaps. If you google max_map_count, then you
> > can find many users facing this problem.
> > 
> > Solaris has already dealt with this issue, and other OSes have also
> > adopted the same method as in Solaris. Currently, Sun's document and
> > AMD 64 ABI include the description for the extension, where they call
> > the extension Extended Numbering. See Reference for further information.
> > 
> > I believe that linux kernel should adopt the same way as they did, so
> > I've written this patch.
> > 
> > I am also preparing for patches of GDB and binutils.
> 
> That's a beautifully presented patchset.  Thanks for doing all that
> work - it helps.
> 
> UML maintenance appears to have ceased in recent times, so if we wish
> to have these changes runtime tested (we should) then I think it would
> be best if you could find someone to do that please.
> 
> And no akpm code-review would be complete without: dump_seek() is
> waaaay to large to be inlined.  Is there some common .c file to where
> we could move it?
> 

I am sorry for very late reply.

* Patch Test for UML-i386

I tested on UML-i386 for the stable release of that time, precisely
2.6.32, since even building process for UML-i386 failed for mainline
and mmotm trees, as you've expected.

I don't know internal UML implementation at all, so I need to find
someone if runtime test for mmotm tree is absolutely necessary.

* modification for dump_seek()

I couldn't find any right .c file at which dump_seek() be placed. We
need to create a new .c file into which we put auxiliary functions to
generate/manipulate coredumps.

There is another problem regarding name space. The name dump_seek() is
too short.  If we move dump_seek() to some .c file, we need to rename
it according to the corresponding object file format, such as
elf_core_dump_seek() or aout_dump_seek(); or coredump_dump_seek(), as
currently dump_seek() is shared among dumping processes in multiple
object formats.

Should I submit these suggestions as a patch set of version 3?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
