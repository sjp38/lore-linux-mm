Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 502B36B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 09:39:19 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id h65-v6so12422648vke.1
        for <linux-mm@kvack.org>; Wed, 02 May 2018 06:39:19 -0700 (PDT)
Received: from mail.stoffel.org (mail.stoffel.org. [104.236.43.127])
        by mx.google.com with ESMTPS id x21-v6si1482829vkx.95.2018.05.02.06.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 06:39:18 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <23273.48986.516559.317965@quad.stoffel.home>
Date: Wed, 2 May 2018 09:38:34 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
In-Reply-To: <alpine.LRH.2.02.1804301622480.4454@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>
	<20180424170349.GQ17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424173836.GR17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
	<1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
	<alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
	<alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<1524694663.4100.21.camel@HansenPartnership.com>
	<alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
	<1524697697.4100.23.camel@HansenPartnership.com>
	<23266.8532.619051.784274@quad.stoffel.home>
	<alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
	<23271.24580.695738.853532@quad.stoffel.home>
	<alpine.LRH.2.02.1804301622480.4454@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: John Stoffel <john@stoffel.org>, Andrew@stoffel.org, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, edumazet@google.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:

Mikulas> On Mon, 30 Apr 2018, John Stoffel wrote:

>> >>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:
>> 
Mikulas> On Thu, 26 Apr 2018, John Stoffel wrote:
>> 
Mikulas> I see your point - and I think the misunderstanding is this.
>> 
>> Thanks.
>> 
Mikulas> This patch is not really helping people to debug existing crashes. It is 
Mikulas> not like "you get a crash" - "you google for some keywords" - "you get a 
Mikulas> page that suggests to turn this option on" - "you turn it on and solve the 
Mikulas> crash".
>> 
Mikulas> What this patch really does is that - it makes the kernel deliberately 
Mikulas> crash in a situation when the code violates the specification, but it 
Mikulas> would not crash otherwise or it would crash very rarely. It helps to 
Mikulas> detect specification violations.
>> 
Mikulas> If the kernel developer (or tester) doesn't use this option, his buggy 
Mikulas> code won't crash - and if it won't crash, he won't fix the bug or report 
Mikulas> it. How is the user or developer supposed to learn about this option, if 
Mikulas> he gets no crash at all?
>> 
>> So why do we make this a KConfig option at all?

Mikulas> Because other people see the KConfig option (so, they may enable it) and 
Mikulas> they don't see the kernel parameter (so, they won't enable it).

Mikulas> Close your eyes and say how many kernel parameters do you remember :-)

>> Just turn it on and let it rip.

Mikulas> I can't test if all the networking drivers use kvmalloc properly, because 
Mikulas> I don't have the hardware. You can't test it neither. No one has all the 
Mikulas> hardware that is supported by Linux.

Mikulas> Driver issues can only be tested by a mass of users. And if the users 
Mikulas> don't know about the debugging option, they won't enable it.

>> >> I agree with James here.  Looking at the SLAB vs SLUB Kconfig entries
>> >> tells me *nothing* about why I should pick one or the other, as an
>> >> example.

Mikulas> BTW. You can enable slub debugging either with CONFIG_SLUB_DEBUG_ON or 
Mikulas> with the kernel parameter "slub_debug" - and most users who compile their 
Mikulas> own kernel use CONFIG_SLUB_DEBUG_ON - just because it is visible.

You miss my point, which is that there's no explanation of what the
difference is between SLAB and SLUB and which I should choose.  The
same goes here.  If the KConfig option doesn't give useful info, it's
useless.

>> Now I also think that Linus has the right idea to not just sprinkle 
>> BUG_ONs into the code, just dump and oops and keep going if you can.  
>> If it's a filesystem or a device, turn it read only so that people 
>> notice right away.

Mikulas> This vmalloc fallback is similar to
Mikulas> CONFIG_DEBUG_KOBJECT_RELEASE.  CONFIG_DEBUG_KOBJECT_RELEASE
Mikulas> changes the behavior of kobject_put in order to cause
Mikulas> deliberate crashes (that wouldn't happen otherwise) in
Mikulas> drivers that misuse kobject_put. In the same sense, we want
Mikulas> to cause deliberate crashes (that wouldn't happen otherwise)
Mikulas> in drivers that misuse kvmalloc.

Mikulas> The crashes will only happen in debugging kernels, not in
Mikulas> production kernels.

Says you.  What about people or distros that enable it
unconditionally?  They're going to get all kinds of reports and then
turn it off again.  Crashing the system isn't the answer here.  
