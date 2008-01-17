From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v6 0/2] Fixing the issue with memory-mapped file times
Date: Fri, 18 Jan 2008 01:31:56 +0300
Message-Id: <12006091182260-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

This is the sixth version of my solution for the bug #2645:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

New since the previous version:

1) a few cosmetic changes according to the latest feedback
   for the cleanup patch;

2) implementation of the following suggestion by Miklos Szeredi:

http://lkml.org/lkml/2008/1/17/158

These changes were tested as explained below. Please note that all
tests were performed with all recommended kernel debug options
enabled. Also note that the tests were performed on regular files
residing on both an ext3 partition and a tmpfs filesystem. I also
checked the block device case, which worked for me as well.

1. My own unit test:

http://bugzilla.kernel.org/attachment.cgi?id=14430

Result: all test cases passed successfully.

2. Unit test provided by Miklos Szeredi:

http://lkml.org/lkml/2008/1/14/104

Result: this test produced the following output:

debian-64:~# ./miklos_test test
begin   1200598736      1200598736      1200598617
write   1200598737      1200598737      1200598617
mmap    1200598737      1200598737      1200598738
b       1200598739      1200598739      1200598738
msync b 1200598739      1200598739      1200598738
c       1200598741      1200598741      1200598738
msync c 1200598741      1200598741      1200598738
d       1200598743      1200598743      1200598738
munmap  1200598743      1200598743      1200598738
close   1200598743      1200598743      1200598738
sync    1200598743      1200598743      1200598738
debian-64:~#

3. Regression tests were performed using the following test cases from
the LTP test suite:

	msync01
	msync02
	msync03
	msync04
	msync05
	mmapstress01
	mmapstress09
	mmapstress10

Result: no regressions were found while running these test cases.

4. Performance test was done using the program available from the
following link:

http://bugzilla.kernel.org/attachment.cgi?id=14493

Result: the impact of the changes was negligible for files of a few
hundred megabytes.

I wonder if these changes can be applied now.

These patches are the result of many fruitful discussions with
Miklos Szeredi, Peter Zijlstra, Rik van Riel, Peter Staubach,
and Jacob Oestergaard. I am grateful to you all for your support
during the days I was working on this long-standing nasty bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
