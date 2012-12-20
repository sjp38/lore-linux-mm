Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 06CD96B006C
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:21:32 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
	<20121219161856.e6aa984f.akpm@linux-foundation.org>
	<878v8ty200.fsf@xmission.com>
	<20121219170038.f7b260c3.akpm@linux-foundation.org>
Date: Wed, 19 Dec 2012 17:20:42 -0800
In-Reply-To: <20121219170038.f7b260c3.akpm@linux-foundation.org> (Andrew
	Morton's message of "Wed, 19 Dec 2012 17:00:38 -0800")
Message-ID: <87ip7xwmc5.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2] Add the values related to buddy system for filtering free pages.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 19 Dec 2012 16:57:03 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> 
>> > Is there any way in which we can move some of this logic into the
>> > kernel?  In this case, add some kernel code which uses PageBuddy() on
>> > behalf of makedumpfile, rather than replicating the PageBuddy() logic
>> > in userspace?
>> 
>> All that exists when makedumpfile runs is a core file.  So it would have
>> to be something like a share library that builds with the kernel and
>> then makedumpfile loads.
>
> Can we omit free pages from that core file?
>
> And/or add a section to that core file which flags free pages?

Ommitting pages is what makedumpfile does.

Very loosely shortly after boot when things are running fine /sbin/kexec
runs.

/sbin/kexec constructs a set of elf headers that describe where the
memory is and load the crashdump kernel an initrd and those elf headers
into memory.

Years later when the running kernel calls panic.
panic calls machine_kexec
machine_kexec jmps to the preloaded crashdump kernel.

I think it is /proc/vmcore that reads the elf headers out of memory and
presents them to userspace.

Then we have options.
vmcore-to-dmesg will just read the dmesg ring buffer so we have that.

makedumpfile reads the kernel data structures and filters out the free
pages for people who don't want to write everything to disk.

So the basic interface is strongly kernel version agnostic.  The
challenge is how to filter out undesirable pages from the core dump
quickly and reliably.

Right now what we have are a set of ELF notes that describe struct page.

For my uses I have either had enough disk space that saving everything
didn't matter or so little disk space that all I could afford was
getting out the dmesg ring buffer.  So I don't know how robust the
solution adopted by makedumpfile is.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
