Date: Tue, 31 Oct 2000 16:17:53 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: kmalloc() allocation.
Message-ID: <20001031161753.F7204@nightmaster.csn.tu-chemnitz.de>
References: <20001031114851.D7204@nightmaster.csn.tu-chemnitz.de> <Pine.LNX.4.21.0010311134590.23139-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010311134590.23139-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, Oct 31, 2000 at 11:35:46AM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Richard B. Johnson" <root@chaos.analogic.com>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 31, 2000 at 11:35:46AM -0200, Rik van Riel wrote:
> > Rik: What do you think about this (physical cont. area cache) for 2.5?
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^ == PCAC
> 
> http://www.surriel.com/zone-alloc.html

Read it when you published it first, but didn't notice you still
worked on it ;-)

My approach is still different. We get the HINT for free. And
your zone only shift this problem from page to mem_zone level.

I thought about sth. like this:

/* Adds an physical continuous area of pages to the PCAC.
 * To be implemented later, once we decide on a data structure
 * for this, which can do fast unique insert and at least O(N)
 * retrieve. (Hashes?)
 */
void add_phys_cont_chunk(struct phys_page *start, size_t area_size);

/* Add page(s) to pool, where we prefer to kmalloc() small things
 * and vmalloc() things. This gets us close to a best fit
 * strategy instead of sth. like the first fit we have now.
 */
void add_small_phys_area(struct phys_page *start, size_t area_size);

/* Gets a chunk of at least area_size pages and removes it from
 * the PCAC or NULL of none found.
 *
 * To be implemented later along with the above routine.
 */
struct phys_page *get_phys_cont_chunk(size_t area_size);

#define suitable(p) (moveable(p) || freeable(p)) /* refine this */
#define MIN_PHYS_CHUNK 2 /* tune this */

/* in physical page scan to transfer REFERENCED bit */

   size_t area_size = 0;
   struct phys_page *p, *chunk_start;

   p = prev = first_phys_page;

   while (p != last_phys_page) {
      if (area_size) {
         if (suitable(p)) { 
         
            /* expand recent chunk */
            area_size++;

         } else {
         
            /* insert last chunk */
            if (area_size >= MIN_PHYS_CHUNK) 
               add_phys_cont_chunk(chunk_start, area_size);
            else add_small_phys_area(chunk_start, area_size);
            area_size = 0;
         }
      } else {
         if (suitable(p)) {

            /* start new chunk */
            area_size = 1;
            chunk_start = p;
         }
      }
      p = p->next;
   }

And later, when we need a physically continuous area >= MIN_PHYS_CHUNK:

   /* lookup PCAC for a hint */
   struct phys_page *s = get_phys_cont_chunk(area_size);
   
   if (s) {
      size_t a = area_size;
      struct phys_page *p = s;
      
      /* lock down page tables */
      while (a--) {
         if ( ! free_or_move_page(p) )
            break;
         p = p->next;
      }
      /* unlock page tables*/
      if (!a) 
         return s; /* hey, it worked! */

   } else {
      /* no hints, try it the old way or fail */
   }


Hope it sound not too stupid ;-)

Regards 

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
