Message-ID: <3D463852.E6F18815@india.hp.com>
Date: Tue, 30 Jul 2002 12:25:14 +0530
From: Anil Kumar Nanduri <anil@india.hp.com>
MIME-Version: 1.0
Subject: Re: Regarding Page Cache ,Buffer Cachein  disabling in LinuxKernel.
References: <Pine.OSF.4.10.10207301003300.3850-100000@moon.cdotd.ernet.in> <a05111b09b96bcf853061@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@chromatix.demon.co.uk>
Cc: Anil Kumar <anilk@cdotd.ernet.in>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anil,
    I suggest you to read some documents on 2.4 linux memory management
    http://home.earthlink.net/~jknapka/linux-mm/pagecache.html
    then read code of 2.4.

    Actually in 2.4 both the swap cache and page cache are unified with
    the concept of struct address_space,
    I mean Any physical page will be in active list (or) inactive clean list
    (or) inactive dirty list.

    If that page is mmaped one (i mean if it is for a file) then it will also
be
    in the inode list of that file (no swap for this page).

    If that page was identified to be swapped(!mmaped || !text || etc..)
    out then it will also be in the swapper_space inode queue until it
    is reclaimed by the system.

    Please remember it is the same page which is on two queues( not two copies)

    In your case As you will not be having any swap...
    all the mmaped files(if you have mounted partition with r/rw),
    text region of executables  will still behave as if they have swap.

    but for other pages which actually need swap like data segments
    will not be in swapper_space inode queue as the get_swap_page()
    function will fail to return an valid entry.

    Now tell me why do you want to disable page cache/ swap cache?

    May be i will suggest you one thing that might be of use to you is
    to have a compressed memory based swap
    ( I am thinking of implementing).

Please let me know if i am not clear enough.

Thanks,
-anil.


Jonathan Morton wrote:

> >  a) i allow page caching then there is going to be 2 copies of
> >   data in my system and i want to avoid it.
>
> If you're using memory, the pages will be evicted from the cache.  It
> is NOT a problem.
>
> --
> --------------------------------------------------------------
> from:     Jonathan "Chromatix" Morton
> mail:     chromi@chromatix.demon.co.uk
> website:  http://www.chromatix.uklinux.net/
> geekcode: GCS$/E dpu(!) s:- a21 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$
>            V? PS PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
> tagline:  The key to knowledge is not to rely on people to teach you it.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
