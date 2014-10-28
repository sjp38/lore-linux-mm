Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id CEC296B0075
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 17:22:54 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h3so1918565igd.13
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 14:22:54 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0158.hostedemail.com. [216.40.44.158])
        by mx.google.com with ESMTP id s32si3909927ioi.30.2014.10.28.14.22.54
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 14:22:54 -0700 (PDT)
Message-ID: <1414531369.10912.14.camel@perches.com>
Subject: [PATCH] 6fire: Convert byte_rev_table uses to bitrev8
From: Joe Perches <joe@perches.com>
Date: Tue, 28 Oct 2014 14:22:49 -0700
In-Reply-To: <1414392371.8884.2.camel@perches.com>
References: 
	  <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Will Deacon <Will.Deacon@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>, linux-arm-kernel@lists.infradead.org, alsa-devel <alsa-devel@alsa-project.org>, LKML <linux-kernel@vger.kernel.org>linux-mm@kvack.orgWill Deacon <Will.Deacon@arm.com>Akinobu Mita <akinobu.mita@gmail.com>linux-arm-kernel@lists.infradead.orgalsa-devel <alsa-devel@alsa-project.org>LKML <linux-kernel@vger.kernel.org>

Use the inline function instead of directly indexing the array.

This allows some architectures with hardware instructions
for bit reversals to eliminate the array.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Sun, 2014-10-26 at 23:46 -0700, Joe Perches wrote:
> On Mon, 2014-10-27 at 14:37 +0800, Wang, Yalin wrote:
> > this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
> > so that we can use arm/arm64 rbit instruction to do bitrev operation
> > by hardware.
[]
> > diff --git a/include/linux/bitrev.h b/include/linux/bitrev.h
> > index 7ffe03f..ef5b2bb 100644
> > --- a/include/linux/bitrev.h
> > +++ b/include/linux/bitrev.h
> > @@ -3,6 +3,14 @@
> >  
> >  #include <linux/types.h>
> >  
> > +#ifdef CONFIG_HAVE_ARCH_BITREVERSE
> > +#include <asm/bitrev.h>
> > +
> > +#define bitrev32 __arch_bitrev32
> > +#define bitrev16 __arch_bitrev16
> > +#define bitrev8 __arch_bitrev8
> > +
> > +#else
> >  extern u8 const byte_rev_table[256];

 sound/usb/6fire/firmware.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/sound/usb/6fire/firmware.c b/sound/usb/6fire/firmware.c
index 3b02e54..62c25e7 100644
--- a/sound/usb/6fire/firmware.c
+++ b/sound/usb/6fire/firmware.c
@@ -316,7 +316,7 @@ static int usb6fire_fw_fpga_upload(
 
 	while (c != end) {
 		for (i = 0; c != end && i < FPGA_BUFSIZE; i++, c++)
-			buffer[i] = byte_rev_table[(u8) *c];
+			buffer[i] = bitrev8((u8)*c);
 
 		ret = usb6fire_fw_fpga_write(device, buffer, i);
 		if (ret < 0) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
