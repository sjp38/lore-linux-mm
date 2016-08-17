Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 349D36B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 08:32:37 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so274746446oih.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:32:37 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id j97si11353292ioi.205.2016.08.17.05.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 05:32:36 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id y195so9929879iod.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:32:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLF2iomkK0xS7VQJmxeS-PR2nURmQq4QQHqWa1S82JQ_og@mail.gmail.com>
References: <CGME20160817101819epcms5p25ad7d8a53c761ffff62993ca4d4bf129@epcms5p2>
 <570065255.35200.1471429099337.JavaMail.weblogic@epwas3e2> <CAOJsxLF2iomkK0xS7VQJmxeS-PR2nURmQq4QQHqWa1S82JQ_og@mail.gmail.com>
From: Pekka Enberg <penberg@kernel.org>
Date: Wed, 17 Aug 2016 15:32:36 +0300
Message-ID: <CAOJsxLEQsnnWjNOcVDNjL0J5hCe1TKxh48AXRD06kJRL62gopg@mail.gmail.com>
Subject: Re: [PATCH 3/4] zswap: Zero-filled pages handling
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: sjenning@redhat.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, =?UTF-8?B?7IOk656A?= <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, =?UTF-8?B?6rmA7KO87ZuI?= <juhunkim@samsung.com>

On Wed, Aug 17, 2016 at 1:18 PM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
>> This patch adds a check in zswap_frontswap_store() to identify zero-filled
>> page before compression of the page. If the page is a zero-filled page, set
>> zswap_entry.zeroflag and skip the compression of the page and alloction
>> of memory in zpool. In zswap_frontswap_load(), check if the zeroflag is
>> set for the page in zswap_entry. If the flag is set, memset the page with
>> zero. This saves the decompression time during load.
>>
>> The overall overhead caused due to zero-filled page check is very minimal
>> when compared to the time saved by avoiding compression and allocation in
>> case of zero-filled pages. The load time of a zero-filled page is reduced
>> by 80% when compared to baseline.

On Wed, Aug 17, 2016 at 3:25 PM, Pekka Enberg <penberg@kernel.org> wrote:
> AFAICT, that's an overall improvement only if there are a lot of
> zero-filled pages because it's just overhead for pages that we *need*
> to compress, no? So I suppose the question is, are there a lot of
> zero-filled pages that we need to swap and why is that the case?

I suppose reading your cover letter would have been helpful before
sending out my email:

"Experiments have shown that around 10-15% of pages stored in zswap are
duplicates which results in 10-12% more RAM required to store these
duplicate compressed pages."

But I still don't understand why we have zero-filled pages that we are
swapping out.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
