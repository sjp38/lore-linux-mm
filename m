From: frankeh@us.ibm.com
Message-ID: <852568E2.000A17E8.00@D51MTA03.pok.ibm.com>
Date: Tue, 16 May 2000 21:51:17 -0400
Subject: Re: Best way to extend try_to_free_pages()?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andreas Bombe <andreas.bombe@munich.netsurf.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is exactly what we would like to see.
In kernel memory caches, such as web server accelerators etc., can take
great advantage of this.

We have been building something similar for this purpose, but if you guys
are willing to put this in, all the better.

I assume everything could register as a first class citizen, including file
cache, etc.....
Some thoughts along the line.
Would it make sense to priorities such <kernel-memory-clients>.
Wouldn't it make sense to specify the number of pages as part of the
interface?
Do you assume fairness among memory clients based on the cyclic queue if
priorities is not desirable.
One can think of the cost of dropping a page in one subsystem to be higher
as in a different subsystem.

Anyway... I am all for it ....

-- Hubertus



Rik van Riel <riel@conectiva.com.br>@kvack.org on 05/16/2000 08:16:51 PM

Sent by:  owner-linux-mm@kvack.org


To:   Andreas Bombe <andreas.bombe@munich.netsurf.de>
cc:   linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Subject:  Re: Best way to extend try_to_free_pages()?



On Wed, 17 May 2000, Andreas Bombe wrote:

> (not possible, since 1394 code can be modularized)?  If not, I
> consider adding some generic code to register callbacks for low
> memory situations as soon as I need it.

A callback system from do_try_to_free_pages(), where anybody
can dynamically register their cache->drop_pages() function
would be nice.

Maybe a list of caches with function pointers?

spin_lock(&cachelist_lock);
for (cache = &cachelist.next ; cache->next != &cachelist  ;
                cache = cachelist->next) {
     count -= cache->drop_pages(priority);
     if (count <= 0)
          break;
}
spin_unlock(&cachelist_lock);


On module load time, init_module() could grab the cachelist_lock,
insert an entry in the list and next time try_to_free_pages() is
called our cache will be shrunk too.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/          http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
