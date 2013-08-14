Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1777C6B0096
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 07:27:46 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id c13so4769428eek.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 04:27:44 -0700 (PDT)
Date: Wed, 14 Aug 2013 13:27:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130814112741.GB13772@gmail.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
 <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
 <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com>
 <520A6DFC.1070201@sgi.com>
 <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com>
 <20130813231020.GA22667@asylum.americas.sgi.com>
 <CA+55aFyeEK6FfNC-7SjGdYVrjiES0V7JNUG==P5p6iu+UNiAfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyeEK6FfNC-7SjGdYVrjiES0V7JNUG==P5p6iu+UNiAfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Mike Travis <travis@sgi.com>, Peter Anvin <hpa@zytor.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Aug 13, 2013 at 4:10 PM, Nathan Zimmer <nzimmer@sgi.com> wrote:
> >
> > The only mm structure we are adding to is a new flag in page->flags. 
> > That didn't seem too much.
> 
> I don't agree.
> 
> I see only downsides, and no upsides. Doing the same thing *without* the 
> downsides seems straightforward, so I simply see no reason for any extra 
> flags or tests at runtime.

The code as presented clearly looks more involved and neither simple nor 
zero-cost - I was hoping for a much more simple approach.

I see three solutions:

 - Speed up the synchronous memory init code: live migrate to the node 
   being set up via set_cpus_allowed(), to make sure the init is always 
   fast and local.

   Pros: if it solves the problem then mem init is still synchronous, 
   deterministic and essentially equivalent to what we do today - so 
   relatively simple and well-tested, with no 'large machine' special
   path.

   Cons: it might not be enough and we might not have scheduling
   enabled on the affected nodes yet.

 - Speed up the synchronous memory init code by paralellizing the key, 
   most expensive initialization portion of setting up the page head 
   arrays to per node, via SMP function-calls.

   Pros: by far the fastest synchronous option. (It will also test the
   power budget and the mains fuses right during bootup.)

   Cons: more complex and depends on SMP cross-calls being available at
   mem init time. Not necessarily hotplug friendly.

 - Avoid the problem by punting to async mem init.

   Pros: it gets us to a minimal working system quickly and leaves the 
   memory code relatively untouched.

   Disadvantages: makes memory state asynchronous and non-deterministic.
   Stats either fluctuate shortly after bootup or have to be faked.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
