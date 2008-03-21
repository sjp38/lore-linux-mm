Received: by el-out-1112.google.com with SMTP id y26so1009878ele.4
        for <linux-mm@kvack.org>; Fri, 21 Mar 2008 10:15:16 -0700 (PDT)
Message-ID: <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
Date: Fri, 21 Mar 2008 10:15:15 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
In-Reply-To: <20080320090005.GA25734@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318209.039112899@firstfloor.org>
	 <20080318003620.d84efb95.akpm@linux-foundation.org>
	 <20080318141828.GD11966@one.firstfloor.org>
	 <20080318095715.27120788.akpm@linux-foundation.org>
	 <20080318172045.GI11966@one.firstfloor.org>
	 <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319083228.GM11966@one.firstfloor.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 20, 2008 at 2:00 AM, Andi Kleen <andi@firstfloor.org> wrote:
>  What chaos exactly? For me it looks rather that a separatate database
>  would be a recipe for chaos. e.g. for example how would you make sure
>  the database keeps track of changing executables?

I didn't say that a separate file with the data is better.  In fact, I
agree, it's not much better.  What I referred to as the problem is
that this is an extension which is not part of the ELF spec and
doesn't fit in.  The ELF spec has rules how programs have to deal with
unknown parts of a binary.  Only this way programs like strip can work
in the presence of extensions.  There are ways to embed such a bitmap
but not ad-hoc as you proposed.


>  But if the binutils leanred about this and added a bitmap phdr (it
>  tends to be only a few hundred bytes even on very large executables)
>  one seek could be avoided.

And that is only one advantage.  Let's not go done the path of invalid
ELF files.


>  > Furthermore, by adding all this data to the end of the file you'll
>
>  We are talking about 32bytes for each MB worth of executable.
>  You can hardly call that "all that data".

This wasn't a comment about the size of the data but the type of data.
 The end of a binary contains data which is not used at runtime.  Now
you're mixing in data which is used.


>  > pages will be needed.  Far more than in most cases.  The prefetching
>  > should really only cover the commonly used code paths in the program.
>
>  Sorry that doesnt make sense. Anything that is read at startup
>  has to be prefetched, even if that code is only executed once.
>  Otherwise the whole scheme is rather useless.
>  Because even a single access requires the IO to read it from
>  disk.

Again, you misunderstand.  I'm not proposing to exclude pages which
are only used at startup time.  I mean the data collection should stop
some time after a process was started to account for possibly quite
different code paths which are taken by different runs of the program.
 I.e., don't record page faults for the entire runtime of the program
which, hopefully in most cases, will result in all the pages of a
program to be marked (unless you have a lot of dead code in the binary
and it's all located together).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
