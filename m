Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B59BC6B0071
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:18:11 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so4738196wib.3
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:18:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id u14si5952514wjr.195.2014.05.06.11.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 11:18:09 -0700 (PDT)
Message-Id: <201405061817.s46IHFlD026027@mail.zytor.com>
In-Reply-To: <20140506165405.GE6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com> <20140506102925.GD11096@twins.programming.kicks-ass.net> <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com> <20140506150014.GA6731@gmail.com> <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com> <20140506153315.GB6731@gmail.com> <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com> <53690E29.7060602@redhat.com> <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com> <53691214.80906@redhat.com> <20140506165405.GE6731@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC] Heterogeneous memory management (mirror process address space on a device mmu).
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 06 May 2014 11:02:33 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or.Gerlitz@zytor.com

<ogerlitz@mellanox.com>,Sagi Grimberg <sagig@mellanox.com>,Shachar Raindel <raindel@mellanox.com>,Liran Liss <liranl@mellanox.com>,Roland Dreier <roland@purestorage.com>,"Sander, Ben" <ben.sander@amd.com>,"Stoner, Greg" <Greg.Stoner@amd.com>,"Bridgman, John" <John.Bridgman@amd.com>,"Mantor, Michael" <Michael.Mantor@amd.com>,"Blinzer, Paul" <Paul.Blinzer@amd.com>,"Morichetti, Laurent" <Laurent.Morichetti@amd.com>,"Deucher, Alexander" <Alexander.Deucher@amd.com>,"Gabbay, Oded" <Oded.Gabbay@amd.com>,Davidlohr Bueso <davidlohr@hp.com>
Message-ID: <0bf54468-3ed1-4cd4-b771-4836c78dde14@email.android.com>

Nothing wrong with device-side memory, but not having it accessible by the CPU seems fundamentally brown from the point of view of unified memory addressing.

On May 6, 2014 9:54:08 AM PDT, Jerome Glisse <j.glisse@gmail.com> wrote:
>On Tue, May 06, 2014 at 12:47:16PM -0400, Rik van Riel wrote:
>> On 05/06/2014 12:34 PM, Linus Torvalds wrote:
>> > On Tue, May 6, 2014 at 9:30 AM, Rik van Riel <riel@redhat.com>
>wrote:
>> >>
>> >> The GPU runs a lot faster when using video memory, instead
>> >> of system memory, on the other side of the PCIe bus.
>> > 
>> > The nineties called, and they want their old broken model back.
>> > 
>> > Get with the times. No high-performance future GPU will ever run
>> > behind the PCIe bus. We still have a few straggling historical
>> > artifacts, but everybody knows where the future is headed.
>> > 
>> > They are already cache-coherent because flushing caches etc was too
>> > damn expensive. They're getting more so.
>> 
>> I suppose that VRAM could simply be turned into a very high
>> capacity CPU cache for the GPU, for the case where people
>> want/need an add-on card.
>> 
>> With a few hundred MB of "CPU cache" on the video card, we
>> could offload processing to the GPU very easily, without
>> having to worry about multiple address or page table formats
>> on the CPU side.
>> 
>> A new generation of GPU hardware seems to come out every
>> six months or so, so I guess we could live with TLB
>> invalidations to the first generations of hardware being
>> comically slow :)
>> 
>
>I do not want to speak for any GPU manufacturer but i think it is safe
>to say that there will be dedicated memory for GPU for a long time. It
>is not going anywhere soon and it is a lot more than few hundred MB,
>think several GB. If you think about 4k, 8k screen you really gonna
>want
>8GB at least on desktop computer and for compute you will likely see
>16GB or 32GB as common size.
>
>Again i stress that there is nothing on the horizon that let me believe
>that regular memory associated to CPU will ever come close to the
>bandwith
>that exist with memory associated to GPU. It is already more than 10
>times
>faster on GPU and as far as i know the gap will grow even more in the
>next
>generation.
>
>So dedicated memory to gpu should not be discarded as something that is
>vanishing quite the contrary it should be acknowledge as something that
>is
>here to stay a lot longer afaict.
>
>Cheers,
>JA(C)rA'me

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
