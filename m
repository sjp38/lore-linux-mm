Message-Id: <l03130326b745e267d7e8@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106072117480.1156-100000@freak.distro.conectiva>
References: <l03130325b745dbca4a2f@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 8 Jun 2001 03:08:00 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 1:19 am +0100 8/6/2001, Marcelo Tosatti wrote:
>+               if ((gfp_mask & (__GFP_WAIT | __GFP_IO)) == (__GFP_WAIT |
>__GFP_IO)) {
>+                       int progress = try_to_free_pages(gfp_mask);
>+                       if(!progress) {
>+                               wakeup_kswapd(1);
>+                               goto try_again;
>+                       }
>
>You're going to allow GFP_BUFFER allocations to eat from the reserved
>queues. Eek.

Hang on, I did optimise that part - let me check it against your
original...  but hey, it's the same behaviour!

                if (gfp_mask & __GFP_WAIT) {
                       int progress;
                       if (gfp_mask & __GFP_IO) {
                                progress = try_to_free_pages(gfp_mask);
                                if (!progress) {
                                        /*
                                         * Not able to make progress freeing
                                         * pages: wait for kswapd to free
                                         * pages if possible.
                                         */
                                        if (gfp_mask & __GFP_IO) {
                                                wakeup_kswapd(1);
                                                goto try_again;
                                        }
                                }
                        }
                }

Can you point out why the behaviour of your code is *any* different from
mine?  Or have you just found a bug in your own code?  :)

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
