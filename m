Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3844F8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:10:26 -0400 (EDT)
Date: 16 Mar 2011 14:10:23 -0400
Message-ID: <20110316181023.2090.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
In-Reply-To: <alpine.LSU.2.00.1103161011370.13407@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, linux@horizon.com
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

> I'm intrigued: please educate me.  On what architectures does cache-
> aligning a 48-byte buffer (previously offset by 4 bytes) speed up
> copying from it, and why?  Does the copying involve 8-byte or 16-byte
> instructions that benefit from that alignment, rather than cacheline
> alignment?

I had two thoughts in my head when I wrote that:
1) A smart compiler could note the alignment and issue wider copy
   instructions.  (Especially on alignment-required architectures.)
2) The cacheline fetch would get more data faster.  The data would
   be transferred in the first 6 beats of the load from RAM (assuming a
   64-bit data bus) rather than waiting for 7, so you'd finish the copy
   1 ns sooner or so.  Similar 1-cycle win on a 128-bit Ln->L(n-1) cache
   transfer.

As I said, "infinitesimal".  The main reason that I bothered to
generate a patch was that it appealed to my sense of neatness to
keep the 3x16-byte buffer 16-byte aligned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
