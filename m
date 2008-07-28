Date: Mon, 28 Jul 2008 10:57:42 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080728105742.50d6514e@cuia.bos.redhat.com>
In-Reply-To: <20080724222510.3bbbbedc@bree.surriel.com>
References: <20080724222510.3bbbbedc@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jul 2008 22:25:10 -0400
Rik van Riel <riel@redhat.com> wrote:

>   TEST 1: dd if=/dev/sda of=/dev/null bs=1M
> 
> kernel  speed    swap used
> 
> 2.6.26  111MB/s  500kB
> -mm     110MB/s  59MB     (ouch, system noticably slower)
> noforce	111MB/s  128kB
> stream  108MB/s  0        (slight regression, not sure why yet)
> 
> This patch shows that the split LRU VM in -mm has a problem
> with large streaming IOs: the working set gets pushed out of
> memory, which makes doing anything else during the big streaming
> IO kind of painful.
> 
> However, either of the two patches posted fixes that problem,
> though at a slight performance penalty for the "stream" patch.

OK, the throughput number with this test turns out not to mean
nearly as much as I thought.

Switching off CPU frequency scaling, pinning the CPUs at the
highest speed, resulted in a throughput of only 102MB/s.

My suspicion is that faster running code on the CPU results
in IOs being sent down to the device faster, resulting in
smaller IOs and lower throughput.

This would be promising for the "stream" patch, which makes
choosing between the two patches harder :)

Andrew, what is your preference between:
	http://lkml.org/lkml/2008/7/15/465
and
	http://marc.info/?l=linux-mm&m=121683855132630&w=2

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
