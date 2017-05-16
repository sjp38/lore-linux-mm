Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D35026B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 18:27:03 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q71so68942662qkl.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 15:27:03 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id y32si144958qtc.312.2017.05.16.15.27.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 15:27:00 -0700 (PDT)
Message-ID: <1494973607.21847.50.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 17 May 2017 08:26:47 +1000
In-Reply-To: <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, 2017-05-16 at 09:43 +0100, Mel Gorman wrote:
> I'm not sure what you're asking here. migration is only partially
> transparent but a move_pages call will be necessary to force pages onto
> CDM if binding policies are not used so the cost of migration will be
> invisible. Even if you made it "transparent", the migration cost would
> be incurred at fault time. If anything, using move_pages would be more
> predictable as you control when the cost is incurred.

One of the main point of this whole exercise is for applications to not
have to bother with any of this and now you are bringing all back into
their lap.

The base idea behind the counters we have on the link is for the HW to
know when memory is accessed "remotely", so that the device driver can
make decision about migrating pages into or away from the device,
especially so that applications don't have to concern themselves with
memory placement.

This is also to a certain extent the programming model provided by HMM
for non-coherent devices.

While some customers want the last % of performance and will explicitly
place their memory, the general case out there is to have "plug in"
libraries using GPU to accelerate common computational problems behind
the scene with no awareness of memory placement. Explicit memory
placement becomes unmanageable is heavily shared environment too.

Thus we want to reply on the GPU driver moving the pages around where
most appropriate (where they are being accessed, either core memory or
GPU memory) based on inputs from the HW counters monitoring the link.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
