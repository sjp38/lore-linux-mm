Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 79E536B0047
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 13:33:13 -0500 (EST)
Message-ID: <494A97DD.7080503@vlnb.net>
Date: Thu, 18 Dec 2008 21:35:09 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
MIME-Version: 1.0
Subject: [RFC]: Support for zero-copy TCP transmit of user space data
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net> <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net>
In-Reply-To: <4947FA1C.2090509@vlnb.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello linux-mm,

Recently I submitted a new SCSI target framework (SCST) and 4 target 
drivers for it for the first iteration of review and comments. See 
http://lkml.org/lkml/2008/12/10/245 for details.

An iSCSI target driver iSCSI-SCST was a part of the patchset 
(http://lkml.org/lkml/2008/12/10/293). For it a nice optimization to 
have TCP zero-copy transmit of user space data was implemented. Patch, 
implementing this optimization was also sent in the patchset, see 
http://lkml.org/lkml/2008/12/10/296.

I would like to ask, if the approach used in this patch can be 
acceptable from your point of view? I understand, that extending struct 
page is a very much undesirable, but, from other side:

  - This approach is very simple and straightforward. The patch is only 
309 lines long, including comments. All other alternative 
implementations would be at least an order of magnitude more complicated.

  - Related kernel config option 
TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION should be disabled by 
default in general distro kernels, so the would be no harm at all from 
this patch. ISCSI-SCST can work without this patch or with 
TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION option disabled, although 
with user space device handlers it will work considerably worse. Only 
few distro kernels users need an iSCSI target and only few among such 
users need to use user space device handlers. People who need both iSCSI 
target *and* fast working user space device handlers would simply enable 
that option and rebuild the kernel. Rejecting this patch provides much 
worse alternative: those people would also have to *patch* the kernel at 
first, only then enable that option, then rebuild the kernel.

  - Although usage of struct page to keep network related pointer might 
look as a layering violation, it isn't. I wrote in 
http://lkml.org/lkml/2008/12/15/190 why.

Thanks,
Vlad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
