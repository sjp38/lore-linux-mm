Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A47BC6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 17:24:25 -0400 (EDT)
Received: by fxg9 with SMTP id 9so5920327fxg.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 14:24:22 -0700 (PDT)
Date: Mon, 8 Aug 2011 23:24:18 +0200
From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: [PATCH] slub: fix check_bytes() for slub debugging
Message-ID: <20110808212418.GA3297@joi.lan>
References: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Sun, Aug 07, 2011 at 06:30:38PM +0900, Akinobu Mita wrote:
> The check_bytes() function is used by slub debugging.  It returns a pointer
> to the first unmatching byte for a character in the given memory area.
> 
> If the character for matching byte is greater than 0x80, check_bytes()
> doesn't work.  Becuase 64-bit pattern is generated as below.
> 
> 	value64 = value | value << 8 | value << 16 | value << 24;
> 	value64 = value64 | value64 << 32;
> 
> The integer promotions are performed and sign-extended as the type of value
> is u8.  The upper 32 bits of value64 is 0xffffffff in the first line, and
> the second line has no effect.
> 
> This fixes the 64-bit pattern generation.

Thank you. I'm a bit ashamed about this bug... I introduced this bug, so:
Reviewed-by: Marcin Slusarz <marcin.slusarz@gmail.com>

I tested your patch to check if performance improvements of commit
c4089f98e943ff445665dea49c190657b34ccffe come from this bug or not.
And forunately they aren't - performance is exactly the same.

How did you find it?

Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
