Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 63B3F6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 06:44:07 -0500 (EST)
Received: by iwn33 with SMTP id 33so3314410iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 03:44:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 22 Nov 2010 20:44:03 +0900
Message-ID: <AANLkTi=E=b7X1Un7Bp_eSAFrFjOPsYpBO-Ba1aeTrrjr@mail.gmail.com>
Subject: Re: [PATCH 3/4] alloc_contig_pages() allocate big chunk memory using migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 5:15 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Add an function to allocate contiguous memory larger than MAX_ORDER.
> The main difference between usual page allocator is that this uses
> memory offline technique (Isolate pages and migrate remaining pages.).
>
> I think this is not 100% solution because we can't avoid fragmentation,
> but we have kernelcore=3D boot option and can create MOVABLE zone. That
> helps us to allow allocate a contiguous range on demand.

And later we can use compaction and reclaim, too.
So I think this approach is the way we have to go.

>
> The new function is
>
> =A0alloc_contig_pages(base, end, nr_pages, alignment)
>
> This function will allocate contiguous pages of nr_pages from the range
> [base, end). If [base, end) is bigger than nr_pages, some pfn which
> meats alignment will be allocated. If alignment is smaller than MAX_ORDER=
,

type meet

> it will be raised to be MAX_ORDER.
>
> __alloc_contig_pages() has much more arguments.
>
>
> Some drivers allocates contig pages by bootmem or hiding some memory
> from the kernel at boot. But if contig pages are necessary only in some
> situation, kernelcore=3D boot option and using page migration is a choice=
