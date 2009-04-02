Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 203756B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 17:13:30 -0400 (EDT)
Date: Thu, 2 Apr 2009 23:13:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-ID: <20090402211336.GB4076@elte.hu>
References: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081231110816.5f80e265@psychotron.englab.brq.redhat.com> <20081231213705.1293.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090103175913.GA21180@redhat.com> <2f11576a0901031313u791d7dcex94b927cc56026e40@mail.gmail.com> <20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com> <20090105141313.a4abd475.akpm@linux-foundation.org> <20090106104839.78eb07d1@psychotron.englab.brq.redhat.com> <20090402134738.43d87cb7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090402134738.43d87cb7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Pirko <jpirko@redhat.com>, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, linux-kernel@vger.kernel.org, hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> I have a note here that this patch needs acks, but I didn't note who
> from.
> 
> Someone ack it :)

looks good to me at a quick glance. A stupid technicality. There's 
repetitive patterns of:

> +	if (current->mm) {
> +		unsigned long hiwater_rss = get_mm_hiwater_rss(current->mm);
> +
> +		if (sig->maxrss < hiwater_rss)
> +			sig->maxrss = hiwater_rss;
> +	}

in about 3 separate places. Wouldnt a helper along the lines of:

	sig->maxrss = mm_hiwater_rss(current->mm, sig->maxrss);

be much more readable?

The helper could be something like:

 static inline unsigned long
 mm_hiwater_rss(struct mm_struct *mm, unsigned long maxrss)
 {
	return max(maxrss, mm ? get_mm_hiwater_rss(mm) : 0);
 }	

much nicer?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
