Date: Tue, 16 May 2000 20:46:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Best way to extend try_to_free_pages()?
In-Reply-To: <20000517005828.A3028@storm.local>
Message-ID: <Pine.LNX.4.21.0005162041530.32026-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Bombe <andreas.bombe@munich.netsurf.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
