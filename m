Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3BEC06B0069
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 20:15:55 -0500 (EST)
Date: Thu, 26 Jan 2012 17:15:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
Message-Id: <20120126171548.2c85dd44.akpm@linux-foundation.org>
In-Reply-To: <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	<4F218D36.2060308@linux.vnet.ibm.com>
	<9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
	<20120126163150.31a8688f.akpm@linux-foundation.org>
	<ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

On Thu, 26 Jan 2012 16:56:34 -0800 (PST)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > > I'll find the place to add the call to ClearPageWasActive() for v2.
> > 
> > AFAICT this patch consumes our second-last page flag, or close to it.
> > We'll all be breaking out in hysterics when the final one is gone.
> 
> I'd be OK with only using this on 64-bit systems, though there
> are ARM folks playing with zcache that might disagree.

64-bit only is pretty lame and will reduce the appeal of cleancache and
will increase the maintenance burden by causing different behavior on
different CPU types.  Most Linux machines are 32-bit!  (My cheerily
unsubstantiated assertion of the day).

>  Am I
> correct in assuming that your "second-last page flag" concern
> applies only to 32-bit systems?

Sort-of.  Usually a flag which is 64-bit-only causes the above issues.

> > This does appear to be a make or break thing for cleancache - if we
> > can't fix https://lkml.org/lkml/2012/1/22/61 then cleancache is pretty
> > much a dead duck.
> 
> Hmmm... is that URL correct?  If so, there is some subtlety in
> that thread that I am missing as I don't understand the relationship
> to cleancache at all?

err, sorry, I meant your https://lkml.org/lkml/2011/8/17/351.

> > And I'm afraid that neither I nor other MM developers are likely to
> > help you with "fix cleancache via other means" because we weren't
> > provided with any description of what the problem is within cleancache,
> > nor how it will be fixed.  All we are given is the assertion "cleancache
> > needs this".
> 
> The patch comment says:
> 
> The patch resolves issues reported with cleancache which occur
> especially during streaming workloads on older processors,
> see https://lkml.org/lkml/2011/8/17/351
> 
> I can see that may not be sufficient, so let me expand on it.
> 
> First, just as page replacement worked prior to the active/inactive
> redesign at 2.6.27, cleancache works without the WasActive page flag.
> However, just as pre-2.6.27 page replacement had problems on
> streaming workloads, so does cleancache.  The WasActive page flag
> is an attempt to pass the same active/inactive info gathered by
> the post-2.6.27 kernel into cleancache, with the same objectives and
> presumably the same result: improving the "quality" of pages preserved
> in memory thus reducing refaults.
> 
> Is that clearer?  If so, I'll do better on the description at v2.

It really didn't tell us anything, apart from referring to vague
"problems on streaming workloads", which forces everyone to go off and
do an hour or two's kernel archeology, probably in the area of
readahead.

Just describe the problem!  Why is it slow?  Where's the time being
spent?  How does the proposed fix (which we haven't actually seen)
address the problem?  If you inform us of these things then perhaps
someone will have a useful suggestion.  And as a side-effect, we'll
understand cleancache better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
