Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id jA76drRH028579
	for <linux-mm@kvack.org>; Sun, 6 Nov 2005 23:39:53 -0700
Subject: Re: Clock-Pro
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <1131056122.18825.173.camel@twins>
References: <1131056122.18825.173.camel@twins>
Content-Type: text/plain
Message-Id: <1131349185.4389.1122.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Mon, 07 Nov 2005 00:39:45 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The following is the table as well as some comments:

  Song

==================================== 

res | h/c | tst | ref || Hcold | Hhot | Htst || Flt
----+-----+-----+-----++-------+------+------++-----
 0  |  0  |  0    |  0   ||         |        |       || 1010
 0  |  0  |  1    |  0   ||  N/A   |X0000 |X0000 || 1100

 1  |  0  |  0    |  0   || X0000 |=1000 |=1000 ||
 1  |  0  |  0    |  1   || 1010  |=1001 |=1001 ||
 1  |  0  |  1    |  0   || X0010 | 1000 | 1000 ||
 1  |  0  |  1    |  1   || 1100  | 1001 | 1001 ||
 1  |  1  |  0    |  0   ||=1100  | 1000 |=1100 || 
 1  |  1  |  0    |  1   ||=1101  | 1100 |=1101 || 

Comments for each state line (res, h/c, tst, ref)

0000: a new state for blocks not in list;

0001: invalid state. If this type of page existed, Hcold must 
      have passed it because its residency has been changed 
      to 0 by Hcold. (Note that all pages that are placed at 
      the list head are resident.). Without its test == 1, 
      the page must have been removed from the LIST besides
      from memory by Hcold.

0010: As stated above, Hcold only sees resident pages. 
      So Hcold + 0010 is N/A. Flt + 0010 -> 1100 
      due to its test == 1.    

0011: invalid state because a non-resident page cannot 
      have its ref == 1.

1000: both Hhot and Htst do not replace pages, which is 
      the task of Tcold.

1001: Hcold + 1001 -> 1010 because a detection of ref == 1 
      means a new access, so test period should be restarted. 
      Hhot(Htst) + 1001 -> =1001 because for COLD pages 
      Hcold is supposed to behave like the clock hand in the 
      traditional CLOCK policy, which is responsible to 
      clear ref bits. Hhot and Htst just leave the ref bits 
      untouched.

1010: Hcold + 1010 -> X0010 because cold page without ref 
      should be replaced. The page remains in the list 
      because of its tst == 1. Hhot + 1010 -> 1000 
      because Hhot does the task on behalf of Htst.

1011: Hhot(Htst) + 1011 -> 1001 because both hands work as Htst.

1100: Hhot + 1100 -> 1000 because the demoted hot page 
      does not have a new access (its ref == 0). Test period 
      is for test reuse distance. Without an access, a new 
      reuse test should not be restarted.

1101: Hhot + 1101 -> =1100 because for HOT pages their ref 
      bits are used to keep their hot status. Once the ref 
      bits have served the purpose, Hhot should clear it.
      Htst + 1101 -> =1101 because Htst should only care 
      about tst bits and removing non-resient blocks out of list.



On Thu, 2005-11-03 at 15:15, Peter Zijlstra wrote:
> Hi Song Jiang,
> 
> 
> I implemented the things I talked about, they can be found here:
>   http://programming.kicks-ass.net/kernel-patches/clockpro/
> 
> However I have the strong feeling I messed up the approximation, hence I
> have tried to extract a state table for the original algorithm from the
> paper but I find some things not quite obvious. Could you help me
> complete this thing:
> 
> 
> res | h/c | tst | ref || Hcold | Hhot | Htst || Flt
> ----+-----+-----+-----++-------+------+------++-----
>  0  |  0  |  0  |  1  ||       |      |      || 1010
>  0  |  0  |  1  |  0  ||=0010  |  X   |  X   || 
>  0  |  0  |  1  |  1  ||       |      |      || 1100
>  1  |  0  |  0  |  0  ||  X    |  X   |=1000 ||
>  1  |  0  |  0  |  1  || 1000  | 100? | 100? ||
>  1  |  0  |  1  |  0  ||=1010  | 0010 | 1000 ||
>  1  |  0  |  1  |  1  || 1100  | 101? | 100? ||
>  1  |  1  |  0  |  0  ||=1100  | 10?0 |=1100 || 
>  1  |  1  |  0  |  1  || 110?  | 1100 | 110? || 
> 
> 
> res := resident
> h/c := hot/cold
> tst := test period
> ref := referenced
> 
> H* := resulting state after specified hand passed,
>       where prefix '=' designated no change and
>       'X' designates remove from list.
> 
>       '?' are uncertain, please help.
> 
> Flt := pagefault column; nonresident and referenced.
>        state after fault.
> 
> 
> Kind regards,
> 
> Peter Zijlstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
