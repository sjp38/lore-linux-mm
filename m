Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABAB86B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:00:27 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f14so55692445ioj.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:00:27 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id 63si18938298iod.17.2016.08.05.09.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 09:00:26 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id y195so24522830iod.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:00:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F50B52E@AcuExch.aculab.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com> <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com> <20160804181913.26ee17b9@redhat.com>
 <CAKgT0UdbVK6Ti9drCQFfa0MyU40Kh=Hu=BtDTRCqqsSiBvJ7rg@mail.gmail.com>
 <20160805035534.GA56390@ast-mbp.thefacebook.com> <CAKgT0Uc0=10xhcJJ+55rBv=YNPgPLmHb8x82CKbj+N895JQY5Q@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F50B52E@AcuExch.aculab.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 5 Aug 2016 09:00:25 -0700
Message-ID: <CAKgT0Ue2vikpFwqTyAEgYsH0iKgOajXvp_F-CMuZfz-cLggrrg@mail.gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@aculab.com>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john fastabend <john.fastabend@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Fri, Aug 5, 2016 at 8:33 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexander Duyck
>> Sent: 05 August 2016 16:15
> ...
>> >
>> > interesting idea. Like dma_map 1GB region and then allocate
>> > pages from it only? but the rest of the kernel won't be able
>> > to use them? so only some smaller region then? or it will be
>> > a boot time flag to reserve this pseudo-huge page?
>>
>> Yeah, something like that.  If we were already talking about
>> allocating a pool of pages it might make sense to just setup something
>> like this where you could reserve a 1GB region for a single 10G device
>> for instance.  Then it would make the whole thing much easier to deal
>> with since you would have a block of memory that should perform very
>> well in terms of DMA accesses.
>
> ISTM that the main kernel allocator ought to be keeping a cache
> of pages that are mapped into the various IOMMU.
> This might be a per-driver cache, but could be much wider.
>
> Then if some code wants such a page it can be allocated one that is
> already mapped.
> Under memory pressure the pages could then be reused for other purposes.
>
> ...
>> In the Intel drivers for instance if the frame
>> size is less than 256 bytes we just copy the whole thing out since it
>> is cheaper to just extend the header copy rather than taking the extra
>> hit for get_page/put_page.
>
> How fast is 'rep movsb' (on cached addresses) on recent x86 cpu?
> It might actually be worth unconditionally copying the entire frame
> on those cpus.

The cost for rep movsb on modern x86 is about 1 cycle for every 16
bytes plus some fixed amount of setup time.  The time it usually takes
for something like an atomic operation can vary but it is usually in
the 10s of cycles when you factor in a get_page/put_page which is why
I ended up going with 256 being the upper limit as I recall since that
allowed for the best performance without starting to incur any
penalty.

> A long time ago we found the breakeven point for the copy to be about
> 1kb on sparc mbus/sbus systems - and that might not have been aligning
> the copy.

I wouldn't know about other architectures.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
