Date: Wed, 8 Sep 2004 16:30:36 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <20040908193036.GH4284@logos.cnet>
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <20040907212051.GC3492@logos.cnet> <413F1518.7050608@sgi.com> <20040908165412.GB4284@logos.cnet> <413F5EE7.6050705@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <413F5EE7.6050705@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2004 at 02:35:03PM -0500, Ray Bryant wrote:
> 
> 
> Marcelo Tosatti wrote:
> 
> >
> >
> >Huh, that changes the meaning of the dirty limits. Dont think its suitable
> >for mainline.
> >
> >
> 
> The change is, in fact, not much different from what is already actually 
> there.  The code in get_dirty_limits() adjusts the value of the user 
> supplied parameters in /proc/sys/vm depending on how much mapped memory 
> there is.  If you undo the convoluted arithmetic that is in there, one 
> finds that if you are using the default dirty_ratio of 40%, then if the 
> unmapped_ratio is between 80% and 10%, then
> 
>    dirty_ratio = unmapped_ratio / 2;
> 
> and, a little bit of algebra later:
> 
>    dirty = (total_pages - wbs->nr_mapped)/2
> 
> and
> 
>    background = dirty_background_ratio/vm_background_ratio * (total_pages
> 	- wbs->nr_mapped)
> 
> That is, for a wide range of memory usage, you are really running with an
> dirty ratio of 50% stated in terms of the number of unmapped pages, and 
> there is no direct way to override this.

OK I see, yes. 

> Of course, at the edges, the code changes these calculations.  It just 
> seems to me that rather than continue the convoluted calculation that is in
> get_dirty_limits(), we just make the outcome more explicit and tell the user
> what is really going on.
> 
> We'd still have to figure out how to encourage a minimum page cache size of
> some kind, which is what I understand the 5% min value for dirty_ratio is 
> in there for.
 
For the user "dirty_ratio" and "dirty_background_ratio" means "percentage
of total memory" (thats how it has been traditionally in Linux). And right now,
 as you noted, we dont do that way.

There's probably a good reason for the "no more than half of unmapped memory".
Andrew ?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
