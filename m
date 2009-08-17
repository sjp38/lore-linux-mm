Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A13F6B004F
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 14:14:38 -0400 (EDT)
Message-ID: <4A899E73.6000505@redhat.com>
Date: Mon, 17 Aug 2009 14:16:19 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	 <1250344518.4159.4.camel@mulgrave.site>	 <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>	 <20090816083434.2ce69859@infradead.org>	 <1250437927.3856.119.camel@mulgrave.site> <4A8834B6.2070104@rtr.ca>	 <1250446047.3856.273.camel@mulgrave.site> <4A884D9C.3060603@rtr.ca>	 <1250447052.3856.294.camel@mulgrave.site> <4A898752.9000205@tmr.com>	 <87f94c370908171008t44ff64ack2153e740128278e@mail.gmail.com> <1250529575.7858.31.camel@mulgrave.site>
In-Reply-To: <1250529575.7858.31.camel@mulgrave.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Bill Davidsen <davidsen@tmr.com>, Mark Lord <liml@rtr.ca>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Chiming in here a bit late, but coalescing requests is also a good way 
to prevent read-modify-write cycles.

Specifically, if I remember the concern correctly, for the WRITE_SAME 
with unmap bit set, when the IO is not evenly aligned on the "erase 
chunk" (whatever they call it) boundary the device can be forced to do a 
read-modify-write (of zeroes) to the end or beginning of that region.

For a disk array, the WRITE_SAME with unmap bit when done cleanly on an 
aligned boundary can be done entirely in the array's cache. The 
read-modify-write can generate several reads to the back end disks which 
are significantly slower....

ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
