Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB8C8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:42:42 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p2GIga9s012311
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:42:36 -0700
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by hpaq13.eem.corp.google.com with ESMTP id p2GIencK015632
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:42:35 -0700
Received: by iyb26 with SMTP id 26so2467404iyb.33
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:42:35 -0700 (PDT)
Date: Wed, 16 Mar 2011 11:42:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
In-Reply-To: <20110316181023.2090.qmail@science.horizon.com>
Message-ID: <alpine.LSU.2.00.1103161123360.14076@sister.anvils>
References: <20110316181023.2090.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

On Wed, 16 Mar 2011, George Spelvin wrote:

> > I'm intrigued: please educate me.  On what architectures does cache-
> > aligning a 48-byte buffer (previously offset by 4 bytes) speed up
> > copying from it, and why?  Does the copying involve 8-byte or 16-byte
> > instructions that benefit from that alignment, rather than cacheline
> > alignment?
> 
> I had two thoughts in my head when I wrote that:
> 1) A smart compiler could note the alignment and issue wider copy
>    instructions.  (Especially on alignment-required architectures.)

Right, that part of it would benefit from stronger alignment,
but does not generally need cacheline alignment.

> 2) The cacheline fetch would get more data faster.  The data would
>    be transferred in the first 6 beats of the load from RAM (assuming a
>    64-bit data bus) rather than waiting for 7, so you'd finish the copy
>    1 ns sooner or so.  Similar 1-cycle win on a 128-bit Ln->L(n-1) cache
>    transfer.

That argument worries me.  I don't know enough to say whether you are
correct or not.  But if you are correct, then it worries me that your
patch will be the first of a trickle growing to a stream to an avalanche
of patches where people align and reorder structures so that the most
commonly accessed fields are at the beginnng of the cacheline, so that
those can then be accessed minutely faster.

Aargh, and now I am setting off the avalanche with that remark.
Please, someone, save us by discrediting George's argument.

> 
> As I said, "infinitesimal".  The main reason that I bothered to
> generate a patch was that it appealed to my sense of neatness to
> keep the 3x16-byte buffer 16-byte aligned.

Ah, now you come clean!  Yes, it does feel neater to me too;
but I doubt that would be sufficient justification by itself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
