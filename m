Date: Sun, 25 Jun 2000 00:51:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: 2.4 / 2.5 VM plans
Message-ID: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

since I've heard some rumours of you folks having come
up with nice VM ideas at USENIX and since I've been
working on various VM things (and experimental 2.5 things)
for the last months, maybe it's a good idea to see which
of your ideas have already been put into code and to see
which ideas fit together or are mutually exclusive.  :)

To start the discussion, here's my flameba^Wlist of ideas:

2.4:

1) re-introduce page aging, my small and simple experiments
   seem to indicate that page aging takes *less* cpu time
   than copying pages to/from highmem all the time (let alone
   making your applications wait for disk because we replaced
   the wrong page last time)

2) fix the latency problems of applications calling shrink_mmap
   and flushing infinite amounts of pages  (mostly fixed)

3) separate page replacement (page aging) and page flushing,
   currently we'll happily free a referenced clean page just
   because the unreferenced pages haven't been flushed to disk
   yet ...   this is very bad since the unreferenced pages often
   turn out to be things like executable code

   we could achieve this by augmenting the current MM subsystem
   with an inactive and scavenge list, in the process splitting
   shrink_mmap() into three better readable functions ... I have
   this mostly done

4) fix balance_dirty() to include inactive pages and have kflushd
   help kswapd by proactively flushing some of the inactive pages
   _before_ we run into trouble

5) implement some form of write throttling for VMAs so it'll be
   impossible for big mmap()s, etc, to competely fill memory
   with dirty pages

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
