Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB95C6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:33:03 -0400 (EDT)
Date: Sun, 5 Jul 2009 23:16:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
Message-ID: <20090705151628.GA11307@localhost>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com> <20090705121308.GC5252@localhost> <20090705211739.091D.A69D9226@jp.fujitsu.com> <20090705130200.GA6585@localhost> <2f11576a0907050619t5dea33cfwc46344600c2b17b5@mail.gmail.com> <28c262360907050804p70bc293uc7330a6d968c0486@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360907050804p70bc293uc7330a6d968c0486@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 11:04:17PM +0800, Minchan Kim wrote:
> On Sun, Jul 5, 2009 at 10:19 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >>> > > + printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES));
> >>> > > A  printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> >>> >
> >>> > Can we put related items together, ie. this looks more friendly:
> >>> >
> >>> > A  A  A  A  Anon:XXX active_anon:XXX inactive_anon:XXX
> >>> > A  A  A  A  File:XXX active_file:XXX inactive_file:XXX
> >>>
> >>> hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON != NR_ANON_PAGES.
> >>> tmpfs pages are accounted as FILE, but it is stay in anon lru.
> >>
> >> Right, that's exactly the reason I propose to put them together: to
> >> make the number of tmpfs pages obvious.
> >>
> >>> I think your proposed format easily makes confusion. this format cause to
> >>> imazine Anon = active_anon + inactive_anon.
> >>
> >> Yes it may confuse normal users :(
> >>
> >>> At least, we need to use another name, I think.
> >>
> >> Hmm I find it hard to work out a good name.
> >>
> >> But instead, it may be a good idea to explicitly compute the tmpfs
> >> pages, because the excessive use of tmpfs pages could be a common
> >> reason of OOM.
> >
> > Yeah, A explicite tmpfs/shmem accounting is also useful for /proc/meminfo.
> 
> Do we have to account it explicitly?

When OOM happens, one frequent question to ask is: are there too many
tmpfs/shmem pages?  Exporting this number makes our oom-message-decoding
life easier :)

> If we know the exact isolate pages of each lru,
> 
> tmpfs/shmem = (NR_ACTIVE_ANON + NR_INACTIVE_ANON + isolate(anon)) -
> NR_ANON_PAGES.
> 
> Is there any cases above equation is wrong ?

That's right, but the calculation may be too complex (and boring) for
our little brain ;)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
