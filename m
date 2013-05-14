Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BDB9C6B0002
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:55:09 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <370eb593-1a2f-41a6-8b16-163f54634f19@default>
Date: Tue, 14 May 2013 13:54:41 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <51920197.9070105@oracle.com> <20130514160040.GB4024@medulla>
 <b9131728-5cf8-4979-a6de-ac14cc409b28@default>
 <20130514172827.GE4024@medulla>
In-Reply-To: <20130514172827.GE4024@medulla>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> On Tue, May 14, 2013 at 09:37:08AM -0700, Dan Magenheimer wrote:
> > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > Subject: Re: [PATCHv11 3/4] zswap: add to mm/
> > >
> > > On Tue, May 14, 2013 at 05:19:19PM +0800, Bob Liu wrote:
> > > > Hi Seth,
> > >
> > > Hi Bob, thanks for the review!
> > >
> > > >
> > > > > +=09/* reclaim space if needed */
> > > > > +=09if (zswap_is_full()) {
> > > > > +=09=09zswap_pool_limit_hit++;
> > > > > +=09=09if (zbud_reclaim_page(tree->pool, 8)) {
> > > >
> > > > My idea is to wake up a kernel thread here to do the reclaim.
> > > > Once zswap is full(20% percent of total mem currently), the kernel
> > > > thread should reclaim pages from it. Not only reclaim one page, it
> > > > should depend on the current memory pressure.
> > > > And then the API in zbud may like this:
> > > > zbud_reclaim_page(pool, nr_pages_to_reclaim, nr_retry);
> > >
> > > So kswapd for zswap.  I'm not opposed to the idea if a case can be
> > > made for the complexity.  I must say, I don't see that case though.
> > >
> > > The policy can evolve as deficiencies are demonstrated and solutions =
are
> > > found.
> >
> > Hmmm... it is fairly easy to demonstrate the deficiency if
> > one tries.  I actually first saw it occur on a real (though
> > early) EL6 system which started some graphics-related service
> > that caused a very brief swapstorm that was invisible during
> > normal boot but clogged up RAM with compressed pages which
> > later caused reduced weird benchmarking performance.
>=20
> Without any specifics, I'm not sure what I can do with this.

Well, I think its customary for the author of a patch to know
the limitations of the patch.  I suggest you synthesize a
workload that attempts to measure worst case.  That's exactly
what I did a year ago that led me to the realization that
zcache needed to solve some issues before it was ready to
promote out of staging.
=20
> I'm hearing you say that the source of the benchmark degradation
> are the idle pages in zswap.  In that case, the periodic writeback
> patches I have in the wings should address this.
>=20
> I think we are on the same page without realizing it.  Right now
> zswap supports a kind of "direct reclaim" model at allocation time.
> The periodic writeback patches will handle the proactive writeback
> part to free up the zswap pool when it has idle pages in it.

I don't think we are on the same page though maybe you are heading
in the same direction now. I won't repeat the comments from the
previous email.

> > I think Mel's unpredictability concern applies equally here...
> > this may be a "long-term source of bugs and strange memory
> > management behavior."
> >
> > > Can I get your ack on this pending the other changes?
> >
> > I'd like to hear Mel's feedback about this, but perhaps
> > a compromise to allow for zswap merging would be to add
> > something like the following to zswap's Kconfig comment:
> >
> > "Zswap reclaim policy is still primitive.  Until it improves,
> > zswap should be considered experimental and is not recommended
> > for production use."
>=20
> Just for the record, an "experimental" tag in the Kconfig won't
> work for me.
>
> The reclaim policy for zswap is not primitive, it's simple.  There
> is a difference.  Plus zswap is already runtime disabled by default.
> If distros/customers enabled it, it is because they purposely
> enabled it.

Hmmm... I think you are proposing to users/distros the following
use model:  "If zswap works for you, turn it on.  If it sucks,
turn it off.  I can't tell you in advance whether it will work
or suck for your distro/workload, but it will probably work so
please try it."

That sounds awfully experimental to me.

The problem is not simple.  Your solution is simple because
you are simply pretending that the harder parts of the problem
don't exist.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
