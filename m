Received: by nz-out-0506.google.com with SMTP id x7so1316018nzc
        for <linux-mm@kvack.org>; Sun, 17 Jun 2007 23:57:55 -0700 (PDT)
Message-ID: <a781481a0706172357s7c473686pa41df174af01cda4@mail.gmail.com>
Date: Mon, 18 Jun 2007 12:27:55 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] mm: More __meminit annotations.
In-Reply-To: <20070618151544.B10A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
	 <20070618055842.GA17858@linux-sh.org>
	 <20070618151544.B10A.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On 6/18/07, Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> > On Mon, Jun 18, 2007 at 02:49:24PM +0900, Yasunori Goto wrote:
> > > > -static inline unsigned long zone_absent_pages_in_node(int nid,
> > > > +static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> > > >                                           unsigned long zone_type,
> > > >                                           unsigned long *zholes_size)
> > > >  {
> > >
> > > I thought __meminit is not effective for these static functions,
> > > because they are inlined function. So, it depends on caller's
> > > defenition. Is it wrong?
> > >
> > Ah, that's possible, I hadn't considered that. It seems to be a bit more
> > obvious what the intention is if it's annotated, especially as this is
> > the convention that's used by the rest of mm/page_alloc.c. A bit more
> > consistent, if nothing more.
>
> I'm not sure which is intended. I found some functions define both
> __init and inline in kernel tree. And probably, some functions don't
> do it. So, it seems there is no convention.
>
> I'm Okay if you prefer both defined. :-)

Marking inline functions as __init (or __meminit etc) is quite insane,
IMHO. Note that all callers of the said inline function will also have to
be __init anyway (else modpost will barf) so the said function will
have all callsites in .init.text anyway, and hence would be inlined
in the same section as the caller (i.e. .init.text). [Note that kernel
uses always_inline.]

The annotation may still be a readability aid (which is subjective so
one can't really comment upon), but asking gcc to put into a separate
specified section, a function whose body would not be emitted by gcc
separately at all, doesn't really make much sense syntactically _or_
semantically -- gcc might not warn, of course, perhaps it's one of those
little things it takes care of by itself silently without complaining (like
taking pointers to inline functions).

Satyam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
