Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F35356B0071
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 04:57:41 -0500 (EST)
Received: by wyf23 with SMTP id 23so5334125wyf.14
        for <linux-mm@kvack.org>; Sat, 20 Nov 2010 01:57:39 -0800 (PST)
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011191158240.4423@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>
	 <alpine.DEB.2.00.1011100939530.23566@router.home>
	 <1290018527.2687.108.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011190941380.32655@router.home>
	 <1290181870.3034.136.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011190958230.2360@router.home>
	 <1290183158.3034.145.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011191108240.3976@router.home>
	 <alpine.DEB.2.00.1011191158240.4423@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 20 Nov 2010 10:50:29 +0100
Message-ID: <1290246629.2756.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Le vendredi 19 novembre 2010 A  11:59 -0600, Christoph Lameter a A(C)crit :
> On Fri, 19 Nov 2010, Christoph Lameter wrote:
> 
> > Ok so rename the macros to this_cpu_return_inc/dec/add/sub?
> 
> Actually this is fetchadd. So call I will call this this_cpu_fetch_add/inc/dec/sub.
> 

It doesnt really matter, because the final "res += added_value" can be
optimized out by compiler if needed, since its C code.

For example in  net/core/neighbour.c, function neigh_alloc() we do

entries = atomic_inc_return(&tbl->entries) - 1;
if (entries >= tbl->gc_thresh3 ||

This generates this optimal code :

mov        $0x1,%eax
lock xadd  %eax,0x1d0(%rdi)
cmp        0xdc(%rdi),%eax

Yes, if we had atomic_fetch_inc() this could be written :

entries = atomic_fetch_inc(&tbl->entries);
if (entries >= tbl->gc_thresh3 ||

Not sure its clearer in this form.
Is it worth adding another seldom used API ?

Everybody understand the xxxx_inc_return() idiom


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
