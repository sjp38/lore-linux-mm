Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA02003
	for <linux-mm@kvack.org>; Sat, 28 Dec 2002 15:28:23 -0800 (PST)
Message-ID: <3E0E3394.489C7BD6@digeo.com>
Date: Sat, 28 Dec 2002 15:28:20 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shared pagetable benchmarking
References: <3E0D4B83.FEE220B8@digeo.com> <Pine.LNX.4.44.0212272338040.4568-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> > ...
> The mmap() case should
> _not_ use that system call path at all, but should instead just call the
> populate function directly. Something like the appended patch.

Seems to do the right thing, but alas, it's slower:

without:
pushpatch 99  8.20s user 10.00s system 99% cpu 18.341 total
poppatch 99  5.76s user 6.65s system 99% cpu 12.521 total
c0114c64 kmap_atomic_to_page                          84   0.9438
c01308ec handle_mm_fault                              92   0.4340
c01c4b58 __copy_from_user                             94   0.8393
c012f330 clear_page_tables                           113   0.5650
c01305b0 do_anonymous_page                           123   0.3844
c011a9c0 do_softirq                                  145   0.8239
c0113d9c pte_alloc_one                               146   1.1406
c012f534 copy_page_range                             174   0.3595
c01c4af0 __copy_to_user                              188   1.8077
c01306f0 do_no_page                                  241   0.4744
c012f718 zap_pte_range                               265   0.6370
c0113ec0 do_page_fault                               321   0.2956
c0133a8c page_add_rmap                               322   1.1838
c0114be4 kmap_atomic                                 326   3.0185
c0133b9c page_remove_rmap                            360   0.9574
c012ff54 do_wp_page                                 1245   1.9095
00000000 total                                      6812   0.0042

(374019 pagefaults)

with:
pushpatch 99  8.16s user 11.76s system 99% cpu 20.072 total
poppatch 99  5.68s user 7.93s system 99% cpu 13.656 total
c012f330 clear_page_tables                           111   0.5550
c0114c64 kmap_atomic_to_page                         121   1.3596
c0113d9c pte_alloc_one                               140   1.0938
c011a9c0 do_softirq                                  150   0.8523
c01305b0 do_anonymous_page                           157   0.4906
c01c4af0 __copy_to_user                              157   1.5096
c012e590 install_page                                202   0.6012
c0113ec0 do_page_fault                               209   0.1924
c012f534 copy_page_range                             215   0.4442
c01306f0 do_no_page                                  224   0.4409
c0114be4 kmap_atomic                                 392   3.6296
c012f718 zap_pte_range                               417   1.0024
c0133a8c page_add_rmap                               563   2.0699
c0133b9c page_remove_rmap                            653   1.7367
c012ff54 do_wp_page                                 1318   2.0215
00000000 total                                      8072   0.0050

(240622 pagefaults)

That's uniprocessor, highpte.  Presumably there are lots of cached
libc pages which these scripts don't actually need.

It needs more analysis/instrumentation/work, but it's not promising.

Cache misses against the pte_chains is what is hurting here. Something
which may help on P4 is to keep the pte_chains at 32 bytes, so that
virtually-adjacent pages' pte_chains will probably share cachelines.  I
have a pseudo-4way HT box sitting here awaiting commissioning...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
