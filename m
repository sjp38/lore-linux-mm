Date: Tue, 18 Mar 2003 13:40:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.65-mm1
Message-ID: <20030318214013.GA1240@holomorphy.com>
References: <20030318031104.13fb34cc.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030318031104.13fb34cc.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 18, 2003 at 03:11:04AM -0800, Andrew Morton wrote:
> . An updated version of Russell's PCMCIA patches
> . Lots more anticipatory scheduler work.
> . It turns out that calling disk request_fns from timer/tasklet context is
>   not permitted because a few old drivers like to sleep in that function. 
>   keventd cannot be used for this because it can deadlock.  So another
>   kernel thread per CPU has been reluctantly added.

So far so good. There are couple of non-critical things I noticed.
On my home machine, 600MHz Athlon w/768MB RAM, Adaptec 39160 + U160 disk

         pte_chain:     4644KB     4661KB   99.64
      dentry_cache:      987KB     1275KB   77.47
   radix_tree_node:      988KB     1233KB   80.14
reiser_inode_cache:      755KB     1181KB   63.93
biovec-BIO_MAX_PAGES:    768KB      780KB   98.46
         size-4096:      624KB      624KB   100.0 
       inode_cache:      457KB      457KB   100.0 
               pgd:      432KB      432KB   100.0 


shpte really blew the doors off of pte_chains for my home box and
slightly more than halved pagetable space. It really helps keep things
from swapping, a good 4-6 MB of pte_chain + pagetable space. I wish for
it back relatively often.

OTOH objrmap appears to have blown page_*_rmap() functions off the
profiles on the execution time front.

Window wiggle test times (ms):

  inter-arrival    service     response
  -------------    -------     --------
     113.828        0.093        4.702
     113.828        0.093        4.702
     113.828        0.093        4.702
     113.828        0.093        4.702
     113.828        0.093        4.702
      56.762        0.090        4.593
      56.762        0.090        4.593
      56.762        0.090        4.593
      56.762        0.090        4.593
      56.762        0.090        4.593
     106.250        0.088        4.545
      51.944        0.135        6.133
      34.006        0.172        7.345
      27.087        0.194        7.276
      26.807        0.120        6.549
      27.975        0.128        6.721
      31.292        0.161        7.278
      32.952        0.147        6.692
      32.952        0.147        6.692
      32.952        0.147        6.692
      32.952        0.147        6.692
      32.952        0.147        6.692

This is really the only visible task scheduling pathology. The user
observable effect is that now transparent xterms "flash" when being
wiggled, where before they merely showed some refresh jitter. But it's
a vast net improvement; good work on mingo's part.

I've not been noticing the more refined aspects of io scheduling.
Basically once deadline-iosched hit, my home machine was very happy,
and the gains after mostly slight. There's some of app startup time
that appears to have been trimmed down that may have come from this.
I noticed it while booting but by and large I don't spawn new large
tasks regularly, so it sort of doesn't do as much for me as others.
It could also be due to the prefaulting or a combined effect.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
