Received: by yx-out-1718.google.com with SMTP id 36so1011908yxh.26
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 09:04:20 -0800 (PST)
Message-ID: <b647ffbd0811030904k4049cca3jafba532c24a4f5e9@mail.gmail.com>
Date: Mon, 3 Nov 2008 18:04:20 +0100
From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: possible dcache aliasing problems after do_swap_page()
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Ralf Baechle <ralf@linux-mips.org>, Nitin Gupta <nitingupta910@gmail.com>, linux-mm-cc@lists.laptop.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

Hi,


the observations below are based on experiments with 'compcache'
(http://code.google.com/p/compcache/) on a MIPS-based system with
2.6.21.5. Although, at first glance 2.6.28-rc2 doesn't seem to make
any diffrence in this respect.


Note, I don't say there is a bug. After all, it likely depends on
whether the use of
(virtual) block-devices as 'swap' is considered sane/supported or not
:-) Other use-cases are unlikely to be affected. OTOH, perhaps having
a dependency on internals of block devices (basically, on how data is
copied from them) in this context is not ok as well.


update_mmu_cache() -> __update_cache() being called at the end of do_swap_page()
does not result in a call of flush_data_cache_page() due to the fact
that a new 'page'
has been anonymously mapped (so page_mapping(page) returns NULL),
notwithstanding
its 'dcache_dirty' bit is present [*]

Now, it all depends on how data has been copied into this new page
from a swap device.
Let's imagine that it's done by a cpu via virtual kernel-space address
(page_address(page)),
so that there can be dcache aliases with a user-space address to which
the 'page' is now mapped.

Obviously, the code doing the actual copying should expect this possibility and
call flush_dcache_page(page). It looks like the correct interface for
this case (?), since the only
info we have got there (passed to a block-device driver via
swap_readpage()) is a 'page' where data has to be written.

The 'problem' is that in this particular case flush_dcache_page(page)
will just call
SetPageDcacheDirty(page) due to the following check being true:

        struct address_space *mapping = page_mapping(page);
        ...
        if (mapping && !mapping_mapped(mapping)) {
                SetPageDcacheDirty(page);
                return;
        }

because 'mapping' is 'swapper_space' and mapping_mapped(&swapper_space) == 0.

To sum it up, the 'dcache_dirty' bit is set but it won't be considered
by __update_cache()
as described above [*].

As a result, for this specific setup 'dcache aliases' are not properly handled
leading to random user-space crashes.

The use of flush_data_cache_page() by (virtual) block-device's driver
fixes it but it's
an overkill (always results in a flush) and moreover it's
arch-specific. The placement of
flush_anon_page() in do_swap_page() (with the version of
flush_anon_page() from .28)
solves the issue as well (sure, there are a few alternative workarounds).

This is a specific setup indeed. One would get a similar problem
enabling a swap on top of
e.g. the "Ram backed block device driver" (drivers/block/brd.c). well,
don't ask me why one would need that :-) The use of 'compcache' is
arguably more useful.

I guess, other cases of anonymous mappings shouldn't be prone to this scenario.
flush_dcache_page() -> page_mapping() -> 'swapper_space' looks like a
'culprit' here.

Any comments?

TIA,

-- 
Best regards,
Dmitry Adamushko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
