Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D7F6C6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 23:10:48 -0400 (EDT)
Received: by wwi14 with SMTP id 14so3782513wwi.26
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 20:10:46 -0700 (PDT)
Subject: Re: [PATCH] slub: fix check_bytes() for slub debugging
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
References: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Aug 2011 05:10:40 +0200
Message-ID: <1312859440.2531.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Le dimanche 07 aoA>>t 2011 A  18:30 +0900, Akinobu Mita a A(C)crit :
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
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: linux-mm@kvack.org
> ---
>  mm/slub.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index eb5a8f9..5695f92 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -701,7 +701,7 @@ static u8 *check_bytes(u8 *start, u8 value, unsigned int bytes)
>  		return check_bytes8(start, value, bytes);
>  
>  	value64 = value | value << 8 | value << 16 | value << 24;
> -	value64 = value64 | value64 << 32;
> +	value64 = (value64 & 0xffffffff) | value64 << 32;
>  	prefix = 8 - ((unsigned long)start) % 8;
>  
>  	if (prefix) {

Still buggy I am afraid. Could we use the following ?


	value64 = value;
	value64 |= value64 << 8;
	value64 |= value64 << 16;
	value64 |= value64 << 32;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
