Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8C44A6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 11:21:30 -0400 (EDT)
Date: Thu, 3 Sep 2009 16:20:50 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: improving checksum cpu consumption in ksm
In-Reply-To: <4A9FB83F.2000605@redhat.com>
Message-ID: <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
References: <4A983C52.7000803@redhat.com> <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
 <4A9FB83F.2000605@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Izik Eidus wrote:
> 
> Hi,
> I just did small test of the new hash compare to the old
> 
> using the program below, i ran ksm (with nice -20)
> at time_to_sleep_in_millisecs = 1

Better 0?

> run = 1
> pages_to_scan = 9999

Okay, the bigger the better.

> 
> (The program is designing just to  pressure the hash calcs and tree walking
> (and not to share any page really)
> 
> then i checked how many full_scans have ksm reached (i just checked
> /sys/kernel/mm/ksm/full_scans)
> 
> And i got the following results:
> with the old jhash version ksm did 395 loops
> with the new jhash version ksm did 455 loops

The first few loops will be settling down, need to subtract those.

> we got here 15% improvment for this case where we have pages that are static
> but are not shareable...
> (And it will help in any case we got page we are not merging in the stable
> tree)
> 
> I think it is nice...

Yes, that's nice, thank you for looking into it.

But please do some more along these lines, if you've time?
Presumably the improvement from Jenkins lookup2 to lookup3
is therefore more than 15%, but we cannot tell how much.

I think you need to do a run with a null version of jhash2(),
one just returning 0 or 0xffffffff (the first would settle down
a little quicker because oldchecksum 0 will match the first time;
but there should be no difference once you cut out settling time).

And a run with an almost-null version of jhash2(), one which does
also read the whole page sequentially into cache, so we can see
how much is the processing and how much is the memory access.

And also, while you're about it, a run with cmp_and_merge_page()
stubbed out, so we can see how much is just the page table walking
(and deduce from that how much is the radix tree walking and memcmping).

Hmm, and a run to see how much is radix tree walking,
by stubbing out the memcmping.

Sorry... if you (or someone else following) have the time!

> 
> (I used  AMD Phenom(tm) II X3 720 Processor, but probably i didnt run the test
> enougth, i should rerun it again and see if the results are consistent)

Right, other processors will differ some(unknown)what, so we shouldn't
take the numbers you find too seriously.  But at this moment I've no
idea of what proportion of time is spent on what: it should be helpful
to see what dominates.

> 
>    p = (unsigned char *) malloc(1024 * 1024 * 100 + 4096);
>    if (!p) {
>        printf("error\n");
>    }
> 
>    p_end = p + 1024 * 1024 * 100;
>    p = (unsigned char *)((unsigned long)p & ~4095);

Doesn't matter to your results, so long as it didn't crash;
but I think you meant to say

     p = (unsigned char *)(((unsigned long)p + 4095) & ~4095);
     p_end = p + 1024 * 1024 * 100;

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
