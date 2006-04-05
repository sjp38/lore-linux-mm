Date: Wed, 5 Apr 2006 10:06:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
Message-Id: <20060405100614.97d2e422.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
	<20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006 08:06:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 4 Apr 2006, KAMEZAWA Hiroyuki wrote:
> 
> > On Mon, 3 Apr 2006 23:58:05 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > Rip the page migration logic out
> > > 
> > 
> > Thank you. I like this removal, especially removing remove_from_swap() :)
> 
> Have a look at remove_migration_ptes(). Like remove_from_swap() it has the 
> requirement that the mmap_sem is held since that is the only secure way to 
> make sure that the anon_vma is not vanishing from under us. That may be a 
> problem if you are not coming from a process context. Any ideas on how to 
> fix that?
> 
I think adding SWP_TYPE_MIGRATION consideration to free_swap_and_cache() is
enough against anon_vma vanishing. Because remove_migration_ptes() compares 
old pte entry with old page's pfn, a page cannot be remapped into old place
when anon_vma has gone. This is my first impression.
My concern is refcnt handling of SWP_TYPE_MIGRATION pages, but maybe no problem.

Note: unuse_vma() doesn't check what pte entry contains.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
