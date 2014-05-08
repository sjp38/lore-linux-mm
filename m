From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: 7 May 2014 21:46:36 -0400
Message-ID: <20140508014636.1298.qmail@ns.horizon.com>
References: <alpine.DEB.2.02.1405071502040.25024@chino.kir.corp.google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1405071502040.25024@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux@horizon.com, rientjes@google.com
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

(Oops, previous e-mail was sent halfway through composition in error.)

> I'm not sure it's even correct since 
> you're now clearing after doing recheck_pfmemalloc_active().

I thought this through before rearranging the code.
recheck_pfmemalloc_active() checks global lists, but __ac_get_obj()
is doing clear_obj_pfmemalloc on a local variable.  So it
can't affect recheck_pfmemalloc_active().

> A function called clear_obj_pfmemalloc() doesn't indicate it's returning 
> anything, I think the vast majority of people would believe that it 
> returns void just as it does.

Perhaps the name needs to be modified, but it's still pretty clear.
It just clears the bit in its argument and returns it, as opposed to
operating in-place.

In particular, when reading the code that calls it, there is obviously
a return value.  What could it possibly be?

> There's no complier generated code optimization with this patch

On that subject, you're absolutely correct:
   text    data     bss     dec     hex filename
  10635     939       4   11578    2d3a mm/slab.o.before
  10635     939       4   11578    2d3a mm/slab.o.after

If I don't have CONFIG_CC_OPTIMIZE_FOR_SIZE=y, the padding NOPs after
unconditional jumps get aligned a little differently and it actually
gets bigger.

   text    data     bss     dec     hex filename
  12958    1079       4   14041    36d9 mm/slab.o.before
  12990    1079       4   14073    36f9 mm/slab.o.after

__ac_get_obj actually spills one fewer register in this case, and
the code paths seem a little cleaner, but I haven't gone through
it completely.
