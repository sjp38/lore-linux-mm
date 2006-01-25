Date: Wed, 25 Jan 2006 15:39:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: nommu use compound pages?
Message-ID: <20060125143943.GA25666@wotan.suse.de>
References: <20060125091509.GB32653@wotan.suse.de> <20060125141356.GA2133@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125141356.GA2133@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, gerg@uclinux.org, uclinux-dev@uclinux.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 02:13:56PM +0000, Christoph Hellwig wrote:
> On Wed, Jan 25, 2006 at 10:15:09AM +0100, Nick Piggin wrote:
> > Hi,
> > 
> > This topic came up about a year ago but I couldn't work out why it never
> > happened. Possibly because compound pages wheren't always enabled.
> > 
> > Now that they are, can we have another shot? It would be great to
> > unify all this stuff finally. I must admit I'm not too familiar with
> > the nommu code, but I couldn't find a fundamental problem from the
> > archives.
> 
> I still don't know why nommu uses these at all.  Cc'in the uclinux maintainer
> and list owuld be helpfull if you'd like to find out though.

AFAIK, David has a handle on the issues, but I will take your advice.

Now that I have some more ears, I'll see if I have the issues right:

>From what I could _gather_, anonymous memory is allocated with kmalloc,
which may be backed by a higher order allocation. Refcounting is done at
the vma level. However, get_user_pages can do a 0->1 transition on the
constituent pages' refcounts and a subsequent put_page would free them.

Possibly cleaner would be to have a put_user_pages function instead
of having callers do the put_page themselves (though I haven't looked
through all callsites so this may not be possible).

nommu would then simply use their vma based refcounting entirely. The
current per-page refcounting in nommu get_user_pages looks scary/racy
against their vma refcounting anyway.

However, my main concern is to remove the hacks in the core VM made
for nommu -- I hope a simple patch like this will turn out to be
possible.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
