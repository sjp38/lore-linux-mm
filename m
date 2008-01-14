Message-ID: <478BA351.2000501@sgi.com>
Date: Mon, 14 Jan 2008 10:00:49 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
 large count NR_CPUs
References: <20080113183453.973425000@sgi.com> <20080114081418.GB18296@elte.hu> <200801141104.18789.ak@suse.de> <20080114101133.GA23238@elte.hu>
In-Reply-To: <20080114101133.GA23238@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Andi Kleen <ak@suse.de> wrote:
> 
>>> i.e. we've got ~22K bloat per CPU - which is not bad, but because 
>>> it's a static component, it hurts smaller boxes. For distributors to 
>>> enable CONFIG_NR_CPU=1024 by default i guess that bloat has to drop 
>>> below 1-2K per CPU :-/ [that would still mean 1-2MB total bloat but 
>>> that's much more acceptable than 23MB]
>> Even 1-2MB overhead would be too much for distributors I think. 
>> Ideally there must be near zero overhead for possible CPUs (and I see 
>> no principle reason why this is not possible) Worst case a low few 
>> hundred KBs, but even that would be much.
> 
> i think this patchset already gives a net win, by moving stuff from 
> NR_CPUS arrays into per_cpu area. (Travis please confirm that this is 
> indeed what the numbers show)
> 
> The (total-)size of the per-cpu area(s) grows linearly with the number 
> of CPUs, so we'll have the expected near-zero overhead on 4-8-16-32 CPUs 
> and the expected larger total overhead on 1024 CPUs.
> 
> 	Ingo

Yes, and it's just the first step.  Ideally, there is *no* extra memory
used by specifying NR_CPUS = <whatever> and all the extra memory only
comes into play when they are "possible/probable".  This means that almost
all of the data needs to be in the percpu area (and compact that as much
as possible) or in the initdata section and discarded after use.

And Andi is right, the distributors will not default the NR_CPUS to a large
value unless there is zero or very little overhead.  And since so much
depends on using standard configurations (certifications, etc.) we cannot
depend on a special build.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
