Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id C643B6B006C
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 22:12:08 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id p10so3571525wes.16
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 19:12:08 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id fa9si15224649wjd.121.2014.07.24.19.12.07
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 19:12:07 -0700 (PDT)
Message-ID: <53D1BCF0.3080706@imgtec.com>
Date: Thu, 24 Jul 2014 19:12:00 -0700
From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com> <20140723141721.d6a58555f124a7024d010067@linux-foundation.org> <CAMo8BfJ0zC16ssBDGUxsLNwmVOpgnyk1PjikunB9u-C7x9uaOA@mail.gmail.com> <20140724152133.bd4556f632b9cbb506b168cf@linux-foundation.org>
In-Reply-To: <20140724152133.bd4556f632b9cbb506b168cf@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux/MIPS
 Mailing List <linux-mips@linux-mips.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, LKML <linux-kernel@vger.kernel.org>, Chris
 Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, Steven Hill <Steven.Hill@imgtec.com>

On 07/24/2014 03:21 PM, Andrew Morton wrote:
> On Thu, 24 Jul 2014 04:38:01 +0400 Max Filippov <jcmvbkbc@gmail.com> wrote:
>
>> On Thu, Jul 24, 2014 at 1:17 AM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>> Fifthly, it would be very useful to publish the performance testing
>>> results for at least one architecture so that we can determine the
>>> patchset's desirability.  And perhaps to motivate other architectures
>>> to implement this.
>> What sort of performance numbers would be relevant?
>> For xtensa this patch enables highmem use for cores with aliasing cache,
>> that is access to a gigabyte of memory (typical on KC705 FPGA board) vs.
>> only 128MBytes of low memory, which is highly desirable. But performance
>> comparison of these two configurations seems to make little sense.
>> OTOH performance comparison of highmem variants with and without
>> cache aliasing would show the quality of our cache flushing code.
> I'd assumed the patch was making cache coloring available as a
> performance tweak.  But you appear to be saying that the (high) memory
> is simply unavailable for such cores without this change.  I think.

>
> Please ensure that v3's changelog explains the full reason for the
> patch.  Assume you're talking to all-the-worlds-an-x86 dummies, OK?
>

I am not sure that I will work on it again, we move to bigger pages and 
non-aliasing cache, and I ask Steven Hill to help with MIPS variant.
So, I try to summarise an expanation here:

If cache line of some page in MIPS (and XTENSA?) is accessed via 
multiple page virtual addresses (kernel or/and user) then it may be 
located twice or more times in L1 cache which is an obvious coherency 
bug. It is a trade-off for simple L1 access hardware. Two virtual 
addresses of page which hits the same location in L1 cache are named as 
"in the same page colour". Usually, colours are numbered and sequential 
page colours looks like 0,1,0,1 or 0,1,2,3,0,1,2,3... It is usually 
least one-two-or-three bits of PFN.

One simple way to hit this problem is using current HIGHMEM remapping 
service because it doesn't take care of "page colouring". To prevent 
coherency failure a current HIGHMEM code attempts to flush page from L1 
cache each time before changing it's virtual address: flush cache each 
PKMAP recycle and at each kunmap_atomic(), see arch/arm/mm/highmem.c - 
MIPS code even doesn't have a flush here (BUG!).

However, kunmap_atomic() should do it locally to CPU without kmap_lock 
by definition of kmap_atomic() and can't prevent a situation then a 
second CPU hyper-thread accesses the same page via kmap() right after 
kmap_atomic() got a page and uses a different page colour (different 
virtual address set). Also, setting the whole cycle 
kmap_atomic()...page...access...kunmap_atomic() under kmap_lock is 
impractical.

This patch introduces some interface for architecture code to work with 
coloured pages in PKMAP array which eliminates the kmap_atomic problem 
and cancels cache flush requirements. It also can be consistent with 
kmap_coherent() code which is required for some cache aliasing 
architecture to handle aliasing between kernel virtual address and user 
virtual address. The whole idea of this patch - force the same page 
colour then page is assigned some PKMAP virtual address or kmap_atomic 
address. Page colour is set by architecture code, usually it is a 
physical address colour (which is usually == KVA colour).

- Leonid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
