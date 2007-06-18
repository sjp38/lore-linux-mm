Received: by an-out-0708.google.com with SMTP id d33so402144and
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 03:29:42 -0700 (PDT)
Message-ID: <a781481a0706180329i688ece9fm4607c273ed3961bc@mail.gmail.com>
Date: Mon, 18 Jun 2007 15:59:42 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] mm: More __meminit annotations.
In-Reply-To: <20070618074529.GA21222@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618045229.GA31635@linux-sh.org>
	 <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
	 <20070618074529.GA21222@uranus.ravnborg.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On 6/18/07, Sam Ravnborg <sam@ravnborg.org> wrote:
> On Mon, Jun 18, 2007 at 02:49:24PM +0900, Yasunori Goto wrote:
> > >  }
> > >
> > > -static inline unsigned long zone_absent_pages_in_node(int nid,
> > > +static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> > >                                             unsigned long zone_type,
> > >                                             unsigned long *zholes_size)
> > >  {
> >
> > I thought __meminit is not effective for these static functions,
> > because they are inlined function. So, it depends on caller's
> > defenition. Is it wrong?
>
> As we do not _know_ if a given function is inline or not it definitely
> makes sense to mark them as __meminit.
> If the compiler then decides to inline the function we are all clear and
> no problems. If the compiler decides not to inline the function we will
> properly discard the code after init has completed so again all clear.

The kernel uses always_inline (as of today), so I'd expect we do know
a function explicitly marked such would be inlined. But yes, if that
inline (or kernel's use of always_inline) is dropped from the code in
future, then we would need to add the __init at that time anyway,
so as long as gcc is doing the right thing given both inline and section,
we might introduce the __init now too as you suggest. [Might also help
readability / uniformity as Paul mentioned.]

> And btw. some people (including myself) consider it a bug that gcc inline
> a function that is forced to a specific section into a function that belongs
> to another section. Now gcc people has another view but that may change.
> So again defining a function as __meminit makes sense no matter the
> section marker.

Well, in-kernel, "inline __init" expands to (currently):
inline __attribute__((always_inline)) __attribute__((__section__(".init.text")))
which is weird, if not crazy, to say the least. So I'm not sure we can
find fault with gcc (regardless of what it does) given such usage :-)

On 6/18/07, Sam Ravnborg <sam@ravnborg.org> wrote:
> On Mon, Jun 18, 2007 at 12:58:34PM +0530, Satyam Sharma wrote:
> >
> > Actually, modpost will _not_ complain precisely _because_ kernel
> > uses always_inline so a separate body for the function will never be
> > emitted at all.
> That has been threaten to change many times. Far far far too much
> are marked inline today. There has been several longer threads about it.
>
> Part of it is that some part MUST be inlined to work while other parts
> may be inline but not needed (and often the wrong thing).
>
> So a carefully added inline is good but the other 98% of inline
> markings are just wrong and ougth to go.

Hmm, this is a bit orthogonal, and I have no strong opinion regarding
the kernel's use of always_inline itself. Those who don't like gcc
rewriting their code would want it to stay but forcing it for all cases
(by redefining a keyword as a macro) isn't best either. Perhaps "inline"
could be left alone by removing the always_inline, and "__always_inline"
used explicitly where we _really_ want stuff to be inlined. But then what
might happen is that everybody would think his particular use of inline
is correct and beneficial and all users of inline in kernel would end up
as __always_inline anyway. Given this, the best way to deal with
kernel bloat due to inlining appears to be to remove the inline marker
from stuff that shouldn't/needn't be inline in the first place, instead of
changing the kernel's default use of always_inline, IMO.

Satyam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
