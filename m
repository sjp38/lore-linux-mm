Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CFFDA6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 11:54:47 -0400 (EDT)
Received: by gwb15 with SMTP id 15so2207732gwb.14
        for <linux-mm@kvack.org>; Sun, 18 Apr 2010 08:54:45 -0700 (PDT)
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1004161105120.7710@router.home>
References: 
	 <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <4BC65237.5080408@kernel.org>
	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
	 <4BC6BE78.1030503@kernel.org>
	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
	 <4BC6CB30.7030308@kernel.org>
	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
	 <alpine.DEB.2.00.1004161105120.7710@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Apr 2010 00:54:39 +0900
Message-ID: <1271606079.2100.159.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Christoph. 

On Fri, 2010-04-16 at 11:07 -0500, Christoph Lameter wrote:
> On Thu, 15 Apr 2010, Minchan Kim wrote:
> 
> > I don't want to remove alloc_pages for UMA system.
> 
> alloc_pages is the same as alloc_pages_any_node so why have it?

I don't want to force using '_node' postfix on UMA users.
Maybe they don't care getting page from any node and event don't need to
know about _NODE_. 

> 
> > #define alloc_pages alloc_page_sexact_node
> >
> > What I want to remove is just alloc_pages_node. :)
> 
> Why remove it? If you want to get rid of -1 handling then check all the

alloc_pages_node have multiple meaning as you said. So some of users
misuses that API. I want to clear intention of user.

> callsites and make sure that they are not using  -1.

Sure. I must do it before any progressing. 

> 
> Also could you define a constant for -1? -1 may have various meanings. One
> is the local node and the other is any node. The difference is if memory
> policies are obeyed or not. Note that alloc_pages follows memory policies
> whereas alloc_pages_node does not.
> 
> Therefore
> 
> alloc_pages() != alloc_pages_node(  , -1)
> 

Yes, now it's totally different. 
On UMA, It's any node but on NUMA, local node.

My concern is following as. 

alloc_pages_node means any node but it has nid argument. 
Why should user of alloc_pages who want to get page from any node pass
nid argument? It's rather awkward. 

Some of user misunderstood it and used alloc_pages_node instead of
alloc_pages_exact_node although he already know exact _NID_. 
Of course, it's not a BUG since if nid >= 0 it works well.

But I want to remove such multiple meaning to clear intention of user. 



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
