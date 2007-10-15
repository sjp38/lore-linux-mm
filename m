From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
Date: Tue, 16 Oct 2007 00:38:03 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710160006.19735.nickpiggin@yahoo.com.au> <200710151105.57442.borntraeger@de.ibm.com>
In-Reply-To: <200710151105.57442.borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710160038.03524.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Monday 15 October 2007 19:05, Christian Borntraeger wrote:
> Am Montag, 15. Oktober 2007 schrieb Nick Piggin:
> > On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
> > > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
> > > unmaintained, so decided to sent the patch to you :-).
> > > I have CCed Ted, who did work on the code in the 90s. I found no
> > > current email address of Chad Page.
> >
> > This really needs to be fixed...
>
> I obviously agree ;-)
> We have seen this problem happen several times.
>
> > I can't make up my mind between the approaches to fixing it.
> >
> > On one hand, I would actually prefer to really mark the buffers
> > dirty (as in: Eric's fix for this problem[*]) than this patch,
> > and this seems a bit like a bandaid...
>
> I have never seen these patches, so I cannot comment on them.

> > On the other hand, the wound being covered by the bandaid is
> > actually the code in the buffer layer that does this latent
> > "cleaning" of the page because it sadly doesn't really keep
> > track of the pagecache state. But it *still* feels like we
> > should be marking the rd page's buffers dirty which should
> > avoid this problem anyway.
>
> Yes, that would solve the problem as well. As long as we fix
> the problem, I am happy. On the other hand, do you see any
> obvious problem with this "bandaid"?

I don't think so -- in fact, it could be the best candidate for
a minimal fix for stable kernels (anyone disagree? if not, maybe
you could also send this to the stable maintainers?).

But I do want to have this fixed in a "nice" way. eg. I'd like
it to mark the buffers dirty because that actually results in
more reuse of generic kernel code, and also should make rd
behave more naturally (I like using it to test filesystems
because it can expose a lot more concurrency than something like
loop on tmpfs). It should also be possible to actually have
rd's buffer heads get reclaimed as well, preferably while
exercising the common buffer paths and without writing much new
code.

All of that is secondary to fixing the data corruption problem
of course! But the fact that those alternate patches do exist now
means I want to just bring them into the discussion again before
merging one or the other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
