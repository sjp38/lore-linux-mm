Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AF9C96B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 21:27:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <bc6b78b2-ab2d-4b95-add3-493d7748ef1f@default>
Date: Mon, 6 Aug 2012 18:26:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
 <1343447832-7182-5-git-send-email-john.stultz@linaro.org>
 <20120806030451.GA11468@bbox> <aa61fb77-258b-4b6f-843f-689bc5c984cc@default>
 <20120807005620.GB19515@bbox>
In-Reply-To: <20120807005620.GB19515@bbox>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
>=20
> On Mon, Aug 06, 2012 at 08:46:18AM -0700, Dan Magenheimer wrote:
> > > From: Minchan Kim [mailto:minchan@kernel.org]
> > > To: John Stultz
> > > Subject: Re: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the =
VM
> >
> > Hi Minchan --
> >
> > Thanks for cc'ing me on this!
> >
> > > Targets for the LRU list could be following as in future
> > >
> > > 1. volatile pages in this patchset.
> > > 2. ephemeral pages of tmem
> > > 3. madivse(DONTNEED)
> > > 4. fadvise(NOREUSE)
> > > 5. PG_reclaimed pages
> > > 6. clean pages if we write CFLRU(clean first LRU)
> > >
> > > So if any guys have objection, please raise your hands
> > > before further progress.
> >
> > I agree that the existing shrinker mechanism is too primitive
> > and the kernel needs to take into account more factors in
> > deciding how to quickly reclaim pages from a broader set
> > of sources.  However, I think it is important to ensure
> > that both the "demand" side and the "supply" side are
> > studied.  There has to be some kind of prioritization policy
> > among all the RAM consumers so that a lower-priority
> > alloc_page doesn't cause a higher-priority "volatile" page
> > to be consumed.  I suspect this policy will be VERY hard to
> > define and maintain.
>=20
> Yes. It's another story.
> At the moment, VM doesn't consider such priority-inversion problem
> excpet giving the more memory to privileged processes. It's so simple
> but works well till now.

I think it is very important that both stories must be
solved together.  See below...

> > Related, ephemeral pages in tmem are not truly volatile
>=20
> "volatile" term is used by John for only his special patch so
> I like Ereclaim(Easy Reclaim) rather than volatile.

If others agree, that's fine.  However, the "E" prefix is
currently used differently in common English (for example,
for e-books).  Maybe "ezreclaim"?

> > as there is always at least one tmem data structure pointing
> > to it.  I haven't followed this thread previously so my apologies
> > if it already has this, but the LRU_VOLATILE list might
> > need to support a per-page "garbage collection" callback.
>=20
> Right. That's why this patch provides purgepage in address_space_operatio=
ns.
> I think zcache could attach own address_space_operations to the page
> which is allocated by zbud for instance, zcache_purgepage which is called=
 by VM
> when the page is reclaimed. So zcache don't need custom LRU policy(but st=
ill need
> linked list for managing zbuddy) and pass the decision to the VM.

The simple VM decisions are going to need a lot more intelligence
(and data?) to drive which page to reclaim.  For example, is it better
to reclaim a pageframe that contains two compressed pages of ephemeral data
or a pageframe that has one active (or inactive) file page?  Such
a policy is not "Easy". ;-)

(Also, BTW, zcache pages aren't in any address space so don't have
an address_space_operations... because it is not possible to directly
address the data in a compressed page.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
