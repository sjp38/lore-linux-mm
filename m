Date: Thu, 30 Nov 2006 20:12:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
Message-Id: <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
References: <20061129030655.941148000@menage.corp.google.com>
	<20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
	<Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
	<6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006 02:45:51 -0800
"Paul Menage" <menage@google.com> wrote:

> On 11/29/06, Christoph Lameter <clameter@sgi.com> wrote:
> >
> > You do not have a problem as long as you hold a mmap_sem lock on any of
> > the vmas in which the page appears. Kame and I discussed several
> > approached on how to avoid the issue in the past but so far there was no
> > need to resolve the issue.
> >
> 
> It sounds like this would be useful for memory hot-unplug too, though.
> A problem worth solving?
> 
It's not solved just because 'there is no user'.
If you'll fix it, I welcome it.

> Why isn't page_lock_anon_vma() safe to use in this case? Because after
> we've established migration ptes, page_mapped() will be false and so
> page_lock_anon_vma() will return NULL?
page_lock_anon_vma() will return NULL because mapcount is 0.
We have to guarantee that we can trust anon_vma(from page->mapping0 even if
page->mapcount is 0.maybe there is several ways.

> How does kswapd do this safely?
> 
kswapd doesn't touches page->mapping after page_mapcount() goes down to 0.

> Possible approach (apologies if you've already considered and rejected this):
> 
As you pointed out, there will be several approaches.

I think one of the biggest concern will be performance impact. And this will 
touch objrmap core, it is good to start discussion with a patch. 

-Kame

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
