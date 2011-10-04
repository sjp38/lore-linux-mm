Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 33F27900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 15:37:49 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 4 Oct 2011 15:36:48 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p94JZm0f110624
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 15:35:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p94JZlud004522
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 16:35:48 -0300
Subject: Re: [RFCv3][PATCH 1/4] replace string_get_size() arrays
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1317497626.22613.1.camel@Joe-Laptop>
References: <20111001000856.DD623081@kernel>
	 <1317497626.22613.1.camel@Joe-Laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Oct 2011 12:35:42 -0700
Message-ID: <1317756942.7842.38.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com

On Sat, 2011-10-01 at 12:33 -0700, Joe Perches wrote:
> On Fri, 2011-09-30 at 17:08 -0700, Dave Hansen wrote:
> > Instead of explicitly storing the entire string for each
> > possible units, just store the thing that varies: the
> > first character.
> 
> trivia

I'm not sure what you mean by that.

> > diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
> > --- linux-2.6.git/lib/string_helpers.c~string_get_size-pow2	2011-09-30 16:50:31.628981352 -0700
> > +++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 17:04:02.211607364 -0700
> > @@ -8,6 +8,23 @@
> >  #include <linux/module.h>
> >  #include <linux/string_helpers.h>
> >  
> > +static const char byte_units[] = "_KMGTPEZY";
> 
> u64 could be up to ~1.8**19 decimal
> zetta and yotta are not possible or necessary.
> u128 maybe someday, but then other changes
> would be necessary too.

Right, but we're only handling u64.

> > +static char *__units_str(enum string_size_units unit, char *buf, int index)
> > +{
> > +	int place = 0;
> > +
> > +	/* index=0 is plain 'B' with no other unit */
> > +	if (index) {
> > +		buf[place++] = byte_units[index];
> 
> index is unbounded (doesn't matter currently, it will for u128)

It's bound by the division or the log2 at least.  You do have to know
what you're passing in to __units_str, just like you had to know what
you were indexing with in to units_2[] and units_10[].

Is there something else you'd like to see done here?  We can
bounds-check index, but that seems a bit unnecessary since it's static
and the two callers are visible on the same page of code.

> > @@ -23,26 +40,19 @@
> >  int string_get_size(u64 size, const enum string_size_units units,
> >  		    char *buf, int len)
> []
> >  	const unsigned int divisor[] = {
> >  		[STRING_UNITS_10] = 1000,
> >  		[STRING_UNITS_2] = 1024,
> >  	};
> 
> static const or it might be better to use
> 	unsigned int divisor = (string_size_units == STRING_UNITS_2) ? 1024 : 1000;
> as that would make the code clearer in a
> couple of uses of divisor[] later.
> 
> > @@ -61,7 +71,7 @@ int string_get_size(u64 size, const enum
> >  	}
> >  
> >  	snprintf(buf, len, "%lld%s %s", (unsigned long long)size,
> 
> %llu

These two are about existing code, and not really necessary for this
set.  They'd make good follow-on patches, though.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
