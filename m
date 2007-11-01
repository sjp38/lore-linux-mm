Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA14fPsw028580
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA14fOoY476370
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA14fOqX030849
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:24 -0400
Message-Id: <20071101033508.720885000@us.ibm.com>
Date: Wed, 31 Oct 2007 20:35:08 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 0/3] Procfs Task exe Symlinks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ftp.linux.org.uk>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The kernel implements readlink of /proc/pid/exe by getting the file from the
first executable VMA. Then the path to the file is reconstructed and reported as
the result. While this method is often correct it does not always identify the
correct path.

I've described the problem in much greater detail in the first patch of this
series. 

Once case I had in mind while trying to solve this problem involves the use
of the out-of-tree MVFS filesystem. While that motivates my work on this patch
series I think there are issues with /proc/self/exe independent of MVFS and
which this patch series can solve. I've also explained the additional wrinkles
MVFS adds in the first patch.

One question that came up while solving this problem was trying to determine
what /proc/self/exe should point to. The common case is easy enough but does
not seem to unambiguously define /proc/self/exe in all possible cases. When
discussing the idea with Dave Hansen off-list I went through some possible
definitions such as:

"what's running"
"used to start"
"last exec"

For now I've chosen "last exec". I'd like to know if this doesn't fit with
what anyone would expect and/or if there's a better definition.

The first patch in this series attempts to solve the problem by keeping
an additional reference to the last exec'd file in the mm struct rather than
walking the VMA list for the first, executable, file-backed VMA.

The next patch adds a spinlock to protect the new reference rather than
reusing the mmap semaphore. This exists mainly to show where the mmap semaphore
is absolutely necessary and where there are other alternatives.

The last patch allows applications to change their exe symlink to fix the
case where a restart loader is designed to map the executable in rather than
use the exec system call.

If there are no objections to the direction of the patches I plan on making
the series acceptable for eventual inclusion.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
