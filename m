Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 19B9B6B0005
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 07:37:44 -0500 (EST)
Received: by mail-ia0-f182.google.com with SMTP id w33so5291283iag.27
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 04:37:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAH9JG2UTnAKHp8FB4rzYDD8VbQ-8S4=j_nAkOwXO4+2HeVrLwQ@mail.gmail.com>
References: <20130122065341.GA1850@kernel.org>
	<20130123075808.GH2723@blaptop>
	<1359018598.2866.5.camel@kernel>
	<CAH9JG2UpVtxeLB21kx5-_pokK8p_uVZ-2o41Ep--oOyKStBZFQ@mail.gmail.com>
	<20130127141853.GB27019@kernel.org>
	<CAH9JG2UTnAKHp8FB4rzYDD8VbQ-8S4=j_nAkOwXO4+2HeVrLwQ@mail.gmail.com>
Date: Fri, 1 Feb 2013 21:37:43 +0900
Message-ID: <CAH9JG2Xq2bCJ0Wvtgu3BHjEzDp0F2k6682+toyoRqE7bHs4gag@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

On Mon, Jan 28, 2013 at 4:37 PM, Kyungmin Park <kmpark@infradead.org> wrote:
> On Sun, Jan 27, 2013 at 11:18 PM, Shaohua Li <shli@kernel.org> wrote:
>> On Sat, Jan 26, 2013 at 01:40:55PM +0900, Kyungmin Park wrote:
>>> Hi,
>>>
>>> On 1/24/13, Simon Jeons <simon.jeons@gmail.com> wrote:
>>> > Hi Minchan,
>>> > On Wed, 2013-01-23 at 16:58 +0900, Minchan Kim wrote:
>>> >> On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
>>> >> > Hi,
>>> >> >
>>> >> > Because of high density, low power and low price, flash storage (SSD) is
>>> >> > a good
>>> >> > candidate to partially replace DRAM. A quick answer for this is using
>>> >> > SSD as
>>> >> > swap. But Linux swap is designed for slow hard disk storage. There are a
>>> >> > lot of
>>> >> > challenges to efficiently use SSD for swap:
>>> >>
>>> >> Many of below item could be applied in in-memory swap like zram, zcache.
>>> >>
>>> >> >
>>> >> > 1. Lock contentions (swap_lock, anon_vma mutex, swap address space
>>> >> > lock)
>>> >> > 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB
>>> >> > flush. This
>>> >> > overhead is very high even in a normal 2-socket machine.
>>> >> > 3. Better swap IO pattern. Both direct and kswapd page reclaim can do
>>> >> > swap,
>>> >> > which makes swap IO pattern is interleave. Block layer isn't always
>>> >> > efficient
>>> >> > to do request merge. Such IO pattern also makes swap prefetch hard.
>>> >>
>>> >> Agreed.
>>> >>
>>> >> > 4. Swap map scan overhead. Swap in-memory map scan scans an array, which
>>> >> > is
>>> >> > very inefficient, especially if swap storage is fast.
>>> >>
>>> >> Agreed.
>>> >>
>>>
>>> 5. SSD related optimization, mainly discard support.
>>>
>>> Now swap codes are based on each swap slots. it means it can't
>>> optimize discard feature since getting meaningful performance gain, it
>>> requires 2 pages at least. Of course it's based on eMMC. In case of
>>> SSD. it requires more pages to support discard.
>>>
>>> To address issue. I consider the batched discard approach used at filesystem.
>>> *Sometime* scan all empty slot and it issues discard continuous swap
>>> slots as many as possible.
>>
>> I posted a patch to make discard async before, which is almost good to me, though we
>> still discard a cluster.
>> http://marc.info/?l=linux-mm&m=135087309208120&w=2
>
> I found your previous patches, It's almost same concept as batched
> discard. Now I'm testing your patches.
> BTW, which test program do you use? Now we just testing some scenario
> and check scenario only.
> There's no generic tool to measure improved performance gain.
>
> After test, I'll share the results.
Updated, it has good performance gain than previous one about 4 times.

Feel free to add.
Tested-by: Kyungmin Park <kyungmin.park@samsung.com>
>
> Thank you,
> Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
