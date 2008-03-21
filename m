Date: Fri, 21 Mar 2008 18:26:44 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080321172644.GG2346@one.firstfloor.org>
References: <20080318003620.d84efb95.akpm@linux-foundation.org> <20080318141828.GD11966@one.firstfloor.org> <20080318095715.27120788.akpm@linux-foundation.org> <20080318172045.GI11966@one.firstfloor.org> <20080318104437.966c10ec.akpm@linux-foundation.org> <20080319083228.GM11966@one.firstfloor.org> <20080319020440.80379d50.akpm@linux-foundation.org> <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com> <20080320090005.GA25734@one.firstfloor.org> <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 10:15:15AM -0700, Ulrich Drepper wrote:
> On Thu, Mar 20, 2008 at 2:00 AM, Andi Kleen <andi@firstfloor.org> wrote:
> >  What chaos exactly? For me it looks rather that a separatate database
> >  would be a recipe for chaos. e.g. for example how would you make sure
> >  the database keeps track of changing executables?
> 
> I didn't say that a separate file with the data is better.  In fact, I
> agree, it's not much better.  What I referred to as the problem is
> that this is an extension which is not part of the ELF spec and

Linux executables already contain plenty of extensions outside
the ELF spec like GNU_EH_FRAME or debuglink etc. It is not surprising
because the ELF spec is kind of not maintained anymore afaik.

> doesn't fit in.  The ELF spec has rules how programs have to deal with
> unknown parts of a binary.  Only this way programs like strip can work

Can you expand how the bitmap headers or pbitmap.c violate these rules? 

> in the presence of extensions.  There are ways to embed such a bitmap
> but not ad-hoc as you proposed.

Concrete suggestions please.

> 
> 
> >  But if the binutils leanred about this and added a bitmap phdr (it
> >  tends to be only a few hundred bytes even on very large executables)
> >  one seek could be avoided.
> 
> And that is only one advantage.  Let's not go done the path of invalid
> ELF files.

What is invalid?

> 
> 
> >  > Furthermore, by adding all this data to the end of the file you'll
> >
> >  We are talking about 32bytes for each MB worth of executable.
> >  You can hardly call that "all that data".
> 
> This wasn't a comment about the size of the data but the type of data.
>  The end of a binary contains data which is not used at runtime.  Now
> you're mixing in data which is used.

Well there was no other choice I know of short of relinking. Or do you
have a way to add a PHDR without relinking? I am aware the SHDR is a hack,
I called it that myself. I just don't know of a better way. 

If the pbitmaps were universally adopted the use of the SHDRs would
be phased out quickly I expect because the bitmaps would be standard
parts of all PHDRs, but short term not requiring relinking
is a huge advantage.

> Again, you misunderstand.  I'm not proposing to exclude pages which
> are only used at startup time.  I mean the data collection should stop
> some time after a process was started to account for possibly quite
> different code paths which are taken by different runs of the program.
>  I.e., don't record page faults for the entire runtime of the program
> which, hopefully in most cases, will result in all the pages of a
> program to be marked (unless you have a lot of dead code in the binary
> and it's all located together).

When would that time be? I cannot think of a single heuristic that would
work for both "/bin/true" and a OpenOffice start.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
