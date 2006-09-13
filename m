Received: by py-out-1112.google.com with SMTP id c59so3232031pyc
        for <Linux-MM@kvack.org>; Wed, 13 Sep 2006 15:27:47 -0700 (PDT)
Message-ID: <34a75100609131527x458d7601x5aa885bb56b6bad6@mail.gmail.com>
Date: Thu, 14 Sep 2006 07:27:47 +0900
From: girish <girishvg@gmail.com>
Subject: Re: why inode creation with GFP_HIGHUSER?
In-Reply-To: <Pine.LNX.4.64.0609131030580.17927@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <34a75100609130734m68729bdaj30258c10edfa7947@mail.gmail.com>
	 <34a75100609130754t24b8bde6xcebda4f0684c51cb@mail.gmail.com>
	 <Pine.LNX.4.64.0609131030580.17927@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> > i'd like to know why page(s) for inodes are allocated with
> > GFP_HIGHUSER & not with GFP_USER mask? is there any particular need
> > that the address_space be set with GFP_HIGHUSER flag?
>
> GFP_HIGHUSER allows the use of HIGH memory but it does not require it. If
> the system has no HIGHMEM then we will just use regular memory.

i understand the policy of zone fallback. but in my case there is, in
fact bigger chunk, meory marked as high memory. please see below for
further explaination -

> > i intend to allocate highmem pages strictly to user processes. my idea
> > is to completely avoid kernel mapping for these pages. so, as a dirty
> > hack - i changed mapping_set_gfp_mask function not to honor
> > __GFP_HIGHMEM zone selector if __GFP_IO | __GFP_FS are set. in short i
> > replace  GFP_HIGHUSER with GFP_USER mask. with this change the kernel
> > comes to life. but i am still confused about the effect of this change
> > on system, that i am yet to see?
>
> I am not sure what you intend to do. The kernel already avoids mapping
> highmem pages into the kernel as much as possible.

that's the whole confusion. kernel is supposed to *avoid* allocating
from ZONE_HIGHMEM if there is some memory left in ZONE_DMA and/or
ZONE_NORMAL. but as i mentioned the zonelist selection that happens
based  on GFP_* mask (in this case GFP_HIGHUSER), makes __alloc_pages
to allocate from a list which has both HIGHMEM and DMA/NORMAL zones
listed in it. the zonelist looping/fallback is as implemented in
get_page_from_freelist (). to this function, the zonelist that is
passed contains both and in the order - HIGHMEM and DMA/NORMAL zones.
shouldn't it be NORMAl/DMA first and then HIGHMEM in the zonelist?

(ref: http://lxr.free-electrons.com/source/mm/page_alloc.c#883)

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
