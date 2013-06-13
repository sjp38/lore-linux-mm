Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D25BB6B0033
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 21:58:58 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf11so4780216pab.24
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 18:58:58 -0700 (PDT)
Date: Thu, 13 Jun 2013 09:58:27 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH]memblock: Fix potential section mismatch problem
Message-ID: <20130613015827.GA2667@udknight>
References: <20130612160816.GA13813@udknight>
 <CAE9FiQUTwwRUuFicCFvdZZ1_9ytkaexK939zKmYyM31BMaiuZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQUTwwRUuFicCFvdZZ1_9ytkaexK939zKmYyM31BMaiuZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>

On Wed, Jun 12, 2013 at 10:29:17AM -0700, Yinghai Lu wrote:
> On Wed, Jun 12, 2013 at 9:08 AM, Wang YanQing <udknight@gmail.com> wrote:
> >
> > This patch convert __init to __init_memblock
> > for functions which make reference to memblock variable
> > with attribute __meminitdata.
> 
> for which arch?

I just think different arch could have different
meaning about __init and __init_memblock, but
if a function call another function with __init_memblock
annotation or has reference to variable with  __initdata_memblock,
then we have better to give it __init_memblock annotation.


> for x86: __init_memblock is __init, so that is not problem.

Thanks for point out this, then I know why I haven't get
compile warning.

> for other arches like powerpc and sparc etc, __init_memblock is " "
> 
> so you need cc  powerpc, and sparc ...

My first motivation to propose this patch was I found below 
two functions have different annotation which I think they 
should have the same annotation:

"
int __init memblock_is_reserved(phys_addr_t addr)
{
        return memblock_search(&memblock.reserved, addr) != -1;
}

int __init_memblock memblock_is_memory(phys_addr_t addr)
{
        return memblock_search(&memblock.memory, addr) != -1;
}
"


Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
