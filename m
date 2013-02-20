Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 174D86B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 21:47:33 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id c10so9277845ieb.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:47:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130220000633.GD16950@blaptop>
References: <bec77f0e-ff96-45df-b090-70120185f560@default>
	<20121211064230.GE22698@blaptop>
	<511F402D.6090006@gmail.com>
	<20130220000633.GD16950@blaptop>
Date: Wed, 20 Feb 2013 11:47:32 +0900
Message-ID: <CAH9JG2USCtN+aD+QvM1YKqqgL6S-u7qGBe24o4xWbL+pEf_7sA@mail.gmail.com>
Subject: Re: zcache+zram working together?
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Simon Jeons <simon.jeons@gmail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Feb 20, 2013 at 9:06 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Sat, Feb 16, 2013 at 04:15:41PM +0800, Simon Jeons wrote:
>> On 12/11/2012 02:42 PM, Minchan Kim wrote:
>> >On Fri, Dec 07, 2012 at 01:31:35PM -0800, Dan Magenheimer wrote:
>> >>Last summer, during the great(?) zcache-vs-zcache2 debate,
>> >>I wondered if there might be some way to obtain the strengths
>> >>of both.  While following Luigi's recent efforts toward
>> >>using zram for ChromeOS "swap", I thought of an interesting
>> >>interposition of zram and zcache that, at first blush, makes
>> >>almost no sense at all, but after more thought, may serve as a
>> >>foundation for moving towards a more optimal solution for use
>> >>of "adaptive compression" in the kernel, at least for
>> >>embedded systems.
>> >>
>> >>To quickly review:
>> >>
>> >>Zram (when used for swap) compresses only anonymous pages and
>> >>only when they are swapped but uses the high-density zsmalloc
>> >>allocator and eliminates the need for a true swap device, thus
>> >>making zram a good fit for embedded systems.  But, because zram
>> >>appears to the kernel as a swap device, zram data must traverse
>> >>the block I/O subsystem and is somewhat difficult to monitor and
>> >>control without significant changes to the swap and/or block
>> >>I/O subsystem, which are designed to handle fixed block-sized
>> >>data.
>> >>
>> >>Zcache (zcache2) compresses BOTH clean page cache pages that
>> >>would otherwise be evicted, and anonymous pages that would
>> >>otherwise be sent to a swap device.  Both paths use in-kernel
>> >>hooks (cleancache and frontswap respectively) which avoid
>> >>most or all of the block I/O subsystem and the swap subsystem.
>> >>Because of this and since it is designed using transcendent
>> >>memory ("tmem") principles, zcache has a great deal more
>> >>flexibility in control and monitoring.  Zcache uses the simpler,
>> >>more predictable "zbud" allocator which achieves lower density
>> >>but provides greater flexibility under high pressure.
>> >>But zcache requires a swap device as a "backup" so seems
>> >>unsuitable for embedded systems.
>> >>
>> >>(Minchan, I know at one point you were working on some
>> >>documentation to contrast zram and zcache so you may
>> >>have something more to add here...)
>> >>
>> >>What if one were to enable both?  This is possible today with
>> >>no kernel change at all by configuring both zram and zcache2
>> >>into the kernel and then configuring zram at boottime.
>> >>
>> >>When memory pressure is dominated by file pages, zcache (via
>> >>the cleancache hooks) provides compression to optimize memory
>> >>utilization.  As more pressure is exerted by anonymous pages,
>> >>"swapping" occurs but the frontswap hooks route the data to
>> >>zcache which, as necessary, reclaims physical pages used by
>> >>compressed file pages to use for compressed anonymous pages.
>> >>At this point, any compressions unsuitable for zbud are rejected
>> >>by zcache and passed through to the "backup" swap device...
>> >>which is zram!  Under high pressure from anonymous pages,
>> >>zcache can also be configured to "unuse" pages to zram (though
>> >>this functionality is still not merged).
>> >>
>> >>I've plugged zcache and zram together and watched them
>> >>work/cooperate, via their respective debugfs statistics.
>> >>While I don't have benchmarking results and may not have
>> >>time anytime soon to do much work on this, it seems like
>> >>there is some potential here, so I thought I'd publish the
>> >>idea so that others can give it a go and/or look at
>> >>other ways (including kernel changes) to combine the two.
>> >>
>> >>Feedback welcome and (early) happy holidays!
>> >Interesting, Dan!
>> >I would like to get a chance to investigate it if I have a time
>> >in future.
>> >
>> >Another synergy with BOTH is to remove CMA completely because
>> >it makes mm core code complicated with hooking and still have a
>> >problem with pinned page and eviction working set for getting
>>
>> Do you mean get_user_pages? Could you explain in details about the
>> downside of CMA?
>
> Good question.
>
> 1. Ignore workingset.
>    CMA can sweep out woring set pages in CMA area for getting contiguous
>    memory.
Theoritically agreed, but there's no data to prove this one.
>
> 2. No guarantee of contigous memory area
>    As I metioned, get_user_pages could pin the page so ends up failing
>    migration.
Right it's working item now, we have to guarantee these pages can't
allocate from CMA area.

>
> 3. Latency
>    CMA reclaims all pages in CMA area when we need it. It means sometime
>    we should write out dirty pages so it could make big overhead POV latency.
>    Even, unmapping of all pages from pte of all processes isn't trivial.
It's trade off between requirement and performance. If feature is more
important and need more memory, it can accept it
>
> 4. Adding many hooks in MM code. - Personally, I really hate it.

But there are cases to use CMA. e.g., DRM playback.

We have to guarantee the physical contiguous memory for TrustZone
solution at ARM.
Without reseverd memory concept. there's no way to get physical
congituous memory execpt CMA.

Thank you,
Kyungmin Park

>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
