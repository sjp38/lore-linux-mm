Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 3BA0A6B005A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 01:27:12 -0500 (EST)
Message-ID: <50BC462E.1080200@synopsys.com>
Date: Mon, 3 Dec 2012 11:56:54 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: Partialy mapped page stays in page cache after unmap
References: <20121030182420.GA17171@rei.Home>
In-Reply-To: <20121030182420.GA17171@rei.Home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chrubis@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Tuesday 30 October 2012 11:54 PM, chrubis@suse.cz wrote:
> Hi!
> I'm currently revisiting mmap related tests in LTP (Linux Test Project)
> and I've came to the tests testing that writes to the partially
> mapped page (at the end of mapping) are carried out correctly.
> 
> These tests fails because even after the object is unmapped and the
> file-descriptor closed the pages still stays in the page cache so if
> (possibly another process) opens and maps the file again the whole
> content of the partial page is preserved.
> 
> Strictly speaking this is not a bug at least when sticking to regular
> files as POSIX which says that the change is not written out. In this
> case the file content is correct and forcing the data to be written out
> by msync() makes the test pass.

Hi Cyril,

I've seen the LTP open posix mmap/{11-4,11-5} issues in the past myself
and was something I wanted to discuss on the lists myself. Thanks for
bringing this up.

Jut to reiterate: the expectations are

1. zero filling of unmapped (trailing) partial page
2. NO Writeout (to disk) of trailing partial page.

#1 is broken as your latter test case proves. We can have an alternate
test case which starts with non empty file (preloaded with all 'a's),
mmap partial page and then read out the trailing partial page, it will
not be zeroes (it's probably ftruncate which does the trick in first place).

Regarding #2 - I did verify that msync indeed makes it pass - but I'm
confused why. After all it is going to commit the buffer  with 'b' to
on-disk - so a subsequent mmap is bound to see the update to file and
hence would make the test fail. What am  I missing here ?

Thx,
-Vineet

 The SHM mappings seems to preserve the
> content even after calling msync() which is, in my opinion, POSIX
> violation although a minor one.
> 
> Looking at the test results I have, the file based mmap test worked fine
> on 2.6.5 (or perhaps the page cache was working/setup differently and
> the test succeeded by accidend).
> 
> Attached is a stripped down LTP test for the problem, uncommenting the
> msync() makes the test succeed.
> 
> I would like to hear your opinions on this problems.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
