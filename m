Date: Wed, 2 Jan 2008 22:44:50 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
Message-ID: <20080102224450.585bf956@bree.surriel.com>
In-Reply-To: <20080102224144.885671949@redhat.com>
References: <20080102224144.885671949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernelporg
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 02 Jan 2008 17:41:44 -0500
linux-kernel@vger.kernelporg wrote:

> This patch series improves VM scalability by:

> 3) switching to SEQ replacement for the anonymous LRUs, so the
>    number of pages that need to be scanned when the system
>    starts swapping is bound to a reasonable number

I have done some (minimal) testing of this tonight.

Running a 16000 MB fillmem on my 16GB test box (where slub
eats up unexplainable amounts of memory so the test gets about
14GB RSS and 1.5GB in swap).

2.6.24-rc6-mm1

$ time ./fillmem 16000
real    3m43.601s
user    0m11.090s
sys     0m55.274s

2.6.24-rc6-mm1-vmsplit

$ time ./fillmem 16000
real    1m51.323s
user    0m10.638s
sys     0m42.859s

This is after carefully emptying out all memory by rebooting
the system and running fillmem a few times.  These results are
repeatable.

With vanilla 2.6.24-rc6-mm1, kswapd eats up 99% of the CPU at
a few points in the test run.  This never seems to happen with
the vmsplit kernel.

Unfortunately the symbol file for vanilla 2.6.24-rc6-mm1 seems
to be hosed, so readprofile is not returning anything useful on
that kernel.  I'll try to come up with more useful data later.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
