Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7BF926B004F
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 12:25:10 -0400 (EDT)
Message-ID: <4AABCD54.8080208@redhat.com>
Date: Sat, 12 Sep 2009 19:33:24 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: improving checksum cpu consumption in ksm
References: <4A983C52.7000803@redhat.com> <Pine.LNX.4.64.0908312233340.23516@sister.anvils> <4A9FB83F.2000605@redhat.com> <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, moussa ba <musaba@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 3 Sep 2009, Izik Eidus wrote:
>   
>
>
> Yes, that's nice, thank you for looking into it.
>
> But please do some more along these lines, if you've time?
> Presumably the improvement from Jenkins lookup2 to lookup3
> is therefore more than 15%, but we cannot tell how much.
>
> I think you need to do a run with a null version of jhash2(),
> one just returning 0 or 0xffffffff (the first would settle down
> a little quicker because oldchecksum 0 will match the first time;
> but there should be no difference once you cut out settling time).
>
> And a run with an almost-null version of jhash2(), one which does
> also read the whole page sequentially into cache, so we can see
> how much is the processing and how much is the memory access.
>
> And also, while you're about it, a run with cmp_and_merge_page()
> stubbed out, so we can see how much is just the page table walking
> (and deduce from that how much is the radix tree walking and memcmping).
>
> Hmm, and a run to see how much is radix tree walking,
> by stubbing out the memcmping.
>
> Sorry... if you (or someone else following) have the time!
>
>   
Ok so with exactly the same program as before (just now sleep() time 
went from 60 to 120)
and:

ksm nice = -20

echo 1 > /sys/kernel/mm/ksm/sleep_millisecs
echo 1 > /sys/kernel/mm/ksm/run
echo 0 > /sys/kernel/mm/ksm/max_kernel_pages
echo 99999 > /sys/kernel/mm/ksm/pages_to_scan
(I forgot to put sleep_millisecs into 0, but I think the results will 
still give good image)

Results:
Normal ksmd as found on mmtom:
1nd run: 789 full scans
2nd run: 751 full scans
3nd run: 790 full scans

no hash version (jhash2 just retun 0xffffffff):
1nd run: 1873
2nd run: 1888
3nd run: 1874

no hash but read all the memory version: (checking memory access)
1nd run: 1364
2nd run: 1363
3nd run: 1251

checksum version - just increase u64 varible by the content of each 
64bits of a page :
something like:
ret = 0;
for(; p != p_end; ++p)
    ret += *p
1nd run: 1362
2nd run: 1250
3nd run: 1250

no cmp_and_merge_page() version:
1nd run: 10,000
2nd run: 10,000
3nd run: 15,017
(At this point I figured it is probably just take time to do the 
sleeping and therefore i tried it with sleep_millisecs = 0 and got:)
4nd run: 29,987
5nd run: 45,012 (didnt really look what happen in the kernel when 
sleep_millisecs = 0, but this results seems to be irrelevant because it 
seems like we are not burning cpus here)

memcmp_pages() return 1 version (without jhash):
(This version should really pressure the unstable tree walking - it will 
build tree of  256,000 pages (the application allocate 100mb)
meaning the depth will be 15, and each time it will check page it will 
walk over all this 15 depth levels in the unstable tree (because return 
of memcmp_pages() will always be 1 so it will keep going right)

1nd run: 1763
2nd run: 1765
3nd run: 1732



Looking on all this results I tend to think that the winner here is 
dirty bit from performance perspective, but because we dont want to deal 
with the problems of dirty bit tracking right now (specially that 
unstable dirty bit),
we probably need to look on how much the jhash cost us, Looking on the 
memory access times compare to jhash times, It does look like jhash is 
expensive,
because we just need to track pages that are not changing, I guess we 
can use some kind of checksum that is much less cpu intensive than jhash...?

(Btw, starting with merging the new jhash would be good idea as well...)

Thanks, and btw did i lose any test that you want might want?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
