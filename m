Date: Thu, 20 Apr 2000 17:13:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [rtf] [patch] 2.3.99-pre6-3 overly swappy
In-Reply-To: <Pine.LNX.4.21.0004201538200.8445-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.21.0004201658110.5864-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2000, Ben LaHaise wrote:

> The balance between swap and shrink_mmap was upset by the recent per-zone
> changes: kswapd wakeups now call swap_out 3 times as much as before,
> resulting in increased page faults and swap out activity, especially
> under heavy io.  This patch seems to help quite a bit -- can other people
> give this a try?

[snip]

> @@ -507,7 +509,7 @@
>  					schedule();
>  				if ((!zone->size) || (!zone->zone_wake_kswapd))
>  					continue;
> -				do_try_to_free_pages(GFP_KSWAPD, zone);
> +				do_try_to_free_pages(GFP_KSWAPD, zone, i == (MAX_NR_ZONES - 1));
>  			}
>  			pgdat = pgdat->node_next;
>  		}

This seems to mostly work for machines where each bigger zone
is a subset of the smaller zones. I don't think this scheme
would be suitable for eg. ccNUMA machines, but it may be a nice
bandaid for x86...

(I'll get to work on a more generic strategy ASAP, it'll be
very much like what I talked about on irc with Stephen and you)

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
