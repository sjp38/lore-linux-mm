Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8FC900114
	for <linux-mm@kvack.org>; Sat, 21 May 2011 07:00:03 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2635227pvc.14
        for <linux-mm@kvack.org>; Sat, 21 May 2011 03:59:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <s5htycp6b25.wl%tiwai@suse.de>
References: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>
	<20110519145921.GE9854@dumpdata.com>
	<4DD53E2B.2090002@ladisch.de>
	<BANLkTinO1xR4XTN2B325pKCpJ3AjC9YidA@mail.gmail.com>
	<4DD60F57.8030000@ladisch.de>
	<s5htycp6b25.wl%tiwai@suse.de>
Date: Sat, 21 May 2011 12:59:59 +0200
Message-ID: <BANLkTi=P6WP-+BiqEwCRTxaNTqNHT988wA@mail.gmail.com>
Subject: Re: mmap() implementation for pci_alloc_consistent() memory?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Takashi Iwai <tiwai@suse.de>, Clemens Ladisch <clemens@ladisch.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Clemens, Takashi,

On Fri, May 20, 2011 at 10:17 AM, Takashi Iwai <tiwai@suse.de> wrote:
> At Fri, 20 May 2011 08:51:03 +0200,
> Clemens Ladisch wrote:
>>
>> Leon Woestenberg wrote:
>> > On Thu, May 19, 2011 at 5:58 PM, Clemens Ladisch <clemens@ladisch.de> =
wrote:
>> >>> On Thu, May 19, 2011 at 12:14:40AM +0200, Leon Woestenberg wrote:
>> >>> > =A0 =A0 vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
>> >>
>> >> So is this an architecture without coherent caches?
>> >
>> > My aim is to have an architecture independent driver.
>>
>> Please note that most MMU architectures forbid mapping the same memory
>> with different attributes, so you must use pgprot_noncached if and only
>> if dma_alloc_coherent actually uses it. =A0Something like the code below=
.
>>
>> And I'm not sure if you have to do some additional cache flushes when
>> mapping on some architectures.
>>
>> >> Or would you want to use pgprot_dmacoherent, if available?
>> >
>> > Hmm, let me check that.
>>
>> It's available only on ARM and Unicore32.
>>
>> There's also dma_mmap_coherent(), which does exactly what you want if
>> your buffer is physically contiguous, but it's ARM only.
>> Takashi tried to implement it for other architectures; I don't know
>> what came of it.
>
> PPC got this recently (thanks to Ben), but still missing in other
> areas.
>
> There was little uncertain issue on MIPS, and it looks difficult to
> achieve it on PA-RISC at all. =A0The development was stuck due to lack
> of time since then.
>
Thanks for all the insights, I wasn't aware there were arch-specific
calls that already solved the topic issue.

Having dma_mmap_coherent() there is good for one or two archs, but how
can we built portable drivers if the others arch's are still missing?

I assume this call is thus not officially DMA-API (yet)?

Clemens showed some pretty amazing preprocessor #if(def)s to cater for
the all the different arch's and their mapping/cache-coherency
behaviour, but that's not something I would like to put in a driver.

How would dma_mmap_coherent() look like on x86?


Regards,
--=20
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
