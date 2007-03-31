From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 00/11] remap_file_pages protection support
Date: Sat, 31 Mar 2007 02:35:08 +0200
Message-ID: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

Again, I'm sending for review (and for possible inclusion into -mm, hopefully)
protection support for remap_file_pages, i.e. setting per-pte protections
(beyond file offset) through this syscall.

== Notes ==

Implementations are provided for i386, x86_64 and UML, and for some other archs
I have patches I will send, based on the ones which were in -mm when Ingo sent
the first version of this work. However, every architecture will still compile
and work fine with these patches applied, until when the new functionality is
not used (that may cause a BUG).

You shouldn't worry for the number of patches, most of them are very little.
I've last tested them in UML and on the host against 2.6.[18-20], and on UML on
2.6.21-rc5-mm3.

== Recent changes ==

This cannot work together with dirty page tracking, however we need this only
for shmfs, and no dirty page tracking is done there. The patch to restrict to
shmfs isn't here, though it's trivial to write.

The problem is that dirty page tracking remaps pages readonly when they're
clean, but this way we forget that the page was writable (since the vma
protections aren't usable here).

===============
For who does not remember what this is for, read on.

== How it works ==

Protections are set in the page tables when the
page is loaded, are saved into the PTE when the page is swapped out and restored
when the page is faulted back in.

Additionally, we modify the fault handler since the VMA protections aren't valid
for PTE with modified protections.

Finally, we must also provide, for each arch, macros to store also the
protections into the PTE; to make the kernel compile for any arch, I've added
since last time dummy default macros to keep the same functionality.

== What is this for ==

The first idea is to use this for UML - it must create a lot of single page
mappings, and managing them through separate VMAs is slow.

Additional note: this idea, with some further refinements (which I'll code after
this chunk is accepted), will allow to reduce the number of used VMAs for most
userspace programs - in particular, it will allow to avoid creating one VMA for
one guard pages (which has PROT_NONE) - forcing PROT_NONE on that page will be
enough.

This will be useful since the VMA lookup at fault time can be a bottleneck for
some programs (I've received a report about this from Ulrich Drepper and I've
been told that also Val Henson from Intel is interested about this). I guess
that since we use RB-trees, the slowness is also due to the poor cache locality
of RB-trees (since RB nodes are within VMAs but aren't accessed together with
their content), compared for instance with radix trees where the lookup has high
cache locality (but they have however space usage problems, possibly bigger, on
64-bit machines).
--
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
