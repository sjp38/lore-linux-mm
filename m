Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7CF66B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 04:09:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q16-v6so14911187pls.15
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 01:09:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203-v6si38917597pfa.60.2018.06.01.01.09.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 01:09:11 -0700 (PDT)
Subject: Re: KVM OS update induced thrashing
References: <1527674684.5297.90.camel@gmx.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4505a137-b4e1-4c2a-67d0-3d526fac0503@suse.cz>
Date: Fri, 1 Jun 2018 10:09:08 +0200
MIME-Version: 1.0
In-Reply-To: <1527674684.5297.90.camel@gmx.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>, linux-mm <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Ivan Kalvachev <ikalvachev@gmail.com>

On 05/30/2018 12:04 PM, Mike Galbraith wrote:
> Greetings mm wizards,
> 
> Yesterday, while running master-rc7, I started updating one of my VM
> images from openSUSE Leap 42.3 -> Leap 15, figuring that could chug
> along while I do some work.  That turned out to be a bad idea, box
> thrashed so badly it became unusable, which seems worthy of mention.
> 
> Box is a garden variety i4790 box with 16G ram, half of which was
> donated to the VM.  The VM image is 64GB, it's an OS plus all critical
> data mirror of my box (that fits on a USB stick).   All was well until
> qemu RSS grew to the full 8G, at which time mm land went mad, swapping
> and thrashing horribly while 7G of ram remained free, see vmstat
> snippet below.

Could it be the same issue that Hugh [1] and Ivan [2] were patching
recently?

Vlastimil

[1] https://marc.info/?l=linux-mm&m=152773700811689&w=2
[2] https://marc.info/?l=linux-mm&m=152779529010674

> It's NOT fully repeatable.  I repeated the update using a 4.14 kernel,
> which behaved fine.  Switching to 4.16, box thrashed, but not as badly
> as master had, nor did it keep as much ram free while doing so (~3G).

If there's still a problem with 4.16 then perhaps not, or there's also
another issue in addition to the 4.17 one...

> Going back to master, mm land remained calm, I could use the box to do
> merges and whatnot (albeit being careful to take it easy on spinning
> rust) just fine while the VM did it's thing.  Phase-of-moon behavior.
> 
> This master vmstat snippet is with only the VM and a mostly idle GUI,
> as trying to do anything resembling work was a waste of time.



> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
>  1  1 1740288 6896088   6828 128340   21   29   350   367  122  103  7  2 83  8  0
>  0  2 1740032 6902320   6828 128636   80    0  1392 18332 2429 8460  8  1 84  7  0
>  1  0 1740032 6898392   6828 128628   28    0   748  1640 2714 5838  6  2 87  6  0
>  1  0 1739776 6897864   6828 128668  164    0  1920    76 2558 7639  3  1 90  6  0
>  1  0 1739776 6895372   6828 129156  116    0  1896    60 2104 6456  3  1 91  5  0
>  0  0 1739776 6895116   6836 129192  196    0   700   168 2945 6677  7  1 89  4  0
>  0  1 1739776 6901092   6844 129292   40    0  1280  1572 3687 9739  5  3 86  6  0
>  1  0 1739776 6898884   6844 128236   12   64   276  1872 4596 18786  8  3 86  3  0
>  0  2 1747200 6910216   6760 127608    8 7380   288  7748 6725 38107  9  4 84  3  0
>  0  0 1756932 6918516   6724 126016    4 10064   172 10420 4711 10038  6  2 88  3  0
>  0  0 1773824 6936980   5728 125060   16 16836   420 17476 8741 9351  7  3 87  3  0
>  3  0 1782060 6943292   5692 128860  152 8252  2116  8536 4025 7673  5  2 88  6  0
>  1  0 1787452 6952868   5676 124644   56 5940   832  7672 3643 8052  6  2 88  5  0
>  0  0 1796428 6964452   5552 122140    0 8956   252  9124 5157 10080  5  3 91  1  0
>  0  1 1798476 6965416   5540 122844   20 1996   436  4436 3824 8384  5  3 91  1  0
>  2  0 1798476 6960840   5548 122828   16    0   212  4508 3559 9714  6  3 88  3  0
>  1  0 1798476 6960744   5556 122844    0    0     0  2408 4049 9925  7  3 89  1  0
>  0  0 1798476 6964672   5556 122932    0    0   164   620 4447 10341  4  4 91  1  0
>  0  1 1818228 6981740   5244 125548    8 19624   200 24472 10605 10163  6  4 86  5  0
>  1  1 1826304 6990164   4716 123008    4 8132  2156 10976 8670 14551  3  3 86  8  0
>  0  0 1829252 6992928   4544 121448    0 2992  1536  5508 4952 14444  3  4 86  7  0
> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
>  3  0 1829252 6999360   4544 121448    0    0     0     0 3997 9792  3  4 92  0  0
>  0  0 1829252 6999092   4552 121568    0    0   192   172 3806 9246  4  4 91  0  0
>  1  0 1829252 6996960   4552 121576    0    0     0     0 4103 9302  4  4 92  0  0
>  2  0 1829252 6998984   4556 116736    0   40     4   212 4696 10466  3  5 91  1  0
>  1  0 1829252 6998404   4564 116904  184    0   312    36 4130 10487  3  3 93  1  0
>  0  0 1828228 7003720   4564 116992 1344    0  2736  6312 5595 17908  3  3 86  8  0
>  1  0 1828228 6998980   4572 117596    0    0   184    28 4347 10927  4  4 92  1  0
>  0  1 1827716 7000768   4572 117612  892    0  1484 18276 3538 9155  4  2 86  9  0
>  0  1 1826692 6992004   4572 119228 2404    0  3404 13100 3532 10196  7  1 80 12  0
>  1  0 1825156 6996056   4572 119540 1804    0  1876 15272 4086 13877  6  2 79 13  0
>  1  1 1823364 6994116   4580 119752 1812    0  2004  1840 3567 9753  6  2 79 14  0
>  0  2 1821828 6990780   4588 119816 1248    0  1648 48244 2728 7815  4  1 87  8  0
>  0  1 1818500 6984708   4588 120392 4020    0  4252     0 3833 9440  5  1 84 10  0
>  1  1 1816708 6987868   4588 120972 2604    0  2760 44032 2909 7877  5  1 86  8  0
>  0  1 1813892 6980520   4588 121300 2884    0  2948 38200 2803 7501  4  1 86  9  0
>  0  1 1811588 6982916   4596 121320 2132    0  2332 22492 2572 7048  8  1 84  6  0
>  0  3 1809284 6976112   4596 121480 2556    0  3004 16036 2820 7733  6  1 82 12  0
>  0  1 1806980 6968892   4596 122200 2904    0  3068 18384 4003 12307  4  2 81 13  0
>  0  1 1805188 6973156   4604 122428 2068    0 20068    12 2587 5901  1  1 87 11  0
>  1  2 1802116 6964912   4604 123264 4144    0 15640    72 3851 8710  2  1 82 14  0
>  1  0 1801092 6961472   4612 123680 1056    0  1720   328 3279 6709  6  1 86  6  0
> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
>  1  0 1801092 6964964   4612 124068    0    0   712  1100 3987 9326  6  3 89  2  0
>  0  1 1801092 6962704   4612 124152  100    0  2116  1684 3718 10004  3  2 91  4  0
>  0  1 1801092 6961856   4612 124776  684    0  2576  5868 2439 6601  5  1 87  7  0
>  2  0 1801092 6963972   4620 125092   16    0   728  1816 2385 7271  2  2 88  8  0
>  0  0 1801092 6961656   4620 125048    0    0     0     0 3932 10045  4  3 93  0  0
>  2  0 1801092 6963992   4628 125048    0    0   384  6220 4780 12670  4  4 90  2  0
>  0  0 1801092 6963608   4628 125052    0    0    48     0 4342 10433  4  4 92  0  0
>  0  0 1801092 6963588   4628 125164    0    0    64     0 4347 11279  4  4 92  0  0
>  0  1 1800836 6961732   4636 125168  160    0   724  9632 3832 9534  4  4 89  3  0
>  1  0 1800324 6959144   4636 125356  480    0  2928   492 2661 6953  3  1 89  7  0
>  0  2 1796996 6957780   4644 125436 3496    0  4140 19848 2998 9266  6  2 84  8  0
>  0  1 1796228 6962888   4644 125484  668    0  1180  5020 3280 10379  6  2 81 12  0
>  0  1 1795972 6958552   4644 125668  444    0  1208 13716 3183 12078  2  2 88  8  0
>  1  1 1794948 6955404   4656 125808 1180    0  1312  5004 2966 11573  3  2 83 12  0
>  1  0 1794692 6958740   4656 126056  508    0  1324  4576 2738 6384  5  1 88  7  0
>  1  0 1794436 6953764   4664 126676  780    0  1952  1136 2625 5898  8  1 84  7  0
>  1  0 1794436 6955744   4664 126968   32    0   892  1320 3097 7727  7  2 88  4  0
>  0  0 1794436 6957320   4664 126968    4    0     4    16 3637 8272  5  3 92  0  0
>  2  0 1794436 6957408   4664 126972    0    0    84     0 3850 9745  4  4 92  0  0
>  1  0 1794436 6951244   4672 127064    8    0    80  4640 3333 9319  9  3 87  2  0
>  0  1 1794436 6956876   4672 127068   28    0  1452  1468 3919 9485  6  2 87  5  0
> 
