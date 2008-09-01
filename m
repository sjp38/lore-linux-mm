From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Date: Mon, 1 Sep 2008 17:43:42 +1000
References: <20080831174756.GA25790@balbir.in.ibm.com> <200809011656.45190.nickpiggin@yahoo.com.au> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809011743.42658.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 01 September 2008 17:19, KAMEZAWA Hiroyuki wrote:
> On Mon, 1 Sep 2008 16:56:44 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > On Monday 01 September 2008 10:01, KAMEZAWA Hiroyuki wrote:
> > > On Sun, 31 Aug 2008 23:17:56 +0530
> > >
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > This is a rewrite of a patch I had written long back to remove struct
> > > > page (I shared the patches with Kamezawa, but never posted them
> > > > anywhere else). I spent the weekend, cleaning them up for
> > > > 2.6.27-rc5-mmotm (29 Aug 2008).
> > >
> > > It's just because I think there is no strong requirements for 64bit
> > > count/mapcount. There is no ZERO_PAGE() for ANON (by Nick Piggin. I add
> > > him to CC.) (shmem still use it but impact is not big.)
> >
> > I think it would be nice to reduce the impact when it is not configured
> > anyway. Normally I would not mind so much, but this is something that
> > many distros will want to enable but fewer users will make use of it.
> >
> > I think it is always a very good idea to try to reduce struct page size.
> > When looking at the performance impact though, just be careful with the
> > alignment of struct page... I actually think it is going to be a
> > performance win in many cases to make struct page 64 bytes.
>
> On 32bit, sizeof(struct page) = 32bytes + 4bytes(page_cgroup)
> On 64bit, sizeof(struct page) = 56bytes + 8bytes(page_cgroup)
> So, 32bit case is a problem.

Right. Well, either one is a problem because we always prefer to have
less things in struct page rather than more ;)


> > If you do that, it might even be an idea to allocate flat arrays with
> > bootmem. It would just be slightly more tricky more tricky to fit this
> > in with the memory model. But that's not a requirement, just an idea
> > for a small optimisation.
>
> If we make mem_res_controller available only under SPARSEMEM, I think we
> can do in very straightfoward way.

That could be a reasonable solution.  Balbir has other concerns about
this... so I think it is OK to try the radix tree approach first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
