Date: Sat, 02 Aug 2008 09:16:28 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
In-Reply-To: <489314FE.7080900@linux-foundation.org>
References: <20080801180522.EC97.E1E9C6FF@jp.fujitsu.com> <489314FE.7080900@linux-foundation.org>
Message-Id: <20080802090335.D6C8.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Yasunori Goto wrote:
> 
> > I thought it at first, but are there the following worst case?
> > 
> > 
> >    CPU 0                                    CPU 1
> > -------------------------------------------------------
> > __alloc_pages()
> >     
> >     parsing_zonelist()
> >         :
> >     enter page_reclarim()
> >     sleep (and remember zone)                 :
> >                                               :
> >                                         update zonelist and node_online_map
> >                                           with stop_machine_run()
> >                                         free pgdat().
> >                                         remove the Node electrically.
> > 
> >     wake up and touch remembered
> >        zone,  but it is removed
> >     (Oops!!!)
> > 
> > 
> > 
> > Anyway, I'm happy if there is better way than my poor idea. :-)
> > 
> > Thanks for your comment.
> 
> Duh. Then the use of RCU would also mean that all of reclaim must
>  be in a rcu period. So  reclaim cannot sleep anymore.

I use srcu_read_lock() (sleepable rcu lock) if kernel must be sleep for
page reclaim. So, my patch basic idea is followings.


   CPU 0                                    CPU 1
-------------------------------------------------------
__alloc_pages()
     
    rcu_read_lock() and check 
      online bitmap
        parsing_zonelist()
    rcu_read_unlock()
        :
    enter page_reclarim()
    srcu_read_lock()
      parse zone/zonelist.
      sleep (and remember zone)                 :
                                               :
                                        update zonelist and node_online_map
                                          with stop_machine_run()

    wake up and touch remembered zone,  
   srcu_read_unlock()
                                        syncronized_sched().
                                        free_pgdat()


Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
