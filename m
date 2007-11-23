Received: by el-out-1112.google.com with SMTP id z25so1345134ele
        for <linux-mm@kvack.org>; Fri, 23 Nov 2007 04:42:58 -0800 (PST)
Message-ID: <cfd9edbf0711230442g4004f242v5c21e06e5663d1a8@mail.gmail.com>
Date: Fri, 23 Nov 2007 13:42:58 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [PATCH] mem notifications v2
In-Reply-To: <20071122193650.07bfe5dd@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20071121195316.GA21481@dmt>
	 <cfd9edbf0711220323v71c1dc84v1d10bda0de93fe51@mail.gmail.com>
	 <20071122154736.02325eca@bree.surriel.com>
	 <cfd9edbf0711221627n55c9220dhe3d6bd44449c47b4@mail.gmail.com>
	 <20071122193650.07bfe5dd@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 11/23/07, Rik van Riel <riel@redhat.com> wrote:
> On Fri, 23 Nov 2007 01:27:38 +0100
> "Daniel Spang" <daniel.spang@gmail.com> wrote:
>
> > On 11/22/07, Rik van Riel <riel@redhat.com> wrote:
> > > On Thu, 22 Nov 2007 12:23:55 +0100
> > > "Daniel Spang" <daniel.spang@gmail.com> wrote:
> > >
> > > > When the page cache is filled, the notification is a bit early as the
> > > > following example shows on a small system with 64 MB ram and no swap.
> > > > On the first run the application can use 58 MB of anonymous pages
> > > > before notification is sent. Then after the page cache is filled the
> > > > test application is runned again and is only able to use 49 MB before
> > > > being notified.
> > >
> > > Excellent.  Throwing away useless memory when three is still
> > > useful memory available sounds like a good idea.
> > >
> > > > I see it as a feature to be able to throw out inactive binaries and
> > > > mmaped files before getting notified about low memory.
> > >
> > > I think that once you get low on memory, you want a bit of
> > > both.  Inactive binaries and mmaped files are potentially
> > > useful; in-process free()d memory and caches are just as
> > > potentially (dubiously) useful.
> > >
> > > Freeing a bit of both will probably provide a good compromise
> > > between CPU and memory efficiency.
> >
> > I get your point, but strictly speaking, it is never freeing inactive
> > binaries nor mapped files until all in-process cache are freed. But
> > your argument is still valid, although a tad weaker, if you replace
> > ``inactive binaries and mmaped files'' with ``page cache''.
>
> How can you say that when you do not know how many userland
> processes will get woken up, or how much memory they will
> free?
>
> The kernel sends the notification in *addition* to freeing
> page cache, not instead of freeing page cache.

Ok, ``never freeing'' and ``all in-process cache'' was a slight
exaggeration. However, I did some tests that show that if a process,
polling on the device and able to free some memory rather quickly, not
much mmaped file backed memory will be thrown out after each
notification.

Note that I'm not against this early notification per se, just that I
think there is a need for a later notification too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
