Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C5A206B006E
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 13:03:55 -0400 (EDT)
Message-ID: <5069CCF9.7040309@linux.intel.com>
Date: Mon, 01 Oct 2012 10:03:53 -0700
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Virtual huge zero page
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com> <20120929134811.GC26989@redhat.com> <5069B804.6040902@linux.intel.com> <20121001163118.GC18051@redhat.com>
In-Reply-To: <20121001163118.GC18051@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On 10/01/2012 09:31 AM, Andrea Arcangeli wrote:
> On Mon, Oct 01, 2012 at 08:34:28AM -0700, H. Peter Anvin wrote:
>> On 09/29/2012 06:48 AM, Andrea Arcangeli wrote:
>>>
>>> There would be a small cache benefit here... but even then some first
>>> level caches are virtually indexed IIRC (always physically tagged to
>>> avoid the software to notice) and virtually indexed ones won't get any
>>> benefit.
>>>
>>
>> Not quite.  The virtual indexing is limited to a few bits (e.g. three
>> bits on K8); the right way to deal with that is to color the zeropage,
>> both the regular one and the virtual one (the virtual one would circle
>> through all the colors repeatedly.)
>>
>> The cache difference, therefore, is *huge*.
> 
> Kirill measured the cache benefit and it provided a 6% gain, not very
> huge but certainly significant.
> 
>> It's a performance tradeoff, and it can, and should, be measured.
> 
> I now measured the other side of the trade, by touching only one
> character every 4k page in the range to simulate a very seeking load,
> and doing so the physical huge zero page wins with a 600% margin, so
> if the cache benefit is huge for the virtual zero page, the TLB
> benefit is massive for the physical zero page.
> 
> Overall I think picking the solution that risks to regress the least
> (also compared to current status of no zero page) is the safest.
> 

Something isn't quite right about that.  If you look at your numbers:

1,049,134,961 LLC-loads
        6,222 LLC-load-misses

This is another way of saying in your benchmark the huge zero page is
parked in your LLC - using up 2 MB of your LLC, typically a significant
portion of said cache.  In a real-life application that will squeeze out
real data, but in your benchmark the system is artificially quiescent.

It is well known that microbenchmarks can be horribly misleading.  What
led to Kirill investigating huge zero page in the first place was the
fact that some applications/macrobenchmarks benefit, and I think those
are the right thing to look at.

	-hpa




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
