Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 193096B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 15:45:24 -0400 (EDT)
Date: Wed, 28 Jul 2010 12:45:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100728124513.85bfa047.akpm@linux-foundation.org>
In-Reply-To: <20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 16:53:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This virt-array allocates a virtally contiguous array via get_vm_area()
> and allows object allocation per an element of array.
> Physical pages are used only for used items in the array.
> 
>  - At first, the user has to create an array by create_virt_array().
>  - At using an element, virt_array_alloc_index(index) should be called.
>  - At freeing an element, virt_array_free_index(index) should be called.
>  - At destroying, destroy_virt_array() should be called.
> 
> Item used/unused status is controlled by bitmap and back-end physical
> pages are automatically allocated/freed. This is useful when you
> want to access objects by index in light weight. For example,
> 
> 	create_virt_array(va);
> 	struct your_struct *objmap = va->address;
> 	Then, you can access your objects by objmap[i].
> 
> In usual case, holding reference by index rather than pointer can save memory.
> But index -> object lookup cost cannot be negligible. In such case,
> this virt-array may be helpful. Ah yes, if lookup performance is not important,
> using radix-tree will be better (from TLB point of view). This virty-array
> may consume VMALLOC area too much. and alloc/free routine is very slow.
> 
> Changelog:
>  - fixed bugs in bitmap ops.
>  - add offset for find_free_index.
> 

My gut reaction to this sort of thing is "run away in terror".  It
encourages kernel developers to operate like lackadaisical userspace
developers and to assume that underlying code can perform heroic and
immortal feats.  But it can't.  This is the kernel and the kernel is a
tough and hostile place and callers should be careful and defensive and
take great efforts to minimise the strain they put upon other systems.

IOW, can we avoid doing this?

>
> ...
>
> +void free_varray_item(struct virt_array *v, int idx)
> +{
> +	mutex_lock(&v->mutex);
> +	__free_unmap_entry(v, idx);
> +	mutex_unlock(&v->mutex);
> +}

It's generally a bad idea for library code to perform its own locking. 
In this case we've just made this whole facility inaccessible to code
which runs from interrupt or atomic contexts.

> +		pg[0] = alloc_page(GFP_KERNEL);

And hard-wiring GFP_KERNEL makes this facility inaccessible to GFP_NOIO
and GFP_NOFS contexts as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
