Subject: Re: [PATCH 0/39] mm: 2.6.17-pr1 - generic page-replacement
	framework and 4 new policies
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0607130838360.27189@schroedinger.engr.sgi.com>
References: <20060712143659.16998.6444.sendpatchset@lappy>
	 <Pine.LNX.4.64.0607130838360.27189@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 15 Jul 2006 19:03:01 +0200
Message-Id: <1152982981.31891.46.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-07-13 at 08:38 -0700, Christoph Lameter wrote:
> On Wed, 12 Jul 2006, Peter Zijlstra wrote:
> 
> > with OLS around the corner, I thought I'd repost all my page-replacement work
> > so people can get a quick peek at the current status. 
> > This should help discussion next week.
> 
> Ummm... Some high level discussion on what you are doing here and why 
> would be helpful.

Sorry for the late reply.

The page replacement framework takes away all knowledge of the page
replacement implementation from the rest of the kernel. That is, it
takes out all direct references to list_active and list_inactive and
manipulations thereon and replaces them by the following functions:

   pgrep_hint_*()
        |
        v
   pgrep_add()
  _____ |\___________________________________________.
 /     \|_________________.                           \
|       v                  \                           v
|  pgrep_get_candidates()   |                     pgrep_remove()
|       |                   |            .____________/|
|       v                   |           v              |
|  pgrep_reclaimable()      |      pgrep_reinsert()    |
|       |                    \__________/              |
|       |\_____________________.   ,___________________/
|       |                       \ /
|       v                        v
|  [pgrep_activate()]       pgrep_clear_state()
|       |                        |
|       v                        v
|  pgrep_put_candidates()   [pgrep_remember()]
 \______/

(There are some more functions, but this shows the main flow)

Then the patch-set goes on to re-implement all this 4 more times.
(admittedly this is a bit excessive, but has been much fun to do, and
has made sure the abstraction is powerfull enough to cope with very
different approaches to page reclaim).

Now on the why, I still believe one of the advanced page replacement
algorithms are better than the currently implemented. If only because
they have access to more information, namely that provided by the
nonresident page tracking. (Which, as shown by Rik's OLS entry this
year, provides more interresting uses)

I hope this answers enough of your questions, hessitate not to ask more.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
