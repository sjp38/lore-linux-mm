Message-Id: <l03130317b70908428b4b@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0104221826000.1685-100000@imladris.rielhome.conectiva>
References: <2ch6etcc6mvtt83g45gu5dta6ftp8kudoe@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 22 Apr 2001 23:26:37 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "James A.Sutherland" <jas88@cam.ac.uk>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> We've crossed wires here: I know that's how the suspension approach
>> works, I'm talking about the "working set" approach - which to me,
>> sounds more likely to give both processes 50Mb each, and spend the
>> next six weeks grinding the disks to powder!
>
>Indeed, in this case the working set approach won't work.

Going back to my description of my algorithm from a few days ago, it
selects *one* process at a time to penalise.  If processes are not
re-ordered and remain with the same-sized working set, it will ensure that
one of the large processes remains fully resident and runs to completion
(as I described).  Thus the period in which the disks get churned is quite
short.  When combined with suspension, the intensity of disk activity would
also be reduced.

Of course, if the working set of the swapped-out process decreases (as a
result of being swapped out and/or suspended), it will eventually come off
the penalised list and replace the resident one.  It is important to keep
the period over which the working set is calculated fairly long, to
minimise the frequency of oscillations resulting from this effect.  My
algorithm takes this into account as well, with the period being
approximately 5.5 minutes on 100Hz hardware.

If further processes come in, increasing the working set further beyond the
system limits, my algorithm selects another *single* process at a time to
add to the penalised list.  This ensures that at any time, the maximum
amount of physical memory is utilised by processes which are not subject to
suspension or thrashing.

Now, I suspect you guys have been thinking "hey, he's going to give
processes memory *proportionate* to their working sets, which doesn't
work!" - well, I realised early on it wasn't going to work that way.  :)

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
