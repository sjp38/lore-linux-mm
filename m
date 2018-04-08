Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79CD36B026A
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 04:20:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 188so3885588qkm.23
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 01:20:45 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b10si588834qtj.372.2018.04.08.01.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Apr 2018 01:20:44 -0700 (PDT)
Date: Sun, 8 Apr 2018 16:20:38 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180408082038.GB19345@localhost.localdomain>
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-5-bhe@redhat.com>
 <5dd3942a-cf66-f749-b1c6-217b0c3c94dc@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5dd3942a-cf66-f749-b1c6-217b0c3c94dc@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 04/06/18 at 07:50am, Dave Hansen wrote:
> I'm having a really hard time tying all the pieces back together.  Let
> me give it a shot and you can tell me where I go wrong.
> 
> On 02/27/2018 07:26 PM, Baoquan He wrote:
> > In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> > are allocated with the size of NR_MEM_SECTIONS.
> 
> In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> are allocated to hold the maps for every possible memory section
> (NR_MEM_SECTIONS).  However, we obviously only need the array sized for
> nr_present_sections (introduced in patch 1).

Yes, correct.

> 
> The reason this is a problem is that, with 5-level paging,
> NR_MEM_SECTIONS (8M->512M) went up dramatically and these temporary
> arrays can eat all of memory, like on kdump kernels.

With 5-level paging enabled, MAX_PHYSMEM_BITS changed from 46 to
52. You can see NR_MEM_SECTIONS becomes 64 times of the old value. So
the two temporary pointer arrays eat more memory, 8M -> 8M*64 = 512M.

# define MAX_PHYSMEM_BITS       (pgtable_l5_enabled ? 52 : 46)

> 
> This patch does two things: it makes sure to give usemap_map/mem_map a
> less gluttonous size on small systems, and it changes the map allocation
> and handling to handle the now more compact, less sparse arrays.

Yes, because 99.9% of systems do not have PB level of memory, not even TB.
Any place of memory allocatin with the size of NR_MEM_SECTIONS should be
avoided.

> 
> ---
> 
> The code looks fine to me.  It's a bit of a shame that there's no
> verification to ensure that idx_present never goes beyond the shiny new
> nr_present_sections. 

This is a good point. Do you think it's OK to replace (section_nr <
NR_MEM_SECTIONS) with (section_nr < nr_present_sections) in below
for_each macro? This for_each_present_section_nr() is only used
during sparse_init() execution.

#define for_each_present_section_nr(start, section_nr)          \
        for (section_nr = next_present_section_nr(start-1);     \
             ((section_nr >= 0) &&                              \
              (section_nr < NR_MEM_SECTIONS) &&                 \                                                                                 
              (section_nr <= __highest_present_section_nr));    \
             section_nr = next_present_section_nr(section_nr))

> 
> 
> > @@ -583,6 +592,7 @@ void __init sparse_init(void)
> >  	unsigned long *usemap;
> >  	unsigned long **usemap_map;
> >  	int size;
> > +	int idx_present = 0;
> 
> I wonder whether idx_present is a good name.  Isn't it the number of
> consumed mem_map[]s or usemaps?

Yeah, in sparse_init(), it's the index of present memory sections, and
also the number of consumed mem_map[]s or usemaps. And I remember you
suggested nr_consumed_maps instead. seems nr_consumed_maps is a little
long to index array to make code line longer than 80 chars. How about
name it idx_present in sparse_init(), nr_consumed_maps in
alloc_usemap_and_memmap(), the maps allocation function? I am also fine
to use nr_consumed_maps for all of them.

> 
> > 
> >  		if (!map) {
> >  			ms->section_mem_map = 0;
> > +			idx_present++;
> >  			continue;
> >  		}
> >  
> 
> 
> This hunk seems logically odd to me.  I would expect a non-used section
> to *not* consume an entry from the temporary array.  Why does it?  The
> error and success paths seem to do the same thing.

Yes, this place is the hardest to understand. The temorary arrays are
allocated beforehand with the size of 'nr_present_sections'. The error
paths you mentioned is caused by allocation failure of mem_map or
map_map, but whatever it's error or success paths, the sections must be
marked as present in memory_present(). Error or success paths happened
in alloc_usemap_and_memmap(), while checking if it's erorr or success
paths happened in the last for_each_present_section_nr() of
sparse_init(), and clear the ms->section_mem_map if it goes along error
paths. This is the key point of this new allocation way.

Thanks
Baoquan
