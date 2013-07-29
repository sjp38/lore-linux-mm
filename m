Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 800086B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 10:59:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 00:48:29 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B3D0F2CE804D
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 00:58:58 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TEwmMh7471592
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 00:58:48 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6TEwvBt022205
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 00:58:57 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
In-Reply-To: <20130729141417.GM2524@moon>
References: <20130726201807.GJ8661@moon> <51F67777.6060609@parallels.com> <20130729141417.GM2524@moon>
Date: Mon, 29 Jul 2013 20:28:54 +0530
Message-ID: <878v0ps98x.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

Cyrill Gorcunov <gorcunov@gmail.com> writes:

> On Mon, Jul 29, 2013 at 06:08:55PM +0400, Pavel Emelyanov wrote:
>> >  
>> > -	if (!pte_none(*pte))
>> > +	ptfile = pgoff_to_pte(pgoff);
>> > +
>> > +	if (!pte_none(*pte)) {
>> > +#ifdef CONFIG_MEM_SOFT_DIRTY
>> > +		if (pte_present(*pte) &&
>> > +		    pte_soft_dirty(*pte))
>> 
>> I think there's no need in wrapping every such if () inside #ifdef CONFIG_...,
>> since the pte_soft_dirty() routine itself would be 0 for non-soft-dirty case
>> and compiler would optimize this code out.
>
> If only I'm not missing something obvious, this code compiles not only on x86,
> CONFIG_MEM_SOFT_DIRTY depends on x86 (otherwise I'll have to implement
> pte_soft_dirty for all archs).

why not

#ifndef pte_soft_dirty 
#define pte_soft_dirty(pte) 0 
#endif

and on x86 
#define pte_soft_dirty pte_soft_dirty

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
