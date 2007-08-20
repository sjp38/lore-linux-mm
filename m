Date: Mon, 20 Aug 2007 16:19:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 7/7] Switch of PF_MEMALLOC during writeout
In-Reply-To: <p73ps1hztwp.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708201618060.32662@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <20070820215317.441134723@sgi.com>
 <p73ps1hztwp.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Aug 2007, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
> 
> > Switch off PF_MEMALLOC during both direct and kswapd reclaim.
> > 
> > This works because we are not holding any locks at that point because
> > reclaim is essentially complete. The write occurs when the memory on
> > the zones is at the high water mark so it is unlikely that writeout
> > will get into trouble. If so then reclaim can be called recursively to
> > reclaim more pages.
> 
> What would stop multiple recursions in extreme low memory cases? Seems 
> risky to me and risking stack overflow.  Perhaps define another flag to catch that?

Right. I am not sure exactly how to handle that. There is also the issue 
of the writes being deferred. I thought maybe of using pdflush to writeout 
the pages? Maybe increase priority of the pdflush so that it runs 
immediately when notified. Shrink_page_list would gather the dirty pages 
in pvecs and then forward to a pdflush. That may make the whole thing much 
cleaner.

Opinions?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
