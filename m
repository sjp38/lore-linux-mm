Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A5B506B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 04:16:41 -0400 (EDT)
Date: Wed, 27 Oct 2010 04:16:38 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <1014156042.534481288167398779.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <395413139.534301288167215758.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: understand KSM
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> Since your 1MB malloc'ed buffers may not fall on page boundaries,
> and there might occasionally be other malloc'ed areas interspersed
> amongst them, I'm not surprised that pages_sharing falls a little
> short of 98302.  But I am surprised that pages_unshared does not
> make up the difference; probably pages_volatile does, but I don't
> see why some should remain volatile indefinitely.
The test program (http://people.redhat.com/qcai/ksm01.c) was changed to use mmap instead of malloc, and pages_sharing was short of the expected value and pages_volatile was indeed non-zero. Those makes it is difficult to predict pages_sharing and pages_volatile although it might be fine to check pages_sharing + pages_volatile with an expected value. Any suggestion to alter the test code to check the stable numbers? Thanks.

ksm01       0  TINFO  :  child 0 allocates 128 MB filled with 'c'.
ksm01       0  TINFO  :  child 1 allocates 128 MB filled with 'a'.
ksm01       0  TINFO  :  child 2 allocates 128 MB filled with 'a'.
ksm01       0  TINFO  :  pages_shared is 2.
ksm01       0  TINFO  :  pages_sharing is 98300.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       0  TINFO  :  pages_volatile is 2.

ksm01       0  TINFO  :  child 1 changes memory content to 'b'.
ksm01       0  TINFO  :  pages_shared is 3.
ksm01       0  TINFO  :  pages_sharing is 98291.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       0  TINFO  :  pages_volatile is 10.

ksm01       0  TINFO  :  child 0 changes memory content to 'd'.
ksm01       0  TINFO  :  child 1 changes memory content to 'd'
ksm01       0  TINFO  :  child 2 changes memory content to 'd'
ksm01       0  TINFO  :  pages_shared is 1.
ksm01       0  TINFO  :  pages_sharing is 98299.
ksm01       0  TINFO  :  pages_unshared is 0.
ksm01       0  TINFO  :  pages_volatile is 4.

ksm01       0  TINFO  :  child 1 changes one page to 'e'.
ksm01       0  TINFO  :  pages_shared is 1.
ksm01       0  TINFO  :  pages_sharing is 98299.
ksm01       0  TINFO  :  pages_unshared is 1.
ksm01       0  TINFO  :  pages_volatile is 3.


CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
