Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2802B6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 20:33:10 -0400 (EDT)
Date: Thu, 3 Nov 2011 01:32:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111103003254.GE18879@redhat.com>
References: <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default20111101012017.GJ3466@redhat.com>
 <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default20111101180702.GL3466@redhat.com>
 <b8a0ca71-a31b-488a-9a92-2502d4a6e9bf@default20111102013122.GA18879@redhat.com>
 <2bc86220-1e48-40e5-b502-dcd093956fd5@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2bc86220-1e48-40e5-b502-dcd093956fd5@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Wed, Nov 02, 2011 at 12:06:02PM -0700, Dan Magenheimer wrote:
> First, let me apologize for yesterday.  I was unnecessarily
> sarcastic and disrespectful, and I am sorry.  I very much appreciate
> your time and discussion, and good hard technical questions
> that have allowed me to clarify some of the design and
> implementation under discussion.

No problem, I know it must be frustrating to wait so long to get
something merged.

Like somebody already pointed out (and I agree) it'd be nice to get
the patches posted to the mailing list (with git send-emails/hg
email/quilt) and get them merged into -mm first.

About the subject, git is a super powerful tool, its design saved our
day with kernel.org too. Awesome backed design (I have to admit way
better then mercurial backend in the end, well after the packs have
been introduced) [despite the user interface is still horrible in my
view but it's very well worth the pain to learn to take advantage of
the backend]. The pulls are extremely scalable way to merge stuff, but
they tends to hide stuff and the VM/MM is such a critical piece of the
kernel that in my view it's probably better to go through the pain of
patchbombing linux-mm (maybe not lkml) and pass through -mm for
merging. It's a less scalable approach but it will get more eyes on
the code and if just a single bug is noticed that way, we all win. So
I think you could try to submit the origin/master..origin/tmem with
Andrew and Hugh in CC and see if more comments showup.

> I agree this email is too long, though it has been very useful.

Sure useful to me. I think it's normal and healthy if it gets down to
more lowlevel issues and long emails... There are still a couple of
unanswered issues left in that mail but they're not major if it can be
fixed.

> Confirmed.  Anything below the "struct frontswap_ops" (and
> "struct cleancache_ops), that is anything in the staging/zcache
> directory, is wide open for your ideas and improvement.
> In fact, I would very much welcome your contribution and
> I think IBM and Nitin would also.

Thanks. So this overall sounds fairly positive (or at least better
than neutral) to me.

The VM camp is large so I'd be nice to get comments from others too,
especially if they had time to read our exchange to see if their
concerns were similar to mine. Hugh's knowledge of the swap path would
really help (last time he added swapping to KSM).

On my side I hope it get improved over time to get the best out of
it. I've not been hugely impressed so far because at this point in
time it doesn't seem a vast improvement in runtime behavior compared
to what zram could provide, like Rik said there's no iov/SG/vectored
input to tmem_put (which I'd find more intuitive renamed to
tmem_store), like Avi said ramster is synchronous and not good having
to wait a long time. But if we can make these plugins stackable and we
can put a storage backend at the end we could do
storage+zcache+frontswap.

It needs to have future potential to be worthwhile considering it's
not self contained and modifies the core VM actively in a way that
must be maintained over time. I think I already clarified myself well
enough in prev long email to explain what are the reasons that would
made like it or not. And well if I don't like it, it wouldn't mean it
won't get merged, like wrote in prev mail it's not my decision and I
understand the distro issues you pointed out.

Now that you cleared the fact there is no API/ABI in the
staging/zcache directory to worry about, frankly I'm a lot more happy,
I thought at some point Xen would get into the equation in the tmem
code. So I certainly don't want to take the slightest risk of stifling
innovation saying no to something that makes sense and is free to
evolve :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
