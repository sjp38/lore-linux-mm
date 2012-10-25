Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0F70D6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 17:27:47 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so3668133ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 14:27:46 -0700 (PDT)
Date: Thu, 25 Oct 2012 14:27:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <508912B0.7080805@gmail.com>
Message-ID: <alpine.LNX.2.00.1210251419260.3623@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <5088C51D.3060009@gmail.com> <alpine.LNX.2.00.1210242338030.2688@eggly.anvils> <508912B0.7080805@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Oct 2012, Ni zhan Chen wrote:
> On 10/25/2012 02:59 PM, Hugh Dickins wrote:
> > On Thu, 25 Oct 2012, Ni zhan Chen wrote:
> > > 
> > > I think it maybe caused by your commit [d189922862e03ce: shmem: fix
> > > negative
> > > rss in memcg memory.stat], one question:
> > Well, yes, I added the VM_BUG_ON in that commit.
> > 
> > > if function shmem_confirm_swap confirm the entry has already brought back
> > > from swap by a racing thread,
> > The reverse: true confirms that the swap entry has not been brought back
> > from swap by a racing thread; false indicates that there has been a race.
> > 
> > > then why call shmem_add_to_page_cache to add
> > > page from swapcache to pagecache again?
> > Adding it to pagecache again, after such a race, would set error to
> > -EEXIST (originating from radix_tree_insert); but we don't do that,
> > we add it to pagecache when it has not already been added.
> > 
> > Or that's the intention: but Dave seems to have found an unexpected
> > exception, despite us holding the page lock across all this.
> > 
> > (But if it weren't for the memcg and replace_page issues, I'd much
> > prefer to let shmem_add_to_page_cache discover the race as before.)
> > 
> > Hugh
> 
> Hi Hugh
> 
> Thanks for your response. You mean the -EEXIST originating from
> radix_tree_insert, in radix_tree_insert:
> if (slot != NULL)
>     return -EEXIST;
> But why slot should be NULL? if no race, the pagecache related radix tree
> entry should be RADIX_TREE_EXCEPTIONAL_ENTRY+swap_entry_t.val, where I miss?

I was describing what would happen in a case that should not exist,
that you had thought the common case.  In actuality, the entry should
not be NULL, it should be as you say there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
