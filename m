Message-ID: <39CB8B13.391C067D@asplinux.ru>
Date: Fri, 22 Sep 2000 20:38:43 +0400
From: Yuri Pudgorodsky <yur@asplinux.ru>
MIME-Version: 1.0
Subject: test9-pre3+t9p2-vmpatch VM deadlock during socket I/O
References: <Pine.LNX.4.21.0009221131110.12532-200000@debella.aszi.sztaki.hu> <Pine.LNX.4.21.0009220725590.4442-200000@duckman.distro.conectiva> <20000922151020.A653@post.netlink.se> <20000922161055.A1088@post.netlink.se>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Andr=E9?= Dahlqvist <andre_dahlqvist@post.netlink.se>
Cc: Rik van Riel <riel@conectiva.com.br>, Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I also encounter instant lockup of test9-pre3 + t9p2-vmpatch / SMP (two CPU).
under high I/O via UNIX domain sockets:

    - running 10 simple tasks doing
    #define BUFFERSIZE 204800
    for (j = 0; ; j++) {
                        if (socketpair(PF_LOCAL, SOCK_STREAM, 0, p) == -1) {
                                exit(1);
                        }
                        fcntl(p[0], F_SETFL, O_NONBLOCK);
                        fcntl(p[1], F_SETFL, O_NONBLOCK);
                        write(p[0], crap, BUFFERSIZE);
                        write(p[1], crap, BUFFERSIZE);
        }

So it looks like swap_out() cannot obtain lock_kernel()
holded by a swap_out() on a second CPU.... See below.

Call trace (looks very similar on both CPU):

Trace; c020aa3e <stext_lock+18a6/8848>
    (called from c0133eb4 <swap_out+0x28>)
Trace; c0133eb4 <swap_out+28/228>               args (6, 3, 0)
Trace; c0134e50 <refill_inactive+c8/170>        args (3, 1)
Trace; c0134f75 <do_try_to_free_pages+7d/9c>    args (3,1)
Trace; c0135168 <wakeup_kswapd+84/bc>
Trace; c0135d72 <__alloc_pages+1d6/264>
Trace; c0135e17 <__get_free_pages+17/28>
Trace; c01322ce <kmem_cache_grow+e2/264>
....

Under lockup, memory map looks like:

Active: 121 Inactive_dirty: 12217 Inactive_clean: 0 free: 12210 (256 512 768)

and does not change from time to time.

Most frequent EIP locations (from Sys-AltRq/P):

Trace; c0133f74 <swap_out+e8/228>
Trace; c0133f23 <swap_out+97/228>
Trace; c0134039 <swap_out+1ad/228>
Trace; c020aa37 <stext_lock+189f/8848>
Trace; c020aa3e <stext_lock+18a6/8848>


In a hope for a quick fix,
Yuri Pudgorodsky


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
