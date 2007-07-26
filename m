Date: Thu, 26 Jul 2007 15:25:50 +0100
Subject: Re: bind_zonelist() - are we definitely sizing this correctly?
Message-ID: <20070726142550.GA14891@skynet.ie>
References: <20070726141756.GB18825@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070726141756.GB18825@skynet.ie>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, Christoph Lameter <clameter@sgi.com>, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (26/07/07 15:17), Mel Gorman didst pronounce:
> I was looking closer at bind_zonelist() and it has the following snippet
> 
>         struct zonelist *zl;
>         int num, max, nd;
>         enum zone_type k;
> 
>         max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
>         max++;                  /* space for zlcache_ptr (see mmzone.h) */
>         zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
>         if (!zl)
>                 return ERR_PTR(-ENOMEM);
> 
> That set off alarm bells because we are allocating based on the size of a
> zone, not the size of the zonelist.
> 

Never mind me, I'm a tool as it's now semi-obvious. When statically defined,
zlcache_ptr is pointing to something useful as it's setup at boottime. When
dynamically allocated in bind_zonelist, the zlcache_ptr is set to NULL so
it never gets used by zlc_setup().

This could have done with a comment.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
