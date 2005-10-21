Received: by zproxy.gmail.com with SMTP id k1so316775nzf
        for <linux-mm@kvack.org>; Thu, 20 Oct 2005 18:57:02 -0700 (PDT)
Message-ID: <aec7e5c30510201857r7cf9d337wce9a4017064adcf@mail.gmail.com>
Date: Fri, 21 Oct 2005 10:57:02 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
In-Reply-To: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On 10/21/05, Christoph Lameter <clameter@sgi.com> wrote:
> Page migration is also useful for other purposes:
>
> 1. Memory hotplug. Migrating processes off a memory node that is going
>    to be disconnected.
>
> 2. Remapping of bad pages. These could be detected through soft ECC errors
>    and other mechanisms.

3. Migrating between zones.

The current per-zone LRU design might have some drawbacks. I would
prefer a per-node LRU to avoid that certain zones needs to shrink more
often than others. But maybe that is not the case, please let me know
if I'm wrong.

If you think about it, say that a certain user space page happens to
be allocated from the DMA zone, and for some reason this DMA zone is
very popular because you have crappy hardware, then it might be more
probable that this page is paged out before some other much older/less
used page in another (larger) zone. And I guess the same applies to
small HIGHMEM zones.

This could very well be related to the "1 GB Memory is bad for you"
problem described briefly here: http://kerneltrap.org/node/2450

Maybe it is possible to have a per-node LRU and always page out the
least recently used page in the entire node, and then migrate pages to
solve specific "within N bits of address space" requirements.

But I'm probably underestimating the cost of page migration...

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
