Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83BC88D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:59:18 -0400 (EDT)
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.LSU.2.00.1103161011370.13407@sister.anvils>
References: <20110316022804.27679.qmail@science.horizon.com>
	 <alpine.LSU.2.00.1103161011370.13407@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 13:23:07 -0500
Message-ID: <1300299787.3128.495.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: George Spelvin <linux@horizon.com>, penberg@cs.helsinki.fi, herbert@gondor.hengli.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2011-03-16 at 10:17 -0700, Hugh Dickins wrote:
> On Sun, 13 Mar 2011, George Spelvin wrote:
> 
> > Cache aligning the secret[] buffer makes copying from it infinitesimally
> > more efficient.
> > ---
> >  drivers/char/random.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > index 72a4fcb..4bcc4f2 100644
> > --- a/drivers/char/random.c
> > +++ b/drivers/char/random.c
> > @@ -1417,8 +1417,8 @@ static __u32 twothirdsMD4Transform(__u32 const buf[4], __u32 const in[12])
> >  #define HASH_MASK ((1 << HASH_BITS) - 1)
> >  
> >  static struct keydata {
> > -	__u32 count; /* already shifted to the final position */
> >  	__u32 secret[12];
> > +	__u32 count; /* already shifted to the final position */
> >  } ____cacheline_aligned ip_keydata[2];
> >  
> >  static unsigned int ip_cnt;
> 
> I'm intrigued: please educate me.  On what architectures does cache-
> aligning a 48-byte buffer (previously offset by 4 bytes) speed up
> copying from it, and why?  Does the copying involve 8-byte or 16-byte
> instructions that benefit from that alignment, rather than cacheline
> alignment?

I think this alignment exists to minimize the number of cacheline
bounces on SMP as this can be a pretty hot structure in the network
stack. It could probably benefit from a per-cpu treatment.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
