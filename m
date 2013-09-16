Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E45866B003D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 11:27:08 -0400 (EDT)
Message-ID: <52372349.6030308@suse.cz>
Date: Mon, 16 Sep 2013 17:27:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:53425553
 pmd:075f4067
References: <20130916084752.GC11479@localhost>
In-Reply-To: <20130916084752.GC11479@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/16/2013 10:47 AM, Fengguang Wu wrote:
> Greetings,
> 
> I got the below dmesg and the first bad commit is
> 
> commit 7a8010cd36273ff5f6fea5201ef9232f30cebbd9
> Author: Vlastimil Babka <vbabka@suse.cz>
> Date:   Wed Sep 11 14:22:35 2013 -0700
> 
>     mm: munlock: manual pte walk in fast path instead of follow_page_mask()
>     
 
> 
> [   56.020577] BUG: Bad page map in process killall5  pte:53425553 pmd:075f4067
> [   56.022578] addr:08800000 vm_flags:00100073 anon_vma:7f5f6f00 mapping:  (null) index:8800
> [   56.025276] CPU: 0 PID: 101 Comm: killall5 Not tainted 3.11.0-09272-g666a584 #52
> 

Hello,

the stacktrace points clearly to the code added by the patch (function __munlock_pagevec_fill),
no question about that. However, the addresses that are reported by print_bad_pte() in the logs
(08800000 and 0a000000) are both on the page table boundary (note this is x86_32 without PAE)
and should never appear inside the while loop of the function (and be passed to vm_normal_page()).
This could only happen if pmd_addr_end() failed to prevent crossing the page table boundary and
I just cannot see how that could occur without some variables being corrupted :/

Also, some of the failures during bisect were not due to this bug, but a WARNING for
list_add corruption which hopefully is not related to munlock. While it is probably a far stretch,
some kind of memory corruption could also lead to the erroneous behavior of the munlock code.

Can you therefore please retest with the bisected patch reverted (patch below) to see if the other
WARNING still occurs and can be dealt with separately, so there are not potentially two bugs to
be chased at the same time?

Thanks,
Vlastimil


-----8<-----
